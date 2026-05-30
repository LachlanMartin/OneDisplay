import AppKit
import CoreGraphics

class DisplayMonitor {
    private let builtInDisplayID: CGDirectDisplayID
    private var isCaptured = false

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
    }

    @objc private func screenParametersChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.evaluate()
        }
    }

    // MARK: - State Evaluation

    func evaluate() {
        if NSScreen.screens.count > 1, !isCaptured {
            captureBuiltIn()
        } else if NSScreen.screens.count == 1, isCaptured {
            releaseBuiltIn()
        }
    }

    // MARK: - Capture / Release

    private func captureBuiltIn() {
        guard !isCaptured else { return }
        let result = CGDisplayCapture(builtInDisplayID)
        if result == .success {
            isCaptured = true
        }
    }

    private func releaseBuiltIn() {
        guard isCaptured else { return }
        let result = CGDisplayRelease(builtInDisplayID)
        if result == .success {
            isCaptured = false
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
    }
}
