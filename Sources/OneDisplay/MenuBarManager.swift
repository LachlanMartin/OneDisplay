import AppKit

class MenuBarManager {
    private let statusItem: NSStatusItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "OneDisplay")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "OneDisplay — Active",
            action: nil,
            keyEquivalent: ""
        ))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
