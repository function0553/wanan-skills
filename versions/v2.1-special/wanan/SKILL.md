---
name: wanan
description: "Use when starting, resuming, or making non-trivial changes to a software project under the Wanan/Harness methodology; when frontend direction, specialized tools, acceptance, handoff, Git checkpoints, or project-scoped learning assessment need governed execution."
---

# Wanan V2.1 特供版

Use gates, not ceremony. Apply the lightest lane that protects the work, then stop at every decision that belongs to the user.

## Choose the lane

- **Bootstrap lane:** Use for a new or materially undocumented project. Complete clarification and Harness gates before implementation.
- **Change lane:** Use for a non-trivial feature, bug fix, architecture change, or visual change in an existing project. Reconcile existing contracts; never recreate them blindly.
- **Resume lane:** Use after compaction, a fresh session, or a handoff. Read the current `HANDOFF.md`, `AGENTS.md`, relevant specs, commits, and live workspace state before acting.
- **Light lane:** Use for a clear, isolated, reversible edit with no product, architecture, visual, security, production, billing, or external-write decision. Skip unnecessary scaffolding, but preserve workspace state, verify the edit, and still treat the completed user-requested deliverable as a mandatory learning module.

If uncertain between lanes, choose the narrower lane and promote only when a gate reveals durable product or architecture work.

## Main controller and branch sessions

Keep the user-facing root session as the controller for every actionable Wanan task. It owns requirement decisions, plans, shared contracts, user updates, acceptance, integration, and final claims. After initial clarification, start at least one bounded branch session for every actionable task when the platform supports branches/threads/subagents, including a one-step Light-lane edit. Keep only purely informational answers or clarification with no delegated work in the controller alone.

Use branch sessions for independently deliverable slices, research, implementation, or acceptance. Give each branch a fixed scope, owned paths, acceptance IDs, starting revision, expected artifacts, and a prohibition on unrelated writes. Prefer an isolated Git branch/worktree for concurrent writers; read-only branches may share the workspace. Monitor with the platform's wait/listener primitive and compact progress snapshots instead of repeatedly rereading full histories.

Track `compaction_count` per branch. On its first observable compaction, require a branch handoff and continue. On its second, require a final branch handoff, stop assigning work to that branch, create a fresh replacement branch for unfinished scope, and pass only durable artifacts plus the handoff. Never guess that compaction occurred: count a platform compaction signal, a summarized-context boundary, or an explicit branch report.

Integrate only completed, accepted branch results. The controller inspects the diff/artifacts, resolves overlaps, runs proportional validation, and merges or cherry-picks the scoped Git result when one exists. A shared-workspace branch is integrated by verified artifact ownership, not by pretending a Git merge occurred. Use [session-orchestration.md](references/session-orchestration.md) for the registry, listener loop, rotation protocol, and integration rules.

If branch-session primitives are unavailable, use a subagent with the same contract. If neither is available, record orchestration as unavailable and continue in the controller without claiming branch independence.

## Gate 0: One-time local preflight

Run once at the start of the root task, cache the capability/environment manifest in controller state, and pass it to branches. Re-run only for a new root task or direct evidence that the manifest is stale.

Inventory `read`, `glob`, `grep`, `bash`, and `replace`; prefer native capabilities and use `scripts/file_ops.py` only for missing file-operation adapters. On Windows, use Git Bash and source `scripts/windows-session-preflight.sh <root-task-id>` once; it creates only task-local temp/UTF-8 state and caches the result. PowerShell-dependent work uses the recorded PowerShell 7 path. Never silently install system software, edit profiles, or clean the user's system temp.

Read [local-tooling.md](references/local-tooling.md) for exact mappings, fallback commands, cache behavior, UTF-8 policy, and cleanup boundaries. Complete this gate when the reusable manifest/report is recorded.

## Gate 1: Ground in evidence

