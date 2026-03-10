import Foundation

public enum OpenClawCalendarCommand: String, Codable, Sendable {
    case events = "calendar.events"
    case add = "calendar.add"
    case update = "calendar.update"
}

public struct OpenClawCalendarEventsParams: Codable, Sendable, Equatable {
    public var startISO: String?
    public var endISO: String?
    public var limit: Int?

    public init(startISO: String? = nil, endISO: String? = nil, limit: Int? = nil) {
        self.startISO = startISO
        self.endISO = endISO
        self.limit = limit
    }
}

public struct OpenClawCalendarAddParams: Codable, Sendable, Equatable {
    public var title: String
    public var startISO: String
    public var endISO: String
    public var isAllDay: Bool?
    public var location: String?
    public var notes: String?
    public var calendarId: String?
    public var calendarTitle: String?
    // Relative offsets in minutes from event start (for example, -10 is 10 minutes before).
    public var alarmOffsetsMinutes: [Int]?
    // Set true to clear all alarms on this item.
    public var clearAllAlarms: Bool?

    public init(
        title: String,
        startISO: String,
        endISO: String,
        isAllDay: Bool? = nil,
        location: String? = nil,
        notes: String? = nil,
        calendarId: String? = nil,
        calendarTitle: String? = nil,
        alarmOffsetsMinutes: [Int]? = nil,
        clearAllAlarms: Bool? = nil)
    {
        self.title = title
        self.startISO = startISO
        self.endISO = endISO
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
        self.calendarId = calendarId
        self.calendarTitle = calendarTitle
        self.alarmOffsetsMinutes = alarmOffsetsMinutes
        self.clearAllAlarms = clearAllAlarms
    }
}

public struct OpenClawCalendarUpdateParams: Codable, Sendable, Equatable {
    public var identifier: String
    public var title: String?
    public var startISO: String?
    public var endISO: String?
    public var isAllDay: Bool?
    public var location: String?
    public var notes: String?
    public var calendarId: String?
    public var calendarTitle: String?
    // Relative offsets in minutes from event start (for example, -10 is 10 minutes before).
    public var alarmOffsetsMinutes: [Int]?
    // Set true to clear all alarms on this item.
    public var clearAllAlarms: Bool?

    public init(
        identifier: String,
        title: String? = nil,
        startISO: String? = nil,
        endISO: String? = nil,
        isAllDay: Bool? = nil,
        location: String? = nil,
        notes: String? = nil,
        calendarId: String? = nil,
        calendarTitle: String? = nil,
        alarmOffsetsMinutes: [Int]? = nil,
        clearAllAlarms: Bool? = nil)
    {
        self.identifier = identifier
        self.title = title
        self.startISO = startISO
        self.endISO = endISO
        self.isAllDay = isAllDay
        self.location = location
        self.notes = notes
        self.calendarId = calendarId
        self.calendarTitle = calendarTitle
        self.alarmOffsetsMinutes = alarmOffsetsMinutes
        self.clearAllAlarms = clearAllAlarms
    }
}

public struct OpenClawCalendarEventPayload: Codable, Sendable, Equatable {
    public var identifier: String
    public var title: String
    public var startISO: String
    public var endISO: String
    public var isAllDay: Bool
    public var location: String?
    public var calendarTitle: String?
    public var alarmOffsetsMinutes: [Int]?

    public init(
        identifier: String,
        title: String,
        startISO: String,
        endISO: String,
        isAllDay: Bool,
        location: String? = nil,
        calendarTitle: String? = nil,
        alarmOffsetsMinutes: [Int]? = nil)
    {
        self.identifier = identifier
        self.title = title
        self.startISO = startISO
        self.endISO = endISO
        self.isAllDay = isAllDay
        self.location = location
        self.calendarTitle = calendarTitle
        self.alarmOffsetsMinutes = alarmOffsetsMinutes
    }
}

public struct OpenClawCalendarEventsPayload: Codable, Sendable, Equatable {
    public var events: [OpenClawCalendarEventPayload]

    public init(events: [OpenClawCalendarEventPayload]) {
        self.events = events
    }
}

public struct OpenClawCalendarAddPayload: Codable, Sendable, Equatable {
    public var event: OpenClawCalendarEventPayload

    public init(event: OpenClawCalendarEventPayload) {
        self.event = event
    }
}

public struct OpenClawCalendarUpdatePayload: Codable, Sendable, Equatable {
    public var event: OpenClawCalendarEventPayload

    public init(event: OpenClawCalendarEventPayload) {
        self.event = event
    }
}
