# Harness template

Use this as a minimum, not as permission to overwrite an established repository structure.

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

- Selected visual source
- Design tokens and assets
- Screen/state inventory
- Responsive or device behavior
- Interaction, loading, empty, error, and permission states

### `05-acceptance.md`

Use stable IDs:

```markdown
### FUN-ACC-001 <Behavior>

Given <starting state>
When <action>
Then <observable result>
And <permission/conflict/idempotency result when relevant>
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
- Unconfirmed rules are visibly open/configurable/fail-safe.
- Platform-specific behavior and visuals are split where needed.
- The definition of done includes independent acceptance, handoff, and Git checkpoint.
