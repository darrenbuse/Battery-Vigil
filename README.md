# 🔋 Battery Vigil

Keep your Mac's battery in check with timely, non-intrusive notifications. Get alerted when your battery drops below custom thresholds—no more being surprised when you're at 1% with no power nearby.

## Features

- **Smart notifications** – Get alerted at custom battery levels (e.g., 20%, 7%, 5%, 3%, 1%)
- **Only when discharging** – Notifications only appear when actually draining power
- **Runs in the background** – Cron checks every 30 seconds
- **No notification spam** – One notification per threshold per discharge cycle
- **Easy config** – Simple JSON file for customization
- **Minimal overhead** – Just bash, jq, and native macOS notifications
- **Simple debugging** – Every run is logged, use `battery-vigil test` to always show notifications

## Installation

### Prerequisites

- macOS 10.12+
- Homebrew

### Quick Start

```bash
git clone https://github.com/darrenbuse/Battery-Vigil.git
cd Battery-Vigil
./install.sh
```

The installer handles:
- Installing dependencies (`jq` and `terminal-notifier`)
- Setting up the script
- Configuring cron jobs to run every 30 seconds

## Configuration

Edit your alert levels:

```bash
nano ~/.config/battery-vigil/config.json
```

Example config:

```json
{
  "alert_levels": [20, 9, 7, 5, 3, 1],
  "check_interval": 30
}
```

- **alert_levels** – Battery percentages to notify at (highest to lowest)
- **check_interval** – Seconds between checks (30 recommended)

After editing, the changes take effect on the next cron run (within 30 seconds). No restart needed.

## Usage

Check battery manually:

```bash
battery-vigil
```

Test mode (always show notifications):

```bash
battery-vigil test
```

View activity logs:

```bash
tail -f ~/.config/battery-vigil/battery-vigil.log
```

View scheduled cron jobs:

```bash
crontab -l
```

## Uninstall

```bash
./uninstall.sh
```

Config and logs are kept for manual cleanup if needed.

## How It Works

Battery Vigil runs continuously via cron jobs (every 30 seconds). Each run:
1. Checks current battery percentage
2. Verifies the device is discharging (not plugged in)
3. Sends a notification if battery is below a configured threshold
4. Tracks which thresholds have been notified to prevent spam
5. Logs every run to `~/.config/battery-vigil/battery-vigil.log`

You'll get exactly one notification per threshold per charge cycle. Use `battery-vigil test` to trigger notifications instantly for testing.

## License

MIT
