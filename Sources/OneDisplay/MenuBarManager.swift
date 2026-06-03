import AppKit

class MenuBarManager {
    private var statusItem: NSStatusItem?
    private let statusMenuItem: NSMenuItem
    private let hideMenuItem: NSMenuItem
    private let loginMenuItem: NSMenuItem
    private let displayCountMenuItem: NSMenuItem
    private let menu: NSMenu
    private weak var displayMonitor: DisplayMonitor?

    private let awakeImage: NSImage
    private let sleepImage: NSImage

    init(displayMonitor: DisplayMonitor) {
        self.displayMonitor = displayMonitor

        awakeImage = Self.loadIcon("laptop-screen-awake") ?? NSImage(systemSymbolName: "display", accessibilityDescription: "OneDisplay")!
        sleepImage = Self.loadIcon("laptop-screen-sleep") ?? NSImage(systemSymbolName: "display", accessibilityDescription: "OneDisplay")!
        awakeImage.isTemplate = true
        sleepImage.isTemplate = true

        let iconHeight: CGFloat = 10
        for img in [awakeImage, sleepImage] {
            let ratio = img.size.width / img.size.height
            img.size = NSSize(width: iconHeight * ratio, height: iconHeight)
        }

        statusMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        displayCountMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        hideMenuItem = NSMenuItem(
            title: "Hide Menu Bar Icon",
            action: #selector(hideIcon),
            keyEquivalent: ""
        )
        loginMenuItem = NSMenuItem(
            title: "Launch at Login",
            action: #selector(toggleLoginItem),
            keyEquivalent: ""
        )
        let quitItem = NSMenuItem(
            title: "Quit",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )

        menu = NSMenu()
        hideMenuItem.target = self
        loginMenuItem.target = self
        quitItem.target = self
        menu.addItem(statusMenuItem)
        menu.addItem(displayCountMenuItem)
        menu.addItem(.separator())
        menu.addItem(loginMenuItem)
        menu.addItem(hideMenuItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)

        createStatusItem()
        updateStatus()

        displayMonitor.onStateChange = { [weak self] in
            self?.updateStatus()
        }
    }

    private func createStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = awakeImage
            button.imageScaling = .scaleProportionallyUpOrDown
        }
        item.menu = menu
        statusItem = item
    }

    func restoreIfNeeded() {
        guard statusItem == nil else { return }
        createStatusItem()
        updateStatus()
    }

    private static func loadIcon(_ name: String) -> NSImage? {
        if let url = Bundle.main.resourceURL?.appendingPathComponent("\(name).png"),
           FileManager.default.fileExists(atPath: url.path) {
            return NSImage(contentsOf: url)
        }
        let devURL = URL(fileURLWithPath: "Resources/\(name).png")
        if FileManager.default.fileExists(atPath: devURL.path) {
            return NSImage(contentsOf: devURL)
        }
        return nil
    }

    private func updateStatus() {
        guard let displayMonitor else { return }

        if let button = statusItem?.button {
            button.image = displayMonitor.isCaptured ? sleepImage : awakeImage
        }

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

    @objc private func hideIcon() {
        guard let item = statusItem else { return }
        NSStatusBar.system.removeStatusItem(item)
        statusItem = nil

        let alert = NSAlert()
        alert.messageText = "Icon Hidden"
        alert.informativeText = "Open OneDisplay.app again to restore the menu bar icon."
        alert.runModal()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
