import AppKit

class MenuBarManager {
    private let statusItem: NSStatusItem
    private let statusMenuItem: NSMenuItem
    private let loginMenuItem: NSMenuItem
    private let displayCountMenuItem: NSMenuItem
    private weak var displayMonitor: DisplayMonitor?

    init(displayMonitor: DisplayMonitor) {
        self.displayMonitor = displayMonitor
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "OneDisplay")
        }

        statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        displayCountMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        loginMenuItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLoginItem),
            keyEquivalent: ""
        )

        let menu = NSMenu()
        menu.addItem(statusMenuItem)
        menu.addItem(displayCountMenuItem)
        menu.addItem(.separator())
        menu.addItem(loginMenuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
        updateStatus()

        displayMonitor.onStateChange = { [weak self] in
            self?.updateStatus()
        }
    }

    private func updateStatus() {
        guard let displayMonitor else { return }
        statusMenuItem.title = displayMonitor.isCaptured
            ? "OneDisplay — Capturing"
            : "OneDisplay — Monitoring"
        let externalCount = displayMonitor.externalDisplayCount
        if externalCount > 0 {
            displayCountMenuItem.title = "\(externalCount) external display\(externalCount == 1 ? "" : "s") connected"
        } else {
            displayCountMenuItem.title = "No external display"
        }
        updateLoginItemState()
    }

    private func updateLoginItemState() {
        loginMenuItem.state = LoginItemManager.isEnabled ? .on : .off
    }

    @objc private func toggleLoginItem() {
        LoginItemManager.isEnabled.toggle()
        updateLoginItemState()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
