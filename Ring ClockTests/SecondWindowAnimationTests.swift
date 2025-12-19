import XCTest
@testable import Ring_Clock

class SecondWindowAnimationTests: XCTestCase {
    var clockManager: ClockManager!

    override func setUp() {
        super.setUp()
        clockManager = ClockManager()
    }

    override func tearDown() {
        clockManager = nil
        super.tearDown()
    }

    func test_should_detect_animation_window_at_59_seconds() {
        // Test that the animation window is detected starting at 59 seconds
        XCTAssertTrue(
            clockManager.isInAnimationWindow(second: 59),
            "Animation window should be active at 59 seconds"
        )
    }

    func test_should_detect_animation_window_at_59_point_5_seconds() {
        // Test that the animation window is detected at 59.5 seconds
        XCTAssertTrue(
            clockManager.isInAnimationWindow(second: 59.5),
            "Animation window should be active at 59.5 seconds"
        )
    }

    func test_should_detect_animation_window_at_59_point_9_seconds() {
        // Test that the animation window is detected near the end
        XCTAssertTrue(
            clockManager.isInAnimationWindow(second: 59.9),
            "Animation window should be active at 59.9 seconds"
        )
    }

    func test_should_not_be_in_animation_window_at_58_seconds() {
        // Test that the animation window is NOT active before 59 seconds
        XCTAssertFalse(
            clockManager.isInAnimationWindow(second: 58.0),
            "Animation window should not be active at 58 seconds"
        )
    }

    func test_should_not_be_in_animation_window_at_30_seconds() {
        // Test that the animation window is NOT active in the middle of minute
        XCTAssertFalse(
            clockManager.isInAnimationWindow(second: 30.0),
            "Animation window should not be active at 30 seconds"
        )
    }

    func test_should_not_be_in_animation_window_at_0_seconds() {
        // Test that the animation window is NOT active at the start
        XCTAssertFalse(
            clockManager.isInAnimationWindow(second: 0.0),
            "Animation window should not be active at 0 seconds"
        )
    }

    func test_animation_window_boundaries() {
        // Test the exact boundary conditions of the animation window
        // At 58.99 seconds, should still be outside window
        XCTAssertFalse(
            clockManager.isInAnimationWindow(second: 58.99),
            "Animation window should not be active at 58.99 seconds"
        )
        
        // At 59.0 seconds, should be inside window
        XCTAssertTrue(
            clockManager.isInAnimationWindow(second: 59.0),
            "Animation window should be active at 59.0 seconds"
        )
        
        // At 59.999 seconds, should still be inside window
        XCTAssertTrue(
            clockManager.isInAnimationWindow(second: 59.999),
            "Animation window should be active at 59.999 seconds"
        )
    }
}
