import SwiftUI

struct TimeRing: View {
    var progress: Double
    var color: Color
    var thickness: CGFloat

    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(color.opacity(0.1), lineWidth: thickness)

            // Active ring
            ZStack {
                // Outer shade line
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: thickness, lineCap: .butt))
                    .rotationEffect(.degrees(-90)) // Start at 12 o'clock
                // Main line
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: thickness - 8, lineCap: .butt))
                    .rotationEffect(.degrees(-90)) // Start at 12 o'clock
            }
            .shadow(color: color.opacity(0.6), radius: 8, x: 0, y: 0)
        }
    }
}