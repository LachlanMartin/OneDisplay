import AppKit

class MenuBarManager {
    private let statusItem: NSStatusItem
    private let loginMenuItem: NSMenuItem

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "display", accessibilityDescription: "OneDisplay")
        }

        loginMenuItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLoginItem),
            keyEquivalent: ""
        )

        let menu = NSMenu()
        menu.addItem(NSMenuItem(
            title: "OneDisplay — Active",
            action: nil,
            keyEquivalent: ""
        ))
        menu.addItem(.separator())
        menu.addItem(loginMenuItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))

        statusItem.menu = menu
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
