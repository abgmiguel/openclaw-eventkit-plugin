import EventKit
import XCTest
import OpenClawKit
@testable import OpenClawRuntime

final class GatewayConnectionControllerTests: XCTestCase {
    @MainActor
    func testCurrentCommandsIncludeCalendarAndReminderUpdates() {
        let controller = GatewayConnectionController()
        let commands = Set(controller._test_currentCommands())

        XCTAssertTrue(commands.contains(OpenClawCalendarCommand.update.rawValue))
        XCTAssertTrue(commands.contains(OpenClawRemindersCommand.update.rawValue))
        XCTAssertFalse(commands.contains("calendar.delete"))
        XCTAssertFalse(commands.contains("reminders.delete"))
    }

    @MainActor
    func testEventKitAuthorizationDoesNotReportReadUnderWriteOnly() {
        let permissions = GatewayConnectionController._test_eventKitPermissions(
            calendarStatus: .writeOnly,
            remindersStatus: .writeOnly)

        XCTAssertFalse(permissions.calendarRead)
        XCTAssertTrue(permissions.calendarWrite)
        XCTAssertFalse(permissions.remindersRead)
        XCTAssertTrue(permissions.remindersWrite)
    }
}
