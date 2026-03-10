# 04 Permissions and Safety

## Centralized EventKit Auth Policy

`EventKitAuthorization.access(status:)` maps EventKit status to read/write booleans.

Mapping:

- `.authorized` / `.fullAccess` -> `read=true`, `write=true`
- `.writeOnly` -> `read=false`, `write=true`
- `.notDetermined` -> `read=false`, `write=false`
- `.restricted` / `.denied` -> `read=false`, `write=false`
- unknown default -> `read=false`, `write=false`

## Non-Blocking Behavior

For `.notDetermined`, policy intentionally does not prompt during `node.invoke`.

Reason:

- prompts can block invoke flow and cause timeouts in headless/automation contexts

Result:

- read/write commands return permission-required errors instead of triggering OS UI.

## Node Permission Reporting

`GatewayConnectionController.currentPermissions()` reports:

- `calendar` (read)
- `calendarWrite` (write)
- `reminders` (read)
- `remindersWrite` (write)

Under write-only grants, read flags remain `false`.

## Dangerous Command Classification

Default dangerous node commands include:

- `calendar.add`
- `calendar.update`
- `reminders.add`
- `reminders.update`

These are not included in default platform allowlists and require explicit gateway allow configuration.

