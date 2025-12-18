import XCTest
@testable import Ring_Clock

final class ScreenshotManagerTests: XCTestCase {

    func test_generateFilename_contains_ring_clock_prefix() {
        let filename = ScreenshotManager.generateFilename()
        XCTAssertTrue(filename.starts(with: "Ring Clock"))
    }

    func test_generateFilename_contains_png_extension() {
        let filename = ScreenshotManager.generateFilename()
        XCTAssertTrue(filename.hasSuffix(".png"))
    }

    func test_generateFilename_contains_timestamp() {
        let filename = ScreenshotManager.generateFilename()
        // Should contain date pattern YYYY-MM-DD
        let datePattern = #"\d{4}-\d{2}-\d{2}"#
        let regex = try! NSRegularExpression(pattern: datePattern)
        let range = NSRange(filename.startIndex..., in: filename)
        XCTAssertTrue(regex.firstMatch(in: filename, range: range) != nil)
    }

    func test_desktopPath_returns_valid_directory() {
        guard let desktopURL = ScreenshotManager.desktopPath() else {
            XCTFail("Desktop path should not be nil")
            return
        }

        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: desktopURL.path, isDirectory: &isDir)
        XCTAssertTrue(exists, "Desktop path should exist")
        XCTAssertTrue(isDir.boolValue, "Desktop should be a directory")
    }

    func test_getScreenshotPath_returns_valid_url() {
        guard let screenshotPath = ScreenshotManager.getScreenshotPath() else {
            XCTFail("Screenshot path should not be nil")
            return
        }

        // Check that the path contains Desktop directory
        XCTAssertTrue(screenshotPath.path.contains("Desktop"))
        // Check that filename ends with .png
        XCTAssertTrue(screenshotPath.lastPathComponent.hasSuffix(".png"))
    }

    func test_getScreenshotPath_returns_different_paths_for_different_calls() {
        let path1 = ScreenshotManager.getScreenshotPath()
        // Delay to ensure different timestamp (DateFormatter uses seconds precision)
        Thread.sleep(forTimeInterval: 1.01)
        let path2 = ScreenshotManager.getScreenshotPath()

        XCTAssertNotNil(path1)
        XCTAssertNotNil(path2)
        // Paths should differ due to timestamp
        XCTAssertNotEqual(path1?.lastPathComponent, path2?.lastPathComponent)
    }
}
