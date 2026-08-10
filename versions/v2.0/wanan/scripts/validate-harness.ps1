[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [switch]$AllowPlaceholders
)

$ErrorActionPreference = 'Stop'

$resolvedRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$required = @(
    'AGENTS.md',
    'spec/README.md',
    'spec/01-product-scope.md',
    'spec/02-domain-and-workflows.md',
    'spec/03-system-architecture.md',
    'spec/04-visual-and-interaction.md',
    'spec/05-acceptance.md',
    'spec/06-visual-acceptance.md',
    'spec/07-delivery-roadmap.md'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($relativePath in $required) {
    $targetPath = Join-Path $resolvedRoot $relativePath
    if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
        $errors.Add("Missing file: $relativePath")
    }
}

if (-not $AllowPlaceholders) {
    foreach ($relativePath in $required) {
        $targetPath = Join-Path $resolvedRoot $relativePath
        if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
            $content = Get-Content -Raw -LiteralPath $targetPath
            if ($content -match '(?im)\bTODO\b|<[^>\r\n]+>') {
                $errors.Add("Unresolved placeholder: $relativePath")
            }
        }
    }
}

$agentsPath = Join-Path $resolvedRoot 'AGENTS.md'
if (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
    $agents = Get-Content -Raw -LiteralPath $agentsPath
    foreach ($heading in @('Purpose', 'Instruction precedence', 'Spec index', 'Definition of done')) {
        if ($agents -notmatch [regex]::Escape($heading)) {
            $errors.Add("AGENTS.md is missing heading text: $heading")
        }
    }
}

$functionalPath = Join-Path $resolvedRoot 'spec/05-acceptance.md'
if (Test-Path -LiteralPath $functionalPath -PathType Leaf) {
    $functional = Get-Content -Raw -LiteralPath $functionalPath
    foreach ($token in @('FUN-ACC-', 'Given', 'When', 'Then')) {
        if ($functional -notmatch [regex]::Escape($token)) {
            $errors.Add("Functional acceptance is missing: $token")
        }
    }
    if (-not $AllowPlaceholders -and $functional -notmatch '(?m)^## FUN-ACC-\d{3}\s+\S+') {
        $errors.Add('Functional acceptance needs at least one concrete FUN-ACC-NNN case')
    }
}

$visualPath = Join-Path $resolvedRoot 'spec/06-visual-acceptance.md'
if (Test-Path -LiteralPath $visualPath -PathType Leaf) {
    $visual = Get-Content -Raw -LiteralPath $visualPath
    foreach ($token in @('VIS-ACC-', 'Source:', 'Viewport/device:', 'Pass conditions:')) {
        if ($visual -notmatch [regex]::Escape($token)) {
            $errors.Add("Visual acceptance is missing: $token")
        }
    }
    if (-not $AllowPlaceholders -and $visual -notmatch '(?m)^## VIS-ACC-\d{3}\s+\S+') {
        $errors.Add('Visual acceptance needs at least one concrete VIS-ACC-NNN case')
    }
}

$indexPath = Join-Path $resolvedRoot 'spec/README.md'
if (Test-Path -LiteralPath $indexPath -PathType Leaf) {
    $index = Get-Content -Raw -LiteralPath $indexPath
    $matches = [regex]::Matches($index, '\]\(([^)]+\.md)\)')
    foreach ($match in $matches) {
        $linked = Join-Path (Split-Path -Parent $indexPath) $match.Groups[1].Value
        if (-not (Test-Path -LiteralPath $linked -PathType Leaf)) {
            $errors.Add("Broken spec index link: $($match.Groups[1].Value)")
        }
    }
    foreach ($relativePath in $required | Where-Object { $_ -like 'spec/*.md' -and $_ -ne 'spec/README.md' }) {
        $fileName = Split-Path -Leaf $relativePath
        if ($index -notmatch [regex]::Escape("($fileName)")) {
            $errors.Add("Spec index does not list required document: $fileName")
        }
    }
}

$roadmapPath = Join-Path $resolvedRoot 'spec/07-delivery-roadmap.md'
if (-not $AllowPlaceholders -and (Test-Path -LiteralPath $roadmapPath -PathType Leaf)) {
    $roadmap = Get-Content -Raw -LiteralPath $roadmapPath
    if ($roadmap -notmatch 'FUN-ACC-\d{3}') {
        $errors.Add('Delivery roadmap does not trace any slice to a FUN-ACC-NNN ID')
    }
    if ($roadmap -notmatch 'VIS-ACC-\d{3}') {
        $errors.Add('Delivery roadmap does not trace any slice to a VIS-ACC-NNN ID')
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Output "ERROR: $_" }
    exit 1
}

if ($AllowPlaceholders) {
    Write-Output "Harness scaffold validation passed (placeholders allowed)"
} else {
    Write-Output "Harness strict validation passed"
}
Write-Output "Required files: $($required.Count)"
