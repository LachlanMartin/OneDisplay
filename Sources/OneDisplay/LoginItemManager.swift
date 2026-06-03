// SPDX-License-Identifier: MIT

import ServiceManagement
import OSLog

enum LoginItemManager {
    private static let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.lachlanmartin.onedisplay", category: "login-item")

    static var isEnabled: Bool {
        get { SMAppService.mainApp.status == .enabled }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                log.error("Failed to update login item: \(error, privacy: .public)")
            }
        }
    }
}
