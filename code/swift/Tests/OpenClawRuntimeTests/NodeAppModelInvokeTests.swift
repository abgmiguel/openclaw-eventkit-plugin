import Foundation
import XCTest
import OpenClawKit
@testable import OpenClawRuntime

@MainActor
private final class MockCalendarService: CalendarServicing {
    var lastUpdateParams: OpenClawCalendarUpdateParams?

    func events(params _: OpenClawCalendarEventsParams) async throws -> OpenClawCalendarEventsPayload {
        OpenClawCalendarEventsPayload(events: [])
    }

    func add(params _: OpenClawCalendarAddParams) async throws -> OpenClawCalendarAddPayload {
        OpenClawCalendarAddPayload(event: OpenClawCalendarEventPayload(
            identifier: "evt-add",
            title: "Added",
            startISO: "2025-01-01T10:00:00Z",
            endISO: "2025-01-01T11:00:00Z",
            isAllDay: false))
    }

    func update(params: OpenClawCalendarUpdateParams) async throws -> OpenClawCalendarUpdatePayload {
        self.lastUpdateParams = params
        return OpenClawCalendarUpdatePayload(event: OpenClawCalendarEventPayload(
            identifier: params.identifier,
            title: params.title ?? "Updated",
            startISO: "2025-01-01T10:00:00Z",
            endISO: "2025-01-01T11:00:00Z",
            isAllDay: params.isAllDay ?? false,
            alarmOffsetsMinutes: params.alarmOffsetsMinutes))
    }
}

@MainActor
private final class MockRemindersService: RemindersServicing {
    var lastUpdateParams: OpenClawRemindersUpdateParams?

    func list(params _: OpenClawRemindersListParams) async throws -> OpenClawRemindersListPayload {
        OpenClawRemindersListPayload(reminders: [])
    }

    func add(params _: OpenClawRemindersAddParams) async throws -> OpenClawRemindersAddPayload {
        OpenClawRemindersAddPayload(reminder: OpenClawReminderPayload(
            identifier: "rem-add",
            title: "Added",
            dueISO: "2025-01-01T10:00:00Z",
            completed: false))
    }

    func update(params: OpenClawRemindersUpdateParams) async throws -> OpenClawRemindersUpdatePayload {
        self.lastUpdateParams = params
        return OpenClawRemindersUpdatePayload(reminder: OpenClawReminderPayload(
            identifier: params.identifier,
            title: params.title ?? "Updated",
            dueISO: params.dueISO,
            completed: params.completed ?? false,
            alarmOffsetsMinutes: params.alarmOffsetsMinutes))
    }
}

final class NodeAppModelInvokeTests: XCTestCase {
    @MainActor
    func testHandleInvokeCalendarUpdateRoutesToService() async throws {
        let calendarService = MockCalendarService()
        let remindersService = MockRemindersService()
        let appModel = NodeAppModel(
            calendarService: calendarService,
            remindersService: remindersService)
        let params = OpenClawCalendarUpdateParams(
            identifier: "event-123",
            title: "Updated title",
            alarmOffsetsMinutes: [-10])
        let paramsJSON = String(decoding: try JSONEncoder().encode(params), as: UTF8.self)
        let req = BridgeInvokeRequest(
            id: "cal-update",
            command: OpenClawCalendarCommand.update.rawValue,
            paramsJSON: paramsJSON)

        let res = await appModel._test_handleInvoke(req)
        XCTAssertTrue(res.ok)
        XCTAssertEqual(calendarService.lastUpdateParams?.identifier, "event-123")
        XCTAssertEqual(calendarService.lastUpdateParams?.alarmOffsetsMinutes, [-10])

        let payloadData = try XCTUnwrap(res.payloadJSON?.data(using: .utf8))
        let payload = try JSONDecoder().decode(OpenClawCalendarUpdatePayload.self, from: payloadData)
        XCTAssertEqual(payload.event.identifier, "event-123")
    }

    @MainActor
    func testHandleInvokeRemindersUpdateRoutesToService() async throws {
        let calendarService = MockCalendarService()
        let remindersService = MockRemindersService()
        let appModel = NodeAppModel(
            calendarService: calendarService,
            remindersService: remindersService)
        let params = OpenClawRemindersUpdateParams(
            identifier: "rem-123",
            title: "Updated reminder",
            completed: true,
            alarmOffsetsMinutes: [-5])
        let paramsJSON = String(decoding: try JSONEncoder().encode(params), as: UTF8.self)
        let req = BridgeInvokeRequest(
            id: "rem-update",
            command: OpenClawRemindersCommand.update.rawValue,
            paramsJSON: paramsJSON)

        let res = await appModel._test_handleInvoke(req)
        XCTAssertTrue(res.ok)
        XCTAssertEqual(remindersService.lastUpdateParams?.identifier, "rem-123")
        XCTAssertEqual(remindersService.lastUpdateParams?.completed, true)
        XCTAssertEqual(remindersService.lastUpdateParams?.alarmOffsetsMinutes, [-5])

        let payloadData = try XCTUnwrap(res.payloadJSON?.data(using: .utf8))
        let payload = try JSONDecoder().decode(OpenClawRemindersUpdatePayload.self, from: payloadData)
        XCTAssertEqual(payload.reminder.identifier, "rem-123")
    }
}