1. Read the nearest applicable `AGENTS.md`, `HANDOFF.md`, spec index, domain glossary, ADRs, and relevant implementation. For the active project root's `经验学习.md`, default to targeted/局部读取 of the top metadata, module registry, and only the active/pending module instead of reloading the entire study book; never search a parent, sibling, or prior project for a substitute learning file. Also use only the active project's `.wanan/assessment-state.json` for protected grading state.
2. Inspect existing files and uncommitted changes before editing. Treat unrelated changes and persistent data as user-owned.
3. Resolve discoverable facts from the workspace or authoritative sources. Ask the user only for decisions.
4. Apply precedence: current user instruction > `AGENTS.md` > acceptance specs > other notes.
5. Keep project evidence scoped to the target named by the user. Prior-project memory may contribute only generalized engineering practices; never import another project's paths, domain terms, business rules, schemas, state enums, assets, specs, or acceptance baselines unless the user explicitly places that project in scope.

Complete this gate when the current state, governing contracts, and user-owned changes are identified.

## Gate 2: Preflight specialized tools and MCPs

Before first use of an external platform, specialized file format, browser, design system, deployment target, remote repository, provider, or unstable API, classify the action risk; read the relevant installed skill and required references; inspect current project/tool schemas and authoritative primary documentation when behavior may change; then select the best purpose-built MCP/app connector. Repeat only when the capability or target changes.

Prefer read-only discovery before mutation. If no callable connector exists, use the supported plugin/app discovery flow when relevant; otherwise state the fallback, lost guarantees, side effects, and required authorization before taking materially riskier/costly/production-affecting action. Never present advertised metadata as verified backing behavior.

Use [tool-mcp-preflight.md](references/tool-mcp-preflight.md) as the detailed routing/mutation authority. Complete this gate when the chosen capability, schema, authorization boundary, and fallback status are explicit.

## Gate 3: Clarify material ambiguity

Stop before generating implementation when an unresolved choice can change product behavior, scope, data, permissions, billing, cancellation, fulfillment, capacity, production, destructive actions, external writes, or visual direction.

Ask one decision at a time. Prefer exactly three materially distinct options:

1. Put the recommended option first.
2. State one concrete trade-off per option.
3. Explain the consequence of deferring the choice.
4. Wait for the answer before moving to the next dependent decision.

Do not ask for facts that can be inspected. For a low-risk, local, reversible detail, state the assumption and proceed.

Complete this gate when actors, outcomes, in-scope behavior, out-of-scope behavior, constraints, and acceptance boundaries are explicit. Record any intentionally deferred decision as configurable, fail-safe, or blocked; never hard-code a guess.

## Gate 4: Establish or reconcile the Harness

For the Bootstrap lane, create:

- Root `AGENTS.md`: purpose, instruction precedence, domain constraints, security and quality constraints, task routing/spec index, validation expectations, and definition of done.
- Root `经验学习.md`: the single mandatory, current-project-only **user-facing** learning book, module registry, question book, stage-score record, and final mastery summary.
- Root `.wanan/assessment-state.json`: hidden current-project-only grading state for stable paper IDs and correct option sets; never surface its answer key.
- `spec/README.md`: numbered index and reading order.
- Product scope, domain/workflows, architecture, visual/interaction decisions, functional and interaction acceptance, visual acceptance, and delivery/decision documents.

Use [harness-template.md](references/harness-template.md) for the minimum structure. Run `scripts/init-harness.ps1` only for a new target with none of the generated files present. In an existing project, edit the current documents in place and preserve their naming and platform split. If the existing project lacks `经验学习.md`, run `scripts/ensure-learning.ps1 -ProjectRoot <path>` or create the same schema manually, then reconcile historical completed modules into the mandatory assessment backlog. This reconciliation may happen before or alongside new implementation and must not block development.

Write functional acceptance as stable IDs with Given/When/Then. Give interaction acceptance `INT-ACC-NNN` IDs and visual acceptance its own IDs, target viewport/device, state, source reference, and observable pass condition. Separate platforms when their behavior or presentation differs.

Maintain a glossary in `CONTEXT.md` only when domain language needs sharpening. Keep it implementation-free. Record an ADR only for a decision that is hard to reverse, surprising without context, and based on a real trade-off.

After filling the Harness, run `scripts/validate-harness.ps1 -ProjectRoot <path>`. Normal strict validation accepts an explicitly recorded frontend `DRAFT` while checking its schema and requires the project-local learning contract. Gate 6 later runs `-RequireFrontendLock`. Use `-AllowPlaceholders` only to smoke-test a newly generated scaffold; it is not completion evidence.

