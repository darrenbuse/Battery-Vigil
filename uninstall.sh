#!/bin/bash

# Battery Vigil Uninstaller

set -e

INSTALL_BIN="/usr/local/bin/battery-vigil"
LAUNCHAGENT_DIR="${HOME}/Library/LaunchAgents"
LAUNCHAGENT_FILE="com.batteryvigil.plist"
CONFIG_DIR="${HOME}/.config/battery-vigil"

echo "🗑️  Battery Vigil Uninstaller"
echo "============================="
echo ""

# Unload LaunchAgent
if [[ -f "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}" ]]; then
    echo "Stopping service..."
    launchctl unload "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}"
    rm "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}"
fi

# Remove binary
if [[ -f "${INSTALL_BIN}" ]]; then
    echo "Removing binary..."
    rm "${INSTALL_BIN}"
fi

echo ""
echo "✅ Uninstall complete!"
echo ""
echo "Note: Config and logs preserved at:"
echo "   ${CONFIG_DIR}"
echo "   /var/log/battery-vigil.log"
