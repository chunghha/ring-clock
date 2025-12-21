import SwiftUI

struct HourDividers: View {
  var color: Color
  var radius: CGFloat
  var progress: Double = 0
  var thickness: CGFloat = 1
  var divisions: Int = 12

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      let progressAngle = progress * 360

      for division in 0..<divisions {
        let angle = CGFloat(division) * (360 / CGFloat(divisions))
        let radians = (angle - 90) * .pi / 180

        // Determine if this divider is in the "past" (completed) section
        let isPast = angle <= progressAngle

        // Start point (inner edge)
        let innerRadius = radius * 0.75
        let innerX = center.x + innerRadius * cos(radians)
        let innerY = center.y + innerRadius * sin(radians)

        // End point (outer edge)
        let outerX = center.x + radius * cos(radians)
        let outerY = center.y + radius * sin(radians)

        var path = Path()
        path.move(to: CGPoint(x: innerX, y: innerY))
        path.addLine(to: CGPoint(x: outerX, y: outerY))

        let dividerColor = isPast ? color : color.opacity(0.3)

        context.stroke(
          path,
          with: .color(dividerColor),
          lineWidth: thickness
        )
      }
    }
    .frame(width: radius * 2, height: radius * 2)
  }
}

#Preview {
  HourDividers(color: .white, radius: 220, progress: 0.5)
}
