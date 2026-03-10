# Apply To OpenClaw

This guide maps each handoff file in this repository to the OpenClaw source tree.

## Mapping

| Handoff file | OpenClaw target path | Apply mode |
| --- | --- | --- |
| `code/swift/Sources/OpenClawKit/CalendarCommands.swift` | `apps/shared/OpenClawKit/Sources/OpenClawKit/CalendarCommands.swift` | replace |
| `code/swift/Sources/OpenClawKit/RemindersCommands.swift` | `apps/shared/OpenClawKit/Sources/OpenClawKit/RemindersCommands.swift` | replace |
| `code/swift/Sources/OpenClawRuntime/EventKitAuthorization.swift` | `apps/ios/Sources/EventKit/EventKitAuthorization.swift` | replace |
| `code/swift/Sources/OpenClawRuntime/CalendarService.swift` | `apps/ios/Sources/Calendar/CalendarService.swift` | replace |
| `code/swift/Sources/OpenClawRuntime/RemindersService.swift` | `apps/ios/Sources/Reminders/RemindersService.swift` | replace |
| `code/swift/Sources/OpenClawRuntime/NodeServiceProtocols.swift` | `apps/ios/Sources/Services/NodeServiceProtocols.swift` | merge EventKit protocol slice |
| `code/swift/Sources/OpenClawRuntime/NodeAppModel.swift` | `apps/ios/Sources/Model/NodeAppModel.swift` | merge EventKit invoke-routing slice |
| `code/swift/Sources/OpenClawRuntime/GatewayConnectionController.swift` | `apps/ios/Sources/Gateway/GatewayConnectionController.swift` | merge EventKit capability/permission slice |
| `code/ts/src/gateway/node-command-policy.ts` | `src/gateway/node-command-policy.ts` | replace relevant policy logic |
| `code/ts/src/wizard/onboarding.gateway-config.ts` | `src/wizard/onboarding.gateway-config.ts` | merge dangerous-default slice |
| `code/swift/Tests/OpenClawKitTests/EventKitCommandsCodableTests.swift` | `apps/shared/OpenClawKit/Tests/OpenClawKitTests/EventKitCommandsCodableTests.swift` | replace |
| `code/swift/Tests/OpenClawRuntimeTests/NodeAppModelInvokeTests.swift` | `apps/ios/Tests/NodeAppModelInvokeTests.swift` | merge relevant update-routing tests |
| `code/swift/Tests/OpenClawRuntimeTests/GatewayConnectionControllerTests.swift` | `apps/ios/Tests/GatewayConnectionControllerTests.swift` | merge relevant permission/command tests |
| `code/ts/src/gateway/gateway-misc.test.ts` | `src/gateway/gateway-misc.test.ts` | merge relevant allowlist tests |
| `code/ts/src/wizard/onboarding.gateway-config.test.ts` | `src/wizard/onboarding.gateway-config.test.ts` | merge relevant onboarding tests |

## Apply Steps

1. Set your OpenClaw root:

```bash
OPENCLAW_ROOT=<path-to-openclaw-repo>
HANDOFF_ROOT=<path-to-openclaw-eventkit-plugin-docs-repo>
```

2. Replace files that should be copied as-is:

```bash
cp "$HANDOFF_ROOT/code/swift/Sources/OpenClawKit/CalendarCommands.swift" \
  "$OPENCLAW_ROOT/apps/shared/OpenClawKit/Sources/OpenClawKit/CalendarCommands.swift"
cp "$HANDOFF_ROOT/code/swift/Sources/OpenClawKit/RemindersCommands.swift" \
  "$OPENCLAW_ROOT/apps/shared/OpenClawKit/Sources/OpenClawKit/RemindersCommands.swift"
cp "$HANDOFF_ROOT/code/swift/Sources/OpenClawRuntime/EventKitAuthorization.swift" \
  "$OPENCLAW_ROOT/apps/ios/Sources/EventKit/EventKitAuthorization.swift"
cp "$HANDOFF_ROOT/code/swift/Sources/OpenClawRuntime/CalendarService.swift" \
  "$OPENCLAW_ROOT/apps/ios/Sources/Calendar/CalendarService.swift"
cp "$HANDOFF_ROOT/code/swift/Sources/OpenClawRuntime/RemindersService.swift" \
  "$OPENCLAW_ROOT/apps/ios/Sources/Reminders/RemindersService.swift"
cp "$HANDOFF_ROOT/code/swift/Tests/OpenClawKitTests/EventKitCommandsCodableTests.swift" \
  "$OPENCLAW_ROOT/apps/shared/OpenClawKit/Tests/OpenClawKitTests/EventKitCommandsCodableTests.swift"
```

3. Merge EventKit slices into existing larger files:

- `NodeServiceProtocols.swift`: apply the `CalendarServicing` and `RemindersServicing` protocol definitions.
- `NodeAppModel.swift`: apply the `handleCalendarInvoke` and `handleRemindersInvoke` switch cases, including `calendar.update` and `reminders.update` branches.
- `GatewayConnectionController.swift`: apply `currentCommands` entries for `calendar.update` and `reminders.update`, and apply `eventKitPermissions(...)` using `EventKitAuthorization.access(...)`.
- `onboarding.gateway-config.ts`: apply default dangerous deny entries including `calendar.update` and `reminders.update`.
- Merge the corresponding test cases from the handoff test files into their OpenClaw test files.

4. Verify key behavior in OpenClaw after merge:

- `calendar.update` exists and routes correctly.
- `reminders.update` exists and routes correctly.
- add/update alarm patch works for calendar and reminders.
- `clearAllAlarms` removes existing alarms.
- write-only EventKit access reports `write=true` and `read=false`.
- dangerous commands are not default-allowlisted.
- no delete commands are introduced.

5. Run OpenClaw validation in that repo:

```bash
pnpm vitest run src/gateway/gateway-misc.test.ts src/wizard/onboarding.gateway-config.test.ts
swift test
```
