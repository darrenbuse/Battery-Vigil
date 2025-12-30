#!/bin/bash

# Battery Vigil Installer

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_BIN="/usr/local/bin/battery-vigil"
CONFIG_DIR="${HOME}/.config/battery-vigil"
LAUNCHAGENT_DIR="${HOME}/Library/LaunchAgents"
LAUNCHAGENT_FILE="com.batteryvigil.plist"

echo "🔋 Battery Vigil Installer"
echo "=========================="
echo ""

# Check for dependencies
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is required. Please install from https://brew.sh"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "📦 Installing jq..."
    brew install jq
fi

if ! command -v terminal-notifier &> /dev/null; then
    echo "📦 Installing terminal-notifier..."
    brew install terminal-notifier
fi

# Create config directory
echo "📁 Creating config directory at ${CONFIG_DIR}..."
mkdir -p "${CONFIG_DIR}"

# Copy config file if it doesn't exist
if [[ ! -f "${CONFIG_DIR}/config.json" ]]; then
    echo "⚙️  Setting up default config..."
    cp "${PROJECT_DIR}/config.json.example" "${CONFIG_DIR}/config.json"
    echo "   Config: ${CONFIG_DIR}/config.json"
else
    echo "✓ Config already exists at ${CONFIG_DIR}/config.json"
fi

# Install binary
echo "📦 Installing binary to ${INSTALL_BIN}..."
cp "${PROJECT_DIR}/battery-vigil.sh" "${INSTALL_BIN}"
chmod +x "${INSTALL_BIN}"

# Install LaunchAgent
echo "🚀 Installing LaunchAgent..."
cp "${PROJECT_DIR}/${LAUNCHAGENT_FILE}" "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}"
launchctl load "${LAUNCHAGENT_DIR}/${LAUNCHAGENT_FILE}"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Edit config: nano ${CONFIG_DIR}/config.json"
echo "   2. The service is now running and will start on login"
echo ""
echo "📖 Usage:"
echo "   - Check battery now: battery-vigil"
echo "   - View logs: tail -f ${CONFIG_DIR}/battery-vigil.log"
echo "   - Restart service: ./restart.sh"
echo ""
echo "🗑️  To uninstall:"
echo "   ./uninstall.sh"
