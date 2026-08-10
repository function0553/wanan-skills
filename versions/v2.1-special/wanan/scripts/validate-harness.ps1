[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectRoot,

    [switch]$AllowPlaceholders,

    [switch]$RequireFrontendLock,

    [switch]$RequireLearningAssessment,

    [string]$LearningModuleId,

    [switch]$RequireLearningComplete
)

$ErrorActionPreference = 'Stop'

$resolvedRoot = [System.IO.Path]::GetFullPath($ProjectRoot)
$required = @(
    'AGENTS.md',
    '经验学习.md',
    '.wanan/assessment-state.json',
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

function Normalize-ChoiceAnswer {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return ''
    }
    $letters = [regex]::Matches($Value.ToUpperInvariant(), '[A-Z]') | ForEach-Object { $_.Value } | Sort-Object -Unique
    return ($letters -join '')
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

$assessmentStatePath = Join-Path $resolvedRoot '.wanan/assessment-state.json'
$assessmentState = $null
if (Test-Path -LiteralPath $assessmentStatePath -PathType Leaf) {
    try {
        $assessmentState = Get-Content -Raw -LiteralPath $assessmentStatePath | ConvertFrom-Json
        if ($assessmentState.project_scope -ne 'CURRENT_PROJECT_ONLY') {
            $errors.Add('.wanan/assessment-state.json project_scope must be CURRENT_PROJECT_ONLY')
        }
        if ($assessmentState.warning -ne 'INTERNAL_GRADING_STATE_DO_NOT_SURFACE') {
            $errors.Add('.wanan/assessment-state.json warning marker is missing or invalid')
        }
        if ($null -eq $assessmentState.modules) {
            $errors.Add('.wanan/assessment-state.json must contain a modules object')
        }
    } catch {
        $errors.Add('.wanan/assessment-state.json is not valid JSON')
    }
}

$learningPath = Join-Path $resolvedRoot '经验学习.md'
if (Test-Path -LiteralPath $learningPath -PathType Leaf) {
    $learning = Get-Content -Raw -LiteralPath $learningPath
    foreach ($token in @('Project scope: CURRENT_PROJECT_ONLY', 'Learning mode: REQUIRED', '## 项目技术栈总览', '## 模块登记表')) {
        if ($learning -notmatch [regex]::Escape($token)) {
            $errors.Add("经验学习.md is missing mandatory learning contract token: $token")
        }
    }
    if ($learning -match '(?im)^-\s*Learning mode:\s*(OPTIONAL|DISABLED|SKIPPED)\s*$') {
        $errors.Add('Learning mode must remain REQUIRED and cannot be disabled or optional')
    }
    if ($learning -match '(?im)^\s*(?:-\s*)?(正确答案|答案解析)\s*[:：]') {
        $errors.Add('经验学习.md must not store correct-answer or answer-explanation fields')
    }

    if ($RequireLearningAssessment) {
        if ([string]::IsNullOrWhiteSpace($LearningModuleId) -or $LearningModuleId -notmatch '^MOD-\d{3}$') {
            $errors.Add('RequireLearningAssessment requires -LearningModuleId MOD-NNN')
        } else {
            $modulePattern = '(?ms)^##\s+' + [regex]::Escape($LearningModuleId) + '\s+\S+.*?(?=^##\s+MOD-\d{3}\s+|^##\s+最终项目综合评价|\z)'
            $moduleMatch = [regex]::Match($learning, $modulePattern)
            if (-not $moduleMatch.Success) {
                $errors.Add("Learning module section not found: $LearningModuleId")
            } else {
                $moduleBlock = $moduleMatch.Value
                $paperId = Get-MarkdownFieldValue -Text $moduleBlock -Label 'Assessment paper ID'
                $protectedModule = $null
                if ($null -eq $assessmentState -or $null -eq $assessmentState.modules) {
                    $errors.Add("$LearningModuleId cannot be graded without protected assessment state")
                } else {
                    $moduleProperty = $assessmentState.modules.PSObject.Properties[$LearningModuleId]
                    if ($null -eq $moduleProperty) {
                        $errors.Add("$LearningModuleId is missing from protected assessment state")
                    } else {
                        $protectedModule = $moduleProperty.Value
                        if ([string]::IsNullOrWhiteSpace([string]$paperId) -or $paperId -eq 'PENDING') {
                            $errors.Add("$LearningModuleId is missing a concrete Assessment paper ID")
                        } elseif ([string]$protectedModule.paper_id -ne [string]$paperId) {
                            $errors.Add("$LearningModuleId visible paper ID does not match protected assessment state")
                        }
                        $protectedQuestions = @($protectedModule.questions)
                        if ($protectedQuestions.Count -ne 10) {
                            $errors.Add("$LearningModuleId protected assessment state must contain exactly 10 questions")
                        }
                    }
                }
                if ((Get-MarkdownFieldValue -Text $moduleBlock -Label 'Learning status') -ne 'ASSESSED') {
                    $errors.Add("$LearningModuleId Learning status must be ASSESSED")
                }
                $scoreText = Get-MarkdownFieldValue -Text $moduleBlock -Label 'Assessment score'
                $scoreMatch = [regex]::Match([string]$scoreText, '^(\d{1,3})\s*/\s*100$')
                if (-not $scoreMatch.Success) {
                    $errors.Add("$LearningModuleId Assessment score must use '<0-100> / 100'")
                }

                $questionMatches = [regex]::Matches($moduleBlock, '(?m)^####\s+Q(\d+)\s+\[(单选|多选)\s*\|\s*(\d+)分\]\s*$')
                if ($questionMatches.Count -ne 10) {
                    $errors.Add("$LearningModuleId must contain exactly 10 choice questions")
                } else {
                    $seenQuestionIds = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                    $pointValues = [System.Collections.Generic.List[int]]::new()
                    $questionTypes = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
                    foreach ($questionMatch in $questionMatches) {
                        [void]$seenQuestionIds.Add($questionMatch.Groups[1].Value)
                        $pointValues.Add([int]$questionMatch.Groups[3].Value)
                        [void]$questionTypes.Add($questionMatch.Groups[2].Value)
                    }
                    if ($seenQuestionIds.Count -ne 10 -or -not $seenQuestionIds.SetEquals([string[]]@('1','2','3','4','5','6','7','8','9','10'))) {
                        $errors.Add("$LearningModuleId question IDs must be exactly Q1 through Q10")
                    }
                    $pointSum = ($pointValues | Measure-Object -Sum).Sum
                    if ($pointSum -ne 100) {
                        $errors.Add("$LearningModuleId question points must total exactly 100; found $pointSum")
                    }
                    if (($pointValues | Select-Object -Unique).Count -eq 1) {
                        $errors.Add("$LearningModuleId question points must not all be equal")
                    }
                    if (-not $questionTypes.Contains('单选') -or -not $questionTypes.Contains('多选')) {
                        $errors.Add("$LearningModuleId must contain both single-choice and multiple-choice questions")
                    }

                    $earnedScore = 0
                    foreach ($questionMatch in $questionMatches) {
                        $qNum = $questionMatch.Groups[1].Value
                        $qType = $questionMatch.Groups[2].Value
                        $qPoints = [int]$questionMatch.Groups[3].Value
                        $qPattern = '(?ms)^####\s+Q' + [regex]::Escape($qNum) + '\s+\[(?:单选|多选)\s*\|\s*\d+分\]\s*$.*?(?=^####\s+Q\d+\s+\[|^###\s+阶段结果|\z)'
                        $qBlockMatch = [regex]::Match($moduleBlock, $qPattern)
                        if (-not $qBlockMatch.Success) {
                            $errors.Add("$LearningModuleId Q$qNum block is malformed")
                            continue
                        }
                        $qBlock = $qBlockMatch.Value
                        foreach ($option in @('A.', 'B.')) {
                            if ($qBlock -notmatch ('(?m)^' + [regex]::Escape($option) + '\s+\S+')) {
                                $errors.Add("$LearningModuleId Q$qNum is missing option $option")
                            }
                        }
                        $answer = Get-MarkdownFieldValue -Text $qBlock -Label '用户答案'
                        $result = Get-MarkdownFieldValue -Text $qBlock -Label '结果'
                        if ([string]::IsNullOrWhiteSpace($answer)) {
                            $errors.Add("$LearningModuleId Q$qNum is missing 用户答案")
                        }
                        if ($result -notin @('对','错')) {
                            $errors.Add("$LearningModuleId Q$qNum result must be 对 or 错")
                        }

                        if ($null -ne $protectedModule) {
                            $protectedQuestion = @($protectedModule.questions | Where-Object { [string]$_.id -eq [string]$qNum })
                            if ($protectedQuestion.Count -ne 1) {
                                $errors.Add("$LearningModuleId Q$qNum is missing or duplicated in protected assessment state")
                            } else {
                                $pq = $protectedQuestion[0]
                                $expectedType = if ([string]$pq.type -eq 'single') { '单选' } elseif ([string]$pq.type -eq 'multiple') { '多选' } else { '' }
                                if ($expectedType -eq '' -or $expectedType -ne $qType) {
                                    $errors.Add("$LearningModuleId Q$qNum type does not match protected assessment state")
                                }
                                if ([int]$pq.points -ne $qPoints) {
                                    $errors.Add("$LearningModuleId Q$qNum points do not match protected assessment state")
                                }
                                $isCorrect = (Normalize-ChoiceAnswer ([string]$answer)) -eq (Normalize-ChoiceAnswer ([string]$pq.correct))
                                $expectedResult = if ($isCorrect) { '对' } else { '错' }
                                if ($result -in @('对','错') -and $result -ne $expectedResult) {
                                    $errors.Add("$LearningModuleId Q$qNum recorded result is inconsistent with protected assessment state")
                                }
                                if ($isCorrect) {
                                    $earnedScore += $qPoints
                                }
                            }
                        } elseif ($result -eq '对') {
                            # Fallback only keeps structural validation running after reporting missing protected state.
                            $earnedScore += $qPoints
                        }
                    }
                    if ($scoreMatch.Success -and [int]$scoreMatch.Groups[1].Value -ne $earnedScore) {
                        $errors.Add("$LearningModuleId recorded score does not match protected/per-question grading; expected $earnedScore / 100")
                    }
                }
            }
        }
    }

    if ($RequireLearningComplete) {
        $rowMatches = [regex]::Matches($learning, '(?im)^\|\s*(MOD-\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(\d+(?:\.\d+)?)\s*\|\s*(\d{1,3})\s*\|$')
        if ($rowMatches.Count -lt 1) {
            $errors.Add('Final learning validation requires at least one completed module registry row with numeric weight and score')
        } else {
            $weightedTotal = 0.0
            $weightTotal = 0.0
            foreach ($row in $rowMatches) {
                $moduleId = $row.Groups[1].Value
                $developmentStatus = $row.Groups[3].Value.Trim()
                $learningStatus = $row.Groups[4].Value.Trim()
                $weight = [double]$row.Groups[5].Value
                $score = [int]$row.Groups[6].Value
                if ($developmentStatus -notin @('COMPLETED','ACCEPTED')) {
                    $errors.Add("$moduleId final registry Development status must be COMPLETED or ACCEPTED")
                }
                if ($learningStatus -ne 'ASSESSED') {
                    $errors.Add("$moduleId final registry Learning status must be ASSESSED")
                }
                if ($null -eq $assessmentState -or $null -eq $assessmentState.modules -or $null -eq $assessmentState.modules.PSObject.Properties[$moduleId]) {
                    $errors.Add("$moduleId final registry is missing protected assessment state")
                }
                if ($score -lt 0 -or $score -gt 100) {
                    $errors.Add("$moduleId final registry score must be 0-100")
                }
                if ($weight -le 0) {
                    $errors.Add("$moduleId learning weight must be greater than zero")
                }
                $weightedTotal += $weight * $score
                $weightTotal += $weight
            }

            $finalMatch = [regex]::Match($learning, '(?ms)^##\s+最终项目综合评价\s*(.*)$')
            if (-not $finalMatch.Success) {
                $errors.Add('经验学习.md is missing 最终项目综合评价')
            } else {
                $finalBlock = $finalMatch.Groups[1].Value
                if ((Get-MarkdownFieldValue -Text $finalBlock -Label 'Final status') -ne 'COMPLETE') {
                    $errors.Add('Final learning status must be COMPLETE')
                }
                if ((Get-MarkdownFieldValue -Text $finalBlock -Label 'Score source') -ne 'PREVIOUS_MODULE_SCORES_ONLY') {
                    $errors.Add('Final score source must be PREVIOUS_MODULE_SCORES_ONLY')
                }
                $finalScoreText = Get-MarkdownFieldValue -Text $finalBlock -Label 'Comprehensive score'
                $finalScoreMatch = [regex]::Match([string]$finalScoreText, '^(\d{1,3})\s*/\s*100$')
                if (-not $finalScoreMatch.Success) {
                    $errors.Add("Comprehensive score must use '<0-100> / 100'")
                } elseif ($weightTotal -gt 0) {
                    $expectedFinal = [int][Math]::Round(($weightedTotal / $weightTotal), 0, [MidpointRounding]::AwayFromZero)
                    if ([int]$finalScoreMatch.Groups[1].Value -ne $expectedFinal) {
                        $errors.Add("Comprehensive score must be the weighted result of prior module scores; expected $expectedFinal / 100")
                    }
                }
                if ($finalBlock -match '(?im)^#{1,6}\s*(最终考核|期末考试|Final\s+exam)\b') {
                    $errors.Add('Final project completion must not contain a new final exam')
                }
                if ((Get-MarkdownFieldValue -Text $learning -Label 'Overall learning status') -ne 'COMPLETE') {
                    $errors.Add('Overall learning status must be COMPLETE at final project completion')
                }
                $overallScoreText = Get-MarkdownFieldValue -Text $learning -Label 'Comprehensive score'
                if ($finalScoreMatch.Success -and $overallScoreText -ne $finalScoreText) {
                    $errors.Add('Top-level Comprehensive score must match the final project comprehensive score')
                }
            }
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
} elseif ($RequireLearningComplete) {
    Write-Output "Harness strict validation passed (learning complete)"
} elseif ($RequireLearningAssessment) {
    Write-Output "Harness strict validation passed (learning assessment: $LearningModuleId)"
} elseif ($RequireFrontendLock) {
    Write-Output "Harness strict validation passed (frontend lock required)"
} else {
    Write-Output "Harness strict validation passed (frontend draft allowed)"
}
Write-Output "Required files: $($required.Count)"
