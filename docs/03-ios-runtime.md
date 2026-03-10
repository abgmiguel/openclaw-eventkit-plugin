# 03 iOS Runtime Behavior

## Routing

`NodeAppModel` routes EventKit commands through dedicated handlers:

- Calendar:
  - `calendar.events` -> `calendarService.events`
  - `calendar.add` -> `calendarService.add`
  - `calendar.update` -> `calendarService.update`
- Reminders:
  - `reminders.list` -> `remindersService.list`
  - `reminders.add` -> `remindersService.add`
  - `reminders.update` -> `remindersService.update`

## Calendar Service

### Read (`events`)

- Requires EventKit read access (`allowsRead`).
- Range defaults:
  - `startISO` missing: now
  - `endISO` missing: `start + 7 days`
- Limit clamp: `1...500` (default `50`)

### Add (`add`)

- Requires write access (`allowsWrite`).
- Validates non-empty `title`.
- Validates ISO-8601 `startISO` and `endISO`.
- Resolves calendar by:
  1. `calendarId`
  2. case-insensitive `calendarTitle`
  3. default calendar
- Normalizes optional text fields (trim, empty -> `nil`).
- Applies alarm patch.

### Update (`update`)

- Requires write access (`allowsWrite`).
- Requires non-empty `identifier`.
- Fails with not-found if identifier lookup misses.
- Patch behavior:
  - only fields present in request are changed
  - `calendarId`/`calendarTitle` trigger calendar reassignment only when either is provided
  - alarm patch follows shared semantics

## Reminders Service

### List (`list`)

- Requires read access (`allowsRead`).
- Limit clamp: `1...500` (default `50`).
- Status filter:
  - default: `incomplete`
  - optional: `completed`, `all`

### Add (`add`)

- Requires write access (`allowsWrite`).
- Validates non-empty `title`.
- Resolves list by:
  1. `listId`
  2. case-insensitive `listName`
  3. default list
- `dueISO` is optional:
  - empty string treated as `nil`
  - non-empty must parse as ISO-8601
- Applies alarm patch.

### Update (`update`)

- Requires write access (`allowsWrite`).
- Requires non-empty `identifier`.
- Fails with not-found if identifier lookup misses.
- Patch behavior:
  - optional updates for title, due date, notes, list, completed state
  - alarm patch follows shared semantics

## Error Contract Pattern

Both services throw `NSError` with stable domain and code families:

- Calendar domain: `"Calendar"` codes include invalid input, not found, permission required.
- Reminders domain: `"Reminders"` codes include invalid input, not found, permission required.

User-visible messages follow prefixed markers such as:

- `CALENDAR_PERMISSION_REQUIRED`
- `CALENDAR_INVALID`
- `CALENDAR_NOT_FOUND`
- `REMINDERS_PERMISSION_REQUIRED`
- `REMINDERS_INVALID`
- `REMINDERS_NOT_FOUND`
