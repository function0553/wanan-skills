# Wanan method map

Wanan is a self-contained fusion. It does not require the upstream skills to be installed at runtime.

## User rules as hard gates

| User rule | Wanan behavior |
|---|---|
| Clarify unclear requirements; AI may offer three options | Gate 3 asks one decision at a time with three materially distinct options and a recommendation. |
| Build a Harness before a project | Gate 4 creates/reconciles `AGENTS.md`, indexed specs, functional acceptance, and visual acceptance. |
| Ask before generating when unsure | Gates 3 and 6 stop on material product or visual decisions. |
| Write a handoff after compaction | Gate 9 updates project-local `HANDOFF.md` after compaction and every milestone. |
| Use Product Design and three visual drafts | Gate 6 follows Product Design context and ideation routing, generates exactly three independent options, and binds selection to displayed result order. |
| Decompose and choose frontend interactions before finalizing | After visual selection, Gate 6 requires an approved page structure, complete `AFF-NNN` coverage, three explicit choices for every material interaction, and bidirectional `INT-NNN`/`INT-ACC-NNN` traceability before the design can be locked or built. |
| Use a subagent to accept each node | Gate 8 gives a fresh subagent the fixed acceptance baseline and keeps production implementation with the main agent. |
| Upload completed parts with Git | Gate 10 creates scoped commits and pushes only to an authorized remote/branch. |
| Read relevant material and check MCPs before other tools | Gate 2 reads the matching skill and current sources, discovers a purpose-built MCP/app, and makes any fallback explicit before specialized tool use. |
| Prefer read/glob/grep/Git Bash/replace and fill missing local tools once | Gate 0 inventories capabilities once per root task, uses bundled file adapters, caches the manifest for branches, and routes Windows terminal work through Git Bash. |
| Avoid slow `%TEMP%` and encoding failures | Gate 0 creates a clean task-local temp directory without changing system Temp, checks PowerShell 7 once, and standardizes child-process UTF-8. |
| Keep the main session as controller and use compaction only as an upper bound | The controller integrates completed accepted work immediately, opens the next bounded branch without waiting for compaction, and rotates only still-unfinished work at the second compaction boundary. |
| Keep the Skill independent from any one project | Wanan may reuse generalized engineering practices from memory, but rejects project-specific paths, domains, schemas, states, assets, specs, and acceptance baselines unless that project is explicitly in scope. |
| Force project-scoped learning for every delivered module | The mandatory learning track uses one root `经验学习.md`, beginner-first bilingual terminology, explicit learning confirmation, exactly 10 choice questions, protected `.wanan/assessment-state.json` answer persistence, unequal point weights totaling 100, per-question right/wrong grading, and a non-blocking score. |
| Backfill already-developed work | Change/Resume entry reconstructs only real completed current-project modules and marks unassessed ones `BACKFILL_REQUIRED`; it never invents a placeholder legacy module, and backlog items do not block new implementation. |
| Keep learning records isolated by project | `经验学习.md` and `.wanan/assessment-state.json` are read and updated only from the active project root; sibling/prior project learning files are never merged or inherited. |
| Reassess materially changed learning | If accepted work changes a taught/tested technology, architecture, security model, runtime flow, interface, or core behavior, mark the prior module `REASSESSMENT_REQUIRED`; development remains non-blocking but final learning scoring waits for a current assessment. |
| Final mastery comes from stage evidence | Final 0-100 mastery is derived from prior module scores and model-assigned module weights; Wanan never runs a final exam. |

## Matt Pocock concepts incorporated

Source: `mattpocock/skills` (MIT), especially:

- `grilling`: discover facts; ask the user one decision at a time; recommend an answer.
- `domain-modeling`: sharpen canonical language, use concrete scenarios, maintain an implementation-free glossary, and create ADRs sparingly.
- `to-spec`: synthesize clarified intent into a traceable spec and pre-agree public testing seams.
- `to-tickets`: use tracer-bullet vertical slices with blocking edges.
- `tdd`: work red-green through public seams one behavior at a time.
- `code-review`: keep Standards and Spec acceptance as separate axes and use isolated subagents.
- `handoff`: bridge context windows with a concise, secret-free artifact that points to existing sources of truth.
- `writing-great-skills`: use explicit invocation branches, completion criteria, progressive disclosure, and one source of truth.

## User-specific precedence over upstream

- Wanan writes the durable handoff to the project convention (default `HANDOFF.md`), not only to an OS temporary directory.
- Wanan makes Harness documents and visual acceptance first-class contracts.
- Wanan extends Product Design selection with a page-structure and interaction-decision lock before `image-to-code` or frontend implementation.
- Wanan requires capability discovery and a documentation/MCP preflight before specialized tools or external systems.
- Wanan performs local capability and Windows environment checks once per root task and shares the cached result with branches.
- Wanan keeps the root session as controller, treats two compactions as an upper-bound corruption boundary rather than a merge gate, and integrates completed accepted branches immediately.
- Wanan treats directly affected independent acceptance and scoped version control as milestone gates, without full-repository regression.
- Wanan preserves user-owned workspace changes and distinguishes local evidence from runtime, device, provider, concurrency, paid, and production evidence.
- Wanan treats the active target as an isolation boundary and never converts one project's business baseline into a universal rule.
- Wanan also treats learning history as project-local: one `经验学习.md` per active project, with mandatory legacy-module backfill and no cross-project score contamination.

## Invocation timing

Invoke automatically for:

- new projects and significant project continuations;
- non-trivial product, architecture, data, permission, or cross-surface changes;
- ambiguous behavior with material consequences;
- first use of a specialized tool, external platform, provider, remote service, or unstable API;
- frontend work without a selected visual target or with unresolved structure/interaction decisions;
- milestone acceptance, context compaction, handoff, or Git checkpoint work.

Stay in the Light lane for:

- explanations and read-only reviews;
- one-line commands or translations;
- ordinary local file reads, searches, patches, and test commands with no specialized external capability;
- clear, isolated, reversible edits without durable contract impact.

Promote a Light-lane task only when investigation reveals a material decision or a durable contract change.
