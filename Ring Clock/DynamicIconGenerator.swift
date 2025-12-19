import AppKit
import Combine

/// Generates and updates a dynamic app icon that shows the current time
class DynamicIconGenerator {
  static let shared = DynamicIconGenerator()

  private var timer: Timer?
  private var statusItem: NSStatusItem?

  func startUpdatingIcon(for statusItem: NSStatusItem) {
    self.statusItem = statusItem
    updateIcon()

    // Update every second
    timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
      self?.updateIcon()
    }
  }

  func stopUpdating() {
    timer?.invalidate()
    timer = nil
  }

  private func updateIcon() {
    guard let statusItem = statusItem else { return }

    if let smallImage = createClockIcon(size: 24) {
      statusItem.button?.image = smallImage
    }

    // Also update the dock icon with a larger version
    if let dockImage = createClockIcon(size: 128) {
      NSApplication.shared.applicationIconImage = dockImage
    }
  }

  private func createClockIcon(size: Int) -> NSImage? {
    guard
      let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .calibratedRGB,
        bytesPerRow: size * 4,
        bitsPerPixel: 32
      )
    else {
      return nil
    }

    let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep)
    NSGraphicsContext.current = graphicsContext
    let cgSize = CGFloat(size)

    drawIconBackground(size: cgSize)
    drawIconClockElements(size: cgSize)

    NSGraphicsContext.current = nil

    let image = NSImage(size: NSSize(width: size, height: size))
    image.addRepresentation(bitmapRep)
    return image
  }

  private func drawIconBackground(size: CGFloat) {
    let padding = size * 0.1
    let bgColor = NSColor(white: 0.20, alpha: 1.0)
    bgColor.setFill()
    let cornerRadius = size * 0.15
    let bgRect = NSRect(
      x: padding, y: padding, width: size - padding * 2, height: size - padding * 2)
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    bgPath.fill()
  }

  private func drawIconClockElements(size: CGFloat) {
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: now)
    let hour = CGFloat(components.hour ?? 0)
    let minute = CGFloat(components.minute ?? 0)

    let minuteAngle = minute * 6.0
    let hourAngle = (hour.truncatingRemainder(dividingBy: 12) * 30.0) + (minute * 0.5)

    let center = CGPoint(x: size / 2.0, y: size / 2.0)
    let radius = size * 0.32

    // Clock ring
    let ringPath = NSBezierPath()
    ringPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
    ringPath.lineWidth = size * 0.035
    NSColor.white.setStroke()
    ringPath.stroke()

    // Hour hand (shorter, thicker)
    drawHand(HandConfig(
      center: center,
      radius: radius,
      angle: hourAngle,
      length: 0.4,
      width: size * 0.065,
      color: .white
    ))

    // Minute hand (longer, thicker) - Always red
    drawHand(HandConfig(
      center: center,
      radius: radius,
      angle: minuteAngle,
      length: 0.5,
      width: size * 0.08,
      color: .systemRed
    ))

    // Center dot
    let dotRadius = size * 0.025
    let dotPath = NSBezierPath(
      ovalIn: NSRect(
        x: center.x - dotRadius,
        y: center.y - dotRadius,
        width: dotRadius * 2,
        height: dotRadius * 2
      )
    )
    NSColor.white.setFill()
    dotPath.fill()
  }

  private func drawHand(_ config: HandConfig) {
    let angleInRadians = config.angle * .pi / 180
    let handLength = config.length * config.radius

    let endX = config.center.x + handLength * sin(angleInRadians)
    let endY = config.center.y - handLength * cos(angleInRadians)

    let path = NSBezierPath()
    path.move(to: NSPoint(x: config.center.x, y: config.center.y))
    path.line(to: NSPoint(x: endX, y: endY))
    path.lineWidth = config.width
    config.color.setStroke()
    path.stroke()
  }
}

private struct HandConfig {
  let center: CGPoint
  let radius: CGFloat
  let angle: CGFloat
  let length: CGFloat
  let width: CGFloat
  let color: NSColor
}
