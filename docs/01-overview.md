# 01 Overview

## Objective

Expose EventKit-backed calendar and reminders operations through OpenClaw `node.invoke` with safe defaults and explicit dangerous-command controls.

## End-to-End Flow

1. Gateway receives `node.invoke` request.
2. Gateway validates command against node allowlist and dangerous-command policy.
3. iOS node routes command through `NodeAppModel` capability router.
4. `CalendarService` or `RemindersService` executes EventKit operation.
5. Service returns typed payload from `OpenClawKit` command models.
6. Gateway returns payload to caller.

## Current Capability Surface

- Calendar:
  - Read: `calendar.events`
  - Write: `calendar.add`, `calendar.update`
- Reminders:
  - Read: `reminders.list`
  - Write: `reminders.add`, `reminders.update`

No delete commands are part of the current feature.

## Core Design Points

- Shared command models live in `OpenClawKit`.
- iOS runtime behavior mirrors contacts/calendar/reminders patterns.
- EventKit auth policy is centralized in `EventKitAuthorization`.
- Non-blocking/headless-safe behavior is preserved:
  - no permission prompts during `node.invoke`
  - not-determined permission state returns permission-required errors
- Write commands are dangerous and not in default allowlist.

