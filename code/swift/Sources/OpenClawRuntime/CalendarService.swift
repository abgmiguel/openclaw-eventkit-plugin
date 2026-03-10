import EventKit
import Foundation
import OpenClawKit

final class CalendarService: CalendarServicing {
    func events(params: OpenClawCalendarEventsParams) async throws -> OpenClawCalendarEventsPayload {
        let store = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        let authorized = EventKitAuthorization.allowsRead(status: status)
        guard authorized else {
            throw NSError(domain: "Calendar", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_PERMISSION_REQUIRED: grant Calendar permission",
            ])
        }

        let (start, end) = Self.resolveRange(
            startISO: params.startISO,
            endISO: params.endISO)
        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate)
        let limit = max(1, min(params.limit ?? 50, 500))
        let selected = Array(events.prefix(limit))

        let formatter = ISO8601DateFormatter()
        let payload = selected.map { event in Self.payload(from: event, formatter: formatter) }

        return OpenClawCalendarEventsPayload(events: payload)
    }

    func add(params: OpenClawCalendarAddParams) async throws -> OpenClawCalendarAddPayload {
        let store = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        let authorized = EventKitAuthorization.allowsWrite(status: status)
        guard authorized else {
            throw NSError(domain: "Calendar", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_PERMISSION_REQUIRED: grant Calendar permission",
            ])
        }

        let title = params.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw NSError(domain: "Calendar", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_INVALID: title required",
            ])
        }

        let start = try Self.parseRequiredDate(
            params.startISO,
            code: 4,
            message: "CALENDAR_INVALID: startISO required")
        let end = try Self.parseRequiredDate(
            params.endISO,
            code: 5,
            message: "CALENDAR_INVALID: endISO required")

        let event = EKEvent(eventStore: store)
        event.title = title
        event.startDate = start
        event.endDate = end
        event.isAllDay = params.isAllDay ?? false
        event.location = Self.normalizeOptionalText(params.location)
        event.notes = Self.normalizeOptionalText(params.notes)
        event.calendar = try Self.resolveCalendar(
            store: store,
            calendarId: params.calendarId,
            calendarTitle: params.calendarTitle)
        Self.applyAlarmPatch(
            item: event,
            alarmOffsetsMinutes: params.alarmOffsetsMinutes,
            clearAllAlarms: params.clearAllAlarms)

        try store.save(event, span: .thisEvent)

        let formatter = ISO8601DateFormatter()
        let payload = Self.payload(from: event, formatter: formatter, fallbackTitle: title)
        return OpenClawCalendarAddPayload(event: payload)
    }

    func update(params: OpenClawCalendarUpdateParams) async throws -> OpenClawCalendarUpdatePayload {
        let store = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .event)
        let authorized = EventKitAuthorization.allowsWrite(status: status)
        guard authorized else {
            throw NSError(domain: "Calendar", code: 8, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_PERMISSION_REQUIRED: grant Calendar permission",
            ])
        }

        let identifier = params.identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty else {
            throw NSError(domain: "Calendar", code: 9, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_INVALID: identifier required",
            ])
        }
        guard let event = store.event(withIdentifier: identifier) else {
            throw NSError(domain: "Calendar", code: 10, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_NOT_FOUND: no event for identifier \(identifier)",
            ])
        }

        if let title = params.title {
            let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normalized.isEmpty else {
                throw NSError(domain: "Calendar", code: 11, userInfo: [
                    NSLocalizedDescriptionKey: "CALENDAR_INVALID: title cannot be empty",
                ])
            }
            event.title = normalized
        }
        if let startISO = params.startISO {
            event.startDate = try Self.parseDate(
                startISO,
                code: 12,
                message: "CALENDAR_INVALID: startISO must be ISO-8601")
        }
        if let endISO = params.endISO {
            event.endDate = try Self.parseDate(
                endISO,
                code: 13,
                message: "CALENDAR_INVALID: endISO must be ISO-8601")
        }
        if let isAllDay = params.isAllDay {
            event.isAllDay = isAllDay
        }
        if let location = params.location {
            event.location = Self.normalizeOptionalText(location)
        }
        if let notes = params.notes {
            event.notes = Self.normalizeOptionalText(notes)
        }

        if params.calendarId != nil || params.calendarTitle != nil {
            event.calendar = try Self.resolveCalendar(
                store: store,
                calendarId: params.calendarId,
                calendarTitle: params.calendarTitle)
        }

        Self.applyAlarmPatch(
            item: event,
            alarmOffsetsMinutes: params.alarmOffsetsMinutes,
            clearAllAlarms: params.clearAllAlarms)
        try store.save(event, span: .thisEvent)

        let formatter = ISO8601DateFormatter()
        let payload = Self.payload(from: event, formatter: formatter)
        return OpenClawCalendarUpdatePayload(event: payload)
    }

    private static func resolveCalendar(
        store: EKEventStore,
        calendarId: String?,
        calendarTitle: String?) throws -> EKCalendar
    {
        if let id = calendarId?.trimmingCharacters(in: .whitespacesAndNewlines), !id.isEmpty,
           let calendar = store.calendar(withIdentifier: id)
        {
            return calendar
        }

        if let title = calendarTitle?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty {
            if let calendar = store.calendars(for: .event).first(where: {
                $0.title.compare(title, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            }) {
                return calendar
            }
            throw NSError(domain: "Calendar", code: 6, userInfo: [
                NSLocalizedDescriptionKey: "CALENDAR_NOT_FOUND: no calendar named \(title)",
            ])
        }

        if let fallback = store.defaultCalendarForNewEvents {
            return fallback
        }

        throw NSError(domain: "Calendar", code: 7, userInfo: [
            NSLocalizedDescriptionKey: "CALENDAR_NOT_FOUND: no default calendar",
        ])
    }

    private static func resolveRange(startISO: String?, endISO: String?) -> (Date, Date) {
        let formatter = ISO8601DateFormatter()
        let start = startISO.flatMap { formatter.date(from: $0) } ?? Date()
        let end = endISO.flatMap { formatter.date(from: $0) } ?? start.addingTimeInterval(7 * 24 * 3600)
        return (start, end)
    }

    private static func payload(
        from event: EKEvent,
        formatter: ISO8601DateFormatter,
        fallbackTitle: String = "(untitled)") -> OpenClawCalendarEventPayload
    {
        OpenClawCalendarEventPayload(
            identifier: event.eventIdentifier ?? UUID().uuidString,
            title: event.title ?? fallbackTitle,
            startISO: formatter.string(from: event.startDate),
            endISO: formatter.string(from: event.endDate),
            isAllDay: event.isAllDay,
            location: event.location,
            calendarTitle: event.calendar.title,
            alarmOffsetsMinutes: Self.relativeAlarmOffsets(from: event.alarms))
    }

    private static func normalizeOptionalText(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func parseRequiredDate(_ raw: String, code: Int, message: String) throws -> Date {
        try self.parseDate(raw, code: code, message: message)
    }

    private static func parseDate(_ raw: String, code: Int, message: String) throws -> Date {
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: value) else {
            throw NSError(domain: "Calendar", code: code, userInfo: [
                NSLocalizedDescriptionKey: message,
            ])
        }
        return date
    }

    private static func applyAlarmPatch(
        item: EKCalendarItem,
        alarmOffsetsMinutes: [Int]?,
        clearAllAlarms: Bool?)
    {
        if clearAllAlarms == true {
            item.alarms = []
            return
        }
        guard let alarmOffsetsMinutes else { return }
        let normalized = Self.normalizeAlarmOffsets(alarmOffsetsMinutes)
        item.alarms = normalized.map { EKAlarm(relativeOffset: TimeInterval($0 * 60)) }
    }

    private static func normalizeAlarmOffsets(_ alarmOffsetsMinutes: [Int]) -> [Int] {
        Array(Set(alarmOffsetsMinutes)).sorted()
    }

    private static func relativeAlarmOffsets(from alarms: [EKAlarm]?) -> [Int]? {
        let offsets = (alarms ?? [])
            .compactMap { alarm -> Int? in
                guard alarm.absoluteDate == nil else { return nil }
                return Int((alarm.relativeOffset / 60.0).rounded())
            }
        if offsets.isEmpty {
            return nil
        }
        return Array(Set(offsets)).sorted()
    }
}
