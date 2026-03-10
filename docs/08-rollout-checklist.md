# 08 Rollout Checklist

## Code Completeness

- [ ] `calendar.update` implemented and routed
- [ ] `reminders.update` implemented and routed
- [ ] alarm patch fields supported on add + update
- [ ] alarm clear behavior implemented via `clearAllAlarms`
- [ ] no delete commands added

## Safety and Policy

- [ ] `EventKitAuthorization` remains centralized
- [ ] not-determined state does not trigger prompts in invoke path
- [ ] write-only permission reports `read=false`
- [ ] write commands are dangerous and not default-allowlisted
- [ ] onboarding dangerous deny defaults include EventKit writes

## Tests

- [ ] gateway/onboarding vitest suite passes
- [ ] dangerous allowCommands audit test passes
- [ ] OpenClawKit tests pass
- [ ] relevant iOS tests pass

## Docs

- [ ] contract docs match current model fields
- [ ] examples are copy-paste ready
- [ ] troubleshooting includes permission and allowlist failure modes

