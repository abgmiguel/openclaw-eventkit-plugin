# 05 Gateway Policy and Onboarding

## Default Allowlist vs Dangerous Commands

OpenClaw gateway resolves a command allowlist from:

1. platform defaults
2. `gateway.nodes.allowCommands` additions
3. `gateway.nodes.denyCommands` removals

For iOS, defaults include read-only EventKit commands:

- `calendar.events`
- `reminders.list`

EventKit writes are dangerous by default:

- `calendar.add`
- `calendar.update`
- `reminders.add`
- `reminders.update`

To allow them, add explicit entries to `gateway.nodes.allowCommands`.

## Onboarding Defaults

Onboarding seeds dangerous deny defaults including:

- `calendar.add`
- `calendar.update`
- `reminders.add`
- `reminders.update`

This keeps write operations blocked unless intentionally armed by user configuration.

## Minimal Config Pattern

See `examples/gateway-allowcommands.json5` for a focused allowlist example.

Recommended:

- allow only exact commands needed for your workflow
- keep deny list explicit for high-risk writes where possible

