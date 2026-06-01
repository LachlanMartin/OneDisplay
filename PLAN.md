# OneDisplay — Plan

## Goal

A macOS menu bar utility that automatically turns off the built-in laptop display when an external monitor is connected, and restores it when the external is disconnected. No clamshell mode needed — keyboard and trackpad still work.

## Behavior

- **External monitor connected** → built-in display blanks (black, captured)
- **External monitor disconnected** → built-in display restores instantly
- **Multiple external monitors** → laptop screen off, all externals remain on
- **App quits** → built-in display restored
- **Sleep/Wake** → releases on sleep, re-evaluates on wake
- **Lid closed** → no interference with clamshell mode

## Tech Stack

- Swift 5.9+, SwiftPM (no Xcode project)
- AppKit + CoreGraphics (`CGDisplayCapture`/`CGDisplayRelease`)
- IOKit (clamshell detection)
- ServiceManagement (auto-launch)
- macOS 13+ target

## Architecture

```
one-display/
├── Package.swift                       # SwiftPM config
├── Sources/OneDisplay/
│   ├── App.swift                       # @main entry, NSApplication setup
│   ├── MenuBarManager.swift            # Menu bar icon + status + toggles
│   ├── DisplayMonitor.swift            # Display detection + capture + sleep/clamshell
│   └── LoginItemManager.swift          # SMAppService wrapper
├── Resources/
│   ├── Info.plist                      # .app bundle metadata
│   └── OneDisplay.icns                 # App icon
├── Scripts/
│   └── gen-icon.swift                  # Icon generator script
├── Makefile                            # Build/bundle/run targets
├── .github/workflows/build.yml         # CI
├── LICENSE
├── README.md
├── PLAN.md
└── .gitignore
```

## Build Phases

### Phase 1 — MVP

Core capture/release logic working as a CLI-executable SwiftPM target.

- [x] Display detection via `CGGetOnlineDisplayList` + `CGDisplayIsBuiltin`
- [x] Listen for `didChangeScreenParametersNotification`
- [x] Capture built-in display with `CGDisplayCapture` when external connected
- [x] Release with `CGDisplayRelease` when external disconnected
- [x] Menu bar with status + Quit
- [x] Git repo + private GitHub

### Phase 2 — Proper .app Bundle

Wrap the binary in a proper macOS `.app` bundle so it feels like a real app.

- [x] Add `Info.plist` with `LSUIElement`
- [x] Create app icon (`.icns`) via CoreGraphics script
- [x] Add `Makefile` to produce `OneDisplay.app`
- [x] Code sign for local development

### Phase 3 — Auto-Launch & Persistence

Make the app feel invisible and automatic.

- [x] Register as Login Item via `SMAppService` (macOS 13+)
- [x] Add "Launch at Login" toggle in the menu

### Phase 4 — Polish & Edge Cases

Handle tricky real-world scenarios.

- [x] Sleep/Wake: Release capture on sleep, re-evaluate on wake
- [x] Lid close (clamshell): Detect and don't fight macOS clamshell mode
- [x] Better menu feedback: Show display count, capture state

### Phase 5 — Open Source

Prepare for public release.

- [x] Add LICENSE (MIT)
- [x] Add README with usage guide, build instructions
- [x] Add CI (GitHub Actions: build + bundle)
- [ ] Toggle repo visibility to public on GitHub
- [ ] Announce / share
