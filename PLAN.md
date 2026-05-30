# OneDisplay — Plan

## Goal

A macOS menu bar utility that automatically turns off the built-in laptop display when an external monitor is connected, and restores it when the external is disconnected. No clamshell mode needed — keyboard and trackpad still work.

## Behavior

- **External monitor connected** → built-in display blanks (black, captured)
- **External monitor disconnected** → built-in display restores instantly
- **Multiple external monitors** → laptop screen off, all externals remain on
- **App quits** → built-in display restored

## Tech Stack

- Swift 5.9+, SwiftPM (no Xcode project)
- AppKit + CoreGraphics (`CGDisplayCapture`/`CGDisplayRelease`)
- macOS 13+ target

## Architecture

```
one-display/
├── Package.swift                  # SwiftPM config
├── Sources/OneDisplay/
│   ├── App.swift                  # @main entry, NSApplication setup
│   ├── MenuBarManager.swift       # Menu bar icon + Quit
│   └── DisplayMonitor.swift       # Display detection + capture logic
├── .gitignore
└── PLAN.md
```

## Progress

- [x] Project plan
- [ ] .gitignore
- [ ] Package.swift
- [ ] Sources/OneDisplay/App.swift
- [ ] Sources/OneDisplay/MenuBarManager.swift
- [ ] Sources/OneDisplay/DisplayMonitor.swift
- [ ] Build & verify
- [ ] Git init & commit
- [ ] GitHub repo (private)
- [ ] Future: Make public / open source
- [ ] Future: Auto-launch via SMAppService
- [ ] Future: App icon / proper .app bundle
