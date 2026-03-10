import Foundation
import OpenClawKit

protocol CalendarServicing: Sendable {
    func events(params: OpenClawCalendarEventsParams) async throws -> OpenClawCalendarEventsPayload
    func add(params: OpenClawCalendarAddParams) async throws -> OpenClawCalendarAddPayload
    func update(params: OpenClawCalendarUpdateParams) async throws -> OpenClawCalendarUpdatePayload
}

protocol RemindersServicing: Sendable {
    func list(params: OpenClawRemindersListParams) async throws -> OpenClawRemindersListPayload
    func add(params: OpenClawRemindersAddParams) async throws -> OpenClawRemindersAddPayload
    func update(params: OpenClawRemindersUpdateParams) async throws -> OpenClawRemindersUpdatePayload
}
