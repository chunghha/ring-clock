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

        if let statusItem = statusItem {
            // Start updating the dynamic icon
            DynamicIconGenerator.shared.startUpdatingIcon(for: statusItem)
            
            if let button = statusItem.button {
                button.action = #selector(statusBarButtonClicked)
                button.target = self
            }
        }

        let menu = NSMenu()

        let showHideItem = NSMenuItem(title: "Show/Hide Clock", action: #selector(toggleClockWindow), keyEquivalent: "")
        showHideItem.target = self
        menu.addItem(showHideItem)

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

    @objc func toggleClockWindow() {
        if let mainWindow = NSApp.windows.first(where: { $0.title.isEmpty && !($0.styleMask.contains(.titled)) }) {
            if mainWindow.isVisible {
                mainWindow.orderOut(nil)
            } else {
                mainWindow.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
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
        DynamicIconGenerator.shared.stopUpdating()
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
        // Main Clock Window
        WindowGroup {
            ContentView()
                .environmentObject(clockManager)
                .background(WindowConfigView())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
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

        // Settings Window (accessible via Cmd + ,)
        Settings {
            SettingsView()
                .environmentObject(clockManager)
        }
    }
}

// Configure main window appearance
struct WindowConfigView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.isOpaque = false
            window.backgroundColor = .clear
            window.styleMask = []  // Remove all frame decorations
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.hasShadow = false
            // This makes it float above desktop but below windows and stick to wallpaper
            window.level = NSWindow.Level(rawValue: -1000)
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.isReleasedWhenClosed = false

            // Position the window at top-right with minimal padding
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let screen = NSScreen.main {
                    let screenFrame = screen.visibleFrame
                    let windowSize = NSSize(width: 500, height: 500)
                    let padding: CGFloat = 20
                    let newOrigin = NSPoint(x: screenFrame.maxX - windowSize.width - padding, y: screenFrame.maxY - windowSize.height - padding)
                    window.setFrame(NSRect(origin: newOrigin, size: windowSize), display: true)
                }
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
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
