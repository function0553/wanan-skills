---
name: wanan
description: "Run a controller-led, gated engineering workflow for non-trivial projects and feature work: perform one-time local-tool and Windows environment preflight, clarify material ambiguity, inspect relevant skills/docs and purpose-built MCP or app connectors, create or reconcile an AGENTS.md plus spec/ Harness, generate three Product Design directions, then require user-selected page structure and interaction decisions before locking frontend implementation, delegate bounded work to monitored branch sessions, integrate completed accepted slices immediately, use two compactions only as an upper-bound rotation boundary for unfinished work, maintain HANDOFF.md, and create scoped Git checkpoints. Use when starting or resuming a project, designing or redesigning a frontend, selecting an external tool or service, requirements affect product behavior, visual or interaction direction is unset, a milestone is complete, or the user invokes Wanan/Harness methodology."
---

# Wanan V2.1

Use gates, not ceremony. Apply the lightest lane that protects the work, then stop at every decision that belongs to the user.

## Choose the lane

- **Bootstrap lane:** Use for a new or materially undocumented project. Complete clarification and Harness gates before implementation.
- **Change lane:** Use for a non-trivial feature, bug fix, architecture change, or visual change in an existing project. Reconcile existing contracts; never recreate them blindly.
- **Resume lane:** Use after compaction, a fresh session, or a handoff. Read the current `HANDOFF.md`, `AGENTS.md`, relevant specs, commits, and live workspace state before acting.
- **Light lane:** Use for a clear, isolated, reversible edit with no product, architecture, visual, security, production, billing, or external-write decision. Skip scaffolding, but preserve workspace state and verify the edit.

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

1. Read the nearest applicable `AGENTS.md`, `HANDOFF.md`, spec index, domain glossary, ADRs, and relevant implementation.
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
- `spec/README.md`: numbered index and reading order.
- Product scope, domain/workflows, architecture, visual/interaction decisions, functional and interaction acceptance, visual acceptance, and delivery/decision documents.

Use [harness-template.md](references/harness-template.md) for the minimum structure. Run `scripts/init-harness.ps1` only for a new target with none of the generated files present. In an existing project, edit the current documents in place and preserve their naming and platform split.

Write functional acceptance as stable IDs with Given/When/Then. Give interaction acceptance `INT-ACC-NNN` IDs and visual acceptance its own IDs, target viewport/device, state, source reference, and observable pass condition. Separate platforms when their behavior or presentation differs.

Maintain a glossary in `CONTEXT.md` only when domain language needs sharpening. Keep it implementation-free. Record an ADR only for a decision that is hard to reverse, surprising without context, and based on a real trade-off.

After filling the Harness, run `scripts/validate-harness.ps1 -ProjectRoot <path>`. Normal strict validation accepts an explicitly recorded frontend `DRAFT` while checking its schema; Gate 6 later runs `-RequireFrontendLock`. Use `-AllowPlaceholders` only to smoke-test a newly generated scaffold; it is not completion evidence.

Complete this gate when strict validation passes, every planned slice traces to a requirement and acceptance ID, all index links resolve, and unresolved rules remain visibly unresolved.

## Gate 5: Slice the work

Break work into tracer-bullet vertical slices:

- Each slice delivers a narrow, complete, independently demonstrable behavior.
- Each slice fits a fresh context window.
- Each slice declares its blocking edges.
- Each slice names its functional, interaction, and visual acceptance IDs when applicable.
- Use expand-migrate-contract for a wide mechanical refactor that cannot land green as one vertical slice.

Agree on public testing seams before writing tests. Prefer red-green development at those seams: one failing behavior test, the minimum implementation, then the next slice. Keep tests behavior-facing and independent of implementation details.

Complete this gate when the next slice can be implemented and accepted without relying on unstated future work.

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

Complete this gate only when the subagent reports every applicable acceptance ID as passed or explicitly lists a user-approved exception.

## Gate 9: Write the handoff

Update the project handoff after every milestone and whenever compaction, context pressure, a fresh session, or another agent boundary occurs. Use the project convention; default to root `HANDOFF.md`.

Use [handoff-template.md](references/handoff-template.md). Include at minimum:

- completed work and evidence;
- unfinished work;
- blockers and unresolved decisions.

Also include the current slice, changed artifacts, validation commands/results, commit/push state, risks, and the exact next action. Link to specs, ADRs, issues, and commits instead of duplicating them. Redact secrets.

For controller-led work, include the branch registry, `compaction_count`, replacement branch, integration state, and ownership of unfinished artifacts. For frontend work, also record the selected visual result, structure approval, open/selected interaction IDs, lock status, and Product Design handoff stage. A branch handoff must contain completed work/evidence, unfinished work, blockers, changed paths or commit, and the exact resumption action.

Complete this gate when a fresh agent can continue without reconstructing hidden conversation history.

## Gate 10: Create the Git checkpoint

After directly affected independent acceptance passes, without waiting for compaction:

1. Confirm the target is a Git worktree and inspect status, diff, and branch.
2. Stage only files belonging to the accepted slice. Preserve unrelated user changes.
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
- completed branch results are integrated and every rotated branch has a durable handoff;
- `HANDOFF.md` is current;
- the Git checkpoint is created and push state is explicit;
- every unrun production, provider, device, concurrency, migration, rollout, or paid check is named.

Read [method-map.md](references/method-map.md) when modifying this skill or explaining how Wanan combines the user's rules with Matt Pocock's engineering skills.
