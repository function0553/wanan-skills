# Wanan method map

Wanan is a self-contained fusion. It does not require the upstream skills to be installed at runtime.

## User rules as hard gates

| User rule | Wanan behavior |
|---|---|
| Clarify unclear requirements; AI may offer three options | Gate 3 asks one decision at a time with three materially distinct options and a recommendation. |
| Build a Harness before a project | Gate 4 creates/reconciles `AGENTS.md`, indexed specs, functional acceptance, and visual acceptance. |
| Ask before generating when unsure | Gates 3 and 6 stop on material product or visual decisions. |
| Write a handoff after compaction | Gate 9 updates project-local `HANDOFF.md` after compaction and every milestone. |
| Use Product Design and three visual drafts | Gate 6 invokes Product Design for net-new/redesign work and requires one of exactly three options to be selected. |
| Use a subagent to accept each node | Gate 8 gives a fresh subagent the fixed acceptance baseline and keeps production implementation with the main agent. |
| Upload completed parts with Git | Gate 10 creates scoped commits and pushes only to an authorized remote/branch. |
| Read relevant material and check MCPs before other tools | Gate 2 reads the matching skill and current sources, discovers a purpose-built MCP/app, and makes any fallback explicit before specialized tool use. |
| Prefer read/glob/grep/Git Bash/replace and fill missing local tools once | Gate 0 inventories capabilities once per root task, uses bundled file adapters, caches the manifest for branches, and routes Windows terminal work through Git Bash. |
| Avoid slow `%TEMP%` and encoding failures | Gate 0 creates a clean task-local temp directory without changing system Temp, checks PowerShell 7 once, and standardizes child-process UTF-8. |
| Keep the main session as controller and rotate compressed branches | The controller delegates bounded work, listens for progress, retires a branch after its second compaction, starts a replacement, and integrates only completed accepted results. |

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
- Wanan requires Product Design selection before net-new frontend implementation.
- Wanan requires capability discovery and a documentation/MCP preflight before specialized tools or external systems.
- Wanan performs local capability and Windows environment checks once per root task and shares the cached result with branches.
- Wanan keeps the root session as controller and makes branch compaction, handoff, replacement, and integration explicit.
- Wanan treats independent acceptance and scoped version control as milestone gates.
- Wanan preserves user-owned workspace changes and distinguishes local evidence from runtime, device, provider, concurrency, paid, and production evidence.

## Invocation timing

Invoke automatically for:

- new projects and significant project continuations;
- non-trivial product, architecture, data, permission, or cross-surface changes;
- ambiguous behavior with material consequences;
- first use of a specialized tool, external platform, provider, remote service, or unstable API;
- frontend work without a selected visual target;
- milestone acceptance, context compaction, handoff, or Git checkpoint work.

Stay in the Light lane for:

- explanations and read-only reviews;
- one-line commands or translations;
- ordinary local file reads, searches, patches, and test commands with no specialized external capability;
- clear, isolated, reversible edits without durable contract impact.

Promote a Light-lane task only when investigation reveals a material decision or a durable contract change.