Complete this gate when strict validation passes, every planned slice traces to a requirement and acceptance ID, all index links resolve, and unresolved rules remain visibly unresolved.

## Mandatory learning track: always on

The learning track is a hard Wanan invariant for every actionable lane; informational/clarification-only turns are exempt. The full learning, backfill, reassessment, grading, persistence, bilingual-annotation, beginner-teaching, answer-tolerance, large-file reading, and final-score contract lives in [learning-assessment.md](references/learning-assessment.md). Read it before the first learning action and treat it as the single authority for learning behavior.

Keep exactly one current-project `经验学习.md` as the user-facing study/question/score book and one hidden `.wanan/assessment-state.json` as protected grading state. Never merge, inherit, search for, or score from another project's learning artifacts, and never expose protected correct-option sets in chat, `经验学习.md`, `HANDOFF.md`, or summaries.

For existing projects, reconstruct only real completed modules from current-project evidence. Missing assessments become `BACKFILL_REQUIRED`; materially changed previously assessed modules become `REASSESSMENT_REQUIRED`. Do not invent placeholder historical modules. Learning and assessment are mandatory backlog work but **do not block later implementation**; low scores, pending confirmation, or pending exams never gate Gate 7. Final comprehensive learning scoring stays `PENDING` until every required module has a current valid assessment.

After the Harness/slice plan is ready, give the user a beginner-friendly project stack brief and persist the detailed version in `经验学习.md`. In educational prose, every English technical term or abbreviation gets an immediate Chinese annotation on first appearance in the project overview/module topic (for example `API（应用程序接口）`); literal code, paths, commands, keys, and identifiers remain unchanged.

After Gate 8 accepts a module, create/update its detailed beginner-first lesson, tell the user the concise technology/knowledge summary, and wait for explicit learning confirmation before generating that module's assessment. The assessment is always exactly 10 choice-only questions, includes both single-choice and multiple-choice items, totals exactly 100 points with non-uniform point values, persists the protected answer key before presentation, tolerates compact answer formats, reveals only per-question `对/错` plus the module score, and never writes correct answers into `经验学习.md`. Validate completed module assessments with `-RequireLearningAssessment`.

At full-project completion, do not run another exam. Compute the 0-100 comprehensive learning score only from prior current module scores and assigned learning weights; if any mandatory module is still pending, leave the learning score `PENDING` while allowing project delivery. Finalize and validate the learning record with `-RequireLearningComplete` only after all required module assessments are current.

## Gate 5: Slice the work

Break work into tracer-bullet vertical slices:

- Each slice delivers a narrow, complete, independently demonstrable behavior.
- Each slice fits a fresh context window.
- Each slice declares its blocking edges.
- Each slice names its functional, interaction, and visual acceptance IDs when applicable.
- Each meaningful slice receives a stable `MOD-NNN` learning-module ID and a learning weight based on architecture importance, dependency centrality, user-facing centrality, and knowledge difficulty.
- Use expand-migrate-contract for a wide mechanical refactor that cannot land green as one vertical slice.

Agree on public testing seams before writing tests. Prefer red-green development at those seams: one failing behavior test, the minimum implementation, then the next slice. Keep tests behavior-facing and independent of implementation details.

Complete this gate when the next slice can be implemented and accepted without relying on unstated future work, and every planned/current/historical deliverable module has an explicit learning state in the active project's `经验学习.md`.

## Gate 6: Explore and lock the frontend design

Apply this gate to net-new frontend screens, visual redesigns, and material UI or interaction changes.

