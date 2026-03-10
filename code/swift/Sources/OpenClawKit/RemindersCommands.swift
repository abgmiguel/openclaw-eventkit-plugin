import Foundation

public enum OpenClawRemindersCommand: String, Codable, Sendable {
    case list = "reminders.list"
    case add = "reminders.add"
    case update = "reminders.update"
}

public enum OpenClawReminderStatusFilter: String, Codable, Sendable {
    case incomplete
    case completed
    case all
}

public struct OpenClawRemindersListParams: Codable, Sendable, Equatable {
    public var status: OpenClawReminderStatusFilter?
    public var limit: Int?

    public init(status: OpenClawReminderStatusFilter? = nil, limit: Int? = nil) {
        self.status = status
        self.limit = limit
    }
}

public struct OpenClawRemindersAddParams: Codable, Sendable, Equatable {
    public var title: String
    public var dueISO: String?
    public var notes: String?
    public var listId: String?
    public var listName: String?
    // Relative offsets in minutes from due date (for example, -10 is 10 minutes before).
    public var alarmOffsetsMinutes: [Int]?
    // Set true to clear all alarms on this item.
    public var clearAllAlarms: Bool?

    public init(
        title: String,
        dueISO: String? = nil,
        notes: String? = nil,
        listId: String? = nil,
        listName: String? = nil,
        alarmOffsetsMinutes: [Int]? = nil,
        clearAllAlarms: Bool? = nil)
    {
        self.title = title
        self.dueISO = dueISO
        self.notes = notes
        self.listId = listId
        self.listName = listName
        self.alarmOffsetsMinutes = alarmOffsetsMinutes
        self.clearAllAlarms = clearAllAlarms
    }
}

public struct OpenClawRemindersUpdateParams: Codable, Sendable, Equatable {
    public var identifier: String
    public var title: String?
    public var dueISO: String?
    public var notes: String?
    public var listId: String?
    public var listName: String?
    public var completed: Bool?
    // Relative offsets in minutes from due date (for example, -10 is 10 minutes before).
    public var alarmOffsetsMinutes: [Int]?
    // Set true to clear all alarms on this item.
    public var clearAllAlarms: Bool?

    public init(
        identifier: String,
        title: String? = nil,
        dueISO: String? = nil,
        notes: String? = nil,
        listId: String? = nil,
        listName: String? = nil,
        completed: Bool? = nil,
        alarmOffsetsMinutes: [Int]? = nil,
        clearAllAlarms: Bool? = nil)
    {
        self.identifier = identifier
        self.title = title
        self.dueISO = dueISO
        self.notes = notes
        self.listId = listId
        self.listName = listName
        self.completed = completed
        self.alarmOffsetsMinutes = alarmOffsetsMinutes
        self.clearAllAlarms = clearAllAlarms
    }
}

public struct OpenClawReminderPayload: Codable, Sendable, Equatable {
    public var identifier: String
    public var title: String
    public var dueISO: String?
    public var completed: Bool
    public var listName: String?
    public var alarmOffsetsMinutes: [Int]?

    public init(
        identifier: String,
        title: String,
        dueISO: String? = nil,
        completed: Bool,
        listName: String? = nil,
        alarmOffsetsMinutes: [Int]? = nil)
    {
        self.identifier = identifier
        self.title = title
        self.dueISO = dueISO
        self.completed = completed
        self.listName = listName
        self.alarmOffsetsMinutes = alarmOffsetsMinutes
    }
}

public struct OpenClawRemindersListPayload: Codable, Sendable, Equatable {
    public var reminders: [OpenClawReminderPayload]

    public init(reminders: [OpenClawReminderPayload]) {
        self.reminders = reminders
    }
}

public struct OpenClawRemindersAddPayload: Codable, Sendable, Equatable {
    public var reminder: OpenClawReminderPayload

    public init(reminder: OpenClawReminderPayload) {
        self.reminder = reminder
    }
}

public struct OpenClawRemindersUpdatePayload: Codable, Sendable, Equatable {
    public var reminder: OpenClawReminderPayload

    public init(reminder: OpenClawReminderPayload) {
        self.reminder = reminder
    }
}
