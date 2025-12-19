import SwiftUI

struct ThemePreviewView: View {
  @EnvironmentObject var clock: ClockManager

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Theme Previews:")
        .font(.subheadline)
        .foregroundColor(.secondary)

      HStack(spacing: 20) {
        themeButton(name: "Base", scheme: "base", colors: [
          Color(red: 0.2, green: 0.6, blue: 0.8),
          Color(red: 0.8, green: 0.4, blue: 0.2),
          Color(red: 0.4, green: 0.8, blue: 0.4)
        ])

        themeButton(name: "Moon", scheme: "moon", colors: [
          Color(red: 0.9, green: 0.7, blue: 0.1, opacity: 0.6),
          Color(red: 0.7, green: 0.4, blue: 0.1, opacity: 0.7),
          Color(red: 0.1, green: 0.2, blue: 0.5, opacity: 0.5)
        ])

        themeButton(name: "Ghost", scheme: "ghost", colors: [
          Color(red: 0.0, green: 0.8, blue: 0.8, opacity: 0.8),
          Color(red: 0.0, green: 1.0, blue: 0.4, opacity: 0.6),
          Color(red: 0.4, green: 0.0, blue: 0.6, opacity: 0.7)
        ])

        themeButton(name: "Gray", scheme: "gray", colors: [
          Color(red: 0.6, green: 0.6, blue: 0.6, opacity: 0.8),
          Color(red: 0.4, green: 0.4, blue: 0.4, opacity: 0.7),
          Color(red: 0.8, green: 0.8, blue: 0.8, opacity: 0.6)
        ])

        themeButton(name: "Vintage", scheme: "vintage", colors: [
          Color(red: 0.75, green: 0.73, blue: 0.64, opacity: 0.6),
          Color(red: 0.70, green: 0.68, blue: 0.58, opacity: 0.7),
          Color(red: 0.80, green: 0.78, blue: 0.70, opacity: 0.8)
        ])
      }
    }
    .padding(.top, 10)
  }

  private func themeButton(name: String, scheme: String, colors: [Color]) -> some View {
    Button(
      action: { clock.colorScheme = scheme },
      label: {
        VStack(spacing: 4) {
          Text(name).font(.caption)
          ZStack {
            TimeRing(progress: 0.5, color: colors[0], thickness: 20)
              .frame(width: 60, height: 60)
            TimeRing(progress: 0.3, color: colors[1], thickness: 20)
              .frame(width: 45, height: 45)
            TimeRing(progress: 0.8, color: colors[2], thickness: 20)
              .frame(width: 30, height: 30)
          }
          .frame(width: 70, height: 70)
          .background(
            RoundedRectangle(cornerRadius: 8)
              .stroke(
                clock.colorScheme == scheme ? Color.accentColor : Color.clear,
                lineWidth: 3
              )
          )
          .padding(6)
        }
      }
    )
    .buttonStyle(.plain)
  }
}