1. Invoke the Product Design router, load its critical overrides, run the saved-context preflight, and satisfy its `get-context` brief gate.
2. Reuse saved product context and inspect the existing design system, related screens, assets, tokens, components, and interaction conventions.
3. Use Product Design `ideate` and ImageGen to generate exactly three independent visual options. Existing URLs, screenshots, Figma frames, mockups, or code targets ground all three options; they do not waive the three-option comparison. Record one batch ID, all three displayed result IDs in displayed order, and their independence; never use request order.
4. Show all three options and wait for the user to choose one. Resolve the exact displayed result, record the selection source, and fail closed on fewer/more than three results or an ambiguous selection.
5. Acknowledge and record the selected visual target, but do **not** route to `image-to-code` or begin implementation yet.
6. Decompose the selected design into pages/routes, viewport sections, content hierarchy, components, assets, responsive rules, and visible loading/empty/error/permission states. Give every visible or user-triggered affordance an `AFF-NNN` ID in its `PAGE-NNN` record. Present the structure before interaction questions. Set `Structure status: APPROVED` only after the user approves it and record the approval source.
7. Create an interaction decision register covering every user-triggered interaction: navigation/page switching, scroll behavior, buttons and CTAs, tabs/menus/overlays, forms, feedback and restoration, responsive/touch/keyboard behavior, and motion/reduced-motion behavior. Maintain an `AFF-NNN` coverage matrix; every declared affordance must map exactly once to an `INT-NNN` or a concrete non-interactive reason. An inherited rule still uses an `INT-NNN` record with accepted evidence.
8. For each material interaction, assign an `INT-NNN` ID and offer exactly three materially distinct choices. Put the recommendation first, state one trade-off per choice, and wait for the user's selection. Do not silently preselect the recommendation. Mark standard behavior `INHERITED` without three options only when the source design system proves it and the user explicitly accepts that inheritance.
9. Keep the design status `DRAFT` while any structural choice, affordance coverage, or interaction is unresolved. Record every choice, its outcome, materiality, relevant states, source, dependencies, and `INT-ACC-NNN` acceptance IDs.
10. When every interaction is `SELECTED` or explicitly accepted as `INHERITED` and coverage is `COMPLETE`, present one frontend lock package: exact visual source, approved page structure, interaction/state-flow map, responsive and accessibility behavior, and acceptance traceability. Ask the user to lock it.
11. Set `Design status: LOCKED` only after the user approves that complete package. Record approval source, revision, and a contract fingerprint, then run `scripts/validate-harness.ps1 -ProjectRoot <path> -RequireFrontendLock`. Then and only then route the locked contract plus selected visual target to Product Design `image-to-code`.

Do not scaffold or implement the frontend before the design is `LOCKED`. Selecting one of the three images is necessary but not sufficient. A full brief or permission to make assumptions does not waive the structure and interaction gates.

If Product Design is unavailable, pause this gate and ask the user to install/connect it. Do not silently replace it with prose-only ideation, an unrelated design tool, or an agent-invented visual target.

For faithful work from a supplied URL, screenshot, Figma frame, mockup, source image, or existing code target, capture and inspect that source first and preserve its design system unless the user asks for a redesign. Use it to ground three faithful implementation directions, then complete the same explicit selection, structure, interaction, and lock flow.

Read [frontend-design-lock.md](references/frontend-design-lock.md) for the decision schema, required interaction categories, question format, lock checklist, and Product Design handoff boundary.

After implementation, compare the selected source and rendered result at the same viewport and state, and exercise every locked `INT-ACC-NNN` flow. Build success and screenshots from a different state are not visual or interaction acceptance.

Complete this gate only when the exact visual target is recorded, page structure is approved, every material interaction decision is resolved, the user has approved the lock package, and the spec says `Design status: LOCKED` with observable visual and interaction pass conditions.

Any material visual, structural, responsive, accessibility, or interaction change after lock returns the design to `DRAFT`, invalidates the prior fingerprint, updates acceptance, and requires user reapproval.

## Gate 7: Implement one slice

Implement only the selected slice. For frontend work, refuse to scaffold, start a server, edit production frontend files, or invoke `image-to-code` unless Gate 6 is `LOCKED` and `validate-harness.ps1 -RequireFrontendLock` passes. Implement from the selected visual plus interaction register rather than filling behavior gaps yourself. Revalidate server-authoritative rules at write boundaries, preserve permission separation, use transactions/idempotency where the contract requires them, and keep sensitive data out of logs.

Run the narrow feedback loop throughout: type/static checks and the smallest relevant tests. Run broader regression in proportion to risk before acceptance. Distinguish local, simulated, device, provider, concurrency, and production evidence.

Complete this gate when the slice works through its public seam and every claimed check has recorded evidence.

## Gate 8: Independent acceptance

