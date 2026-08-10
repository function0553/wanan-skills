[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [switch]$AllowPlaceholders,

    [switch]$RequireFrontendLock
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

function Get-MarkdownFieldValue {
    param(
        [string]$Text,
        [string]$Label
    )

    $pattern = '(?im)^-\s*' + [regex]::Escape($Label) + ':\s*(.*?)\s*$'
    $match = [regex]::Match($Text, $pattern)
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return $null
}

function Test-ConcreteValue {
    param([string]$Value)

    return -not [string]::IsNullOrWhiteSpace($Value) -and $Value -notmatch '^(?i:TODO|OPEN|PENDING|UNRESOLVED|UNSELECTED|TBD)$'
}

function Get-InteractionOption {
    param([string]$Value)

    $match = [regex]::Match($Value, '^(.*?)\s*\|\s*Trade-off:\s*(.*?)\s*$', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) {
        return $null
    }
    $choice = $match.Groups[1].Value.Trim()
    $tradeOff = $match.Groups[2].Value.Trim()
    if (-not (Test-ConcreteValue $choice) -or -not (Test-ConcreteValue $tradeOff)) {
        return $null
    }
    return [pscustomobject]@{
        Choice = $choice
        TradeOff = $tradeOff
    }
}

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

$interactionAcceptanceMatches = @()
$interactionAcceptanceIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$interactionAcceptanceDecisionById = @{}
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
    if ($RequireFrontendLock) {
        foreach ($token in @('INT-ACC-', 'Decision:', 'Trigger:', 'Expected transition:', 'Evidence:')) {
            if ($functional -notmatch [regex]::Escape($token)) {
                $errors.Add("Interaction acceptance is missing: $token")
            }
        }
        if (-not $AllowPlaceholders -and $functional -notmatch '(?m)^## INT-ACC-\d{3}\s+\S+') {
            $errors.Add('Interaction acceptance needs at least one concrete INT-ACC-NNN case')
        }
        $interactionAcceptanceMatches = [regex]::Matches($functional, '(?ms)^## (INT-ACC-\d{3})\s+\S+.*?(?=^## |\z)')
        foreach ($acceptanceMatch in $interactionAcceptanceMatches) {
            $acceptanceId = $acceptanceMatch.Groups[1].Value
            $acceptanceBlock = $acceptanceMatch.Value
            if (-not $interactionAcceptanceIds.Add($acceptanceId)) {
                $errors.Add("Duplicate interaction acceptance ID: $acceptanceId")
            }
            foreach ($field in @('Decision', 'Trigger', 'Expected transition', 'Evidence')) {
                if (-not (Test-ConcreteValue (Get-MarkdownFieldValue -Text $acceptanceBlock -Label $field))) {
                    $errors.Add("$acceptanceId needs a concrete value for: $field")
                }
            }
            $interactionAcceptanceDecisionById[$acceptanceId] = Get-MarkdownFieldValue -Text $acceptanceBlock -Label 'Decision'
        }
    }
}

