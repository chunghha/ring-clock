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
        guard let bitmapRep = NSBitmapImageRep(
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
        ) else {
            return nil
        }
        
        let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep)
        NSGraphicsContext.current = graphicsContext
        
        // Fill background with rounded square (macOS style) with padding
        let cgSize = CGFloat(size)
        let padding = cgSize * 0.1
        let bgColor = NSColor(white: 0.20, alpha: 1.0)
        bgColor.setFill()
        let cornerRadius = cgSize * 0.15
        let bgRect = NSRect(x: padding, y: padding, width: cgSize - padding * 2, height: cgSize - padding * 2)
        let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)
        bgPath.fill()
        
        // Colors: white elements on black background
        let ringColor: NSColor = .white
        let hourColor: NSColor = .white
        let minuteColor: NSColor = .systemRed
        let dotColor: NSColor = .white
        
        // Get current time
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let hour = CGFloat(components.hour ?? 0)
        let minute = CGFloat(components.minute ?? 0)
        
        // Calculate angles (0 degrees at 12 o'clock, positive clockwise)
        let minuteAngle = minute * 6.0
        let hourAngle = (hour.truncatingRemainder(dividingBy: 12) * 30.0) + (minute * 0.5)
        
        let center = CGPoint(x: cgSize / 2.0, y: cgSize / 2.0)
        let radius = cgSize * 0.32
        
        // Clock ring
        let ringPath = NSBezierPath()
        ringPath.appendArc(withCenter: center, radius: radius, startAngle: 0, endAngle: 360)
        ringPath.lineWidth = cgSize * 0.035
        ringColor.setStroke()
        ringPath.stroke()
        
        // Hour hand (shorter, thicker)
        drawHand(
            center: center,
            radius: radius,
            angle: hourAngle,
            length: 0.4,
            width: cgSize * 0.065,
            color: hourColor
        )
        
        // Minute hand (longer, thicker) - Always red
        drawHand(
            center: center,
            radius: radius,
            angle: minuteAngle,
            length: 0.5,
            width: cgSize * 0.08,
            color: minuteColor
        )
        
        // Center dot
        let dotRadius = cgSize * 0.025
        let dotPath = NSBezierPath(
            ovalIn: NSRect(
                x: center.x - dotRadius,
                y: center.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            )
        )
        dotColor.setFill()
        dotPath.fill()
        
        NSGraphicsContext.current = nil
        
        let image = NSImage(size: NSSize(width: size, height: size))
        image.addRepresentation(bitmapRep)
        return image
    }
    
    private func drawHand(
        center: CGPoint,
        radius: CGFloat,
        angle: CGFloat,
        length: CGFloat,
        width: CGFloat,
        color: NSColor
    ) {
        let angleInRadians = angle * .pi / 180
        let handLength = length * radius
        
        let endX = center.x + handLength * sin(angleInRadians)
        let endY = center.y - handLength * cos(angleInRadians)
        
        let path = NSBezierPath()
        path.move(to: NSPoint(x: center.x, y: center.y))
        path.line(to: NSPoint(x: endX, y: endY))
        path.lineWidth = width
        color.setStroke()
        path.stroke()
    }
}
