import SwiftUI

struct ProgressMarker: View {
  var color: Color
  var radius: CGFloat
  var progress: Double
  var thickness: CGFloat = 2

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      let progressAngle = progress * 360
      let radians = (progressAngle - 90) * .pi / 180

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

      context.stroke(
        path,
        with: .color(color),
        lineWidth: thickness
      )
    }
    .frame(width: radius * 2, height: radius * 2)
  }
}

#Preview {
  ProgressMarker(color: .white, radius: 210, progress: 0.5)
}
