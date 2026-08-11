# Controller and branch-session orchestration

## Branch registry

The main session is the only controller. Keep a registry with:

- branch/session ID and parent controller ID;
- scope, owned paths, fixed acceptance IDs, and starting revision;
- state: `active`, `completed`, `blocked`, or `retired`;
- `compaction_count`: `0`, `1`, or `2`;
- latest durable handoff, replacement ID, commit/diff, and integration state.

## Dispatch

Split work only at low-conflict seams. Give each branch raw source artifacts and a bounded contract. Do not leak the expected answer to an acceptance branch. Concurrent write branches should use isolated Git branches/worktrees; do not let two branches own the same paths unless the controller sequences them.

## Listener loop

Use the platform's thread/branch wait mechanism. Wait on all active branches in one bounded snapshot when supported, carry forward cursors, and report only changed state to the user. Do not busy-poll or repeatedly read entire transcripts.

When a branch needs a product decision, the controller obtains it from the user and relays the answer. Branches must not independently broaden scope, publish, deploy, pay, or perform unapproved external writes.

## Compaction upper bound and completion-driven rotation

`compaction_count` is a context-corruption prevention boundary only. Two compactions are the **upper bound**, not a merge gate, batching target, or minimum branch lifetime. Never keep completed work open to “reach” a compaction.

If a branch becomes complete before compaction:

1. Stop implementation immediately.
2. Run only the unit/contract/acceptance checks directly affected by that branch.
3. Produce the scoped commit/diff and integrate it immediately.
4. Mark that branch `completed`/`retired` and create the next bounded branch when more work remains.

For still-unfinished work, increment the counter only on an observable compaction signal, summarized-context boundary, or explicit branch report.

At compaction 1 of unfinished work:

1. Require a durable branch handoff with completed work/evidence, unfinished work, blockers, owned paths, diff/commit, and exact next action.
2. Let the same branch continue from that handoff.

At compaction 2 of unfinished work:

1. Freeze new assignments to the branch.
2. Require its final durable handoff and classify completed artifacts separately from incomplete artifacts.
3. Mark it `retired` even if it remains technically callable.
4. Create a fresh replacement for unfinished scope using current specs, repository state, accepted artifacts, and the handoff—not the full old conversation.
5. Record the replacement link in both registry entries.

Never reset the counter or keep using a twice-compacted unfinished branch because it still responds. Never delay a completed branch's acceptance or integration to wait for compaction. Do not expand security review, audit scope, or unrelated checks merely to keep a branch occupied.

## Acceptance and integration

The controller integrates a completed result as soon as it passes its directly affected fixed acceptance baseline. Completion before compaction means immediate commit/integration and branch retirement; compaction is never awaited.

1. Inspect branch artifacts and diff against the declared starting revision.
2. Reject unrelated changes and resolve overlaps without overwriting user work.
3. Run independent **targeted acceptance** plus only the unit/contract checks directly affected by the change; do no full-repository or repeated full-suite check.
4. Merge or cherry-pick an isolated Git result into the controller branch; for a shared workspace, verify owned artifacts and record that no Git merge occurred.
5. Update specs, `HANDOFF.md`, registry, commit, and push state.

Incomplete branch work remains explicitly unfinished. Do not mix it into an accepted commit merely because another part of the branch passed.
