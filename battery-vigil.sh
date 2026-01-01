#!/bin/bash

# Battery Vigil - Monitor Mac battery at custom alert levels
# This script checks battery percentage and sends notifications at configured thresholds

CONFIG_DIR="${HOME}/.config/battery-vigil"
CONFIG_FILE="${CONFIG_DIR}/config.json"
STATE_FILE="${CONFIG_DIR}/.state"

# Colors for logging
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Get current battery percentage
get_battery_percentage() {
  pmset -g batt | grep -Eo "[0-9]+%" | head -1 | sed 's/%//'
}

# Check if battery is discharging (not charging)
is_discharging() {
  pmset -g batt | grep -q "discharging"
}

# Send macOS notification for threshold alert
send_notification() {
  local log_file="${CONFIG_DIR}/battery-vigil.log"
  local level=$1
  local message="Battery at ${level}%"

  # Use terminal-notifier for reliable alerts
  if [[ -x /usr/local/bin/terminal-notifier ]]; then
    local notify_error
    notify_error=$(/usr/local/bin/terminal-notifier -title "Battery Alert" -message "$message" -sound "Glass" 2>&1)
    if [[ $? -ne 0 ]]; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error sending notification: $notify_error" >>"${log_file}"
    fi
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: terminal-notifier not found at /usr/local/bin/terminal-notifier" >>"${log_file}"
  fi

  logger -t Battery-Vigil "$message"
}

# Check if we've already notified for this level
# Returns 0 (true) if we should notify, 1 (false) if already notified
is_level_notified() {
  local log_file="${CONFIG_DIR}/battery-vigil.log"
  local level=$1

  # Create state file if it doesn't exist
  if [[ ! -f "${STATE_FILE}" ]]; then
    if ! echo "{}" >"${STATE_FILE}" 2>/dev/null; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to create state file ${STATE_FILE}" >>"${log_file}"
      return 1
    fi
  fi

  # Check if this level is marked as notified
  local notified
  notified=$(jq -r ".level_${level} // empty" "${STATE_FILE}" 2>/dev/null)

  if [[ -n "${notified}" ]]; then
    return 0  # Already notified
  fi
  return 1  # Not yet notified
}

# Mark a level as notified in state
mark_level_notified() {
  local log_file="${CONFIG_DIR}/battery-vigil.log"
  local level=$1

  if ! jq ".level_${level} = true" "${STATE_FILE}" >"${STATE_FILE}.tmp" 2>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to update state file" >>"${log_file}"
    return 1
  fi
  mv -f "${STATE_FILE}.tmp" "${STATE_FILE}" 2>/dev/null
}

# Clear a level from state (when battery rises above it)
clear_level_state() {
  local log_file="${CONFIG_DIR}/battery-vigil.log"
  local level=$1

  if [[ -f "${STATE_FILE}" ]]; then
    if ! jq "del(.level_${level})" "${STATE_FILE}" >"${STATE_FILE}.tmp" 2>/dev/null; then
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to clear state for level ${level}" >>"${log_file}"
      return 1
    fi
    mv -f "${STATE_FILE}.tmp" "${STATE_FILE}" 2>/dev/null
  fi
}

# Load config and check battery levels
check_battery() {
  local log_file="${CONFIG_DIR}/battery-vigil.log"
  local test_mode=${1:-0}

  # Ensure config directory exists
  if ! mkdir -p "${CONFIG_DIR}" 2>/dev/null; then
    echo "Error: Failed to create config directory ${CONFIG_DIR}" >&2
    return 1
  fi

  # Get battery info
  local battery
  battery=$(get_battery_percentage)
  if [[ -z "${battery}" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Failed to get battery percentage" >>"${log_file}"
    return 1
  fi

  local charging_status="unknown"
  if is_discharging; then
    charging_status="discharging"
  else
    charging_status="charging"
  fi

  if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Error: Config file not found at ${CONFIG_FILE}" >>"${log_file}"
    return 1
  fi

  # Check if jq is installed
  if ! command -v jq &>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Error: jq is required" >>"${log_file}"
    return 1
  fi

  # Get alert levels from config
  local jq_error
  local levels
  levels=$(jq -r '.alert_levels | join(" ")' "${CONFIG_FILE}" 2>&1)
  jq_error=$?

  if [[ ${jq_error} -ne 0 ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Error: Failed to parse config: $levels" >>"${log_file}"
    return 1
  fi

  if [[ -z "${levels}" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Error: No alert_levels found in config" >>"${log_file}"
    return 1
  fi

  # First pass: Clear state for any levels the battery is now above
  # This allows re-notification if battery drops again later
  for level in ${levels}; do
    if [[ ${battery} -gt ${level} ]]; then
      clear_level_state "${level}"
    fi
  done

  # Only process notifications when discharging (unless test mode)
  if [[ ${test_mode} -eq 0 ]] && ! is_discharging; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Skipping (charging)" >>"${log_file}"
    return 0
  fi

  # Track if we sent any notifications this run
  local notified=0

  # Second pass: Check each level for notifications
  for level in ${levels}; do
    if [[ ${battery} -le ${level} ]]; then
      # In test mode, always notify; otherwise check if already notified
      if [[ ${test_mode} -eq 1 ]]; then
        send_notification "${battery}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Test notification for ${level}% threshold" >>"${log_file}"
        notified=1
      elif ! is_level_notified "${level}"; then
        # Not yet notified for this level - send notification and mark it
        send_notification "${battery}"
        mark_level_notified "${level}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - Notified for ${level}% threshold" >>"${log_file}"
        notified=1
      fi
    fi
  done

  # Log if no notification was sent
  if [[ ${notified} -eq 0 ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery: ${battery}% (${charging_status}) - No action (above thresholds or already notified)" >>"${log_file}"
  fi
}

# Main entry point
main() {
  case "${1:-check}" in
  check)
    check_battery 0
    ;;
  test)
    check_battery 1
    ;;
  *)
    check_battery 0
    ;;
  esac
}

main "$@"
