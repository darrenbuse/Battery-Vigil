# Battery Vigil

A lightweight macOS utility that sends notifications when your battery drops to custom alert levels. Get notified at 5%, 3%, 1%—or whatever thresholds you prefer.

## Features

- 🔔 macOS Notification Center alerts at configurable battery levels
- ⚡ Runs silently in the background as a LaunchAgent
- ⚙️ Easy JSON configuration
- 📝 Minimal dependencies (`jq`, `terminal-notifier`)
- 🗑️ Clean uninstall script

## Installation

### Prerequisites

- macOS 10.12+
- Bash 4+
- Homebrew

### Quick Install

```bash
git clone https://github.com/yourusername/battery-vigil.git
cd battery-vigil
chmod +x install.sh uninstall.sh
./install.sh
```

The installer will:
- Install dependencies (`jq` and `terminal-notifier` via Homebrew)
- Copy the script to `/usr/local/bin`
- Set up config at `~/.config/battery-vigil/config.json`
- Load the LaunchAgent to run automatically on login

## Configuration

Edit `~/.config/battery-vigil/config.json`:

```json
{
  "alert_levels": [5, 3, 1],
  "check_interval": 30
}
```

- **alert_levels**: Battery percentages to be notified at (descending order)
- **check_interval**: How often to check battery in seconds

After editing, restart the service:
```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.batteryvigil.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.batteryvigil.plist
```

## Usage

Manually check battery:
```bash
battery-vigil
```

View logs:
```bash
tail -f ~/Library/Logs/battery-vigil.log
```

## Uninstall

```bash
./uninstall.sh
```

Config and logs are preserved for manual cleanup if needed.

## How It Works

Battery Vigil runs every 30 seconds (configurable) via macOS LaunchAgent. When the battery drops to a configured level, a native notification is sent. The script tracks notified levels to avoid spam—you'll only get one notification per threshold per discharge cycle.

## License

MIT
