import SwiftUI

@main
struct RingClockApp: App {
    @StateObject private var clockManager = ClockManager()

    var body: some Scene {
        // Main Clock Window
        WindowGroup {
            ContentView()
                .environmentObject(clockManager)
                .background(TransparentWindowView())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

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
        }
    }
}

// Helper to make the window transparent
struct TransparentWindowView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.isOpaque = false
                window.backgroundColor = .clear
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.hasShadow = false
                // This makes it float above desktop but below windows
                 window.level = NSWindow.Level(rawValue: -1000)
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

                if let screen = NSScreen.main {
                    let screenFrame = screen.visibleFrame
                    let windowFrame = window.frame
                    let newOrigin = NSPoint(x: screenFrame.maxX - windowFrame.width - 20, y: screenFrame.maxY - windowFrame.height)
                    window.setFrameOrigin(newOrigin)
                }
            }
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}

// This extension allows @AppStorage to handle SwiftUI Color
extension Color: RawRepresentable {
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
