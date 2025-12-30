#!/bin/bash

# Restart Battery Vigil LaunchAgent

LAUNCHAGENT_DIR="${HOME}/Library/LaunchAgents"
LAUNCHAGENT_FILE="com.batteryvigil.plist"

echo "🔄 Restarting Battery Vigil..."
echo ""

# Unload
echo "Stopping service..."
launchctl bootout gui/$(id -u) "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}" 2>/dev/null || echo "  (wasn't running)"

# Reload
echo "Starting service..."
launchctl bootstrap gui/$(id -u) "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}"

echo ""
sleep 2

# Show status
if launchctl list | grep -q com.batteryvigil; then
    echo "✅ Battery Vigil is running"
    echo ""
    echo "Recent logs:"
    tail -5 ~/.config/battery-vigil/battery-vigil.log 2>/dev/null || echo "  (no logs yet)"
else
    echo "❌ Failed to start Battery Vigil"
fi
