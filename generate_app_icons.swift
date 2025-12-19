#!/usr/bin/env swift

import Foundation
#if os(macOS)
import AppKit
#endif

/// Generates app icons for Ring Clock from an SVG template
/// Creates all required macOS app icon sizes

func generateIcons() {
    let assetPath = "Ring Clock/Assets.xcassets/AppIcon.appiconset"
    
    // Create the directory if it doesn't exist
    try? FileManager.default.createDirectory(atPath: assetPath, withIntermediateDirectories: true)
    
    // Define all required sizes for macOS app icons
    // Format: (logical_size, scale, filename) where pixel_size = logical_size * scale
    let sizes: [(logicalSize: Int, scale: Int, pixelSize: Int, filename: String)] = [
        (16, 1, 16, "icon_16x16.png"),
        (16, 2, 32, "icon_16x16@2x.png"),
        (32, 1, 32, "icon_32x32.png"),
        (32, 2, 64, "icon_32x32@2x.png"),
        (128, 1, 128, "icon_128x128.png"),
        (128, 2, 256, "icon_128x128@2x.png"),
        (256, 1, 256, "icon_256x256.png"),
        (256, 2, 512, "icon_256x256@2x.png"),
        (512, 1, 512, "icon_512x512.png"),
        (512, 2, 1024, "icon_512x512@2x.png"),
    ]
    
    #if os(macOS)
    // Generate each icon size
    for (logicalSize, scale, pixelSize, filename) in sizes {
        if let pngData = createClockIconPNG(size: pixelSize) {
            let filePath = "\(assetPath)/\(filename)"
            try? pngData.write(to: URL(fileURLWithPath: filePath))
            print("✅ Generated: \(filename) (\(pixelSize)x\(pixelSize)px)")
        }
    }
    
    // Update Contents.json
    updateContentsJson(assetPath: assetPath, sizes: sizes)
    print("✅ Updated Contents.json")
    #else
    print("❌ This script must be run on macOS")
    #endif
}

#if os(macOS)
func createClockIconPNG(size: Int) -> Data? {
    // Create a bitmap representation of the desired size
    guard let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                          pixelsWide: size,
                                          pixelsHigh: size,
                                          bitsPerSample: 8,
                                          samplesPerPixel: 4,
                                          hasAlpha: true,
                                          isPlanar: false,
                                          colorSpaceName: .calibratedRGB,
                                          bytesPerRow: size * 4,
                                          bitsPerPixel: 32) else {
        return nil
    }
    
    // Create an NSGraphicsContext for drawing
    let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep)
    NSGraphicsContext.current = graphicsContext
    
    // Get current time
    let now = Date()
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: now)
    let hour = CGFloat(components.hour ?? 0)
    let minute = CGFloat(components.minute ?? 0)
    
    // Calculate angles (0 degrees is at 12 o'clock, positive is clockwise)
    // Minute hand: 360 / 60 = 6 degrees per minute
    let minuteAngle = minute * 6.0
    // Hour hand: 360 / 12 = 30 degrees per hour, plus movement based on minutes
    let hourAngle = (hour.truncatingRemainder(dividingBy: 12) * 30.0) + (minute * 0.5)
    
    let cgSize = CGFloat(size)
    let center = CGPoint(x: cgSize / 2.0, y: cgSize / 2.0 + cgSize * 0.05)
    let radius = cgSize * 0.35
    
    // Transparent background (already transparent from NSBitmapImageRep initialization)
    
    // Clock ring
    let ringPath = NSBezierPath()
    ringPath.appendArc(withCenter: center,
                       radius: radius,
                       startAngle: 0,
                       endAngle: 360)
    ringPath.lineWidth = cgSize * 0.025
    NSColor.black.setStroke()
    ringPath.stroke()
    
    // Hour markers (12, 3, 6, 9)
    let markerPositions = [(angle: 0.0, length: 0.15),
                           (angle: 90.0, length: 0.15),
                           (angle: 180.0, length: 0.15),
                           (angle: 270.0, length: 0.15)]
    
    for (angle, length) in markerPositions {
        drawMarker(center: center, radius: radius, angle: angle,
                  length: length, width: cgSize * 0.01)
    }
    
    // Minute markers
    for i in 0..<60 {
        if i % 5 != 0 {
            let angle = CGFloat(i) * 6.0
            drawMarker(center: center, radius: radius, angle: angle,
                      length: 0.08, width: cgSize * 0.005)
        }
    }
    
    // Hour hand (shorter, thicker)
    drawHand(center: center, radius: radius, angle: hourAngle, length: 0.35,
            width: cgSize * 0.015, color: .black)
    
    // Minute hand (longer, thinner)
    drawHand(center: center, radius: radius, angle: minuteAngle, length: 0.45,
            width: cgSize * 0.01, color: .black)
    
    // Center dot
    let dotRadius = cgSize * 0.03
    let dotPath = NSBezierPath(ovalIn: NSRect(x: center.x - dotRadius,
                                               y: center.y - dotRadius,
                                               width: dotRadius * 2,
                                               height: dotRadius * 2))
    NSColor.black.setFill()
    dotPath.fill()
    
    NSGraphicsContext.current = nil
    
    return bitmapRep.representation(using: .png, properties: [:])
}

func drawMarker(center: CGPoint, radius: CGFloat, angle: CGFloat,
               length: CGFloat, width: CGFloat) {
    let angleInRadians = angle * .pi / 180
    let outerRadius = radius
    let innerRadius = radius - (length * radius)
    
    let startX = center.x + innerRadius * sin(angleInRadians)
    let startY = center.y + innerRadius * cos(angleInRadians)
    let endX = center.x + outerRadius * sin(angleInRadians)
    let endY = center.y + outerRadius * cos(angleInRadians)
    
    let path = NSBezierPath()
    path.move(to: NSPoint(x: startX, y: startY))
    path.line(to: NSPoint(x: endX, y: endY))
    path.lineWidth = width
    NSColor.black.setStroke()
    path.stroke()
}

func drawHand(center: CGPoint, radius: CGFloat, angle: CGFloat,
             length: CGFloat, width: CGFloat, color: NSColor) {
    let angleInRadians = angle * .pi / 180
    let handLength = length * radius
    
    let endX = center.x + handLength * sin(angleInRadians)
    let endY = center.y + handLength * cos(angleInRadians)
    
    let path = NSBezierPath()
    path.move(to: NSPoint(x: center.x, y: center.y))
    path.line(to: NSPoint(x: endX, y: endY))
    path.lineWidth = width
    color.setStroke()
    path.stroke()
}

func updateContentsJson(assetPath: String, sizes: [(logicalSize: Int, scale: Int, pixelSize: Int, filename: String)]) {
    let contentsDict: [String: Any] = [
        "images": sizes.map { logicalSize, scale, pixelSize, filename in
            let sizeStr = "\(logicalSize)x\(logicalSize)"
            return [
                "idiom": "mac",
                "scale": "\(scale)x",
                "size": sizeStr,
                "filename": filename
            ]
        },
        "info": [
            "author": "xcode",
            "version": 1
        ]
    ]
    
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: contentsDict, options: [.prettyPrinted, .sortedKeys])
        let jsonPath = "\(assetPath)/Contents.json"
        try jsonData.write(to: URL(fileURLWithPath: jsonPath))
    } catch {
        print("❌ Error updating Contents.json: \(error)")
    }
}
#endif

// Run the generation
generateIcons()
