import SwiftUI
import Combine

class ClockManager: ObservableObject {
    @Published var hour: Double = 0
    @Published var minute: Double = 0
    @Published var second: Double = 0
    
    // User Preferences
    @AppStorage("colorScheme") var colorScheme: String = "ghost"
    @AppStorage("showSeconds") var showSeconds: Bool = false
    @AppStorage("ringThickness") var ringThickness: Double = 50
    @AppStorage("windowOpacity") var windowOpacity: Double = 1.0

    // Clock style preferences
    @AppStorage("use24HourFormat") var use24HourFormat: Bool = false
    @AppStorage("showDigitalTime") var showDigitalTime: Bool = true
    @AppStorage("digitalFontSize") var digitalFontSize: Double = 56

    // Menu bar preferences
    @AppStorage("showMenuBarIcon") var showMenuBarIcon: Bool = true

    // Animation state
    @Published var rotationAngle: Double = 0
    @Published var rotationX: Double = 0  // 3D rotation around X axis
    @Published var rotationY: Double = 0  // 3D rotation around Y axis
    @Published var rotationZ: Double = 0  // 3D rotation around Z axis
    @Published var shouldAnimate: Bool = false
    private var lastMinute: Int = -1
    private var lastAnimationTriggerSecond: Double = -1

    // Time zone preferences
    @AppStorage("selectedTimeZones") var selectedTimeZonesData: String = "[]"
    @AppStorage("primaryTimeZone") var primaryTimeZone: String = TimeZone.current.identifier

    // Custom theme colors
    @AppStorage("customHourColor") var customHourColorData: String = ""
    @AppStorage("customMinColor") var customMinColorData: String = ""
    @AppStorage("customSecColor") var customSecColorData: String = ""

    // Saved themes (stored as JSON)
    @AppStorage("savedThemes") var savedThemesData: String = "{}"

    // Time zone management
    var selectedTimeZones: [String] {
        get {
            if let data = selectedTimeZonesData.data(using: .utf8),
               let timeZones = try? JSONDecoder().decode([String].self, from: data) {
                return timeZones
            }
            return [TimeZone.current.identifier] // Default to current time zone
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let jsonString = String(data: data, encoding: .utf8) {
                selectedTimeZonesData = jsonString
            }
        }
    }

    func addTimeZone(_ identifier: String) {
        var zones = selectedTimeZones
        if !zones.contains(identifier) {
            zones.append(identifier)
            selectedTimeZones = zones
        }
    }

    func removeTimeZone(_ identifier: String) {
        var zones = selectedTimeZones
        zones.removeAll { $0 == identifier }
        selectedTimeZones = zones
    }

    func timeForZone(_ identifier: String) -> Date {
        let zone = TimeZone(identifier: identifier) ?? TimeZone.current
        let now = Date()
        let offset = TimeInterval(zone.secondsFromGMT(for: now))
        return now.addingTimeInterval(offset)
    }

