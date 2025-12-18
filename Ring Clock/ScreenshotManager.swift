import AppKit
import Foundation

class ScreenshotManager {
    /// Get the Desktop directory path
    static func desktopPath() -> URL? {
        FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
    }

    /// Generate a screenshot filename with timestamp
    static func generateFilename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let timestamp = formatter.string(from: Date())
        return "Ring Clock \(timestamp).png"
    }

    /// Get the full path for the screenshot file
    static func getScreenshotPath() -> URL? {
        guard let desktopURL = desktopPath() else { return nil }
        return desktopURL.appendingPathComponent(generateFilename())
    }

    /// Capture the main window and save to Desktop
    static func captureWindow() -> Bool {
        guard let mainWindow = NSApp.mainWindow else {
            print("❌ No main window found")
            return false
        }

        guard let screenshotPath = getScreenshotPath() else {
            print("❌ Could not determine screenshot path")
            return false
        }

        // Create image from window content view
        guard let windowImage = createImage(from: mainWindow) else {
            print("❌ Could not capture window content")
            return false
        }

        guard let pngData = windowImage.tiffRepresentation else {
            print("❌ Could not convert to TIFF")
            return false
        }

        guard let bitmapImage = NSBitmapImageRep(data: pngData),
              let imageData = bitmapImage.representation(using: .png, properties: [:]) else {
            print("❌ Could not convert to PNG")
            return false
        }

        do {
            try imageData.write(to: screenshotPath)
            print("✅ Screenshot saved to: \(screenshotPath.path)")
            return true
        } catch {
            print("❌ Failed to save screenshot: \(error.localizedDescription)")
            return false
        }
    }

    /// Create NSImage from window content view
    private static func createImage(from window: NSWindow) -> NSImage? {
        guard let contentView = window.contentView else { return nil }

        // Create a bitmap image representation from the view
        let frame = contentView.bounds
        let image = NSImage(size: frame.size)

        image.lockFocus()
        defer { image.unlockFocus() }

        // Draw the view into the image
        contentView.draw(frame)

        // Render the view layer if available
        if contentView.layer != nil {
            CATransaction.begin()
            CATransaction.commit()
        }

        return image
    }
}
