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

Track `compaction_count` per branch as a **corruption-prevention upper bound**, not as a merge gate. A branch never waits for compaction to become mergeable. If its scoped function is complete before any compaction boundary, run only the directly affected targeted acceptance, create the scoped commit, integrate it immediately, retire that completed branch, and open the next bounded branch/slice. On the first observable compaction of still-unfinished work, require a durable handoff and continue. On the second observable compaction of still-unfinished work, require a final handoff, retire the branch, and create a fresh replacement for the remaining scope. Never guess that compaction occurred: count a platform compaction signal, a summarized-context boundary, or an explicit branch report. Two compactions are the upper bound, **not a merge gate** and never a reason to keep completed work alive.

Integrate completed, accepted branch results immediately rather than waiting for compaction. The controller inspects only the scoped diff/artifacts, resolves overlaps, runs the directly affected unit/contract/acceptance checks, and merges or cherry-picks the scoped Git result when one exists. Do not add security review, unrelated audit work, or extra regression merely to occupy a branch until compaction. A shared-workspace branch is integrated by verified artifact ownership, not by pretending a Git merge occurred. Use [session-orchestration.md](references/session-orchestration.md) for the registry, listener loop, upper-bound rotation protocol, and completion-driven integration rules.

If branch-session primitives are unavailable, use a subagent with the same contract. If neither is available, record orchestration as unavailable and continue in the controller without claiming branch independence.

## Gate 0: One-time local preflight

Run this gate exactly once at the start of the root task. Store the capability manifest and environment report in controller state and pass them to every branch; branches must not repeat it. Re-run only when the user starts a new root task or evidence shows the recorded capability changed.

Prefer these local capabilities in order:

1. `read`: bounded, line-numbered, encoding-aware reads; never load a large file blindly.
2. `glob`: file discovery by scoped patterns.
3. `grep`: content search with paths and line numbers.
4. `bash`: on Windows, invoke Git Bash explicitly and use it as the default terminal.
5. `replace`: previewed, count-checked, atomic text replacement; use precise patches for small edits.

Inventory native tools once. When `read`, `glob`, `grep`, or `replace` is absent, use `scripts/file_ops.py` as the bundled adapter rather than rediscovering alternatives. When Git Bash is absent, locate it in standard Git for Windows paths; if still absent, request authorization for a supported Git for Windows installation because a Skill cannot safely emulate Bash. Do not perform a system-wide installation silently.

On Windows, source `scripts/windows-session-preflight.sh <root-task-id>` through Git Bash once. It performs a bounded check of the original temp directory, creates a clean task-local temp directory, exports UTF-8 settings for Wanan child processes, detects PowerShell 7, and caches the result for all branches. It never deletes or changes the system temp directory and never edits a PowerShell profile. Prefer Git Bash; run PowerShell-dependent scripts only with PowerShell 7 (`pwsh`) and process-local UTF-8 settings. If PowerShell 7 is missing, request authorization before installing it or use a non-PowerShell adapter when equivalent.

Read [local-tooling.md](references/local-tooling.md) for exact capability mappings, invocation examples, cache behavior, UTF-8 policy, and cleanup boundaries.

## Gate 1: Ground in evidence

1. Read the nearest applicable `AGENTS.md`, `HANDOFF.md`, spec index, domain glossary, ADRs, and relevant implementation. For the active project root's `经验学习.md`, default to targeted/局部读取 of the top metadata, module registry, and only the active/pending module instead of reloading the entire study book; never search a parent, sibling, or prior project for a substitute learning file. Also use only the active project's `.wanan/assessment-state.json` for protected grading state.
2. Inspect existing files and uncommitted changes before editing. Treat unrelated changes and persistent data as user-owned.
3. Resolve discoverable facts from the workspace or authoritative sources. Ask the user only for decisions.
4. Apply precedence: current user instruction > `AGENTS.md` > acceptance specs > other notes.
5. Keep project evidence scoped to the target named by the user. Prior-project memory may contribute only generalized engineering practices; never import another project's paths, domain terms, business rules, schemas, state enums, assets, specs, or acceptance baselines unless the user explicitly places that project in scope.

Complete this gate when the current state, governing contracts, and user-owned changes are identified.

## Gate 2: Preflight specialized tools and MCPs

Run this gate before the first use of an external platform, specialized file format, browser, design system, deployment target, remote repository, provider, or unstable API. Repeat only when the required capability or target system changes. Ordinary local file reads, searches, patches, and test commands stay lightweight unless a specialized connector could materially change correctness.

