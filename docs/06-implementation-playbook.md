# 06 Implementation Playbook

Use this sequence when implementing or extending EventKit commands in OpenClaw.

## 1. Shared Contract (`OpenClawKit`)

Update shared command models first:

- add enum case in command type (`calendar.*` / `reminders.*`)
- define `Params` struct
- define payload struct if response shape differs
- ensure Codable + Equatable + Sendable

Keep alarm API shape stable:

- `alarmOffsetsMinutes: [Int]?`
- `clearAllAlarms: Bool?`

## 2. Service Protocols

Add method signatures in iOS service protocols:

- `CalendarServicing`
- `RemindersServicing`

This keeps runtime and tests compile-checked for API completeness.

## 3. iOS Runtime Service Logic

Implement in:

- `CalendarService`
- `RemindersService`

Pattern requirements:

- gate read/write with `EventKitAuthorization`
- validate required fields early
- trim optional text inputs
- resolve target calendar/list by id -> title -> default
- apply alarm patch helper consistently
- return normalized payload projection

## 4. Node Invoke Routing

Wire new commands through `NodeAppModel`:

- decode params
- call service method
- encode payload
- register command in capability router

## 5. Gateway Capability and Permission Surface

Update iOS gateway connection layer:

- include new command in declared command set
- keep permission keys read/write split

## 6. Policy and Onboarding

Update:

- `src/gateway/node-command-policy.ts`
- `src/wizard/onboarding.gateway-config.ts`

Ensure write commands remain dangerous by default.

## 7. Tests

Add/adjust tests in:

- OpenClawKit codable round-trip tests
- iOS invoke routing tests
- iOS permission mapping tests
- gateway allowlist behavior tests
- onboarding config tests

