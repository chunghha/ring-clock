import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var clock: ClockManager
    @State private var newThemeName: String = ""

    var body: some View {
        Form {
            Section(header: Text("Color Scheme")) {
                Picker("Theme", selection: $clock.colorScheme) {
                    Text("Base").tag("base")
                    Text("Moon").tag("moon")
                    Text("Ghost in the Shell").tag("ghost")
                    Text("Custom").tag("custom")
                }
                .pickerStyle(.segmented)

                if clock.colorScheme == "custom" {
                    VStack(alignment: .leading, spacing: 10) {
                        ColorPicker("Hour Ring Color", selection: $clock.customHourColor)
                        ColorPicker("Minute Ring Color", selection: $clock.customMinColor)
                        ColorPicker("Second Ring Color", selection: $clock.customSecColor)
                    }
                    .padding(.top, 10)
                }
            }

            Section(header: Text("Appearance")) {
                Slider(value: $clock.ringThickness, in: 30...70, step: 5) {
                    Text("Ring Thickness: \(Int(clock.ringThickness))")
                }
                Slider(value: $clock.windowOpacity, in: 0.5...1.0, step: 0.1) {
                    Text("Window Opacity: \(String(format: "%.1f", clock.windowOpacity))")
                }
            }

            Section(header: Text("Custom Themes")) {
                HStack {
                    TextField("Theme name", text: $newThemeName)
                    Button("Save") {
                        if !newThemeName.isEmpty {
                            clock.saveCurrentTheme(name: newThemeName)
                            newThemeName = ""
                        }
                    }
                    .disabled(newThemeName.isEmpty)
                }

                if !clock.savedThemes.isEmpty {
                    Text("Saved Themes:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    ForEach(clock.savedThemes, id: \.name) { theme in
                        HStack {
                            Button(theme.name) {
                                clock.loadTheme(theme)
                            }
                            Spacer()
                            Button(action: {
                                clock.deleteTheme(named: theme.name)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
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
