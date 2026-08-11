# Mandatory learning and assessment track

This contract is mandatory for every actionable Wanan project lane. It is project-scoped, cannot be disabled, and never imports another project's learning record.

## Core invariants

1. The current project root owns exactly one user-facing learning artifact named `经验学习.md`.
2. `Learning mode: REQUIRED` is immutable while Wanan is active. Do not offer a skip, disable, postpone-indefinitely, or "developer-only" mode.
3. Informational answers and clarification-only turns do not create an assessment. Any implemented or already-implemented meaningful deliverable module does.
4. A module must be an independently meaningful deliverable/slice/stage. Do not create exams for mechanical micro-steps such as imports, renames, file creation, dependency installation, or typo fixes unless that edit is the entire user-requested deliverable.
5. Learning and assessment are mandatory but **non-blocking for implementation**. A completed module may remain pending while later modules are developed; keep it visible in the assessment backlog until it reaches `ASSESSED`.
6. Existing projects are not grandfathered. Any completed module without a recorded Wanan assessment becomes `BACKFILL_REQUIRED`; this does not block new implementation, but that historical module must still be taught and receive a valid assessment before final comprehensive learning scoring.
7. Never read, merge, inherit, or score from `经验学习.md` or grading state outside the active project root.
8. The final project score is derived only from valid recorded module scores and model-assigned module learning weights. Never run a final exam.
9. Before an assessment is submitted and graded, correct answers are protected grading state and must exist only in `<project-root>/.wanan/assessment-state.json`. After the full paper is graded, archive each question's `正确答案` and `为什么这样选` in the current project's `经验学习.md` for review. The grading chat still reports only per-question `对/错` and the stage score unless the user separately asks for explanations. Never place answer keys in `HANDOFF.md` or ordinary summaries.
10. If a previously assessed module changes materially, its old assessment no longer proves mastery of the current implementation. Mark it `REASSESSMENT_REQUIRED`; this remains non-blocking for development but must be resolved before final comprehensive learning scoring.

## Project-scoped durable grading state

`经验学习.md` remains the only user-facing learning/题目本 file. Use one hidden machine-state file only for stable cross-session grading:

`<project-root>/.wanan/assessment-state.json`

Minimum shape:

```json
{
  "schema_version": 1,
  "project_scope": "CURRENT_PROJECT_ONLY",
  "warning": "INTERNAL_GRADING_STATE_DO_NOT_SURFACE",
  "modules": {
    "MOD-001": {
      "paper_id": "MOD-001-<unique-id>",
      "questions": [
        {"id": 1, "type": "single", "points": 6, "correct": "A", "knowledge_ids": ["K1"]}
      ],
      "history": []
    }
  }
}
```

Rules:

- Create the hidden file when the Harness learning files are initialized or when an existing project first receives Wanan learning support.
- Immediately before presenting a generated paper to the user, persist that paper's `paper_id`, question IDs, question types, points, correct option sets, and referenced chat-taught `knowledge_ids` to the matching module in `.wanan/assessment-state.json`.
- Write the same `paper_id` into the module section of `经验学习.md` as `Assessment paper ID`.
- The protected state and visible paper must refer to the same `paper_id`. Never grade an answer against a different or reconstructed paper silently.
- On reassessment, preserve the prior attempt in `history` when practical, replace the module's current paper state, and keep historical scores in `经验学习.md` for review.
- Before grading, never copy `correct` values into user-facing content. After the full paper is graded, copy only the finalized per-question `正确答案` plus a beginner-readable `为什么这样选` explanation into `经验学习.md`; keep `.wanan/assessment-state.json` itself hidden and never dump its raw contents. Validation errors may say grading is inconsistent, but must not print the protected answer.

## Project entry and historical backfill

On Bootstrap, Change, and Resume lanes:

1. Resolve the active project root before reading learning data.
2. Read only the required parts of `<project-root>/经验学习.md` (see **Large study-book reading policy**) if it exists. Do not search parent/sibling projects for another copy.
3. Ensure `<project-root>/.wanan/assessment-state.json` exists. Never borrow another project's grading state.
4. Reconstruct completed modules from the strongest local evidence available: current Harness roadmap/acceptance, `HANDOFF.md`, scoped commits, runnable implementation, and accepted behavior.
5. Compare reconstructed completed modules with the module registry in `经验学习.md`.
6. For every real completed module with no valid assessment, add or update its row to `BACKFILL_REQUIRED`.
7. **Do not invent a placeholder historical module.** If no completed historical module can be identified yet, keep the registry empty until project evidence establishes real module boundaries.
8. Keep all `BACKFILL_REQUIRED` modules in a visible mandatory assessment backlog. Teach and assess them in a sensible dependency/delivery order when the user is ready, without blocking Gate 7 or later implementation.
9. If module boundaries are materially ambiguous, use the strongest project evidence and record the uncertainty. Ask one boundary question only when the ambiguity would materially change the learning module split.

