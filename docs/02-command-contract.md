# 02 Command Contract

## Calendar Commands

### `calendar.events`

Params:

- `startISO: String?`
- `endISO: String?`
- `limit: Int?`

Payload:

- `events: OpenClawCalendarEventPayload[]`

### `calendar.add`

Params:

- `title: String` (required)
- `startISO: String` (required)
- `endISO: String` (required)
- `isAllDay: Bool?`
- `location: String?`
- `notes: String?`
- `calendarId: String?`
- `calendarTitle: String?`
- `alarmOffsetsMinutes: [Int]?`
- `clearAllAlarms: Bool?`

Payload:

- `event: OpenClawCalendarEventPayload`

### `calendar.update`

Params:

- `identifier: String` (required)
- `title: String?`
- `startISO: String?`
- `endISO: String?`
- `isAllDay: Bool?`
- `location: String?`
- `notes: String?`
- `calendarId: String?`
- `calendarTitle: String?`
- `alarmOffsetsMinutes: [Int]?`
- `clearAllAlarms: Bool?`

Payload:

- `event: OpenClawCalendarEventPayload`

## Reminders Commands

### `reminders.list`

Params:

- `status: "incomplete" | "completed" | "all"?`
- `limit: Int?`

Payload:

- `reminders: OpenClawReminderPayload[]`

### `reminders.add`

Params:

- `title: String` (required)
- `dueISO: String?`
- `notes: String?`
- `listId: String?`
- `listName: String?`
- `alarmOffsetsMinutes: [Int]?`
- `clearAllAlarms: Bool?`

Payload:

- `reminder: OpenClawReminderPayload`

### `reminders.update`

Params:

- `identifier: String` (required)
- `title: String?`
- `dueISO: String?`
- `notes: String?`
- `listId: String?`
- `listName: String?`
- `completed: Bool?`
- `alarmOffsetsMinutes: [Int]?`
- `clearAllAlarms: Bool?`

Payload:

- `reminder: OpenClawReminderPayload`

## Shared Payload Fields

### `OpenClawCalendarEventPayload`

- `identifier: String`
- `title: String`
- `startISO: String`
- `endISO: String`
- `isAllDay: Bool`
- `location: String?`
- `calendarTitle: String?`
- `alarmOffsetsMinutes: [Int]?`

### `OpenClawReminderPayload`

- `identifier: String`
- `title: String`
- `dueISO: String?`
- `completed: Bool`
- `listName: String?`
- `alarmOffsetsMinutes: [Int]?`

## Alarm Patch Semantics

On add/update for calendar and reminders:

- If `clearAllAlarms == true`: clear alarms and return.
- Else if `alarmOffsetsMinutes` is present:
  - de-duplicate values
  - sort ascending
  - set relative alarms based on minutes
- Else: leave existing alarms unchanged.

Returned `alarmOffsetsMinutes` values are derived from relative alarms only. Absolute-date alarms are ignored in this projection.