1. Classify the intended action as read-only, external write, destructive, paid, or production-affecting.
2. Read the corresponding installed skill's `SKILL.md` completely. Follow its mandatory references and prerequisites before acting.
3. Inspect relevant project documentation and current tool schemas. For changing APIs or provider behavior, consult primary official documentation rather than relying on recall.
4. Search the available tool catalog for a purpose-built MCP or app connector by capability. In Codex, use `tool_search` for deferred tools and MCP discovery; do not substitute raw MCP resource enumeration for installed Apps.
5. Prefer the purpose-built connector over browser automation, shell commands, or raw HTTP when it represents the target system and supports the needed action.
6. If no suitable connector is callable, check whether an appropriate plugin/app can be installed or connected through the supported plugin-management flow. Suggest it when relevant; do not claim it was installed until confirmed.
7. If no connector path exists, state the fallback, its lost guarantees, and any authorization or fidelity impact. Ask before using the fallback when it materially changes risk, cost, production state, or the user's result.
8. Inspect the selected tool's schema and authorization boundary before the first call. Start with read-only discovery when practical, then keep mutations inside the user's explicit scope.
9. Verify real backing behavior. Do not present metadata, prompt facades, or advertised capabilities as working execution without evidence.

Use [tool-mcp-preflight.md](references/tool-mcp-preflight.md) for capability routing, source order, missing-tool handling, and mutation boundaries.

Complete this gate when the relevant skill and current sources have been read, a suitable MCP/app has been selected or explicitly ruled out, the call schema is understood, and fallback/side effects are visible.

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

The learning track is a hard Wanan invariant for every actionable lane and cannot be disabled, skipped, or replaced with an optional summary. Informational/clarification-only turns are exempt because they deliver no implemented module. Read [learning-assessment.md](references/learning-assessment.md) before the first learning action.

Use exactly one **user-facing** learning artifact at the active project root: `经验学习.md`. It belongs only to that project. Never merge, inherit, search for, or score from another project's learning file. **聊天框（chat）是唯一权威的完整教学与考试交互载体：** all knowledge that may be tested must first be fully explained in chat, not merely written to a file. `经验学习.md` is the durable project review/question/score book and may archive or expand already-taught material after it has been presented in chat, but it must never substitute for chat teaching. Maintain one hidden project-local machine state at `.wanan/assessment-state.json` to persist paper IDs, points, correct option sets, and knowledge-source IDs across compaction/session changes. Before grading, protected answers stay hidden there. After the user's full paper is graded, `经验学习.md` must archive each question's correct answer and a beginner-readable `为什么这样选` explanation; do not reveal those explanations in the grading chat unless the user separately asks. Never put answer keys in `HANDOFF.md` or ordinary summaries.

### Existing-project backfill

On Change and Resume lanes, and on Bootstrap when implementation already exists, reconstruct previously completed deliverable modules from current-project evidence: Harness roadmap/acceptance, `HANDOFF.md`, scoped commits, runnable code, and accepted behavior. Any real completed module without a valid recorded assessment becomes `BACKFILL_REQUIRED`. Register every such module as a mandatory assessment backlog item and prepare its project-grounded lesson. **Do not invent a placeholder historical `MOD-NNN` when project evidence has not established one.** **Do not block Gate 7 or later implementation while the user has not yet completed the learning confirmation or assessment.** Each historical module must still receive one learning cycle and one 10-question assessment before the final comprehensive learning score is produced. Do not collapse clearly separate historical product modules into one giant exam merely to reduce work.

Neither a low score nor an incomplete assessment blocks implementation progress. If a completed module is still `BACKFILL_REQUIRED`, `WAITING_FOR_LEARNING_CONFIRMATION`, `ASSESSING`, or `REASSESSMENT_REQUIRED`, keep it in the mandatory assessment backlog and continue later implementation when useful. The learning track cannot be skipped: every completed module must still hold a current valid assessment before final comprehensive learning scoring. A score of 0 is valid and never blocks development. If later accepted work materially changes a previously taught/tested technology, architecture/data/control flow, security model, public interface, runtime/deployment model, or core observable behavior, mark that module `REASSESSMENT_REQUIRED`, refresh its lesson, preserve its earlier attempt as history, and reassess when the user is ready; trivial/cosmetic changes do not trigger reassessment.

### Project stack brief

After the Harness and slice plan are ready, but before first implementation, tell the user the selected/inherited technology stack, each technology's role, why it is used here, the modules that will use it, and the main knowledge areas they will encounter. Assume a beginner unless the user clearly demonstrates otherwise. In user-facing educational prose, every English technical term or abbreviation must receive an immediate Chinese annotation on its first appearance in the project overview/module topic, for example `API（应用程序接口）` and `ORM（对象关系映射）`; do not alter literal code, paths, commands, keys, or identifiers. After presenting the stack knowledge in chat, archive the same already-taught content in `经验学习.md` for review. The file may add review detail, but exam-eligible knowledge must not appear there unless it was already taught in chat. This orientation is not a separate exam unless it is itself a completed deliverable module.

