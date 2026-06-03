<p align="center">
  <img src="Resources/app-icon.png" alt="OneDisplay" width="128">
</p>

<h1 align="center">OneDisplay</h1>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-13%2B-lightgrey">
  <img src="https://img.shields.io/badge/license-MIT-blue">
</p>

When you plug in an external monitor, OneDisplay blanks your laptop screen and keeps your keyboard and trackpad working. Unplug and it restores.

Uses macOS's `CGDisplayCapture` API to take exclusive control of the built-in display, rendering it black and inactive.

## Requirements

- macOS 13+
- Apple Silicon or Intel Mac

## Installation

```bash
git clone https://github.com/LachlanMartin/OneDisplay
cd OneDisplay
make run
```

## Usage

Launch OneDisplay — it lives in your menu bar. Plug in an external monitor, and the laptop screen goes black. Unplug and it comes back. Click the icon to Quit, toggle Launch at Login, or Hide the icon.

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
