#!/bin/bash

# Battery Vigil Installer

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_BIN="/usr/local/bin/battery-vigil"
CONFIG_DIR="${HOME}/.config/battery-vigil"
CRON_JOB="* * * * * ${INSTALL_BIN} check
* * * * * sleep 30 && ${INSTALL_BIN} check"

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
cp -f "${PROJECT_DIR}/battery-vigil.sh" "${INSTALL_BIN}"
chmod +x "${INSTALL_BIN}"

# Install cron job
echo "⏰ Setting up cron job (every 30 seconds)..."
# Remove existing battery-vigil cron jobs
crontab -l 2>/dev/null | grep -v "${INSTALL_BIN}" | crontab - 2>/dev/null || true

# Add new cron jobs
(crontab -l 2>/dev/null || true; echo "$CRON_JOB") | crontab -

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Edit config: nano ${CONFIG_DIR}/config.json"
echo "   2. The service is now running (via cron)"
echo ""
echo "📖 Usage:"
echo "   - Check battery now: battery-vigil"
echo "   - Test mode (always notify): battery-vigil test"
echo "   - View logs: tail -f ${CONFIG_DIR}/battery-vigil.log"
echo "   - View cron jobs: crontab -l"
echo ""
echo "🗑️  To uninstall:"
echo "   ./uninstall.sh"
