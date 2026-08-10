# Controller and branch-session orchestration

## Branch registry

The main session is the only controller. Keep a registry with:

- branch/session ID and parent controller ID;
- scope, owned paths, fixed acceptance IDs, `MOD-NNN` learning-module ID, learning state, and starting revision;
- state: `active`, `completed`, `blocked`, or `retired`;
- `compaction_count`: `0`, `1`, or `2`;
- latest durable handoff, replacement ID, commit/diff, and integration state.

## Learning-state resume discipline

`经验学习.md` may grow into a large project study book. On resume, do **局部读取** by default: read the top learning metadata, `## 模块登记表`, and only the active/pending `MOD-NNN` section needed for the current action. Do not reload the 整本/全文 study book unless a structural audit genuinely requires it. Read `.wanan/assessment-state.json` only when generating/grading/recovering the specific module paper; never surface its protected answers.

Pending `BACKFILL_REQUIRED`, `WAITING_FOR_LEARNING_CONFIRMATION`, `ASSESSING`, or `REASSESSMENT_REQUIRED` items are mandatory learning backlog but remain non-blocking for later implementation.

## Dispatch

Split work only at low-conflict seams. Give each branch raw source artifacts and a bounded contract. Do not leak the expected answer to an acceptance branch. Concurrent write branches should use isolated Git branches/worktrees; do not let two branches own the same paths unless the controller sequences them.

## Listener loop

Use the platform's thread/branch wait mechanism. Wait on all active branches in one bounded snapshot when supported, carry forward cursors, and report only changed state to the user. Do not busy-poll or repeatedly read entire transcripts.

When a branch needs a product decision, the controller obtains it from the user and relays the answer. Branches must not independently broaden scope, publish, deploy, pay, or perform unapproved external writes.

## Compaction rotation

Increment the counter only on an observable compaction signal, summarized-context boundary, or explicit branch report.

At compaction 1:

1. Require a durable branch handoff with completed work/evidence, unfinished work, blockers, owned paths, diff/commit, and exact next action.
2. Let the same branch continue from that handoff.

At compaction 2:

1. Freeze new assignments to the branch.
2. Require its final durable handoff and classify completed artifacts separately from incomplete artifacts.
3. Mark it `retired` even if it remains technically callable.
4. Create a fresh replacement for unfinished scope using current specs, repository state, accepted artifacts, and the handoff—not the full old conversation.
5. Record the replacement link in both registry entries.

Never reset the counter or keep using a twice-compacted branch because it still responds.

## Acceptance and integration

The controller integrates only a completed result that passes its fixed acceptance baseline.

1. Inspect branch artifacts and diff against the declared starting revision.
2. Reject unrelated changes and resolve overlaps without overwriting user work.
3. Run independent acceptance and proportional regression.
4. Merge or cherry-pick an isolated Git result into the controller branch; for a shared workspace, verify owned artifacts and record that no Git merge occurred.
5. After acceptance, return control to the controller to create/update the mandatory learning backlog and `经验学习.md`. The module may remain pending learning/assessment while later implementation, HANDOFF, registry, commit, and push work continues; mark it `ASSESSED` when the user eventually completes its exam.

Incomplete branch work remains explicitly unfinished. Do not mix it into an accepted commit merely because another part of the branch passed.
