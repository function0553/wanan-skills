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

Read `spec/README.md`, then the documents relevant to the task.

## 6. Validation

Cover normal, unauthorized, conflict, duplicate-submit, empty, loading, and failure paths as applicable.

## 7. Definition of done

Require implementation, proportional tests, independent acceptance, current handoff, and a scoped Git checkpoint.
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
