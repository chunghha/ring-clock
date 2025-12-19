import XCTest
@testable import Ring_Clock

class RotationResetTests: XCTestCase {
    var clockManager: ClockManager!

    override func setUp() {
        super.setUp()
        clockManager = ClockManager()
    }

    override func tearDown() {
        clockManager = nil
        super.tearDown()
    }

    func test_initial_rotations_are_zero() {
        // Verify initial state: all rotations should be zero
        XCTAssertEqual(clockManager.rotationX, 0, "Initial rotationX should be 0")
        XCTAssertEqual(clockManager.rotationY, 0, "Initial rotationY should be 0")
        XCTAssertEqual(clockManager.rotationZ, 0, "Initial rotationZ should be 0")
    }

    func test_rotation_values_should_not_accumulate_indefinitely() {
        // After many minute updates (even with animations), 
        // rotation values should remain bounded and eventually return to zero
        // This test verifies the fix works correctly
        
        var rotationXValues: [Double] = []
        var rotationYValues: [Double] = []
        var rotationZValues: [Double] = []
        
        // Capture rotation values multiple times
        for _ in 0..<10 {
            clockManager.updateTime()
            rotationXValues.append(clockManager.rotationX)
            rotationYValues.append(clockManager.rotationY)
            rotationZValues.append(clockManager.rotationZ)
            
            // Small delay between updates
            usleep(100000) // 0.1 seconds
        }
        
        // Wait for animations to complete
        let expectation = XCTestExpectation(description: "Wait for animations to complete")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // After animation completes, should be back at zero
        XCTAssertEqual(
            clockManager.rotationX, 0,
            "After animations, rotationX should be 0, got \(clockManager.rotationX)"
        )
        XCTAssertEqual(
            clockManager.rotationY, 0,
            "After animations, rotationY should be 0, got \(clockManager.rotationY)"
        )
        XCTAssertEqual(
            clockManager.rotationZ, 0,
            "After animations, rotationZ should be 0, got \(clockManager.rotationZ)"
        )
    }
}
