# OneDisplay

A macOS menu bar utility that automatically blanks your built-in laptop display when an external monitor is connected, and restores it when disconnected. No clamshell mode needed — your keyboard and trackpad still work.

## How it works

OneDisplay uses macOS's `CGDisplayCapture` API to take exclusive control of the built-in display, rendering it black and inactive. When the external monitor is disconnected, it releases the display and everything returns to normal.

## Features

- **Auto-detect**: Monitors display connections in real-time
- **Auto-restore**: Laptop display comes back when you unplug
- **Multiple displays**: Laptop screen turns off, all external monitors stay on
- **Sleep/Wake safe**: Releases capture before sleep, re-evaluates on wake
- **Clamshell aware**: Doesn't interfere when your laptop lid is closed
- **Launch at Login**: Optional auto-launch via macOS Login Items

## Requirements

- macOS 13+
- Apple Silicon or Intel Mac

## Installation

### Download

Download the latest release from the [Releases](https://github.com/LachlanMartin/one-display/releases) page.

### Build from source

```bash
git clone https://github.com/LachlanMartin/one-display.git
cd one-display
make run
```

This builds the release binary, creates `OneDisplay.app`, and opens it.

The app will appear in your menu bar with a display icon.

## Usage

1. Launch OneDisplay — it lives in your menu bar
2. Plug in an external monitor — the laptop screen goes black
3. Unplug the external monitor — the laptop screen comes back
4. Click the menu bar icon to Quit or toggle Launch at Login

## Build

```bash
make build     # Build the Swift binary
make bundle    # Build + create .app bundle
make run       # Build + bundle + launch
make icon      # Regenerate the app icon
make clean     # Remove build artifacts
```

## License

MIT