### Per-module learning cycle

After Gate 8 accepts each new module, and for every `BACKFILL_REQUIRED` historical module, run or schedule the following mandatory learning cycle. This cycle is mandatory but non-blocking for subsequent implementation:

1. **Teach the full beginner-first lesson directly in chat first**, grounded only in the current project's real artifacts. Explain in the order: what it does -> why this project needs it -> terms -> code mapping -> runtime flow -> design reason -> common mistakes -> deeper understanding. Classify knowledge as `必须掌握`, `建议理解`, or `了解即可`, apply English（中文注释） on first use of technical English terms, and assign stable knowledge IDs such as `K1`, `K2`, `K3` to the points actually taught in that chat lesson.
2. After the chat lesson is delivered, archive those same taught knowledge IDs and review notes into that module's section of `经验学习.md`. The file may be more detailed for revision, but **the exam scope is limited to knowledge already explicitly taught in chat**. Never tell the user to read `经验学习.md` instead of giving the teaching content in chat.
3. Wait for explicit confirmation that learning is complete before generating that module's questions. If the user has not confirmed yet, leave the module in `WAITING_FOR_LEARNING_CONFIRMATION` and allow later development modules to proceed; do not mark the learning requirement complete.
4. Generate exactly 10 choice-only questions with both single-choice and multiple-choice items. Total points must equal 100 and point values must not all be equal. Every question must include `知识点来源: Kx` (or multiple taught IDs) and may test only those chat-taught IDs. Do not use trick questions, double negatives, ambiguous wording, cold trivia, or content outside the just-delivered chat lesson/project evidence. Before showing the paper, persist a unique `paper_id`, question types/points, correct option sets, and referenced knowledge IDs to current-project `.wanan/assessment-state.json`; write the same `Assessment paper ID` and visible paper (without answers) to `经验学习.md`.
5. Accept compact answers such as `1A`, `1.A`, `7ABC`, and `7 A,C`; normalize case/separators/spacing. If answers are incomplete or one item is malformed, ask only for the missing/invalid question numbers. Multiple-choice is exact-set scoring with no partial credit.
6. Grade against `.wanan/assessment-state.json` rather than conversation memory, and in chat report only `对/错` for each question plus the module score. Do not reveal correct options or explanations in the grading chat. **After the whole submitted paper is graded**, append to each question in `经验学习.md`: the user's answer, `结果: 对/错`, `正确答案`, and `为什么这样选` (a beginner-readable explanation tied back to the referenced `K` knowledge point). Do not write these answer/explanation fields before the user submits the paper.
7. When the user eventually completes the assessment, mark the module `ASSESSED` and run `scripts/validate-harness.ps1 -ProjectRoot <path> -RequireLearningAssessment -LearningModuleId <MOD-NNN>`. Development may already have progressed; the score never gates implementation.

At final project completion, do **not** run another exam. Use only prior module scores and model-assigned learning weights to produce a 0-100 comprehensive score, write the final mastery summary to the same `经验学习.md`, and validate with `-RequireLearningComplete`.

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

Run the narrow feedback loop throughout: only type/static checks and unit/contract/acceptance tests directly affected by this slice. Before acceptance, run **targeted acceptance** for the impacted behavior only. Do **no full-repository** or full-suite regression in the milestone path, and do not repeat broad repository checks across branches. Distinguish local, simulated, device, provider, concurrency, and production evidence only where the current change or fixed acceptance contract directly requires it.

Complete this gate when the slice works through its public seam and every claimed check has recorded evidence.

## Gate 8: Independent acceptance

Treat every completed slice/node as a milestone. As soon as its scoped function is complete—whether `compaction_count` is 0, 1, or 2—dispatch a fresh subagent against only the fixed acceptance baseline directly affected by that slice. Do not wait for a compaction boundary before acceptance, commit, integration, or creation of the next branch.

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

After directly affected independent acceptance passes, without waiting for compaction:

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
- directly affected unit/contract/acceptance checks pass, with no full-repository or repeated full-suite run;
- independent acceptance passes;
- the mandatory learning track is active and `经验学习.md` belongs to the current project only; pending module assessments may coexist with completed implementation, but every completed/historical module must hold a current valid `ASSESSED` result before the final comprehensive learning score is finalized;
- completed branch results are integrated and every rotated branch has a durable handoff;
- `HANDOFF.md` is current and records learning/backfill state;
- at full-project completion, `经验学习.md` contains the weighted final score derived only from prior module scores and no final exam was run;
- the Git checkpoint is created and push state is explicit;
- every unrun production, provider, device, concurrency, migration, rollout, or paid check is named.

Read [method-map.md](references/method-map.md) when modifying this skill or explaining how Wanan combines the user's rules with Matt Pocock's engineering skills.
