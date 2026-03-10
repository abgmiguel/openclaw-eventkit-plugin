import EventKit
import Foundation
import OpenClawKit

final class RemindersService: RemindersServicing {
    func list(params: OpenClawRemindersListParams) async throws -> OpenClawRemindersListPayload {
        let store = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .reminder)
        let authorized = EventKitAuthorization.allowsRead(status: status)
        guard authorized else {
            throw NSError(domain: "Reminders", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_PERMISSION_REQUIRED: grant Reminders permission",
            ])
        }

        let limit = max(1, min(params.limit ?? 50, 500))
        let statusFilter = params.status ?? .incomplete

        let predicate = store.predicateForReminders(in: nil)
        let payload: [OpenClawReminderPayload] = try await withCheckedThrowingContinuation { cont in
            store.fetchReminders(matching: predicate) { items in
                let formatter = ISO8601DateFormatter()
                let filtered = (items ?? []).filter { reminder in
                    switch statusFilter {
                    case .all:
                        return true
                    case .completed:
                        return reminder.isCompleted
                    case .incomplete:
                        return !reminder.isCompleted
                    }
                }
                let selected = Array(filtered.prefix(limit))
                let payload = selected.map { reminder in Self.payload(from: reminder, formatter: formatter) }
                cont.resume(returning: payload)
            }
        }

        return OpenClawRemindersListPayload(reminders: payload)
    }

    func add(params: OpenClawRemindersAddParams) async throws -> OpenClawRemindersAddPayload {
        let store = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .reminder)
        let authorized = EventKitAuthorization.allowsWrite(status: status)
        guard authorized else {
            throw NSError(domain: "Reminders", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_PERMISSION_REQUIRED: grant Reminders permission",
            ])
        }

        let title = params.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw NSError(domain: "Reminders", code: 3, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_INVALID: title required",
            ])
        }

        let reminder = EKReminder(eventStore: store)
        reminder.title = title
        reminder.notes = Self.normalizeOptionalText(params.notes)
        reminder.calendar = try Self.resolveList(
            store: store,
            listId: params.listId,
            listName: params.listName)

        reminder.dueDateComponents = try Self.resolveDueDateComponents(params.dueISO, code: 4)
        Self.applyAlarmPatch(
            item: reminder,
            alarmOffsetsMinutes: params.alarmOffsetsMinutes,
            clearAllAlarms: params.clearAllAlarms)

        try store.save(reminder, commit: true)

        let formatter = ISO8601DateFormatter()
        let payload = Self.payload(from: reminder, formatter: formatter)

        return OpenClawRemindersAddPayload(reminder: payload)
    }

    func update(params: OpenClawRemindersUpdateParams) async throws -> OpenClawRemindersUpdatePayload {
        let store = EKEventStore()
        let status = EKEventStore.authorizationStatus(for: .reminder)
        let authorized = EventKitAuthorization.allowsWrite(status: status)
        guard authorized else {
            throw NSError(domain: "Reminders", code: 7, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_PERMISSION_REQUIRED: grant Reminders permission",
            ])
        }

        let identifier = params.identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !identifier.isEmpty else {
            throw NSError(domain: "Reminders", code: 8, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_INVALID: identifier required",
            ])
        }
        guard let reminder = store.calendarItem(withIdentifier: identifier) as? EKReminder else {
            throw NSError(domain: "Reminders", code: 9, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_NOT_FOUND: no reminder for identifier \(identifier)",
            ])
        }

        if let title = params.title {
            let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !normalized.isEmpty else {
                throw NSError(domain: "Reminders", code: 10, userInfo: [
                    NSLocalizedDescriptionKey: "REMINDERS_INVALID: title cannot be empty",
                ])
            }
            reminder.title = normalized
        }
        if let dueISO = params.dueISO {
            reminder.dueDateComponents = try Self.resolveDueDateComponents(dueISO, code: 11)
        }
        if let notes = params.notes {
            reminder.notes = Self.normalizeOptionalText(notes)
        }
        if params.listId != nil || params.listName != nil {
            reminder.calendar = try Self.resolveList(
                store: store,
                listId: params.listId,
                listName: params.listName)
        }
        if let completed = params.completed {
            reminder.isCompleted = completed
        }

        Self.applyAlarmPatch(
            item: reminder,
            alarmOffsetsMinutes: params.alarmOffsetsMinutes,
            clearAllAlarms: params.clearAllAlarms)
        try store.save(reminder, commit: true)

        let formatter = ISO8601DateFormatter()
        let payload = Self.payload(from: reminder, formatter: formatter)
        return OpenClawRemindersUpdatePayload(reminder: payload)
    }

    private static func resolveList(
        store: EKEventStore,
        listId: String?,
        listName: String?) throws -> EKCalendar
    {
        if let id = listId?.trimmingCharacters(in: .whitespacesAndNewlines), !id.isEmpty,
           let calendar = store.calendar(withIdentifier: id)
        {
            return calendar
        }

        if let title = listName?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty {
            if let calendar = store.calendars(for: .reminder).first(where: {
                $0.title.compare(title, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
            }) {
                return calendar
            }
            throw NSError(domain: "Reminders", code: 5, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_LIST_NOT_FOUND: no list named \(title)",
            ])
        }

        if let fallback = store.defaultCalendarForNewReminders() {
            return fallback
        }

        throw NSError(domain: "Reminders", code: 6, userInfo: [
            NSLocalizedDescriptionKey: "REMINDERS_LIST_NOT_FOUND: no default list",
        ])
    }

    private static func payload(
        from reminder: EKReminder,
        formatter: ISO8601DateFormatter) -> OpenClawReminderPayload
    {
        let due = reminder.dueDateComponents.flatMap { Calendar.current.date(from: $0) }
        return OpenClawReminderPayload(
            identifier: reminder.calendarItemIdentifier,
            title: reminder.title,
            dueISO: due.map { formatter.string(from: $0) },
            completed: reminder.isCompleted,
            listName: reminder.calendar.title,
            alarmOffsetsMinutes: Self.relativeAlarmOffsets(from: reminder.alarms))
    }

    private static func resolveDueDateComponents(_ raw: String?, code: Int) throws -> DateComponents? {
        guard let raw else { return nil }
        let dueISO = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !dueISO.isEmpty else { return nil }
        let formatter = ISO8601DateFormatter()
        guard let dueDate = formatter.date(from: dueISO) else {
            throw NSError(domain: "Reminders", code: code, userInfo: [
                NSLocalizedDescriptionKey: "REMINDERS_INVALID: dueISO must be ISO-8601",
            ])
        }
        return Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: dueDate)
    }

    private static func normalizeOptionalText(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
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
        let normalized = Array(Set(alarmOffsetsMinutes)).sorted()
        item.alarms = normalized.map { EKAlarm(relativeOffset: TimeInterval($0 * 60)) }
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
