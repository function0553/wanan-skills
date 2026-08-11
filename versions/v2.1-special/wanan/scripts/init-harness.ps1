[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot
)

$ErrorActionPreference = 'Stop'

$resolvedRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
if (-not (Test-Path -LiteralPath $resolvedRoot -PathType Container)) {
    throw "Project root does not exist: $resolvedRoot"
}

$targets = [ordered]@{
    '.wanan/assessment-state.json' = @'
{
  "schema_version": 1,
  "project_scope": "CURRENT_PROJECT_ONLY",
  "warning": "INTERNAL_GRADING_STATE_DO_NOT_SURFACE",
  "modules": {}
}
'@
    'AGENTS.md' = @'
# Project Harness

## 1. Purpose

TODO: Describe the product goal, users, and supported surfaces.

## 2. Instruction precedence

Current user instruction > this file > spec acceptance > other notes.

## 3. Domain constraints

TODO: Record server-authoritative rules, entity distinctions, state machines, and concurrency constraints.

## 4. Security and quality constraints

TODO: Record authentication, authorization, validation, ownership, secrets, idempotency, transactions, and time-zone rules.

## 5. Spec index and task routing

Read `spec/README.md`, the documents relevant to the task, and current-project `经验学习.md` before resuming or starting a later module.

## 6. Validation

Cover normal, unauthorized, conflict, duplicate-submit, empty, loading, and failure paths as applicable.

## 7. Definition of done

Require implementation, directly affected unit/contract/acceptance checks only (no full-repository run), independent targeted acceptance, mandatory module learning/assessment, current handoff, and a scoped Git checkpoint. Completed branches integrate immediately; two compactions are an upper bound, not a merge gate.
'@
    '经验学习.md' = @'
# 经验学习

- Project scope: CURRENT_PROJECT_ONLY
- Learning mode: REQUIRED
- Overall learning status: ACTIVE
- Comprehensive score: PENDING

## 项目信息

- 项目名称: TODO
- 项目根目录: TODO
- 创建/接管时间: TODO
- 学习记录来源: CURRENT_PROJECT_ONLY

## 项目技术栈总览

TODO: Harness 规划完成后，必须先在聊天框完整讲解技术栈、项目用途、选择/继承原因、涉及模块和主要知识点，再把已经讲过的内容归档到这里供复习。面向小白的教学正文中，英文技术名词首次出现必须紧跟中文注释。

## 模块登记表

| Module ID | 模块 | Development status | Learning status | Learning weight | Score |
|---|---|---|---|---:|---:|
| MOD-001 | TODO | PLANNED | NOT_STARTED | TODO | PENDING |

> 已经开发完成但尚未考核的历史模块必须标记为 `BACKFILL_REQUIRED`。这些待学习/待考核项不阻塞后续开发，但必须保留在考核待办中，并在最终综合学习评分前各完成一次学习与考核。

## MOD-001 TODO

- Development status: PLANNED
- Learning status: NOT_STARTED
- Learning weight: TODO
- Assessment score: PENDING
- Assessment paper ID: PENDING
- Evidence: TODO

### 本模块技术栈

TODO

### 本轮聊天教学知识点（考试范围）

- K1: TODO（必须先在聊天框完整讲解）
- K2: TODO（必须先在聊天框完整讲解）

### 知识优先级

- 必须掌握: TODO
- 建议理解: TODO
- 了解即可: TODO

### 复习讲解

TODO：只归档/扩展聊天中已经讲过的知识；未在聊天讲过的内容不得进入本模块考试范围。

### 项目代码与运行链路对应

TODO

### 易错点与复习重点

TODO

### 阶段考核

学习完成后生成，固定 10 道选择题，包含单选和多选，总分 100 且每题分值不得全部相同。每题必须标记 `知识点来源: Kx`，且只能考聊天框中已经讲过的 K 知识点。生成试卷时先把 paper_id、分值、知识点来源和正确选项写入本项目 `.wanan/assessment-state.json`。考试提交并完成判卷前，本文件不得出现正确答案或解析；判卷完成后，每题必须追加用户答案、对/错、正确答案和“为什么这样选”的复习解析。
'@
    'spec/README.md' = @'
# Specification index

1. [Product scope](01-product-scope.md)
2. [Domain and workflows](02-domain-and-workflows.md)
3. [System architecture](03-system-architecture.md)
4. [Visual and interaction](04-visual-and-interaction.md)
5. [Functional acceptance](05-acceptance.md)
6. [Visual acceptance](06-visual-acceptance.md)
7. [Delivery roadmap](07-delivery-roadmap.md)
'@
    'spec/01-product-scope.md' = "# Product scope`n`nTODO: Define problem, actors, outcomes, scope, and open decisions.`n"
    'spec/02-domain-and-workflows.md' = "# Domain and workflows`n`nTODO: Define canonical entities, states, server authority, conflicts, and audit behavior.`n"
    'spec/03-system-architecture.md' = "# System architecture`n`nTODO: Define components, boundaries, contracts, persistence, security, and test seams.`n"
    'spec/04-visual-and-interaction.md' = @'
# Visual and interaction

Design status: DRAFT

## Visual exploration manifest

- Mode: IDEATED
- Batch ID: TODO
- Displayed result 1: TODO
- Displayed result 2: TODO
- Displayed result 3: TODO
- Independence evidence: TODO
- Selected result: TODO
- Selection source: TODO

## Page structure

### PAGE-001 TODO

- Route/surface: TODO
- Viewport sections: TODO
- Content priority: TODO
- Components/assets: TODO
- Responsive structure: TODO
- States: TODO
- Affordances: AFF-001

- Structure status: PENDING
- Structure approval source: TODO

## Interaction coverage

- Coverage status: PENDING

| Affordance ID | Surface/control | Mapping | Coverage |
|---|---|---|---|
| AFF-001 | TODO | INT-001 | OPEN |

## Interaction decision register

### INT-001 TODO

- Category: TODO
- Surface/control: TODO
- Trigger: TODO
- Outcome: TODO
- Materiality: MATERIAL
- Option 1 (recommended): TODO
- Option 2: TODO
- Option 3: TODO
- Selected option: TODO
- Status: OPEN
- Decision source: TODO
- Dependencies: TODO
- Relevant states: TODO
- Acceptance: INT-ACC-001

## Frontend lock

- Approval source: TODO
- Revision: TODO
- Contract fingerprint: TODO
'@
    'spec/05-acceptance.md' = @'
# Functional and interaction acceptance

## FUN-ACC-001 TODO

Given TODO
When TODO
Then TODO

## INT-ACC-001 TODO

- Decision: INT-001
- Trigger: TODO
- Starting state: TODO
- Expected transition: TODO
- Alternate/reduced-motion behavior: TODO
- Evidence: TODO
'@
    'spec/06-visual-acceptance.md' = "# Visual acceptance`n`n## VIS-ACC-001 TODO`n`n- Source: TODO`n- Viewport/device: TODO`n- State/data: TODO`n- Pass conditions: TODO`n- Evidence: TODO`n"
    'spec/07-delivery-roadmap.md' = "# Delivery roadmap`n`nTODO: List vertical slices, blocking edges, acceptance IDs, deferred decisions, and release boundaries.`n"
}

$existing = foreach ($relativePath in $targets.Keys) {
    $targetPath = Join-Path $resolvedRoot $relativePath
    if (Test-Path -LiteralPath $targetPath) {
        $targetPath
    }
}

if ($existing.Count -gt 0) {
    $details = $existing -join [Environment]::NewLine
    throw "Harness initialization aborted before writing because target files already exist:`n$details"
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
foreach ($entry in $targets.GetEnumerator()) {
    $targetPath = Join-Path $resolvedRoot $entry.Key
    $parent = Split-Path -Parent $targetPath
    if (-not (Test-Path -LiteralPath $parent)) {
        [System.IO.Directory]::CreateDirectory($parent) | Out-Null
    }
    [System.IO.File]::WriteAllText($targetPath, [string]$entry.Value, $utf8NoBom)
}

Write-Output "Created Harness files: $($targets.Count)"
Write-Output "Project root: $resolvedRoot"
