# 07 Testing and Validation

## Required Gateway/Wizard Tests

Run from OpenClaw repo root:

```bash
pnpm vitest run src/gateway/gateway-misc.test.ts src/wizard/onboarding.gateway-config.test.ts
pnpm vitest run src/security/audit.test.ts -t "dangerous gateway.nodes.allowCommands"
```

## Shared Swift Package Tests

```bash
cd apps/shared/OpenClawKit
swift test
```

Targeted coverage:

- EventKit command model codable round-trips
- alarm field persistence

## iOS Tests

Run relevant tests for:

- `NodeAppModelInvokeTests`
- `GatewayConnectionControllerTests`

Validate:

- new commands route correctly
- write-only permission does not report read access
- command declarations include update commands

## Acceptance Criteria

- No schema drift between docs and `OpenClawKit` models.
- Update commands exist end-to-end (contract, routing, runtime, policy).
- Alarm fields work for add and update, including `clearAllAlarms`.
- Dangerous command defaults remain strict.

