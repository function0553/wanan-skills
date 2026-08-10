# Harness template

Use this as a minimum, not as permission to overwrite an established repository structure.

## Contents

- Root `AGENTS.md`
- `spec/README.md`
- Minimum numbered specs
- Validation checklist

## Root `AGENTS.md`

```markdown
# <Project> Harness

## 1. Purpose
<Product goal, users, and supported surfaces.>

## 2. Instruction precedence
Current user instruction > this file > spec acceptance > other notes.

## 3. Domain constraints
<Server authority, entity distinctions, state-machine and concurrency rules.>

## 4. Security and quality constraints
<Authentication, authorization, validation, ownership, secrets, uploads, idempotency, transactions, time zone.>

## 5. Spec index and task routing
| Task area | Read first |
|---|---|
| Product scope | `spec/01-product-scope.md` |
| Domain and workflows | `spec/02-domain-and-workflows.md` |
| Architecture | `spec/03-system-architecture.md` |
| Visual and interaction | `spec/04-visual-and-interaction.md` |
| Functional acceptance | `spec/05-acceptance.md` |
| Visual acceptance | `spec/06-visual-acceptance.md` |
| Delivery and decisions | `spec/07-delivery-roadmap.md` |

## 6. Validation
<Normal, unauthorized, conflict, duplicate-submit, empty, loading, and failure coverage.>

## 7. Definition of done
<Implementation, acceptance, documentation, handoff, and Git checkpoint requirements.>
```

## `spec/README.md`

List every spec, its role, reading order, requirement prefix, acceptance prefix, owner, and status. Require links to resolve.

## Minimum numbered specs

### `01-product-scope.md`

- Problem and user outcomes
- Actors and permissions
- In scope / out of scope
- User stories
- Open decisions

### `02-domain-and-workflows.md`

- Canonical terms and entity distinctions
- State machines
- Server-authoritative rules
- Conflict, concurrency, idempotency, and audit behavior
- Time and ownership rules

### `03-system-architecture.md`

- Components and module boundaries
- Data and API contracts
- Authentication and authorization boundaries
- Persistence, migrations, observability, and deployment boundaries
- Test seams

### `04-visual-and-interaction.md`

- `Design status: DRAFT | LOCKED`
- One IDEATED visual batch with exactly three displayed result IDs in displayed order, independence evidence, exact selection, and selection source; supplied sources may ground the batch but never bypass it
- Design tokens and assets
- Page/route and viewport-section structure with `Structure status: APPROVED` and approval source
- Component, content-priority, and screen/state inventory
- Responsive or device behavior
- `INT-NNN` decision register for navigation, scrolling, controls, forms, overlays, feedback/restoration, responsive input, and motion
- Control-to-interaction coverage matrix with `Coverage status: COMPLETE`
- Loading, empty, error, permission, disabled, submitting, success, and destructive states
- Frontend lock approval, revision, and contract fingerprint

Use this page structure form:

```markdown
### PAGE-001 <Page or surface>

- Route/surface: <route, tab, modal, or embedded surface>
- Viewport sections: <ordered regions and focus/reading order>
- Content priority: <primary outcome, CTA, supporting content>
- Components/assets: <component boundaries and real asset sources>
- Responsive structure: <mobile/tablet/desktop changes>
- States: <loading/empty/error/permission/success/destructive>
- Affordances: <AFF-001, AFF-002, ...; every visible or user-triggered control/surface>
```

Use this coverage form. Every `AFF-NNN` declared by a page must appear exactly once. `COMPLETE` maps to a selected `INT-NNN`; `INHERITED` maps to an inherited `INT-NNN`; `NON_INTERACTIVE` uses `REASON: <concrete reason>`.

```markdown
| Affordance ID | Surface/control | Mapping | Coverage |
|---|---|---|---|
| AFF-001 | Primary CTA | INT-001 | COMPLETE |
```

Use this interaction decision form:

```markdown
### INT-001 <Interaction>

- Category: <navigation/scroll/control/form/overlay/state/responsive/motion>
- Surface/control: <exact target>
- Trigger: <click/tap/scroll/swipe/key/submit/system event>
- Outcome: <observable result>
- Materiality: <MATERIAL/INHERITED>
- Option 1 (recommended): <choice> | Trade-off: <cost or limitation>
- Option 2: <choice> | Trade-off: <cost or limitation>
- Option 3: <choice> | Trade-off: <cost or limitation>
- Selected option: <user-selected behavior>
- Status: SELECTED
- Decision source: <user message, issue, or approved design-system rule>
- Dependencies: <related INT IDs or none>
- Relevant states: <loading/empty/error/disabled/submitting/success/destructive/focus/reduced-motion>
- Acceptance: INT-ACC-001
```

### `05-acceptance.md`

Use stable IDs:

```markdown
### FUN-ACC-001 <Behavior>

Given <starting state>
When <action>
Then <observable result>
And <permission/conflict/idempotency result when relevant>
```

Add interaction acceptance:

```markdown
### INT-ACC-001 <Interaction outcome>

- Decision: INT-001
- Trigger: <user/system action>
- Starting state: <visible and stored state>
- Expected transition: <next page/state, motion, focus, scroll, feedback>
- Alternate/reduced-motion behavior: <behavior or not applicable>
- Evidence: <runtime capture or automated interaction check>
```

### `06-visual-acceptance.md`

```markdown
### VIS-ACC-001 <Surface and state>

- Source: <selected option, URL, screenshot, Figma frame, or asset>
- Viewport/device: <exact target>
- State/data: <exact visible state>
- Pass conditions: <layout, typography, spacing, assets, control states>
- Evidence: <side-by-side comparison path or runtime capture>
```

### `07-delivery-roadmap.md`

- Vertical slices and blocking edges
- Requirement/acceptance traceability
- Deferred decisions
- Release and rollback boundaries
- Milestone status

## Validation checklist

- Every index link resolves.
- Every planned slice maps to functional acceptance IDs.
- Every frontend slice maps to visual acceptance IDs.
- Every frontend slice maps to interaction decision and `INT-ACC-NNN` IDs.
- `Design status: LOCKED` appears only after the selected visual, structure approval, and all material interaction decisions are recorded.
- No interaction decision remains `OPEN`, `PENDING`, `UNRESOLVED`, or `TODO` at lock.
- The lock records approval source, revision, and contract fingerprint; a material change reopens the design as `DRAFT`.
- Unconfirmed rules are visibly open/configurable/fail-safe.
- Platform-specific behavior and visuals are split where needed.
- The definition of done includes independent acceptance, handoff, and Git checkpoint.
