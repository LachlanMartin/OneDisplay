import AppKit

@main
struct OneDisplay {
    private static let delegate = AppDelegate()

    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarManager: MenuBarManager?
    private var displayMonitor: DisplayMonitor?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarManager = MenuBarManager()
        displayMonitor = DisplayMonitor()
    }

    func applicationWillTerminate(_ notification: Notification) {
        displayMonitor?.restore()
    }
}
