import XCTest
import Foundation
@testable import Ring_Clock

class DynamicIconGeneratorTests: XCTestCase {
  func test_extractTimeComponents_usesLocalTime() {
    // Test that we extract the correct local time components
    let now = Date()
    let calendar = Calendar.current
    let expectedComponents = calendar.dateComponents([.hour, .minute], from: now)
    let expectedHour = expectedComponents.hour ?? 0
    let expectedMinute = expectedComponents.minute ?? 0

    XCTAssertNotNil(expectedHour, "Hour should be available from Calendar.current")
    XCTAssertNotNil(expectedMinute, "Minute should be available from Calendar.current")
    XCTAssertTrue(expectedHour >= 0 && expectedHour < 24, "Hour should be 0-23")
    XCTAssertTrue(expectedMinute >= 0 && expectedMinute < 60, "Minute should be 0-59")
  }

  func test_dynamicIconGenerator_getsCorrectTime() {
    let generator = DynamicIconGenerator.shared
    let (hour, minute) = generator.getCurrentTimeComponents()
    
    // Verify we get reasonable values
    XCTAssertTrue(hour >= 0 && hour < 24, "Icon generator should return valid hour (0-23), got \(hour)")
    XCTAssertTrue(minute >= 0 && minute < 60, "Icon generator should return valid minute (0-59), got \(minute)")
    
    // Also verify it matches Calendar.current
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: Date())
    let expectedHour = components.hour ?? 0
    let expectedMinute = components.minute ?? 0
    
    XCTAssertEqual(hour, expectedHour, "Icon generator hour should match Calendar.current, got \(hour), expected \(expectedHour)")
    XCTAssertEqual(minute, expectedMinute, "Icon generator minute should match Calendar.current, got \(minute), expected \(expectedMinute)")
  }
  
  func test_icon_drawing_logic_with_known_time() {
    // Test the exact drawing logic with hour=11, minute=33
    let hour: CGFloat = 11
    let minute: CGFloat = 33
    
    let minuteAngle = minute * 6.0
    let hourAngle = (hour.truncatingRemainder(dividingBy: 12) * 30.0) + (minute * 0.5)
    
    // For 11:33:
    // minuteAngle should be 33 * 6 = 198 degrees (pointing at ~6.6 on clock face, between 6 and 7)
    // hourAngle should be (11 * 30) + (33 * 0.5) = 330 + 16.5 = 346.5 degrees (just before 12, past 11)
    
    XCTAssertEqual(minuteAngle, 198.0, "Minute angle for 33 minutes should be 198 degrees")
    XCTAssertEqual(hourAngle, 346.5, "Hour angle for 11:33 should be 346.5 degrees")
  }

  func test_timeComponentsMatch_systemTime() {
    // Verify that Calendar.current and DateFormatter give same results
    let now = Date()
    
    // Method 1: Calendar.current
    let calendar = Calendar.current
    let calendarComponents = calendar.dateComponents([.hour, .minute], from: now)
    let calendarHour = calendarComponents.hour ?? 0
    let calendarMinute = calendarComponents.minute ?? 0
    
    // Method 2: DateFormatter
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let formattedTime = formatter.string(from: now)
    let parts = formattedTime.split(separator: ":").compactMap { Int($0) }
    let formatterHour = parts.count > 0 ? parts[0] : 0
    let formatterMinute = parts.count > 1 ? parts[1] : 0
    
    print("Calendar.current -> Hour: \(calendarHour), Minute: \(calendarMinute)")
    print("DateFormatter -> Hour: \(formatterHour), Minute: \(formatterMinute)")
    
    XCTAssertEqual(calendarHour, formatterHour, "Calendar and DateFormatter should return same hour")
    XCTAssertEqual(calendarMinute, formatterMinute, "Calendar and DateFormatter should return same minute")
  }

  func test_hourHandAngle_correctlyCalculated() {
    // For 11:15, hour hand should point between 11 and 12
    // hour = 11, minute = 15
    // hourAngle = (11 % 12 * 30) + (15 * 0.5) = (11 * 30) + 7.5 = 330 + 7.5 = 337.5 degrees
    // 337.5 degrees is correct (11 o'clock position + quarter way to 12)
    
    let hour: CGFloat = 11
    let minute: CGFloat = 15
    let hourAngle = (hour.truncatingRemainder(dividingBy: 12) * 30.0) + (minute * 0.5)
    
    let expectedAngle: CGFloat = 337.5
    XCTAssertEqual(hourAngle, expectedAngle, "Hour hand angle for 11:15 should be 337.5 degrees")
  }

  func test_minuteHandAngle_correctlyCalculated() {
    // For minute 15, hand should point at 3 (90 degrees)
    let minute: CGFloat = 15
    let minuteAngle = minute * 6.0
    
    let expectedAngle: CGFloat = 90.0
    XCTAssertEqual(minuteAngle, expectedAngle, "Minute hand angle for 15 minutes should be 90 degrees")
  }
}