$designPath = Join-Path $resolvedRoot 'spec/04-visual-and-interaction.md'
if (Test-Path -LiteralPath $designPath -PathType Leaf) {
    $design = Get-Content -Raw -LiteralPath $designPath
    foreach ($token in @('Design status:', 'Visual exploration manifest', 'Mode:', 'Page structure', 'Structure status:', 'Interaction coverage', 'Coverage status:', 'Interaction decision register', 'Frontend lock', 'Contract fingerprint:')) {
        if ($design -notmatch [regex]::Escape($token)) {
            $errors.Add("Visual and interaction spec is missing: $token")
        }
    }

    $decisionMatches = [regex]::Matches($design, '(?ms)^### (INT-\d{3})\s+\S+.*?(?=^### INT-\d{3}\s+|^## |\z)')
    $seenDecisionIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($decisionMatch in $decisionMatches) {
        $decisionId = $decisionMatch.Groups[1].Value
        $decisionBlock = $decisionMatch.Value
        if (-not $seenDecisionIds.Add($decisionId)) {
            $errors.Add("Duplicate interaction decision ID: $decisionId")
        }
        foreach ($field in @('Category', 'Surface/control', 'Trigger', 'Outcome', 'Materiality', 'Option 1 (recommended)', 'Option 2', 'Option 3', 'Selected option', 'Status', 'Decision source', 'Dependencies', 'Relevant states', 'Acceptance')) {
            if ($null -eq (Get-MarkdownFieldValue -Text $decisionBlock -Label $field)) {
                $errors.Add("$decisionId is missing field: $field")
            }
        }
    }

    $pageMatches = [regex]::Matches($design, '(?ms)^### (PAGE-\d{3})\s+\S+.*?(?=^### PAGE-\d{3}\s+|^## |\z)')
    $seenPageIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $declaredAffordanceIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($pageMatch in $pageMatches) {
        $pageId = $pageMatch.Groups[1].Value
        $pageBlock = $pageMatch.Value
        if (-not $seenPageIds.Add($pageId)) {
            $errors.Add("Duplicate page structure ID: $pageId")
        }
        foreach ($field in @('Route/surface', 'Viewport sections', 'Content priority', 'Components/assets', 'Responsive structure', 'States', 'Affordances')) {
            if ($null -eq (Get-MarkdownFieldValue -Text $pageBlock -Label $field)) {
                $errors.Add("$pageId is missing field: $field")
            }
        }
        $affordanceValue = Get-MarkdownFieldValue -Text $pageBlock -Label 'Affordances'
        if ($null -ne $affordanceValue) {
            $affordanceMatches = [regex]::Matches($affordanceValue, '\bAFF-\d{3}\b')
            $affordanceResidue = [regex]::Replace($affordanceValue, '\bAFF-\d{3}\b', '') -replace '[,\s]', ''
            if ($affordanceMatches.Count -lt 1 -or $affordanceResidue.Length -gt 0) {
                $errors.Add("$pageId Affordances must be a comma-separated list of AFF-NNN IDs")
            }
            foreach ($affordanceMatch in $affordanceMatches) {
                if (-not $declaredAffordanceIds.Add($affordanceMatch.Value)) {
                    $errors.Add("Duplicate declared affordance ID: $($affordanceMatch.Value)")
                }
            }
        }
    }

    if (-not $AllowPlaceholders) {
        $designStatusMatches = [regex]::Matches($design, '(?im)^Design status:\s*(DRAFT|LOCKED)\s*$')
        if ($designStatusMatches.Count -ne 1) {
            $errors.Add('Frontend design must contain exactly one Design status line with DRAFT or LOCKED')
        }

        if ($RequireFrontendLock) {
            if ($designStatusMatches.Count -ne 1 -or $designStatusMatches[0].Groups[1].Value -ne 'LOCKED') {
                $errors.Add('Frontend design must be explicitly LOCKED before implementation')
            }
            if ($pageMatches.Count -lt 1) {
                $errors.Add('Locked frontend design needs at least one concrete PAGE-NNN structure record')
            }
            if ($decisionMatches.Count -lt 1) {
                $errors.Add('Locked frontend design needs at least one concrete INT-NNN decision')
            }

            $mode = Get-MarkdownFieldValue -Text $design -Label 'Mode'
            if ($mode -eq 'IDEATED') {
                $manifestSectionMatch = [regex]::Match($design, '(?ms)^## Visual exploration manifest\s*(.*?)(?=^## |\z)')
                $manifestSection = if ($manifestSectionMatch.Success) { $manifestSectionMatch.Groups[1].Value } else { '' }
                $displayedResultLines = [regex]::Matches($manifestSection, '(?im)^-\s*Displayed result\s+(\d+):\s*.*$')
                $displayedResultOrdinals = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
                foreach ($displayedResultLine in $displayedResultLines) {
                    [void]$displayedResultOrdinals.Add($displayedResultLine.Groups[1].Value)
                }
                if ($displayedResultLines.Count -ne 3 -or $displayedResultOrdinals.Count -ne 3 -or -not $displayedResultOrdinals.SetEquals([string[]]@('1', '2', '3'))) {
                    $errors.Add('IDEATED frontend lock must contain only Displayed result 1, 2, and 3')
                }
                $batchId = Get-MarkdownFieldValue -Text $design -Label 'Batch ID'
                $independence = Get-MarkdownFieldValue -Text $design -Label 'Independence evidence'
                $results = @(
                    Get-MarkdownFieldValue -Text $design -Label 'Displayed result 1'
                    Get-MarkdownFieldValue -Text $design -Label 'Displayed result 2'
                    Get-MarkdownFieldValue -Text $design -Label 'Displayed result 3'
                )
                if (-not (Test-ConcreteValue $batchId) -or -not (Test-ConcreteValue $independence)) {
                    $errors.Add('IDEATED frontend lock requires a concrete batch ID and independence evidence')
                }
                if (($results | Where-Object { Test-ConcreteValue $_ }).Count -ne 3 -or ($results | Select-Object -Unique).Count -ne 3) {
                    $errors.Add('IDEATED frontend lock requires exactly three unique displayed result IDs')
                }
                $selectedResult = Get-MarkdownFieldValue -Text $design -Label 'Selected result'
                if (-not (Test-ConcreteValue $selectedResult) -or $results -notcontains $selectedResult) {
                    $errors.Add('Selected result must resolve to one of the three displayed result IDs')
                }
            } else {
                $errors.Add('Frontend visual Mode must be IDEATED; supplied sources may ground but not bypass the three-option batch')
            }

            if (-not (Test-ConcreteValue (Get-MarkdownFieldValue -Text $design -Label 'Selection source'))) {
                $errors.Add('Frontend lock requires a concrete visual selection source')
            }
            if ((Get-MarkdownFieldValue -Text $design -Label 'Structure status') -ne 'APPROVED' -or -not (Test-ConcreteValue (Get-MarkdownFieldValue -Text $design -Label 'Structure approval source'))) {
                $errors.Add('Page structure must be APPROVED with a concrete approval source')
            }
            foreach ($pageMatch in $pageMatches) {
                $pageId = $pageMatch.Groups[1].Value
                $pageBlock = $pageMatch.Value
                foreach ($field in @('Route/surface', 'Viewport sections', 'Content priority', 'Components/assets', 'Responsive structure', 'States', 'Affordances')) {
                    if (-not (Test-ConcreteValue (Get-MarkdownFieldValue -Text $pageBlock -Label $field))) {
                        $errors.Add("$pageId needs a concrete locked value for: $field")
                    }
                }
            }
            if ((Get-MarkdownFieldValue -Text $design -Label 'Coverage status') -ne 'COMPLETE') {
                $errors.Add('Interaction coverage must be COMPLETE with no OPEN affordance rows')
            }

            $decisionStatusById = @{}
            $decisionAcceptanceIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            $acceptanceReferenceOwner = @{}
            foreach ($decisionMatch in $decisionMatches) {
                $decisionId = $decisionMatch.Groups[1].Value
                $decisionBlock = $decisionMatch.Value
                $status = Get-MarkdownFieldValue -Text $decisionBlock -Label 'Status'
                foreach ($field in @('Category', 'Surface/control', 'Trigger', 'Outcome', 'Materiality', 'Option 1 (recommended)', 'Option 2', 'Option 3', 'Selected option', 'Decision source', 'Dependencies', 'Relevant states', 'Acceptance')) {
                    if (-not (Test-ConcreteValue (Get-MarkdownFieldValue -Text $decisionBlock -Label $field))) {
                        $errors.Add("$decisionId needs a concrete locked value for: $field")
                    }
                }
                $decisionStatusById[$decisionId] = $status
                if ($status -notin @('SELECTED', 'INHERITED')) {
                    $errors.Add("$decisionId status must be SELECTED or INHERITED")
                }
                $materiality = Get-MarkdownFieldValue -Text $decisionBlock -Label 'Materiality'
                if (($status -eq 'SELECTED' -and $materiality -ne 'MATERIAL') -or ($status -eq 'INHERITED' -and $materiality -ne 'INHERITED')) {
                    $errors.Add("$decisionId materiality must match its SELECTED or INHERITED status")
                }
                $optionLabels = @('Option 1 (recommended)', 'Option 2', 'Option 3')
                if ($status -eq 'SELECTED' -and $materiality -eq 'MATERIAL') {
                    $optionLines = [regex]::Matches($decisionBlock, '(?im)^-\s*Option\s+(\d+)(?:\s+\(recommended\))?:\s*.*$')
                    $optionOrdinals = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
                    foreach ($optionLine in $optionLines) {
                        [void]$optionOrdinals.Add($optionLine.Groups[1].Value)
                    }
                    if ($optionLines.Count -ne 3 -or $optionOrdinals.Count -ne 3 -or -not $optionOrdinals.SetEquals([string[]]@('1', '2', '3'))) {
                        $errors.Add("$decisionId must contain only Option 1, Option 2, and Option 3")
                    }
                    $choices = [System.Collections.Generic.List[string]]::new()
                    $uniqueChoices = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                    foreach ($optionLabel in $optionLabels) {
                        $parsedOption = Get-InteractionOption (Get-MarkdownFieldValue -Text $decisionBlock -Label $optionLabel)
                        if ($null -eq $parsedOption) {
                            $errors.Add("$decisionId $optionLabel must use '<choice> | Trade-off: <concrete trade-off>'")
                        } else {
                            $choices.Add($parsedOption.Choice)
                            [void]$uniqueChoices.Add($parsedOption.Choice)
                        }
                    }
                    if ($uniqueChoices.Count -ne 3) {
                        $errors.Add("$decisionId needs exactly three materially distinct option choices")
                    }
                    $selectedOption = Get-MarkdownFieldValue -Text $decisionBlock -Label 'Selected option'
                    if ($choices.Count -eq 3 -and $choices -notcontains $selectedOption) {
                        $errors.Add("$decisionId Selected option must equal one of its three option choices")
                    }
                } elseif ($status -eq 'INHERITED' -and $materiality -eq 'INHERITED') {
                    $optionLines = [regex]::Matches($decisionBlock, '(?im)^-\s*Option\s+(\d+)(?:\s+\(recommended\))?:\s*.*$')
                    $optionOrdinals = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
                    foreach ($optionLine in $optionLines) {
                        [void]$optionOrdinals.Add($optionLine.Groups[1].Value)
                    }
                    if ($optionLines.Count -ne 3 -or $optionOrdinals.Count -ne 3 -or -not $optionOrdinals.SetEquals([string[]]@('1', '2', '3'))) {
                        $errors.Add("$decisionId inherited record must contain only Option 1, Option 2, and Option 3")
                    }
                    foreach ($optionLabel in $optionLabels) {
                        if ((Get-MarkdownFieldValue -Text $decisionBlock -Label $optionLabel) -ne 'INHERITED') {
                            $errors.Add("$decisionId inherited decisions must set all option fields to INHERITED")
                        }
                    }
                }
                $acceptanceId = Get-MarkdownFieldValue -Text $decisionBlock -Label 'Acceptance'
                if ($acceptanceId -notmatch '^INT-ACC-\d{3}$') {
                    $errors.Add("$decisionId must map to an INT-ACC-NNN ID")
                } else {
                    [void]$decisionAcceptanceIds.Add($acceptanceId)
                    if (-not $interactionAcceptanceIds.Contains($acceptanceId)) {
                        $errors.Add("$decisionId references missing interaction acceptance: $acceptanceId")
                    } elseif ($interactionAcceptanceDecisionById[$acceptanceId] -ne $decisionId) {
                        $errors.Add("$acceptanceId Decision must point back to $decisionId")
                    }
                    if ($acceptanceReferenceOwner.ContainsKey($acceptanceId) -and $acceptanceReferenceOwner[$acceptanceId] -ne $decisionId) {
                        $errors.Add("$acceptanceId is referenced by more than one interaction decision")
                    } else {
                        $acceptanceReferenceOwner[$acceptanceId] = $decisionId
                    }
                }
            }

            foreach ($acceptanceMatch in $interactionAcceptanceMatches) {
                $acceptanceId = $acceptanceMatch.Groups[1].Value
                $decisionId = $interactionAcceptanceDecisionById[$acceptanceId]
                if ($decisionId -notmatch '^INT-\d{3}$' -or -not $seenDecisionIds.Contains($decisionId)) {
                    $errors.Add("$acceptanceId references missing interaction decision: $decisionId")
                }
                if (-not $decisionAcceptanceIds.Contains($acceptanceId)) {
                    $errors.Add("$acceptanceId is not referenced by its interaction decision")
                }
            }

            $coverageSectionMatch = [regex]::Match($design, '(?ms)^## Interaction coverage\s*(.*?)(?=^## |\z)')
            $coverageSection = if ($coverageSectionMatch.Success) { $coverageSectionMatch.Groups[1].Value } else { '' }
            $coverageRows = [regex]::Matches($coverageSection, '(?im)^\|\s*(AFF-\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(COMPLETE|INHERITED|NON_INTERACTIVE|OPEN)\s*\|$')
            $affordanceLines = [regex]::Matches($coverageSection, '(?im)^\|\s*AFF-\d{3}\b.*$')
            if ($coverageRows.Count -lt 1 -or $coverageRows.Count -ne $affordanceLines.Count) {
                $errors.Add('Interaction coverage needs well-formed AFF-NNN mapping rows')
            }
            $coveredAffordanceIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($coverageRow in $coverageRows) {
                $affordanceId = $coverageRow.Groups[1].Value
                $surface = $coverageRow.Groups[2].Value.Trim()
                $mapping = $coverageRow.Groups[3].Value.Trim()
                $coverage = $coverageRow.Groups[4].Value
                if (-not $coveredAffordanceIds.Add($affordanceId)) {
                    $errors.Add("Duplicate interaction coverage row: $affordanceId")
                }
                if (-not $declaredAffordanceIds.Contains($affordanceId)) {
                    $errors.Add("Coverage row is not declared by a PAGE-NNN record: $affordanceId")
                }
                if (-not (Test-ConcreteValue $surface)) {
                    $errors.Add("$affordanceId needs a concrete surface/control")
                }
                if ($coverage -eq 'OPEN') {
                    $errors.Add("$affordanceId coverage remains OPEN")
                } elseif ($coverage -in @('COMPLETE', 'INHERITED')) {
                    if ($mapping -notmatch '^INT-\d{3}$' -or -not $seenDecisionIds.Contains($mapping)) {
                        $errors.Add("$affordanceId must map to an existing INT-NNN decision")
                    } elseif ($coverage -eq 'COMPLETE' -and $decisionStatusById[$mapping] -ne 'SELECTED') {
                        $errors.Add("$affordanceId COMPLETE coverage must map to a selected decision")
                    } elseif ($coverage -eq 'INHERITED' -and $decisionStatusById[$mapping] -ne 'INHERITED') {
                        $errors.Add("$affordanceId INHERITED coverage must map to an inherited decision")
                    }
                } elseif ($coverage -eq 'NON_INTERACTIVE') {
                    $reasonMatch = [regex]::Match($mapping, '^REASON:\s*(.+)$', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                    if (-not $reasonMatch.Success -or -not (Test-ConcreteValue $reasonMatch.Groups[1].Value.Trim())) {
                        $errors.Add("$affordanceId NON_INTERACTIVE coverage needs a concrete REASON")
                    }
                }
            }
            foreach ($affordanceId in $declaredAffordanceIds) {
                if (-not $coveredAffordanceIds.Contains($affordanceId)) {
                    $errors.Add("Declared affordance is missing from interaction coverage: $affordanceId")
                }
            }

            foreach ($field in @('Approval source', 'Revision', 'Contract fingerprint')) {
                if (-not (Test-ConcreteValue (Get-MarkdownFieldValue -Text $design -Label $field))) {
                    $errors.Add("Frontend lock needs a concrete value for: $field")
                }
            }
        }
    }
}

$visualPath = Join-Path $resolvedRoot 'spec/06-visual-acceptance.md'
if (Test-Path -LiteralPath $visualPath -PathType Leaf) {
    $visual = Get-Content -Raw -LiteralPath $visualPath
    if ($RequireFrontendLock) {
        foreach ($token in @('VIS-ACC-', 'Source:', 'Viewport/device:', 'Pass conditions:')) {
            if ($visual -notmatch [regex]::Escape($token)) {
                $errors.Add("Visual acceptance is missing: $token")
            }
        }
        if (-not $AllowPlaceholders -and $visual -notmatch '(?m)^## VIS-ACC-\d{3}\s+\S+') {
            $errors.Add('Visual acceptance needs at least one concrete VIS-ACC-NNN case')
        }
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
    if ($RequireFrontendLock) {
        if ($roadmap -notmatch 'VIS-ACC-\d{3}') {
            $errors.Add('Delivery roadmap does not trace any slice to a VIS-ACC-NNN ID')
        }
        if ($roadmap -notmatch 'INT-ACC-\d{3}') {
            $errors.Add('Delivery roadmap does not trace any slice to an INT-ACC-NNN ID')
        }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Output "ERROR: $_" }
    exit 1
}

if ($AllowPlaceholders) {
    Write-Output "Harness scaffold validation passed (placeholders allowed)"
} elseif ($RequireFrontendLock) {
    Write-Output "Harness strict validation passed (frontend lock required)"
} else {
    Write-Output "Harness strict validation passed (frontend draft allowed)"
}
Write-Output "Required files: $($required.Count)"
