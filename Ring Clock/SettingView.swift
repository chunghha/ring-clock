import SwiftUI

struct SettingsView: View {
  @EnvironmentObject var clock: ClockManager
  @State private var newThemeName: String = ""
  @State private var selectedTimeZone: String = TimeZone.current.identifier
  @State private var showingTimeZonePicker = false
  @State private var previewScheme: String = "ghost"  // For theme preview

  private let commonTimeZones = [
    "America/New_York": "Eastern Time",
    "America/Chicago": "Central Time",
    "America/Denver": "Mountain Time",
    "America/Los_Angeles": "Pacific Time",
    "Europe/London": "London",
    "Europe/Paris": "Paris",
    "Europe/Berlin": "Berlin",
    "Asia/Tokyo": "Tokyo",
    "Asia/Shanghai": "Shanghai",
    "Australia/Sydney": "Sydney"
  ]

  var body: some View {
    ScrollView {
      Form {
        Section(header: Text("Color Scheme")) {
          Picker("Theme", selection: $clock.colorScheme) {
            Text("Base").tag("base")
            Text("Moon").tag("moon")
            Text("Ghost in the Shell").tag("ghost")
            Text("Gray").tag("gray")
            Text("Vintage").tag("vintage")
            Text("Custom").tag("custom")
          }
          .pickerStyle(.segmented)

          ThemePreviewView()

          if clock.colorScheme == "custom" {
            VStack(alignment: .leading, spacing: 10) {
              ColorPicker("Hour Ring Color", selection: $clock.customHourColor)
              ColorPicker("Minute Ring Color", selection: $clock.customMinColor)
              ColorPicker("Second Ring Color", selection: $clock.customSecColor)

              HStack {
                TextField("Theme name", text: $newThemeName)
                  .frame(width: 120)
                Button("Save Theme") {
                  if !newThemeName.isEmpty {
                    clock.saveCurrentTheme(name: newThemeName)
                    newThemeName = ""
                  }
                }
                .disabled(newThemeName.isEmpty)
              }
              .padding(.top, 8)
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

        Section(header: Text("Clock Style")) {
          Toggle("24-hour format", isOn: $clock.use24HourFormat)
          Toggle("Show digital time", isOn: $clock.showDigitalTime)

          if clock.showDigitalTime {
            Slider(value: $clock.digitalFontSize, in: 16...48, step: 2) {
              Text("Font Size: \(Int(clock.digitalFontSize))")
            }

            Picker("Text Color", selection: $clock.digitalTimeTextColor) {
              Text("White").tag("white")
              Text("Black").tag("black")
              Text("Brightest in Theme").tag("brightest")
              Text("Darkest in Theme").tag("darkest")
            }
            .pickerStyle(.menu)
          }
        }

        Section(header: Text("Menu Bar")) {
          Toggle("Show menu bar icon", isOn: $clock.showMenuBarIcon)
          Text("When enabled, shows a clock icon in the menu bar for quick access")
            .font(.caption)
            .foregroundColor(.gray)
        }

        Section(header: Text("Display Options")) {
          Toggle("Show seconds ring", isOn: $clock.showSeconds)
          Text("Display the seconds ring (hover to temporarily show when disabled)")
            .font(.caption)
            .foregroundColor(.gray)

          Toggle("Show digital time", isOn: $clock.showDigitalTime)
          if clock.showDigitalTime {
            VStack(alignment: .leading, spacing: 8) {
              Toggle("24-hour format", isOn: $clock.use24HourFormat)
              HStack {
                Text("Font size:")
                Slider(value: $clock.digitalFontSize, in: 16...48, step: 2)
                  .frame(width: 100)
                Text("\(Int(clock.digitalFontSize))pt")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
            }
            .padding(.leading, 16)
          }
        }

        Section(header: Text("Appearance")) {
          HStack {
            Text("Ring thickness:")
            Slider(value: $clock.ringThickness, in: 30...70, step: 5)
              .frame(width: 100)
            Text("\(Int(clock.ringThickness))px")
              .font(.caption)
              .foregroundColor(.secondary)
          }

          HStack {
            Text("Window opacity:")
            Slider(value: $clock.windowOpacity, in: 0.5...1.0, step: 0.1)
              .frame(width: 100)
            Text("\(Int(clock.windowOpacity * 100))%")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

        Section(header: Text("Time Zones")) {
          Text("Multiple Time Zones: \(clock.selectedTimeZones.count)")
            .font(.subheadline)

          if clock.selectedTimeZones.count > 1 {
            ForEach(clock.selectedTimeZones, id: \.self) { zoneId in
              HStack {
                Text("\(zoneId) (\(commonTimeZones[zoneId] ?? "Unknown"))")
                Spacer()
                if clock.selectedTimeZones.count > 1 {
                  Button(
                    action: { clock.removeTimeZone(zoneId) },
                    label: {
                      Image(systemName: "minus.circle.fill")
                        .foregroundColor(.red)
                    }
                  )
                  .buttonStyle(.borderless)
                }
              }
            }
          }

          HStack {
            Picker("Add Time Zone", selection: $selectedTimeZone) {
              ForEach(Array(commonTimeZones.keys.sorted()), id: \.self) { zoneId in
                Text("\(zoneId) (\(commonTimeZones[zoneId]!))")
                  .tag(zoneId)
              }
            }
            .pickerStyle(.menu)

            Button("Add") {
              if !clock.selectedTimeZones.contains(selectedTimeZone) {
                clock.addTimeZone(selectedTimeZone)
              }
            }
            .disabled(clock.selectedTimeZones.contains(selectedTimeZone))
          }

          if !clock.savedThemes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
              Text("Saved Themes:")
                .font(.subheadline)
                .foregroundColor(.secondary)

              ForEach(clock.savedThemes, id: \.name) { theme in
                HStack {
                  Button(theme.name) {
                    clock.loadTheme(theme)
                  }
                  .buttonStyle(.borderless)
                  Spacer()
                  Button(
                    action: { clock.deleteTheme(named: theme.name) },
                    label: {
                      Image(systemName: "trash")
                        .foregroundColor(.red)
                    }
                  )
                  .buttonStyle(.borderless)
                }
              }
            }
            .padding(.top, 8)
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
                Button(
                  action: { clock.deleteTheme(named: theme.name) },
                  label: {
                    Image(systemName: "trash")
                      .foregroundColor(.red)
                  }
                )
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
    }
    .padding(20)
    .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600)
  }
}
