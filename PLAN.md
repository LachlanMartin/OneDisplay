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

## Build Phases

### Phase 1 — MVP (done)

Core capture/release logic working as a CLI-executable SwiftPM target.

- [x] Display detection via `CGGetOnlineDisplayList` + `CGDisplayIsBuiltin`
- [x] Listen for `didChangeScreenParametersNotification`
- [x] Capture built-in display with `CGDisplayCapture` when external connected
- [x] Release with `CGDisplayRelease` when external disconnected
- [x] Menu bar with status + Quit
- [x] Git repo + private GitHub

### Phase 2 — Proper .app Bundle

Wrap the binary in a proper macOS `.app` bundle so it feels like a real app.

- [ ] Add `Info.plist` with `LSUIElement` (already set in code, but bundle needs it)
- [ ] Create app icon (`.icns` or SF Symbol–based)
- [ ] Add a build script or `Makefile` to produce `OneDisplay.app`
- [ ] Code sign for local development
- [ ] Support dragging into Applications folder

### Phase 3 — Auto-Launch & Persistence

Make the app feel invisible and automatic.

- [ ] Register as Login Item via `SMAppService` (macOS 13+)
- [ ] Add "Launch at Login" toggle in the menu
- [ ] Handle re-launch edge cases (already-running detection)

### Phase 4 — Polish & Edge Cases

Handle tricky real-world scenarios.

- [ ] **Sleep/Wake**: Release capture on sleep, re-evaluate on wake
- [ ] **Lid close (clamshell)**: Detect and don't fight macOS clamshell mode
- [ ] **App restart after crash**: Capture state persists across launches
- [ ] **User switches main display**: Still identifies built-in correctly
- [ ] **Accessibility permissions**: If needed, guide user to grant them
- [ ] **Better menu feedback**: Show count of detected displays, capture state

### Phase 5 — Open Source

Prepare for public release.

- [ ] Add LICENSE (MIT / Apache 2.0)
- [ ] Improve README with screenshots, usage guide, build instructions
- [ ] Add CI (GitHub Actions: build + lint)
- [ ] Clean up code, add doc comments
- [ ] Toggle repo visibility to public on GitHub
- [ ] Announce / share

## Progress

- [x] Project plan
- [x] .gitignore
- [x] Package.swift
- [x] Sources/OneDisplay/App.swift
- [x] Sources/OneDisplay/MenuBarManager.swift
- [x] Sources/OneDisplay/DisplayMonitor.swift
- [x] Build & verify
- [x] Git init & commit
- [x] GitHub repo (private) → https://github.com/LachlanMartin/one-display