Treat every completed slice/node as a milestone. Before starting the next slice, dispatch a fresh subagent against the fixed acceptance baseline for the slice just completed.

- Give it the raw spec, acceptance IDs, diff/fixed point, and runnable artifacts.
- Do not give it the intended answer, suspected defect, or implementation rationale.
- Ask it to assess **Spec** and **Standards** separately.
- When the repository permits, let the subagent design and add acceptance tests only under the test area; the main agent owns production code.
- Require runtime or foreground evidence for visual and interactive claims, including every applicable `INT-ACC-NNN` flow.
- If the subagent finds failures, the main agent fixes them and dispatches a fresh acceptance pass.

If subagents are unavailable, mark independent acceptance as unverified. A main-agent self-review cannot be relabeled as independent acceptance.

Complete this gate only when the subagent reports every applicable acceptance ID as passed or explicitly lists a user-approved exception. Gate 8 acceptance immediately creates or updates the mandatory per-module learning backlog above, but a pending learning confirmation or assessment does **not** block a later Gate 7 implementation.

## Gate 9: Write the handoff

Update the project handoff after every milestone and whenever compaction, context pressure, a fresh session, or another agent boundary occurs. Use the project convention; default to root `HANDOFF.md`.

Use [handoff-template.md](references/handoff-template.md). Include at minimum:

- completed work and evidence;
- unfinished work;
- blockers and unresolved decisions.

Also include the current slice, changed artifacts, validation commands/results, commit/push state, risks, and the exact next action. Include current learning module/state, pending `BACKFILL_REQUIRED` modules, completed module scores, and the active project's `经验学习.md` status. Link to specs, ADRs, issues, commits, and the learning book instead of duplicating them. Redact secrets.

For controller-led work, include the branch registry, `compaction_count`, replacement branch, integration state, and ownership of unfinished artifacts. For frontend work, also record the selected visual result, structure approval, open/selected interaction IDs, lock status, and Product Design handoff stage. A branch handoff must contain completed work/evidence, unfinished work, blockers, changed paths or commit, and the exact resumption action.

Complete this gate when a fresh agent can continue without reconstructing hidden conversation history.

## Gate 10: Create the Git checkpoint

After independent acceptance passes:

1. Confirm the target is a Git worktree and inspect status, diff, and branch.
2. Stage only files belonging to the accepted slice plus its project-local `经验学习.md` update and current `HANDOFF.md`. Preserve unrelated user changes.
3. Create one focused commit that names the delivered behavior or acceptance IDs.
4. Push only when the user has explicitly authorized that remote/branch or the project records standing push authorization. Ask before a first push, protected-branch push, force push, release, or production deployment.
5. Record commit and push state in `HANDOFF.md`.

If the target is not a Git worktree, report the missing checkpoint. Initialize or attach a remote only with user authorization.

Complete this gate when the accepted slice is recoverable from a scoped commit and its remote status is explicit.

## Completion contract

Declare a milestone complete only when:

- requirements and deferred decisions are traceable;
- no out-of-scope project memory, business baseline, or workspace artifact has contaminated the target;
- the one-time tool/environment manifest is recorded and reused by branches;
- specialized tools passed the documentation/MCP preflight, or their fallback is explicit;
- Harness/spec changes match the implementation;
- the selected visual target is verified when applicable;
- frontend structure and every material interaction are user-resolved and `Design status: LOCKED` before implementation;
- targeted and proportional regression checks pass;
- independent acceptance passes;
- the mandatory learning track is active and `经验学习.md` belongs to the current project only; pending module assessments may coexist with completed implementation, but every completed/historical module must hold a current valid `ASSESSED` result before the final comprehensive learning score is finalized;
- completed branch results are integrated and every rotated branch has a durable handoff;
- `HANDOFF.md` is current and records learning/backfill state;
- at full-project completion, `经验学习.md` contains the weighted final score derived only from prior module scores and no final exam was run;
- the Git checkpoint is created and push state is explicit;
- every unrun production, provider, device, concurrency, migration, rollout, or paid check is named.

Read [method-map.md](references/method-map.md) when modifying this skill or explaining how Wanan combines the user's rules with Matt Pocock's engineering skills.
