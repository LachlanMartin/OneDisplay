import AppKit
import CoreGraphics
import IOKit

class DisplayMonitor {
    private let builtInDisplayID: CGDirectDisplayID
    private(set) var isCaptured = false
    var onStateChange: (() -> Void)?

    init() {
        builtInDisplayID = Self.findBuiltInDisplay()
        startObserving()
        DispatchQueue.main.async { [weak self] in
            self?.evaluate()
        }
    }

    // MARK: - Built-in Display Detection

    private static func findBuiltInDisplay() -> CGDirectDisplayID {
        var displayCount: UInt32 = 0
        var displays: [CGDirectDisplayID] = Array(repeating: 0, count: 32)
        let err = CGGetOnlineDisplayList(32, &displays, &displayCount)
        guard err == .success else { return CGMainDisplayID() }

        for i in 0 ..< Int(displayCount) {
            if CGDisplayIsBuiltin(displays[i]) != 0 {
                return displays[i]
            }
        }
        return CGMainDisplayID()
    }

    // MARK: - Observation

    private func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }

    @objc private func screenParametersChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.evaluate()
        }
    }

    @objc private func systemWillSleep() {
        restore()
    }

    @objc private func systemDidWake() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.evaluate()
        }
    }

    // MARK: - Clamshell Detection

    static func isLidClosed() -> Bool {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleClamshellState"))
        guard service != 0 else { return false }
        defer { IOObjectRelease(service) }
        if let present = IORegistryEntryCreateCFProperty(
            service, "ClamshellState" as CFString,
            kCFAllocatorDefault, 0
        )?.takeRetainedValue() as? Bool {
            return present
        }
        return false
    }

    // MARK: - State Evaluation

    func evaluate() {
        guard !Self.isLidClosed() else { return }

        let externalCount = NSScreen.screens.filter { screen in
            let screenID = screen.displayID
            return screenID != builtInDisplayID
        }.count

        if externalCount > 0, !isCaptured {
            captureBuiltIn()
        } else if externalCount == 0, isCaptured {
            releaseBuiltIn()
        }
    }

    var externalDisplayCount: Int {
        NSScreen.screens.filter { $0.displayID != builtInDisplayID }.count
    }

    // MARK: - Capture / Release

    private func captureBuiltIn() {
        guard !isCaptured else { return }
        let result = CGDisplayCapture(builtInDisplayID)
        if result == .success {
            isCaptured = true
            onStateChange?()
        }
    }

    private func releaseBuiltIn() {
        guard isCaptured else { return }
        let result = CGDisplayRelease(builtInDisplayID)
        if result == .success {
            isCaptured = false
            onStateChange?()
        }
    }

    func restore() {
        if isCaptured {
            releaseBuiltIn()
        }
    }

    deinit {
        restore()
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}

private extension NSScreen {
    var displayID: CGDirectDisplayID {
        let key = NSDeviceDescriptionKey("NSScreenNumber")
        return (deviceDescription[key] as? NSNumber)?.uint32Value ?? 0
    }
}
