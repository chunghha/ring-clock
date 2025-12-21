import SwiftUI

struct ContentView: View {
  @EnvironmentObject var clock: ClockManager
  @State private var isHovering = false

  // Screenshot notification
  private let screenshotNotification = Notification.Name("RequestScreenshot")

  var body: some View {
    if clock.selectedTimeZones.count <= 1 {
      // Single clock view
      ZStack {
        // Minute Ring (Outer)
        TimeRing(progress: clock.minute, color: clock.minColor, thickness: clock.ringThickness)
          .frame(width: 420, height: 420)
          .accessibilityLabel("Minute ring")
          .accessibilityValue("\(clock.currentMinute) minutes past the hour")

        // Minute dividers
        HourDividers(color: clock.minColor, radius: 210, progress: clock.minute, divisions: 60)

        // Minute progress dividers (subtle minute color on ring)
        RingProgressDividers(
          radius: 210, progress: clock.minute, divisions: 60, thickness: 2,
          ringThickness: clock.ringThickness, color: clock.minColor.opacity(0.5))

        // Minute progress marker
        ProgressMarker(color: clock.minColor, radius: 210, progress: clock.minute, thickness: 2.5)

        // Second Ring (Middle - Visible on hover or toggle)
        TimeRing(progress: clock.second, color: clock.secColor, thickness: clock.ringThickness)
          .frame(width: 325, height: 325)
          .opacity((isHovering || clock.showSeconds) ? 1 : 0)
          .animation(.easeInOut(duration: 0.3), value: isHovering || clock.showSeconds)
          .accessibilityLabel("Second ring")
          .accessibilityValue("\(clock.currentSecond) seconds")

        // Second dividers
        HourDividers(color: clock.secColor, radius: 162.5, progress: clock.second, divisions: 60)
          .opacity((isHovering || clock.showSeconds) ? 1 : 0)
          .animation(.easeInOut(duration: 0.3), value: isHovering || clock.showSeconds)

        // Second progress dividers (subtle second color on ring)
        RingProgressDividers(
          radius: 162.5, progress: clock.second, divisions: 60, thickness: 2,
          ringThickness: clock.ringThickness, color: clock.secColor.opacity(0.5)
        )
        .opacity((isHovering || clock.showSeconds) ? 1 : 0)
        .animation(.easeInOut(duration: 0.3), value: isHovering || clock.showSeconds)

        // Second progress marker
        ProgressMarker(color: clock.secColor, radius: 162.5, progress: clock.second, thickness: 2.5)
          .opacity((isHovering || clock.showSeconds) ? 1 : 0)
          .animation(.easeInOut(duration: 0.3), value: isHovering || clock.showSeconds)

        // Hour Ring (Inner)
        TimeRing(progress: clock.hour, color: clock.hourColor, thickness: clock.ringThickness)
          .frame(width: 240, height: 240)
          .accessibilityLabel("Hour ring")
          .accessibilityValue("\(clock.currentHour) o'clock")

        // Hour dividers
        HourDividers(color: clock.hourColor, radius: 120, progress: clock.hour)

        // Hour progress dividers (subtle hour color on ring)
        RingProgressDividers(
          radius: 120, progress: clock.hour, divisions: 12, thickness: 2,
          ringThickness: clock.ringThickness, color: clock.hourColor.opacity(0.5))

        // Hour progress marker
        ProgressMarker(color: clock.hourColor, radius: 120, progress: clock.hour, thickness: 2.5)

        // Digital time overlay (optional)
        if clock.showDigitalTime {
          Text(clock.digitalTimeString)
            .font(.system(size: clock.digitalFontSize, weight: .bold, design: .monospaced))
            .foregroundColor(clock.digitalTextColor)
            .shadow(color: .black.opacity(0.8), radius: 4, x: 0, y: 0)
            .accessibilityLabel("Digital time display")
            .accessibilityValue(clock.digitalTimeString)
        }
      }
      .padding(40)
      .opacity(clock.windowOpacity)
      .animation(.easeInOut(duration: 0.5), value: clock.colorScheme)
      .rotation3DEffect(
        .degrees(clock.rotationX),
        axis: (1, 0, 0)
      )
      .rotation3DEffect(
        .degrees(clock.rotationY),
        axis: (0, 1, 0)
      )
      .rotation3DEffect(
        .degrees(clock.rotationZ),
        axis: (0, 0, 1)
      )
      .animation(clock.shouldAnimate ? .easeInOut(duration: 1.0) : .none, value: clock.rotationX)
      .animation(clock.shouldAnimate ? .easeInOut(duration: 1.0) : .none, value: clock.rotationY)
      .animation(clock.shouldAnimate ? .easeInOut(duration: 1.0) : .none, value: clock.rotationZ)
      .onHover { hovering in
        isHovering = hovering
      }
      .simultaneousGesture(
        TapGesture()
          .onEnded { _ in
            print("🖱️ Simultaneous tap detected, checking for Cmd...")
            if NSApp.currentEvent?.modifierFlags.contains(.command) == true {
              print("🎯 Cmd+click detected - posting screenshot notification")
              NotificationCenter.default.post(name: screenshotNotification, object: nil)
            } else {
              print("❌ Tap detected but no Cmd key")
            }
          }
      )
    } else {
      // Multiple time zone view
      HStack(spacing: 20) {
        ForEach(clock.selectedTimeZones, id: \.self) { zoneId in
          let timeZone = TimeZone(identifier: zoneId) ?? TimeZone.current
          let zoneName =
            zoneId.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? zoneId

          TimeZoneClock(timeZone: timeZone, label: zoneName, clockManager: clock)
        }
      }
      .padding(20)
      .opacity(clock.windowOpacity)
      .animation(.easeInOut(duration: 0.5), value: clock.colorScheme)
      .rotation3DEffect(
        .degrees(clock.rotationX),
        axis: (1, 0, 0)
      )
      .rotation3DEffect(
        .degrees(clock.rotationY),
        axis: (0, 1, 0)
      )
      .rotation3DEffect(
        .degrees(clock.rotationZ),
        axis: (0, 0, 1)
      )
      .animation(clock.shouldAnimate ? .easeInOut(duration: 1.0) : .none, value: clock.rotationX)
      .animation(clock.shouldAnimate ? .easeInOut(duration: 1.0) : .none, value: clock.rotationY)
      .animation(clock.shouldAnimate ? .easeInOut(duration: 1.0) : .none, value: clock.rotationZ)
    }
  }
}