    // Basic color scheme
    private let basicHourColor: Color = Color(NSColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0))
    private let basicMinColor: Color = Color(NSColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 1.0))
    private let basicSecColor: Color = Color(NSColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0.7))

    // Moon color scheme - soft, ethereal colors
    private let moonHourColor: Color = Color(NSColor(red: 0.7, green: 0.4, blue: 0.1, alpha: 0.7))
    private let moonMinColor: Color = Color(NSColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.6))
    private let moonSecColor: Color = Color(NSColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 0.5))

    // Ghost in the Shell color scheme - cyberpunk aesthetic
    private let ghostHourColor: Color = Color(NSColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 0.8)) // Bright cyan
    private let ghostMinColor: Color = Color(NSColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 0.6)) // Neon green
    private let ghostSecColor: Color = Color(NSColor(red: 0.4, green: 0.0, blue: 0.6, alpha: 0.7)) // Deep purple

    // Gray color scheme - neutral, elegant aesthetic
    private let grayHourColor: Color = Color(NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.8)) // Medium gray
    private let grayMinColor: Color = Color(NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.7)) // Dark gray
    private let graySecColor: Color = Color(NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.6)) // Light gray

    // Vintage color scheme - aged paper aesthetic with warm yellow tone
    private let vintageHourColor: Color = Color(NSColor(red: 0.80, green: 0.78, blue: 0.70, alpha: 0.8)) // Aged paper light
    private let vintageMinColor: Color = Color(NSColor(red: 0.70, green: 0.68, blue: 0.58, alpha: 0.7)) // Aged paper medium (darkest)
    private let vintageSecColor: Color = Color(NSColor(red: 0.75, green: 0.73, blue: 0.64, alpha: 0.6)) // Aged paper

    /// Custom color properties with improved error handling
    var customHourColor: Color {
        get {
            guard !customHourColorData.isEmpty else {
                return moonHourColor // Default fallback
            }

            guard let data = Data(base64Encoded: customHourColorData) else {
                print("Warning: Invalid base64 data for customHourColor")
                return moonHourColor
            }

            do {
                guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                    print("Warning: Failed to unarchive NSColor for customHourColor")
                    return moonHourColor
                }
                return Color(nsColor)
            } catch {
                print("Error: Failed to decode customHourColor: \(error.localizedDescription)")
                return moonHourColor
            }
        }
        set {
            do {
                let nsColor = NSColor(newValue)
                let data = try NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false)
                customHourColorData = data.base64EncodedString()
            } catch {
                print("Error: Failed to encode customHourColor: \(error.localizedDescription)")
                customHourColorData = "" // Reset to empty on error
            }
        }
    }

    var customMinColor: Color {
        get {
            guard !customMinColorData.isEmpty else {
                return moonMinColor // Default fallback
            }

            guard let data = Data(base64Encoded: customMinColorData) else {
                print("Warning: Invalid base64 data for customMinColor")
                return moonMinColor
            }

            do {
                guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                    print("Warning: Failed to unarchive NSColor for customMinColor")
                    return moonMinColor
                }
                return Color(nsColor)
            } catch {
                print("Error: Failed to decode customMinColor: \(error.localizedDescription)")
                return moonMinColor
            }
        }
        set {
            do {
                let nsColor = NSColor(newValue)
                let data = try NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false)
                customMinColorData = data.base64EncodedString()
            } catch {
                print("Error: Failed to encode customMinColor: \(error.localizedDescription)")
                customMinColorData = "" // Reset to empty on error
            }
        }
    }

    var customSecColor: Color {
        get {
            guard !customSecColorData.isEmpty else {
                return moonSecColor // Default fallback
            }

            guard let data = Data(base64Encoded: customSecColorData) else {
                print("Warning: Invalid base64 data for customSecColor")
                return moonSecColor
            }

            do {
                guard let nsColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
                    print("Warning: Failed to unarchive NSColor for customSecColor")
                    return moonSecColor
                }
                return Color(nsColor)
            } catch {
                print("Error: Failed to decode customSecColor: \(error.localizedDescription)")
                return moonSecColor
            }
        }
        set {
            do {
                let nsColor = NSColor(newValue)
                let data = try NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false)
                customSecColorData = data.base64EncodedString()
            } catch {
                print("Error: Failed to encode customSecColor: \(error.localizedDescription)")
                customSecColorData = "" // Reset to empty on error
            }
        }
    }

    // Effective colors based on current scheme
    var hourColor: Color {
        switch colorScheme {
        case "moon": return moonHourColor
        case "ghost": return ghostHourColor
        case "gray": return grayHourColor
        case "vintage": return vintageHourColor
        case "custom": return customHourColor
        default: return basicHourColor
        }
    }
    var minColor: Color {
        switch colorScheme {
        case "moon": return moonMinColor
        case "ghost": return ghostMinColor
        case "gray": return grayMinColor
        case "vintage": return vintageMinColor
        case "custom": return customMinColor
        default: return basicMinColor
        }
    }
    var secColor: Color {
        switch colorScheme {
        case "moon": return moonSecColor
        case "ghost": return ghostSecColor
        case "gray": return graySecColor
        case "vintage": return vintageSecColor
        case "custom": return customSecColor
        default: return basicSecColor
        }
    }

    func toggleScheme() {
        colorScheme = colorScheme == "base" ? "moon" : "base"
    }

    // Theme management
    struct ThemeData: Codable {
        let name: String
        let hourColorData: String
        let minColorData: String
        let secColorData: String
    }

    struct Theme {
        let name: String
        let hourColor: Color
        let minColor: Color
        let secColor: Color

        init(name: String, hourColor: Color, minColor: Color, secColor: Color) {
            self.name = name
            self.hourColor = hourColor
            self.minColor = minColor
            self.secColor = secColor
        }

        init?(from data: ThemeData) {
            self.name = data.name

            // Decode colors from base64 data
            func decodeColor(_ dataString: String, fallback: Color) -> Color {
                if let data = Data(base64Encoded: dataString),
                   let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
                    return Color(nsColor)
                }
                return fallback
            }

            self.hourColor = decodeColor(data.hourColorData, fallback: Color.red)
            self.minColor = decodeColor(data.minColorData, fallback: Color.green)
            self.secColor = decodeColor(data.secColorData, fallback: Color.blue)
        }

        func toData() -> ThemeData {
            func encodeColor(_ color: Color) -> String {
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: NSColor(color), requiringSecureCoding: false)
                    return data.base64EncodedString()
                } catch {
                    return ""
                }
            }

            return ThemeData(
                name: name,
                hourColorData: encodeColor(hourColor),
                minColorData: encodeColor(minColor),
                secColorData: encodeColor(secColor)
            )
        }
    }

    var savedThemes: [Theme] {
        get {
            if let data = savedThemesData.data(using: .utf8),
               let themeDatas = try? JSONDecoder().decode([ThemeData].self, from: data) {
                return themeDatas.compactMap { Theme(from: $0) }
            }
            return []
        }
        set {
            let themeDatas = newValue.map { $0.toData() }
            if let data = try? JSONEncoder().encode(themeDatas),
               let jsonString = String(data: data, encoding: .utf8) {
                savedThemesData = jsonString
            }
        }
    }

    func saveCurrentTheme(name: String) {
        let theme = Theme(
            name: name,
            hourColor: customHourColor,
            minColor: customMinColor,
            secColor: customSecColor
        )
        var themes = savedThemes
        // Remove existing theme with same name
        themes.removeAll { $0.name == name }
        themes.append(theme)
        savedThemes = themes
    }

    func loadTheme(_ theme: Theme) {
        customHourColor = theme.hourColor
        customMinColor = theme.minColor
        customSecColor = theme.secColor
        colorScheme = "custom"
    }

    func deleteTheme(named name: String) {
        var themes = savedThemes
        themes.removeAll { $0.name == name }
        savedThemes = themes
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

    // Formatted time string for digital display (hh:mm format)
    var digitalTimeString: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.hour, .minute], from: now)

        let hour = components.hour ?? 0
        let minute = components.minute ?? 0

        if use24HourFormat {
            return String(format: "%02d:%02d", hour, minute)
        } else {
            let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
            return String(format: "%d:%02d", displayHour, minute)
        }
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

        // Check for animation window (59 seconds onward) to trigger rotation animation
        if isInAnimationWindow(second: secs) && lastAnimationTriggerSecond < 59.0 {
            // Just entered the 59-second window - trigger animation
            triggerMinuteAnimation()
            lastAnimationTriggerSecond = secs
        } else if !isInAnimationWindow(second: secs) {
            // Left the animation window - reset for next minute
            lastAnimationTriggerSecond = -1
        }

        // Check for minute change to trigger animation (legacy behavior)
        let currentMinute = components.minute ?? 0
        if currentMinute != lastMinute && lastMinute != -1 {
            // Only trigger if we haven't already triggered in the 59-second window
            if lastAnimationTriggerSecond < 59.0 {
                triggerMinuteAnimation()
            }
        }
        lastMinute = currentMinute
    }

    /// Check if the current second is within the animation window (59 seconds onward)
    func isInAnimationWindow(second: Double) -> Bool {
        return second >= 59.0
    }

    private func triggerMinuteAnimation() {
        // Generate random 3D rotation angles
        // X axis rotation: -40 to 40 degrees
        let randomX = Double.random(in: -40...40)
        // Y axis rotation: -40 to 40 degrees
        let randomY = Double.random(in: -40...40)
        // Z axis rotation: random full 360 rotation
        let randomZ = Bool.random() ? 360.0 : -360.0

        // Animate to new angles
        rotationX = randomX
        rotationY = randomY
        rotationZ = rotationZ + randomZ
        shouldAnimate = true

        // Reset animation flag and return rotations to zero after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.shouldAnimate = false
            // Smoothly return to initial position
            self.rotationX = 0
            self.rotationY = 0
            self.rotationZ = 0
        }
    }

    func updateTimeForZone(_ timeZone: TimeZone) {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
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