Historical assessment evaluates what the current project already contains. Do not invent implementation facts that cannot be observed.

## Stack brief after Harness planning

Immediately after Gate 4 has established/reconciled the Harness and Gate 5 has a usable module plan, present a concise project technology-stack brief before implementation begins:

- technology/tool;
- role in this project;
- why it was selected or inherited;
- modules that will use it;
- knowledge areas the user will encounter.

Deliver this stack brief in chat first. Then archive the same already-taught content to `经验学习.md` under `## 项目技术栈总览` for review. The file may add review detail, but material that was never taught in chat is not eligible assessment scope. This project-level brief is orientation only; do not run an exam here unless it is itself an independently completed module.

### Beginner language and Chinese annotation rule

Assume the learner may be a complete beginner unless the user clearly demonstrates otherwise.

- In user-facing educational prose, an English technical term or abbreviation must receive a Chinese annotation on its **first appearance within each project overview or module lesson**. Examples: `API（应用程序接口）`, `ORM（对象关系映射）`, `JWT（身份令牌标准）`, `React（前端界面库）`.
- If there is no clean literal Chinese translation, provide a short Chinese role explanation instead of forcing an awkward translation, for example `FastAPI（Python 接口开发框架）`.
- If multiple new English terms appear in the same sentence, annotate each one. Do not dump unexplained English jargon on a beginner.
- After a term has been explained in the current module/topic, its short English form may be reused.
- Do not alter literal code, package names inside code blocks, filenames, paths, commands, JSON/YAML keys, class names, function names, protocol literals, or exact API symbols merely to add Chinese text. Explain them in surrounding prose instead.
- The same rule applies to technology-stack briefs, `经验学习.md`, and assessment question stems/options when they contain technical terminology.

## Module learning lifecycle

Implementation and learning are parallel tracks.

Typical new-module states:

`PLANNED -> IMPLEMENTING -> COMPLETED -> ACCEPTED -> TEACHING -> WAITING_FOR_LEARNING_CONFIRMATION -> ASSESSING -> ASSESSED`

Existing unassessed modules enter at:

`BACKFILL_REQUIRED -> TEACHING -> WAITING_FOR_LEARNING_CONFIRMATION -> ASSESSING -> ASSESSED`

Materially changed previously assessed modules enter at:

`ASSESSED -> REASSESSMENT_REQUIRED -> TEACHING -> WAITING_FOR_LEARNING_CONFIRMATION -> ASSESSING -> ASSESSED`

These learning states run alongside implementation and do **not** block development of later modules.

After Gate 8 accepts a module:

1. **Teach the complete beginner-first lesson directly in chat before relying on any file.** Cover the module's actual technology stack, what each part does, why this project uses it, terms, code mapping, runtime flow, design reason, common mistakes, and deeper understanding. Follow the Chinese annotation rule.
2. Give each actually taught knowledge point a stable ID such as `K1`, `K2`, `K3`, and show those IDs in the chat lesson.
3. After the chat lesson is complete, archive the same taught knowledge IDs and review notes in `经验学习.md`. The file may be more detailed for revision, but it cannot replace chat teaching and cannot expand the exam scope beyond what was taught in chat.
4. Require explicit confirmation such as `学习完成` or an unambiguous equivalent before generating that module's exam. If confirmation is not available yet, keep the module pending and allow implementation of later modules to continue.
5. Only after confirmation, generate exactly 10 choice questions. Every question must declare `知识点来源: Kx` (one or more IDs from the chat lesson). Persist the protected answer state, source IDs, and `paper_id` **before** presenting the paper. Append the same visible paper (without answer key or rationale) to that module's assessment section.
6. Wait for the user's answers. Development may continue independently.
7. Grade against `.wanan/assessment-state.json`, append user answers and per-question result, record the stage score, and mark the module `ASSESSED`. After the full paper is graded, also append each question's `正确答案` and `为什么这样选` to `经验学习.md`, tied to its `知识点来源`.
8. In chat, report only each question as `对` or `错` plus the stage score. Do not reveal correct answers or explanations in the grading response unless the user separately asks later.
9. Neither a pending assessment nor any score can block implementation. The module remains mandatory and must hold a current valid assessment before final comprehensive learning scoring.

### Material-change reassessment rule

Mark an already assessed module `REASSESSMENT_REQUIRED` when later accepted work materially changes knowledge the learner was previously tested on, including substantial changes to:

