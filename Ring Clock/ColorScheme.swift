import SwiftUI

extension ClockManager {
  var basicHourColor: Color {
    Color(NSColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0))
  }

  var basicMinColor: Color {
    Color(NSColor(red: 0.5, green: 0.8, blue: 0.6, alpha: 1.0))
  }

  var basicSecColor: Color {
    Color(NSColor(red: 1.0, green: 0.8, blue: 0.6, alpha: 0.7))
  }

  var moonHourColor: Color {
    Color(NSColor(red: 0.7, green: 0.4, blue: 0.1, alpha: 0.7))
  }

  var moonMinColor: Color {
    Color(NSColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 0.6))
  }

  var moonSecColor: Color {
    Color(NSColor(red: 0.1, green: 0.2, blue: 0.5, alpha: 0.5))
  }

  var ghostHourColor: Color {
    Color(NSColor(red: 0.0, green: 0.8, blue: 0.8, alpha: 0.8))
  }

  var ghostMinColor: Color {
    Color(NSColor(red: 0.0, green: 1.0, blue: 0.4, alpha: 0.6))
  }

  var ghostSecColor: Color {
    Color(NSColor(red: 0.4, green: 0.0, blue: 0.6, alpha: 0.7))
  }

  var grayHourColor: Color {
    Color(NSColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 0.8))  // Middle gray
  }

  var grayMinColor: Color {
    Color(NSColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 0.8))  // Darkest gray
  }

  var graySecColor: Color {
    Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.7))  // Brightest gray
  }

  var vintageHourColor: Color {
    Color(NSColor(red: 0.82, green: 0.78, blue: 0.68, alpha: 0.7))  // Old paper color
  }

  var vintageMinColor: Color {
    Color(NSColor(red: 0.70, green: 0.65, blue: 0.40, alpha: 0.8))  // Yellowish brown
  }

  var vintageSecColor: Color {
    Color(NSColor(red: 0.92, green: 0.80, blue: 0.72, alpha: 0.7))  // Brightest vintage peach
  }
}
