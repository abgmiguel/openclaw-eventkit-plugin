import EventKit
import Foundation
import OpenClawKit

@MainActor
final class GatewayConnectionController {
    func _test_currentCaps() -> [String] {
        self.currentCaps()
    }

    func _test_currentCommands() -> [String] {
        self.currentCommands()
    }

    func _test_currentPermissions() -> [String: Bool] {
        self.currentPermissions()
    }

    static func _test_eventKitPermissions(
        calendarStatus: EKAuthorizationStatus,
        remindersStatus: EKAuthorizationStatus)
        -> (calendarRead: Bool, calendarWrite: Bool, remindersRead: Bool, remindersWrite: Bool)
    {
        self.eventKitPermissions(calendarStatus: calendarStatus, remindersStatus: remindersStatus)
    }

    private func currentCaps() -> [String] {
        [
            OpenClawCapability.calendar.rawValue,
            OpenClawCapability.reminders.rawValue,
        ]
    }

    private func currentCommands() -> [String] {
        var commands: [String] = []

        let caps = Set(self.currentCaps())
        if caps.contains(OpenClawCapability.calendar.rawValue) {
            commands.append(OpenClawCalendarCommand.events.rawValue)
            commands.append(OpenClawCalendarCommand.add.rawValue)
            commands.append(OpenClawCalendarCommand.update.rawValue)
        }
        if caps.contains(OpenClawCapability.reminders.rawValue) {
            commands.append(OpenClawRemindersCommand.list.rawValue)
            commands.append(OpenClawRemindersCommand.add.rawValue)
            commands.append(OpenClawRemindersCommand.update.rawValue)
        }

        return commands
    }

    private func currentPermissions() -> [String: Bool] {
        var permissions: [String: Bool] = [:]
        let calendarStatus = EKEventStore.authorizationStatus(for: .event)
        let remindersStatus = EKEventStore.authorizationStatus(for: .reminder)
        let eventKit = Self.eventKitPermissions(calendarStatus: calendarStatus, remindersStatus: remindersStatus)
        permissions["calendar"] = eventKit.calendarRead
        permissions["calendarWrite"] = eventKit.calendarWrite
        permissions["reminders"] = eventKit.remindersRead
        permissions["remindersWrite"] = eventKit.remindersWrite
        return permissions
    }

    private static func eventKitPermissions(
        calendarStatus: EKAuthorizationStatus,
        remindersStatus: EKAuthorizationStatus)
        -> (calendarRead: Bool, calendarWrite: Bool, remindersRead: Bool, remindersWrite: Bool)
    {
        let calendar = EventKitAuthorization.access(status: calendarStatus)
        let reminders = EventKitAuthorization.access(status: remindersStatus)
        return (
            calendarRead: calendar.read,
            calendarWrite: calendar.write,
            remindersRead: reminders.read,
            remindersWrite: reminders.write
        )
    }
}