- technology/framework choice;
- authentication/authorization/security model;
- architecture, data flow, control flow, state model, persistence model, or public interfaces;
- core business behavior or observable workflow;
- deployment/runtime model;
- another central concept explicitly taught and tested in that module.

Do **not** trigger reassessment for cosmetic text/style changes, renames that preserve meaning, formatting-only edits, trivial refactors, or small bug fixes that do not change the taught model.

When reassessment is required, update the lesson to match the current code, preserve the old attempt as historical evidence, set the registry's current score to pending/currently invalid for final scoring, and run a new 10-question module assessment when the user is ready. Because `经验学习.md` keeps prior answers and rationales for review, every reassessment must use a new `paper_id` and a newly generated paper; do not reuse the previous 10 questions unchanged. Development remains non-blocking.

## Detailed lesson requirements for beginners

The **chat lesson must be complete**. `经验学习.md` is the durable review book, not a substitute teaching surface. Teach each module directly in chat in this order so a beginner is not dropped into advanced terminology, then archive the same taught knowledge for review:

1. **一句话说明它是干什么的** — describe the module/technology in ordinary language.
2. **为什么这个项目需要它** — connect the concept to the user's actual feature.
3. **术语拆解** — define new terms, following the English + 中文注释 rule.
4. **代码对应关系** — point to relevant files, public interfaces, commands, schemas, or runtime surfaces and explain what each does.
5. **运行链路** — explain request/data/control flow step by step.
6. **为什么这样设计** — explain the important trade-off or chosen approach without unrelated theory.
7. **易错点** — list realistic misunderstandings/failure modes from this project.
8. **进阶理解** — only after the basics, add deeper principles that genuinely help understand the implementation.

Classify module knowledge so the learner knows what to prioritize:

- `必须掌握`：不理解就很难解释或修改本模块的核心知识。
- `建议理解`：理解后能更稳地调试、扩展或判断方案。
- `了解即可`：当前项目不是必须，但知道它存在有助于建立技术地图。

Teach only technologies actually used in that module. Do not pad lessons with unrelated framework trivia. A beginner should be able to answer “它是做什么的、为什么这里要用、代码在哪里、运行时发生什么” before being asked about deeper theory.

## Assessment rules

Every module assessment must satisfy all rules below:

- Exactly 10 questions.
- Choice questions only; no true/false, fill-in-the-blank, essay, coding, or free-response questions.
- Include both single-choice and multiple-choice questions.
- Each question labels its type and point value, for example `#### Q1 [单选 | 6分]`.
- Total available points equal exactly 100.
- Question point values must not all be equal. Do not use ten 10-point questions.
- Assign points by importance, centrality, and difficulty of the knowledge being tested.
- Questions test only knowledge explicitly delivered in the immediately relevant chat lesson and the module's observable implementation. **禁止超出刚刚聊天教学范围**来考冷知识。 Every question must include `知识点来源: Kx` (or multiple `K` IDs), and every referenced ID must exist in the module's chat-taught knowledge list.
- 禁止陷阱题、双重否定、故意绕字眼、模糊前提或只有模型自己能猜到的选项差异。
- Prefer understanding and project application over pure memorization: why this code exists, what a component does, what happens in the real runtime flow, and which choice matches the project's actual implementation.
- Options must be meaningfully distinguishable; avoid “以上都对/以上都不对” unless that form is genuinely necessary and unambiguous.
- Difficulty may rise from basic understanding to project application to integrated understanding, but every question must remain answerable from the provided lesson/project evidence.
- Multiple-choice uses exact-set scoring: all correct options and no incorrect options are required for credit. No partial credit.
- Persist the paper's protected answer key and `knowledge_ids` in `.wanan/assessment-state.json` before showing the paper. Do not rely on conversation memory for grading.
- During grading chat, do not reveal the correct option set, answer key, rationale, or correction explanation; report only `对/错` and the stage score.
- Before submission, `经验学习.md` stores only the visible paper and `知识点来源`, without answers or rationales. After the full paper is graded, append the user's submitted answer, `结果: 对/错`, `正确答案`, and `为什么这样选` for every question. The explanation must be beginner-readable and explicitly connect back to the cited `K` knowledge point.

### Answer input tolerance

Accept practical formats such as `1A`, `1.A`, `1 A`, `7ABC`, `7 A,C`, or line-separated answers. Normalize case, common separators, whitespace, and option ordering before grading.

- If the user answers only some questions, ask only for the **缺失题号**. Do not regenerate the paper.
- If only one answer has an invalid **格式**, ask only for that question again.
- Do not punish harmless formatting differences.
- For multiple choice, compare normalized option sets exactly; no partial credit.

## Module weighting and final score

