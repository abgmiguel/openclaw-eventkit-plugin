import Foundation
import XCTest
@testable import OpenClawKit

final class EventKitCommandsCodableTests: XCTestCase {
    func testCalendarUpdateParamsRoundTripAlarmFields() throws {
        let params = OpenClawCalendarUpdateParams(
            identifier: "event-123",
            title: "Weekly sync",
            startISO: "2026-01-10T14:00:00Z",
            endISO: "2026-01-10T14:30:00Z",
            isAllDay: false,
            location: "Room 1",
            notes: "Bring docs",
            calendarId: "cal-1",
            calendarTitle: "Work",
            alarmOffsetsMinutes: [-10, -5],
            clearAllAlarms: false)

        let data = try JSONEncoder().encode(params)
        let decoded = try JSONDecoder().decode(OpenClawCalendarUpdateParams.self, from: data)
        XCTAssertEqual(decoded, params)
    }

    func testRemindersAddParamsRoundTripAlarmFields() throws {
        let params = OpenClawRemindersAddParams(
            title: "Pay rent",
            dueISO: "2026-02-01T09:00:00Z",
            notes: "Online",
            listId: "list-1",
            listName: "Home",
            alarmOffsetsMinutes: [-60],
            clearAllAlarms: true)

        let data = try JSONEncoder().encode(params)
        let decoded = try JSONDecoder().decode(OpenClawRemindersAddParams.self, from: data)
        XCTAssertEqual(decoded, params)
    }
}
