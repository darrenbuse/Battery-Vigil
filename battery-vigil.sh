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

# Send macOS notification
send_notification() {
    local level=$1
    local message="Battery at ${level}%"

    # Use terminal-notifier for reliable alerts
    if command -v terminal-notifier &> /dev/null; then
        terminal-notifier -title "Battery Alert" -message "$message" -sound "Glass" 2>/dev/null
    fi

    logger -t Battery-Vigil "$message"
}

# Check if we've already notified for this level in this session
should_notify() {
    local level=$1

    # Create state file if it doesn't exist
    mkdir -p "${CONFIG_DIR}"
    if [[ ! -f "${STATE_FILE}" ]]; then
        echo "{}" > "${STATE_FILE}"
    fi

    # Read current state
    local last_notified=$(jq -r ".level_${level} // empty" "${STATE_FILE}" 2>/dev/null)

    # If battery went above threshold and came back down, allow notification again
    local current_battery=$(get_battery_percentage)

    if [[ -z "${last_notified}" || "${current_battery}" -gt $((level + 2)) ]]; then
        # Update state
        jq ".level_${level} = true" "${STATE_FILE}" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "${STATE_FILE}"
        return 0
    fi

    return 1
}

# Load config and check battery levels
check_battery() {
    local log_file="${CONFIG_DIR}/battery-vigil.log"
    mkdir -p "${CONFIG_DIR}"

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: Config file not found at ${CONFIG_FILE}" >> "${log_file}"
        return 1
    fi

    local battery=$(get_battery_percentage)

    # Only notify when discharging
    if ! is_discharging; then
        return 0
    fi

    # Check if jq is installed
    if ! command -v jq &> /dev/null; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: jq is required" >> "${log_file}"
        return 1
    fi

    # Get alert levels from config
    local levels=$(jq -r '.alert_levels | join(" ")' "${CONFIG_FILE}" 2>/dev/null)

    if [[ -z "${levels}" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Error: No alert_levels found in config" >> "${log_file}"
        return 1
    fi

    # Check each level
    for level in ${levels}; do
        if [[ ${battery} -le ${level} ]]; then
            if should_notify "${level}"; then
                send_notification "${battery}"
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Battery at ${battery}% - Notified for ${level}% threshold" >> "${log_file}"
            fi
        fi
    done
}

# Main entry point
main() {
    case "${1:-check}" in
        check)
            check_battery
            ;;
        *)
            check_battery
            ;;
    esac
}

main "$@"
