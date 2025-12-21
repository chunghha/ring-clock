import SwiftUI

struct RingProgressDividers: View {
  var radius: CGFloat
  var progress: Double
  var divisions: Int = 12
  var thickness: CGFloat = 3
  var ringThickness: CGFloat = 18
  var color: Color = .white

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      let totalDivisions = Int(ceil(progress * Double(divisions)))

      for division in 0..<totalDivisions {
        let angle = CGFloat(division) * (360 / CGFloat(divisions))
        let radians = (angle - 90) * .pi / 180

        // Points along the ring thickness
        let outerRadius = radius + ringThickness / 2
        let innerRadius = radius - ringThickness / 2

        let outerX = center.x + outerRadius * cos(radians)
        let outerY = center.y + outerRadius * sin(radians)

        let innerX = center.x + innerRadius * cos(radians)
        let innerY = center.y + innerRadius * sin(radians)

        var path = Path()
        path.move(to: CGPoint(x: outerX, y: outerY))
        path.addLine(to: CGPoint(x: innerX, y: innerY))

        context.stroke(
          path,
          with: .color(color),
          lineWidth: thickness
        )
      }
    }
    .frame(width: radius * 2 + ringThickness, height: radius * 2 + ringThickness)
  }
}

#Preview {
  RingProgressDividers(radius: 210, progress: 0.5, divisions: 60)
}
