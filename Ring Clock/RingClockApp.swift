import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: NSWindow?
    var clockManager: ClockManager?
    private var screenshotObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestNotificationPermissions()
        setupStatusBar()
        setupScreenshotObserver()
    }

    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error)")
            } else if granted {
                print("✅ Notification permissions granted")
            } else {
                print("⚠️ Notification permissions denied")
            }
        }
    }

    func setupStatusBar() {
        // Always show status bar for now (can be made configurable later)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            // Use a simple clock emoji as icon, or we could load an image
            button.title = "🕐"
            button.action = #selector(statusBarButtonClicked)
            button.target = self
        }

        let menu = NSMenu()

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.keyEquivalentModifierMask = .command
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())



        let quitItem = NSMenuItem(title: "Quit Ring Clock", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.keyEquivalentModifierMask = .command
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc func statusBarButtonClicked() {
        // Show menu when clicked
        statusItem?.button?.performClick(nil)
    }



    @objc func openSettings() {
        // If settings window already exists and is visible, just activate it
        if let existingWindow = settingsWindow, existingWindow.isVisible {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        // Create a new settings window
        let settingsView = SettingsView()
            .environmentObject(clockManager ?? ClockManager())
            .frame(width: 900, height: 650) // Adjusted frame size for better fit

        let hostingController = NSHostingController(rootView: settingsView)
        let window = NSWindow(contentViewController: hostingController)

        window.title = "Ring Clock Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.titlebarAppearsTransparent = false
        window.isReleasedWhenClosed = false
        window.center()

        // Set minimum and content size (adjusted for better screen fit)
        window.minSize = NSSize(width: 800, height: 600)
        window.setContentSize(NSSize(width: 900, height: 650))

        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }





    @objc func quitApp() {
        NSApp.terminate(nil)
    }



    private func setupScreenshotObserver() {
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RequestScreenshot"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleScreenshot()
        }
    }

    @objc private func handleScreenshot() {
        let success = ScreenshotManager.captureWindow()
        if success {
            NSSound(named: "Glass")?.play()
        }
    }

    func setClockManager(_ manager: ClockManager) {
        clockManager = manager
    }
}

@main
struct RingClockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var clockManager = ClockManager()

    var body: some Scene {
        // Settings Window (accessible via Cmd + ,)
        Settings {
            SettingsView()
                .environmentObject(clockManager)
        }
        .commands {
            CommandMenu("Theme") {
                Button("Switch Color Scheme") {
                    clockManager.toggleScheme()
                }
                .keyboardShortcut("t", modifiers: .command)
            }
            CommandMenu("Tools") {
                Button("Take Screenshot") {
                    _ = ScreenshotManager.captureWindow()
                }
                .keyboardShortcut("t", modifiers: [.command, .shift])
            }
        }
    }
}

// This extension allows @AppStorage to handle SwiftUI Color
extension Color: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        
        do {
            // macOS uses NSColor, iOS uses UIColor.
            // We use NSKeyedUnarchiver for cross-compatibility and simplicity.
            if let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
                self = Color(nsColor)
            } else {
                self = .black
            }
        } catch {
            self = .black
        }
    }

    public var rawValue: String {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(self), requiringSecureCoding: false)
            return data.base64EncodedString()
        } catch {
            return ""
        }
    }
}
