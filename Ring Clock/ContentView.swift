import SwiftUI

struct ContentView: View {
    @EnvironmentObject var clock: ClockManager
    @State private var isHovering = false

    var body: some View {
        if clock.selectedTimeZones.count <= 1 {
            // Single clock view
            ZStack {
                // Minute Ring (Outer)
                TimeRing(progress: clock.minute, color: clock.minColor, thickness: clock.ringThickness)
                    .frame(width: 420, height: 420)
                    .accessibilityLabel("Minute ring")
                    .accessibilityValue("\(clock.currentMinute) minutes past the hour")

                // Second Ring (Middle - Visible on hover or toggle)
                TimeRing(progress: clock.second, color: clock.secColor, thickness: clock.ringThickness)
                    .frame(width: 325, height: 325)
                    .opacity((isHovering || clock.showSeconds) ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: isHovering || clock.showSeconds)
                    .accessibilityLabel("Second ring")
                    .accessibilityValue("\(clock.currentSecond) seconds")

                // Hour Ring (Inner)
                TimeRing(progress: clock.hour, color: clock.hourColor, thickness: clock.ringThickness)
                    .frame(width: 240, height: 240)
                    .accessibilityLabel("Hour ring")
                    .accessibilityValue("\(clock.currentHour) o'clock")

                // Digital time overlay (optional)
                if clock.showDigitalTime {
                    Text(clock.digitalTimeString)
                        .font(.system(size: clock.digitalFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 0)
                        .accessibilityLabel("Digital time display")
                        .accessibilityValue(clock.digitalTimeString)
                }
            }
            .padding(40)
            .opacity(clock.windowOpacity)
            .animation(.easeInOut(duration: 0.5), value: clock.colorScheme)
            .onHover { hovering in
                isHovering = hovering
            }
        } else {
            // Multiple time zone view
            HStack(spacing: 20) {
                ForEach(clock.selectedTimeZones, id: \.self) { zoneId in
                    let timeZone = TimeZone(identifier: zoneId) ?? TimeZone.current
                    let zoneName = zoneId.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? zoneId

                    TimeZoneClock(timeZone: timeZone, label: zoneName, clockManager: clock)
                }
            }
            .padding(20)
            .opacity(clock.windowOpacity)
            .animation(.easeInOut(duration: 0.5), value: clock.colorScheme)
        }
    }
}


