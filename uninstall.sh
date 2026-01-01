#!/bin/bash

# Battery Vigil Uninstaller

set -e

INSTALL_BIN="/usr/local/bin/battery-vigil"
CONFIG_DIR="${HOME}/.config/battery-vigil"

echo "🗑️  Battery Vigil Uninstaller"
echo "============================="
echo ""

# Remove cron jobs
echo "Removing cron jobs..."
crontab -l 2>/dev/null | grep -v "${INSTALL_BIN}" | crontab - 2>/dev/null || true

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
