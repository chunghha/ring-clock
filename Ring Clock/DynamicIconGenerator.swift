import AppKit
import Combine

/// Generates and updates a dynamic app icon that shows the current time
class DynamicIconGenerator {
  static let shared = DynamicIconGenerator()

  private var timer: Timer?
  private var statusItem: NSStatusItem?

  func getCurrentTimeComponents() -> (hour: Int, minute: Int) {
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: now)
    return (
      hour: components.hour ?? 0,
      minute: components.minute ?? 0
    )
  }

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
    let cornerRadius = size * 0.15
    let bgRect = NSRect(
      x: padding, y: padding, width: size - padding * 2, height: size - padding * 2)

    // Deep 3D shadow effect underneath
    let shadowPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    NSColor(white: 0.0, alpha: 0.9).setFill()
    shadowPath.fill()

    // Dramatic gradient background with strong 3D depth
    let gradient = NSGradient(colors: [
      NSColor(white: 0.02, alpha: 1.0),  // Very dark top
      NSColor(white: 0.4, alpha: 1.0),  // Much lighter bottom for depth
    ])
    let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    gradient?.draw(in: bgPath, angle: 90)  // Top to bottom for 3D effect

    // Bright inner highlight edge for beveled 3D effect
    let innerPadding = size * 0.015
    let innerRect = NSRect(
      x: padding + innerPadding,
      y: padding + innerPadding,
      width: size - padding * 2 - innerPadding * 2,
      height: size - padding * 2 - innerPadding * 2
    )
    let innerPath = NSBezierPath(
      roundedRect: innerRect, xRadius: cornerRadius, yRadius: cornerRadius)
    NSColor(white: 0.65, alpha: 0.9).setStroke()
    innerPath.lineWidth = size * 0.008
    innerPath.stroke()

    // Dark outer border shadow for depth
    let borderColor = NSColor(white: 0.0, alpha: 1.0)
    borderColor.setStroke()
    bgPath.lineWidth = size * 0.016
    bgPath.stroke()

    // Top highlight edge for gloss effect
    let topHighlightPath = NSBezierPath(
      roundedRect:
        NSRect(
          x: padding + size * 0.01, y: padding + size * 0.01,
          width: size - padding * 2 - size * 0.02, height: size * 0.028),
      xRadius: cornerRadius * 0.6, yRadius: cornerRadius * 0.6)
    NSColor(white: 1.0, alpha: 0.5).setFill()
    topHighlightPath.fill()
  }

  private func drawIconClockElements(size: CGFloat) {
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: now)

    var hour = CGFloat(components.hour ?? 0)
    let minute = CGFloat(components.minute ?? 0)

    // Convert to 12-hour format (0-11)
    hour = hour.truncatingRemainder(dividingBy: 12)

    let minuteAngle = minute * 6.0
    let hourAngle = (hour * 30.0) + (minute * 0.5)

    let center = CGPoint(x: size / 2.0, y: size / 2.0)
    let radius = size * 0.28

    // Draw tick marks
    drawTickMarks(center: center, radius: radius, size: size)

    // Clock ring deep shadow (3D depth layer 1)
    let deepShadowPath = NSBezierPath()
    deepShadowPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
    deepShadowPath.lineWidth = size * 0.055
    NSColor(white: 0.0, alpha: 0.8).setStroke()
    deepShadowPath.stroke()

    // Clock ring medium shadow (3D depth layer 2)
    let shadowRingPath = NSBezierPath()
    shadowRingPath.appendArc(
      withCenter: center, radius: radius - size * 0.006, startAngle: 0, endAngle: 360)
    shadowRingPath.lineWidth = size * 0.04
    NSColor(white: 0.0, alpha: 0.4).setStroke()
    shadowRingPath.stroke()

    // Clock ring main (bright highlight)
    let ringPath = NSBezierPath()
    ringPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
    ringPath.lineWidth = size * 0.035
    NSColor.white.setStroke()
    ringPath.stroke()

    // Clock ring bright inner highlight (3D gloss)
    let innerGlossPath = NSBezierPath()
    innerGlossPath.appendArc(
      withCenter: center, radius: radius - size * 0.008, startAngle: 0, endAngle: 360)
    innerGlossPath.lineWidth = size * 0.012
    NSColor(white: 1.0, alpha: 0.7).setStroke()
    innerGlossPath.stroke()

    // Hour hand (shorter, thicker) with shadow
    drawHandShadow(
      HandConfig(
        center: center,
        radius: radius,
        angle: hourAngle,
        length: 0.55,
        width: size * 0.065,
        color: .white
      ),
      size: size
    )
    drawHand(
      HandConfig(
        center: center,
        radius: radius,
        angle: hourAngle,
        length: 0.55,
        width: size * 0.065,
        color: .white
      ))

    // Minute hand (longer, thicker) - Always red with shadow
    drawHandShadow(
      HandConfig(
        center: center,
        radius: radius,
        angle: minuteAngle,
        length: 0.65,
        width: size * 0.08,
        color: .systemRed
      ),
      size: size
    )
    drawHand(
      HandConfig(
        center: center,
        radius: radius,
        angle: minuteAngle,
        length: 0.65,
        width: size * 0.08,
        color: .systemRed
      ))

    // Center dot deep shadow (3D depth)
    let dotShadowRadius = size * 0.03
    let dotShadowPath = NSBezierPath(
      ovalIn: NSRect(
        x: center.x - dotShadowRadius + size * 0.005,
        y: center.y - dotShadowRadius + size * 0.005,
        width: dotShadowRadius * 2,
        height: dotShadowRadius * 2
      )
    )
    NSColor(white: 0.0, alpha: 0.8).setFill()
    dotShadowPath.fill()

    // Center dot outer glow - dark shadow
    let dotOuterRadius = size * 0.038
    let dotOuterPath = NSBezierPath(
      ovalIn: NSRect(
        x: center.x - dotOuterRadius,
        y: center.y - dotOuterRadius,
        width: dotOuterRadius * 2,
        height: dotOuterRadius * 2
      )
    )
    NSColor(white: 0.0, alpha: 0.6).setFill()
    dotOuterPath.fill()

    // Center dot main sphere
    let dotRadius = size * 0.025
    let dotPath = NSBezierPath(
      ovalIn: NSRect(
        x: center.x - dotRadius,
        y: center.y - dotRadius,
        width: dotRadius * 2,
        height: dotRadius * 2
      )
    )
    // Radial gradient for dramatic 3D sphere effect
    if let sphereGradient = NSGradient(colors: [
      NSColor.white,
      NSColor(white: 0.6, alpha: 1.0),
    ]) {
      sphereGradient.draw(in: dotPath, angle: 135)
    } else {
      NSColor.white.setFill()
      dotPath.fill()
    }

    // Primary dot highlight (bright 3D shine)
    let dotHighlightRadius = size * 0.009
    let dotHighlightPath = NSBezierPath(
      ovalIn: NSRect(
        x: center.x - dotHighlightRadius - size * 0.007,
        y: center.y - dotHighlightRadius - size * 0.007,
        width: dotHighlightRadius * 2,
        height: dotHighlightRadius * 2
      )
    )
    NSColor(white: 1.0, alpha: 1.0).setFill()
    dotHighlightPath.fill()

    // Secondary subtle highlight for extra gloss
    let dotHighlight2Radius = size * 0.004
    let dotHighlight2Path = NSBezierPath(
      ovalIn: NSRect(
        x: center.x - dotHighlight2Radius + size * 0.003,
        y: center.y - dotHighlight2Radius + size * 0.003,
        width: dotHighlight2Radius * 2,
        height: dotHighlight2Radius * 2
      )
    )
    NSColor(white: 1.0, alpha: 0.7).setFill()
    dotHighlight2Path.fill()
  }

  private func drawTickMarks(center: CGPoint, radius: CGFloat, size: CGFloat) {
    let tickRadius = radius * 1.08
    let majorTickLength = size * 0.04
    let minorTickLength = size * 0.02

    for tickIndex in 0..<60 {
      let angle = CGFloat(tickIndex) * 6.0
      let angleInRadians = angle * .pi / 180
      let isMajor = tickIndex % 5 == 0

      let tickLength = isMajor ? majorTickLength : minorTickLength
      let startRadius = tickRadius - tickLength
      let endRadius = tickRadius

      let startX = center.x + startRadius * sin(angleInRadians)
      let startY = center.y - startRadius * cos(angleInRadians)
      let endX = center.x + endRadius * sin(angleInRadians)
      let endY = center.y - endRadius * cos(angleInRadians)

      let tickPath = NSBezierPath()
      tickPath.move(to: NSPoint(x: startX, y: startY))
      tickPath.line(to: NSPoint(x: endX, y: endY))
      tickPath.lineWidth = isMajor ? size * 0.015 : size * 0.008
      let tickColor: NSColor = isMajor ? .white : NSColor(white: 0.7, alpha: 1.0)
      tickColor.setStroke()
      tickPath.stroke()
    }
  }

  private func drawHandShadow(_ config: HandConfig, size: CGFloat) {
    let angleInRadians = config.angle * .pi / 180
    let handLength = config.length * config.radius

    // Primary drop shadow - strong
    let shadowOffset = size * 0.012
    let endX = config.center.x + handLength * sin(angleInRadians) + shadowOffset
    let endY = config.center.y - handLength * cos(angleInRadians) + shadowOffset

    let path = NSBezierPath()
    path.move(to: NSPoint(x: config.center.x + shadowOffset, y: config.center.y + shadowOffset))
    path.line(to: NSPoint(x: endX, y: endY))
    path.lineWidth = config.width + size * 0.01
    NSColor(white: 0.0, alpha: 0.9).setStroke()
    path.stroke()

    // Secondary shadow layer
    let shadowOffset2 = size * 0.006
    let endX2 = config.center.x + handLength * sin(angleInRadians) + shadowOffset2
    let endY2 = config.center.y - handLength * cos(angleInRadians) + shadowOffset2
    let path2 = NSBezierPath()
    path2.move(to: NSPoint(x: config.center.x + shadowOffset2, y: config.center.y + shadowOffset2))
    path2.line(to: NSPoint(x: endX2, y: endY2))
    path2.lineWidth = config.width
    NSColor(white: 0.0, alpha: 0.4).setStroke()
    path2.stroke()
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
