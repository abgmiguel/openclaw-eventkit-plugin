# OpenClaw EventKit Plugin Implementation Docs

Production-ready documentation pack for implementing and maintaining the EventKit plugin surface in OpenClaw.

It is written for engineers who need a fast, correct path from zero to production.

## Table of Contents

- [What This Covers](#what-this-covers)
- [Repo Layout](#repo-layout)
- [Code Handoff](#code-handoff)
- [Quick Start](#quick-start)
- [Source of Truth](#source-of-truth)
- [Tooling Baseline](#tooling-baseline)
- [Publish to GitHub](#publish-to-github)
- [License](#license)

## What This Covers

- Calendar commands: `calendar.events`, `calendar.add`, `calendar.update`
- Reminders commands: `reminders.list`, `reminders.add`, `reminders.update`
- Alarm model on add/update:
  - `alarmOffsetsMinutes: [Int]?`
  - `clearAllAlarms: Bool?`
- Centralized EventKit authorization policy (`read` vs `write`)
- Gateway command allowlist and dangerous-command policy
- Onboarding defaults for dangerous command deny list
- Test coverage and rollout gating

Out of scope:

- `calendar.delete`
- `reminders.delete`

## Repo Layout

- `docs/01-overview.md`: architecture and request flow
- `docs/02-command-contract.md`: API contract for command params and payloads
- `docs/03-ios-runtime.md`: iOS service behavior and patch semantics
- `docs/04-permissions-and-safety.md`: auth model and non-blocking behavior
- `docs/05-gateway-policy-and-onboarding.md`: allowlist/denylist integration
- `docs/06-implementation-playbook.md`: step-by-step implementation sequence
- `docs/07-testing-and-validation.md`: test matrix and commands
- `docs/08-rollout-checklist.md`: merge/release checklist
- `docs/09-troubleshooting.md`: common failures and fixes
- `examples/`: copy-paste request/config snippets
- `code/swift/`: runnable Swift package with EventKit implementation + tests
- `code/ts/`: runnable TypeScript policy/onboarding module + Vitest tests
- `APPLY_TO_OPENCLAW.md`: exact file mapping and apply steps back to OpenClaw

## Code Handoff

This repository now includes implementation code, not only docs:

- `code/swift/Sources/OpenClawKit/`:
  - `CalendarCommands.swift`
  - `RemindersCommands.swift`
- `code/swift/Sources/OpenClawRuntime/`:
  - `EventKitAuthorization.swift`
  - `CalendarService.swift`
  - `RemindersService.swift`
  - `NodeServiceProtocols.swift` (EventKit slice)
  - `NodeAppModel.swift` (EventKit invoke-routing slice)
  - `GatewayConnectionController.swift` (EventKit capability/permission slice)
- `code/swift/Tests/`:
  - `EventKitCommandsCodableTests.swift`
  - `NodeAppModelInvokeTests.swift` (update routing cases)
  - `GatewayConnectionControllerTests.swift` (permission/command cases)
- `code/ts/src/`:
  - `gateway/node-command-policy.ts`
  - `wizard/onboarding.gateway-config.ts`
  - `gateway/gateway-misc.test.ts`
  - `wizard/onboarding.gateway-config.test.ts`

Validation entry points:

- Swift: `cd code/swift && swift test`
- TS: `cd code/ts && pnpm vitest run`

## Quick Start

1. Read `docs/02-command-contract.md` for exact API shapes.
2. Follow `docs/06-implementation-playbook.md` in order.
3. Run tests from `docs/07-testing-and-validation.md`.
4. Use `docs/08-rollout-checklist.md` before merge.

## Source of Truth

These docs were derived from current OpenClaw code at:

- `apps/shared/OpenClawKit/Sources/OpenClawKit/CalendarCommands.swift`
- `apps/shared/OpenClawKit/Sources/OpenClawKit/RemindersCommands.swift`
- `apps/ios/Sources/Calendar/CalendarService.swift`
- `apps/ios/Sources/Reminders/RemindersService.swift`
- `apps/ios/Sources/EventKit/EventKitAuthorization.swift`
- `apps/ios/Sources/Services/NodeServiceProtocols.swift`
- `apps/ios/Sources/Model/NodeAppModel.swift`
- `apps/ios/Sources/Gateway/GatewayConnectionController.swift`
- `src/gateway/node-command-policy.ts`
- `src/wizard/onboarding.gateway-config.ts`
- `apps/shared/OpenClawKit/Tests/OpenClawKitTests/EventKitCommandsCodableTests.swift`
- `apps/ios/Tests/NodeAppModelInvokeTests.swift`
- `apps/ios/Tests/GatewayConnectionControllerTests.swift`
- `src/gateway/gateway-misc.test.ts`
- `src/wizard/onboarding.gateway-config.test.ts`

## Tooling Baseline

- OpenClaw shared Swift package uses Swift tools `6.2`.
- iOS tests require an Xcode/toolchain baseline that can resolve Swift `6.2` package manifests.

## Publish to GitHub

Create an empty GitHub repository, then push:

```bash
cd <repo-root>
git remote add origin git@github.com:<your-username>/openclaw-eventkit-plugin-docs.git
git push -u origin main
```

## License

MIT. See [`LICENSE`](./LICENSE).
