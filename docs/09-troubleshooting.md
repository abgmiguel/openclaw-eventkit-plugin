# 09 Troubleshooting

## `*_PERMISSION_REQUIRED` errors

Cause:

- missing EventKit permission for read/write operation
- or permission is `notDetermined` and invoke path intentionally does not prompt

Fix:

- grant permission in iOS settings/app flow
- retry command

## `CALENDAR_NOT_FOUND` or `REMINDERS_LIST_NOT_FOUND`

Cause:

- supplied `calendarId` / `listId` does not resolve
- supplied title does not match any existing list/calendar
- no default calendar/list available

Fix:

- provide a valid identifier
- or provide exact calendar/list title
- verify a default target exists

## `CALENDAR_INVALID` or `REMINDERS_INVALID`

Cause:

- required field missing/empty
- malformed ISO-8601 date

Fix:

- validate inputs before invoke
- ensure timestamps are ISO-8601 strings

## Command not allowed

Cause:

- write command blocked by gateway allowlist/denylist policy

Fix:

- add explicit command to `gateway.nodes.allowCommands`
- ensure it is not present in `gateway.nodes.denyCommands`

## Write-only permission reports no read

This is expected behavior.

`writeOnly` maps to:

- `read=false`
- `write=true`

Use write commands if policy allows, but do not expect list/read operations to pass under write-only grant.

