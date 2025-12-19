import SwiftUI

struct TimeZoneClock: View {
  let timeZone: TimeZone
  let label: String
  @ObservedObject var clockManager: ClockManager

  // Calculate time components for this time zone
  private var hourProgress: Double {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    let now = Date()
    let components = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: now)

    let nsecs = Double(components.nanosecond ?? 0) / 1_000_000_000
    let secs = Double(components.second ?? 0) + nsecs
    let mins = Double(components.minute ?? 0) + (secs / 60.0)
    let hrs = Double(components.hour ?? 0 % 12) + (mins / 60.0)

    return (hrs.truncatingRemainder(dividingBy: 12)) / 12.0
  }

  private var minuteProgress: Double {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    let now = Date()
    let components = calendar.dateComponents([.minute, .second, .nanosecond], from: now)

    let nsecs = Double(components.nanosecond ?? 0) / 1_000_000_000
    let secs = Double(components.second ?? 0) + nsecs
    let mins = Double(components.minute ?? 0) + (secs / 60.0)

    return mins / 60.0
  }

  private var secondProgress: Double {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    let now = Date()
    let components = calendar.dateComponents([.second, .nanosecond], from: now)

    let nsecs = Double(components.nanosecond ?? 0) / 1_000_000_000
    let secs = Double(components.second ?? 0) + nsecs

    return secs / 60.0
  }

  var body: some View {
    VStack(spacing: 8) {
      Text(label)
        .font(.caption)
        .foregroundColor(clockManager.digitalTextColor.opacity(0.8))

      ZStack {
        // Second Ring (Outer) - smaller for multi-clock view
        TimeRing(progress: secondProgress, color: clockManager.secColor, thickness: 30)
          .frame(width: 120, height: 120)
          .opacity((clockManager.showSeconds) ? 1 : 0)
          .animation(.easeInOut(duration: 0.3), value: clockManager.showSeconds)

        // Minute Ring (Middle)
        TimeRing(progress: minuteProgress, color: clockManager.minColor, thickness: 30)
          .frame(width: 90, height: 90)

        // Hour Ring (Inner)
        TimeRing(progress: hourProgress, color: clockManager.hourColor, thickness: 30)
          .frame(width: 60, height: 60)
      }
    }
    .padding(8)
  }
}
