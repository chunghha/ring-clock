//
//  TransparentWindowView.swift
//  Ring Clock
//
//  Created by Chris Ha on 12/18/25.
//

import SwiftUI
import UserNotifications

// Helper to make the window transparent and handle mouse events
struct TransparentWindowView<Content: View>: NSViewRepresentable {
  let content: Content
  var onScreenshotRequest: (() -> Void)?

  init(@ViewBuilder content: () -> Content, onScreenshotRequest: (() -> Void)? = nil) {
    self.content = content()
    self.onScreenshotRequest = onScreenshotRequest
  }

  func makeNSView(context: Context) -> NSHostingView<Content> {
    let hostingView = TransparentHostingView(rootView: content)
    hostingView.onScreenshotRequest = onScreenshotRequest
    return hostingView
  }

  func updateNSView(_ nsView: NSHostingView<Content>, context: Context) {
    nsView.rootView = content
    if let transparentView = nsView as? TransparentHostingView<Content> {
      transparentView.onScreenshotRequest = onScreenshotRequest
    }
  }
}

// Custom NSHostingView to handle Cmd+click gestures and contain SwiftUI content
class TransparentHostingView<Content: View>: NSHostingView<Content> {
  var onScreenshotRequest: (() -> Void)?

  private let screenshotNotification = Notification.Name("RequestScreenshot")

  required init(rootView: Content) {
    super.init(rootView: rootView)
    setupNotificationObserver()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupNotificationObserver()
  }

  private func setupNotificationObserver() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleScreenshotRequest),
      name: screenshotNotification,
      object: nil
    )
  }

  @objc private func handleScreenshotRequest() {
    print("📸 Received screenshot notification from SwiftUI")
    takeScreenshot()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    // Ensure this view can receive mouse events
    self.window?.makeFirstResponder(self)

    DispatchQueue.main.async {
      if let window = self.window {
        window.isOpaque = false
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.hasShadow = false
        // This makes it float above desktop but below windows and stick to wallpaper
        window.level = NSWindow.Level(rawValue: -1000)
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        window.isReleasedWhenClosed = false

        // Position the window after a short delay to ensure proper sizing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            // Use a fixed size based on our content (500x500 approximately)
            let windowSize = NSSize(width: 500, height: 500)
            let newOrigin = NSPoint(
              x: screenFrame.maxX - windowSize.width - 20, y: screenFrame.maxY - windowSize.height)
            window.setFrame(NSRect(origin: newOrigin, size: windowSize), display: true)
          }
        }
      }
    }
  }

  override var acceptsFirstResponder: Bool {
    return true
  }

  override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
    return true
  }

  func requestScreenshot() {
    print("📸 Screenshot requested from SwiftUI")
    takeScreenshot()
  }

  override func mouseDown(with event: NSEvent) {
    print("Mouse down event received, modifier flags: \(event.modifierFlags)")

    // Check if Cmd key is held down
    if event.modifierFlags.contains(.command) {
      print("✅ Cmd+click detected - taking screenshot")
      takeScreenshot()
      return
    }

    print("Passing through mouse event (no Cmd key)")
    // Pass through other mouse events
    super.mouseDown(with: event)
  }

  func takeScreenshot() {
    print("🎯 takeScreenshot() called")

    guard let window = self.window,
      let contentView = window.contentView
    else {
      print("❌ Screenshot failed - window or content view not available")
      return
    }

    print("✅ Taking screenshot of clock window...")

    // Get the content view bounds
    let bounds = contentView.bounds
    print("📐 Content view bounds: \(bounds)")

    // Create image context and render the view
    let image = NSImage(size: bounds.size)
    print("🖼️ Created NSImage with size: \(bounds.size)")

    image.lockFocus()

    // Create graphics context for rendering
    guard let context = NSGraphicsContext.current else {
      print("❌ Failed to get graphics context")
      image.unlockFocus()
      return
    }

    // Save current graphics state
    context.saveGraphicsState()

    // Render the view content
    print("🎨 Rendering view content...")
    contentView.draw(bounds)

    // Restore graphics state
    context.restoreGraphicsState()

    image.unlockFocus()
    print("✅ Image rendering completed")

    saveImageToDesktop(image, filenamePrefix: "Ring_Clock_CmdClick")
  }

  private func saveImageToDesktop(_ image: NSImage, filenamePrefix: String) {
    print("💾 Attempting to save image to desktop...")

    // Save to desktop with timestamp
    let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
    print("📁 Desktop URL: \(desktopURL?.path ?? "nil")")

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let timestamp = dateFormatter.string(from: Date())
    let filename = "\(filenamePrefix)_\(timestamp).png"
    let fileURL = desktopURL?.appendingPathComponent(filename)

    print("📄 Target file URL: \(fileURL?.path ?? "nil")")

    guard let fileURL = fileURL,
      let tiffData = image.tiffRepresentation,
      let bitmapImage = NSBitmapImageRep(data: tiffData),
      let pngData = bitmapImage.representation(using: .png, properties: [:])
    else {
      print("❌ Failed to prepare PNG data")
      return
    }

    print("📊 PNG data size: \(pngData.count) bytes")

    do {
      try pngData.write(to: fileURL)
      print("✅ Screenshot saved to: \(fileURL.path)")

      // Show a notification that screenshot was saved
      let content = UNMutableNotificationContent()
      content.title = "Screenshot Saved"
      content.body = "Saved to Desktop as \(filename)"
      content.sound = .default

      print("🔔 Sending notification...")
      let request = UNNotificationRequest(
        identifier: UUID().uuidString, content: content, trigger: nil)
      UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
          print("❌ Error showing notification: \(error)")
        } else {
          print("✅ Notification sent successfully")
        }
      }
    } catch {
      print("❌ Error saving screenshot: \(error)")
    }
  }
}
