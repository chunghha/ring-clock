import SwiftUI
import Combine

class ClockManager: ObservableObject {
    @Published var hour: Double = 0
    @Published var minute: Double = 0
    @Published var second: Double = 0
    
    // User Preferences
    @AppStorage("colorScheme") var colorScheme: String = "moon"
    @AppStorage("showSeconds") var showSeconds: Bool = false
    @AppStorage("ringThickness") var ringThickness: Double = 50
    @AppStorage("windowOpacity") var windowOpacity: Double = 1.0

    // Basic color scheme
    private let basicHourColor: Color = Color(NSColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0))
    private let basicMinColor: Color = Color(NSColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 1.0))
    private let basicSecColor: Color = Color(NSColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0.7))

    // Moon color scheme - soft, ethereal colors
    private let moonHourColor: Color = Color(NSColor(red: 0.7, green: 0.4, blue: 0.1, alpha: 0.7))
    private let moonMinColor: Color = Color(NSColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.6))
    private let moonSecColor: Color = Color(NSColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 0.5))

    // Effective colors based on current scheme
    var hourColor: Color {
        colorScheme == "moon" ? moonHourColor : basicHourColor
    }
    var minColor: Color {
        colorScheme == "moon" ? moonMinColor : basicMinColor
    }
    var secColor: Color {
        colorScheme == "moon" ? moonSecColor : basicSecColor
    }

    func toggleScheme() {
        colorScheme = colorScheme == "base" ? "moon" : "base"
    }

    private var timer: AnyCancellable?

    init() {
        updateTime()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTime()
            }
    }

    // Current time values for accessibility
    var currentHour: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour], from: now)
        return (components.hour ?? 0) % 12
    }

    var currentMinute: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute], from: now)
        return components.minute ?? 0
    }

    var currentSecond: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.second], from: now)
        return components.second ?? 0
    }

    func updateTime() {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: now)

        // Calculate smooth movement
        let nsecs = Double(components.nanosecond ?? 0) / 1_000_000_000
        let secs = Double(components.second ?? 0) + nsecs
        let mins = Double(components.minute ?? 0) + (secs / 60.0)
        let hrs = Double(components.hour ?? 0 % 12) + (mins / 60.0)

        self.second = secs / 60.0
        self.minute = mins / 60.0
        self.hour = (hrs.truncatingRemainder(dividingBy: 12)) / 12.0
    }
}
