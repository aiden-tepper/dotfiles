# Noctalia Wallpaper Sync

A lightweight automation suite to change the noctalia-shell wallpaper based on the time of day.

## File Structure

| File | Description |
|------|-------------|
| `wallpaper.conf` | Configuration mapping 24h time ranges to image filenames |
| `wallpaper-sync.sh` | Script that parses the config and sends IPC calls to Noctalia |
| `wallpaper-sync.service` | Systemd unit that executes the script |
| `wallpaper-sync.timer` | Systemd timer that triggers the service every hour |

## Installation

This guide assumes you have placed the `wallpaper` directory in `~/.config`.

### 1. Make the Script Executable

```bash
chmod +x ~/.config/wallpaper/wallpaper-sync.sh
```

### 2. Setup Systemd User Units

```bash
mkdir -p ~/.config/systemd/user
ln -sf ~/.config/wallpaper/wallpaper-sync.service ~/.config/systemd/user/
ln -sf ~/.config/wallpaper/wallpaper-sync.timer ~/.config/systemd/user/
```

### 3. Enable and Start

```bash
systemctl --user daemon-reload
systemctl --user enable --now wallpaper-sync.timer
```

## Configuration

Edit `~/.config/wallpaper/wallpaper.conf` to set your wallpaper directory and time ranges.

**Format:**
```
DIR=/path/to/wallpapers
START_HOUR|END_HOUR|FILENAME
```

**Example:**
```ini
DIR=/home/user/Pictures/Wallpapers
06|11|morning.jpg
11|17|afternoon.jpg
17|22|evening.jpg
22|06|night.jpg
```

## Debugging

Manually trigger a wallpaper update:
```bash
systemctl --user start wallpaper-sync.service
```

Check the service logs:
```bash
journalctl --user -u wallpaper-sync.service
```

View when the next update is scheduled:
```bash
systemctl --user list-timers | grep wallpaper
```
