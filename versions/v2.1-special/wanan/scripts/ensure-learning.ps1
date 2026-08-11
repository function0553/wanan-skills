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

$projectName = Split-Path -Leaf $resolvedRoot
$timestamp = [DateTimeOffset]::Now.ToString('yyyy-MM-dd HH:mm:ss zzz')
$learningPath = Join-Path $resolvedRoot '经验学习.md'
$stateDir = Join-Path $resolvedRoot '.wanan'
$statePath = Join-Path $stateDir 'assessment-state.json'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

if (-not (Test-Path -LiteralPath $stateDir -PathType Container)) {
    [System.IO.Directory]::CreateDirectory($stateDir) | Out-Null
}

if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
    $state = @'
{
  "schema_version": 1,
  "project_scope": "CURRENT_PROJECT_ONLY",
  "warning": "INTERNAL_GRADING_STATE_DO_NOT_SURFACE",
  "modules": {}
}
'@
    [System.IO.File]::WriteAllText($statePath, $state, $utf8NoBom)
    Write-Output "Created protected grading state: $statePath"
} else {
    Write-Output "Protected grading state already exists: $statePath"
}

if (Test-Path -LiteralPath $learningPath -PathType Leaf) {
    Write-Output "Learning file already exists: $learningPath"
    Write-Output 'Next action: audit only real completed modules from current-project evidence; add unassessed ones as BACKFILL_REQUIRED without blocking development.'
    exit 0
}

$content = @'
# 经验学习

- Project scope: CURRENT_PROJECT_ONLY
- Learning mode: REQUIRED
- Overall learning status: ACTIVE
- Comprehensive score: PENDING

## 项目信息

- 项目名称: __PROJECT_NAME__
- 项目根目录: __PROJECT_ROOT__
- 创建/接管时间: __TIMESTAMP__
- 学习记录来源: CURRENT_PROJECT_ONLY

## 项目技术栈总览

必须先在聊天框根据当前项目 Harness、代码和依赖完整讲解真实技术栈，再把已讲内容归档到这里复习。面向小白讲解时，英文技术名词首次出现必须紧跟中文注释，例如 API（应用程序接口）、ORM（对象关系映射）。

## 历史模块审计

> 先根据当前项目的 Harness、HANDOFF、提交记录、可运行代码与验收结果重建真实已完成模块。任何已完成但没有有效阶段考核的模块登记为 `BACKFILL_REQUIRED`。如果暂时无法确认任何真实历史模块，保持下面登记表为空，不得凭空创建 `MOD-001`。待学习/待考核不阻塞新的开发模块，但必须保留在学习待办中，并在最终综合学习评分前补齐当前有效考核。

## 模块登记表

| Module ID | 模块 | Development status | Learning status | Learning weight | Score |
|---|---|---|---|---:|---:|

> 每个模块必须先在聊天框完整教学，按“一句话作用 → 为什么项目需要 → 术语拆解 → 代码对应 → 运行链路 → 设计原因 → 易错点 → 进阶理解”展开，并把已讲知识编号为 K1/K2/...；本文件用于归档复习，不能替代聊天教学。知识分成 `必须掌握`、`建议理解`、`了解即可`。

> 阶段考核固定 10 道选择题，包含单选和多选，总分 100 且每题分值不得全部相同；每题必须写 `知识点来源: Kx`，且只能考聊天框已经讲过的知识。判卷前正确答案仅保存于本项目 `.wanan/assessment-state.json`；整套答题完成并判卷后，本文件每题必须追加 `正确答案` 与 `为什么这样选`，用于后续复习。
'@
$content = $content.Replace('__PROJECT_NAME__', $projectName).Replace('__PROJECT_ROOT__', $resolvedRoot).Replace('__TIMESTAMP__', $timestamp)

[System.IO.File]::WriteAllText($learningPath, $content, $utf8NoBom)
Write-Output "Created mandatory project learning file: $learningPath"
Write-Output 'Next action: audit existing completed modules, register only real modules as BACKFILL_REQUIRED, and keep development non-blocking while the learning backlog is completed.'
