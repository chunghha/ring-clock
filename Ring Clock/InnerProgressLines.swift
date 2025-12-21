import SwiftUI

struct InnerProgressLines: View {
  var radius: CGFloat
  var progress: Double
  var divisions: Int = 12
  var thickness: CGFloat = 1

  var body: some View {
    Canvas { context, size in
      let center = CGPoint(x: size.width / 2, y: size.height / 2)
      let totalDivisions = Int(ceil(progress * Double(divisions)))

      for division in 0..<totalDivisions {
        let angle = CGFloat(division) * (360 / CGFloat(divisions))
        let radians = (angle - 90) * .pi / 180

        // Inner edge starting point
        let innerRadius = radius * 0.75
        let startX = center.x + innerRadius * cos(radians)
        let startY = center.y + innerRadius * sin(radians)

        // Inner edge end point (shorter line)
        let lineLength = radius * 0.08
        let endX = center.x + (innerRadius - lineLength) * cos(radians)
        let endY = center.y + (innerRadius - lineLength) * sin(radians)

        var path = Path()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: endX, y: endY))

        context.stroke(
          path,
          with: .color(.white),
          lineWidth: thickness
        )
      }
    }
    .frame(width: radius * 2, height: radius * 2)
  }
}

#Preview {
  InnerProgressLines(radius: 210, progress: 0.5, divisions: 60)
}
