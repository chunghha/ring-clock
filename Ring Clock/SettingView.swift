import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var clock: ClockManager

    var body: some View {
        Form {
            Section(header: Text("Color Scheme")) {
                Picker("Theme", selection: $clock.colorScheme) {
                    Text("Base").tag("base")
                    Text("Moon").tag("moon")
                }
                .pickerStyle(.segmented)
            }

            Section(header: Text("Appearance")) {
                Slider(value: $clock.ringThickness, in: 30...70, step: 5) {
                    Text("Ring Thickness: \(Int(clock.ringThickness))")
                }
                Slider(value: $clock.windowOpacity, in: 0.5...1.0, step: 0.1) {
                    Text("Window Opacity: \(String(format: "%.1f", clock.windowOpacity))")
                }
            }

            Section(header: Text("Visibility")) {
                Toggle("Always show seconds", isOn: $clock.showSeconds)
                Text("If off, hover over the clock to see seconds.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .frame(width: 350)
    }
}