During Harness slicing, assign each meaningful module a `Learning weight` based on how central its knowledge is to understanding the project. Record the rationale in `经验学习.md`. Implementation completion does not wait for assessment completion.

When producing the final comprehensive learning score:

1. Find all real completed current/historical modules in the current project's registry.
2. Require each module to have a current valid `ASSESSED` result. `BACKFILL_REQUIRED`, `WAITING_FOR_LEARNING_CONFIRMATION`, `ASSESSING`, and `REASSESSMENT_REQUIRED` remain pending for learning scoring but do not invalidate project delivery.
3. Normalize module weights and calculate the numerical score from current valid module scores only.
4. If any required module remains pending, leave the comprehensive learning score as `PENDING`. Do not create a substitute final exam.

After all mandatory module assessments are current and complete, set `Overall learning status: COMPLETE`, replace the top-level `Comprehensive score: PENDING` with the final score, and append one `## 最终项目综合评价` section containing:

- every assessed module and its score;
- every module learning weight;
- `Score source: PREVIOUS_MODULE_SCORES_ONLY`;
- `Comprehensive score: <0-100> / 100`;
- stronger knowledge areas;
- adequate knowledge areas;
- priority review areas;
- a concise project knowledge map.

Do not ask the user to take another final exam.

## Large study-book reading policy

`经验学习.md` can become very large. Do not repeatedly load the 整本/全文 learning book into context by default.

For normal resume, implementation, or grading work, use **局部读取**:

1. Read the top metadata and `## 模块登记表`.
2. Read only the active module, the module being graded, or the specific pending module needed now.
3. Read `## 最终项目综合评价` only when it already exists and is relevant.
4. Use headings/module IDs to search or range-read the needed section instead of rereading the full file.

A full-file read is acceptable only when the file is still small, when repairing its structure, or when a complete audit truly requires it. Even final score calculation should normally use the registry and relevant stage results rather than reload every lesson body.

## Required `经验学习.md` schema

Use one file per project root and update it in place. Preserve earlier module lessons and assessment history.

```markdown
# 经验学习

- Project scope: CURRENT_PROJECT_ONLY
- Learning mode: REQUIRED
- Overall learning status: ACTIVE
- Comprehensive score: PENDING

## 项目信息

- 项目名称: <name>
- 项目根目录: <current project root or safe project-relative identifier>
- 创建/接管时间: <timestamp>
- 学习记录来源: CURRENT_PROJECT_ONLY

## 项目技术栈总览

### React（前端界面库）
- 项目用途: <...>
- 选择/继承原因: <...>
- 涉及模块: <MOD IDs>
- 主要知识点: <...>

## 模块登记表

| Module ID | 模块 | Development status | Learning status | Learning weight | Score |
|---|---|---|---|---:|---:|
| MOD-001 | <name> | PLANNED | NOT_STARTED | <weight> | PENDING |

## MOD-001 <模块名称>

- Development status: ACCEPTED
- Learning status: TEACHING
- Learning weight: <weight>
- Assessment score: PENDING
- Assessment paper ID: PENDING
- Evidence: <spec/acceptance/files/commit>

### 本模块技术栈
<beginner-first detailed lesson with English（中文注释） on first use>

### 本轮聊天教学知识点（考试范围）
- K1: <已在聊天中完整讲解的知识点>
- K2: <已在聊天中完整讲解的知识点>

### 知识优先级
- 必须掌握: <...>
- 建议理解: <...>
- 了解即可: <...>

### 复习讲解
<只归档/扩展已经在聊天中讲过的知识，不得把未在聊天教学过的新知识纳入考试范围>

### 项目代码与运行链路对应
<detailed project-specific mapping>

### 易错点与复习重点
<review notes>

### 阶段考核

#### Q1 [单选 | 6分]
- 知识点来源: K1

<question>

A. <option>
B. <option>
C. <option>
D. <option>

- 用户答案: A
- 结果: 对
- 正确答案: A
- 为什么这样选: <结合 K1，用小白能理解的话解释正确选项为什么符合本项目实际；错误选项为何不符合可简要说明>

...

### 阶段结果
- 正确题数: <n>
- 错误题数: <n>
- Assessment score: <score> / 100

## 最终项目综合评价
- Final status: COMPLETE
- Score source: PREVIOUS_MODULE_SCORES_ONLY
- Comprehensive score: <score> / 100
```

Do not store secrets, credentials, private keys, paid-service secrets, or personal data in `经验学习.md`. Before grading, the answer key exists only in current-project `.wanan/assessment-state.json`. After the full paper is graded, `经验学习.md` must store the finalized per-question `正确答案` and `为什么这样选` for revision, while the hidden state remains the canonical grading source.
