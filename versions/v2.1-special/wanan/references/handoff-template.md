# Handoff template

Update the existing handoff in place. Preserve useful history while making the current state obvious.

```markdown
# HANDOFF

Updated: <timestamp and time zone>
Current objective: <one sentence>
Current slice: <slice and acceptance IDs>

## Completed

- <Delivered behavior>
  - Evidence: <commands, tests, runtime capture, or acceptance report>
  - Artifacts: <paths, issue/spec/ADR links>

## Verification

- Passed: <exact command/check and result>
- Independent acceptance: <subagent result and covered IDs>
- Unverified: <device/provider/production/concurrency/rollout/paid checks not run>

## Unfinished

- <Remaining behavior, missing acceptance IDs, or cleanup>

## Blockers

- <Blocking condition, owner, and required decision/change>

## Decisions and open questions

- Confirmed: <decision and source>
- Deferred: <decision, safe temporary behavior, and trigger to revisit>

## Workspace and version control

- Changed artifacts: <paths>
- Preserved unrelated changes: <paths or summary>
- Commit: <SHA or not created>
- Push: <remote/branch/status or not authorized>

## Tool and environment manifest

- Root task ID: <stable ID shared by controller and branches>
- Native capabilities: <read/glob/grep/bash/replace availability>
- Adapters: <bundled fallbacks in use>
- Shell: <Git Bash path/version>
- Temp: <dedicated task-local directory; system Temp unchanged>
- Encoding: <UTF-8 process settings>
- PowerShell: <pwsh version or unavailable>

## Branch registry

| Branch session | Scope/owned paths | Compactions | State | Handoff/replacement | Integration |
|---|---|---:|---|---|---|
| <id> | <scope> | <0, 1, or 2> | <active/completed/retired/blocked> | <artifact or replacement id> | <pending/accepted/integrated/rejected> |

## Learning and assessment

- Learning file: `经验学习.md` (current project only, user-facing)
- Protected grading state: `.wanan/assessment-state.json` (current project only; never include answer keys in handoff)
- Learning mode: REQUIRED
- Current module: <MOD-NNN and name>
- Current learning state: <BACKFILL_REQUIRED/REASSESSMENT_REQUIRED/TEACHING/WAITING_FOR_LEARNING_CONFIRMATION/ASSESSING/ASSESSED>
- Historical backfill pending: <MOD IDs or none>
- Completed assessments: <MOD-NNN score/100, ...>
- Pending reassessments: <MOD-NNN or none>
- Comprehensive score: <PENDING or score/100>
- Exact next learning action: <teach/wait for confirmation/wait for answers/grade/continue>

## Frontend design lock

- Visual batch: <three displayed result IDs in order; grounding source if any>
- Selected visual: <one exact displayed result ID and user selection source>
- Structure: <DRAFT/APPROVED and decision source>
- Affordance coverage: <declared/covered AFF IDs and COMPLETE/PENDING>
- Interaction decisions: <selected/inherited/open INT IDs and INT-ACC mappings>
- Lock: <DRAFT/LOCKED, approval source, revision>
- Product Design stage: <get-context/ideate/decision-lock/image-to-code/design-qa>

## Risks

- <Risk and mitigation>

## Next action

1. <Exact first action for a fresh agent>
```

Never include credentials, tokens, private keys, personal data, or paid-service secrets.
