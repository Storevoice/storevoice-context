# Agent Loading Validation Script
# Tests that agent definitions are properly structured and loadable

$agentDir = "D:\StoreVoice-Source-of-Truth\.opencode\agent"
$configFile = "D:\StoreVoice-Source-of-Truth\opencode.json"

Write-Host "=== Agent Loading Validation ===" -ForegroundColor Cyan

# Test 1: Check if opencode.json exists and is valid JSON
Write-Host "`n1. Checking opencode.json..." -ForegroundColor Yellow
if (Test-Path $configFile) {
    try {
        $config = Get-Content $configFile -Raw | ConvertFrom-Json
        Write-Host "   ✓ opencode.json is valid JSON" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ opencode.json is invalid JSON: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "   ✗ opencode.json not found" -ForegroundColor Red
    exit 1
}

# Test 2: Check if agent directory exists
Write-Host "`n2. Checking agent directory..." -ForegroundColor Yellow
if (Test-Path $agentDir) {
    $agentFiles = Get-ChildItem -Path $agentDir -Filter "*.md" -File
    Write-Host "   ✓ Agent directory exists with $($agentFiles.Count) agent files" -ForegroundColor Green
} else {
    Write-Host "   ✗ Agent directory not found" -ForegroundColor Red
    exit 1
}

# Test 3: Check if orchestrator agent exists
Write-Host "`n3. Checking orchestrator agent..." -ForegroundColor Yellow
$orchestratorFile = Join-Path $agentDir "orchestrator.md"
if (Test-Path $orchestratorFile) {
    $content = Get-Content $orchestratorFile -Raw
    if ($content -match "description:") {
        Write-Host "   ✓ Orchestrator agent exists with description" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Orchestrator agent missing description" -ForegroundColor Red
    }
} else {
    Write-Host "   ✗ Orchestrator agent file not found" -ForegroundColor Red
    exit 1
}

# Test 4: Validate agent file structure
Write-Host "`n4. Validating agent file structure..." -ForegroundColor Yellow
$requiredFields = @("description", "mode", "model", "permission")
$validationErrors = @()

foreach ($agentFile in $agentFiles) {
    $content = Get-Content $agentFile.FullName -Raw
    
    # Check for required frontmatter fields
    foreach ($field in $requiredFields) {
        $pattern = "$field" + ":"
        if ($content -notmatch [regex]::Escape($pattern)) {
            $validationErrors += "$($agentFile.Name): Missing $field"
        }
    }
    
    # Check for valid mode
    if ($content -match '"mode":\s*"([^"]+)"') {
        $mode = $Matches[1]
        if ($mode -notin @("primary", "subagent", "all")) {
            $validationErrors += "$($agentFile.Name): Invalid mode '$mode'"
        }
    }
}

if ($validationErrors.Count -eq 0) {
    Write-Host "   ✓ All agent files have valid structure" -ForegroundColor Green
} else {
    Write-Host "   ✗ Agent file validation errors:" -ForegroundColor Red
    foreach ($error in $validationErrors) {
        Write-Host "     - $error" -ForegroundColor Red
    }
}

# Test 5: Check for duplicate agent definitions
Write-Host "`n5. Checking for duplicate agents..." -ForegroundColor Yellow
$agentNames = @()
foreach ($agentFile in $agentFiles) {
    $agentName = $agentFile.BaseName
    $agentNames += $agentName
}

$duplicates = $agentNames | Group-Object | Where-Object { $_.Count -gt 1 }
if ($duplicates.Count -eq 0) {
    Write-Host "   ✓ No duplicate agent definitions found" -ForegroundColor Green
} else {
    Write-Host "   ✗ Duplicate agents found:" -ForegroundColor Red
    foreach ($duplicate in $duplicates) {
        Write-Host "     - $($duplicate.Name) (appears $($duplicate.Count) times)" -ForegroundColor Red
    }
}

# Test 6: Verify agent count matches topology
Write-Host "`n6. Verifying agent count against topology..." -ForegroundColor Yellow
$expectedAgentCount = 31  # From 005E topology
$actualAgentCount = $agentFiles.Count

if ($actualAgentCount -eq $expectedAgentCount) {
    Write-Host "   ✓ Agent count matches topology: $actualAgentCount agents" -ForegroundColor Green
} else {
    Write-Host "   ✗ Agent count mismatch: Expected $expectedAgentCount, found $actualAgentCount" -ForegroundColor Red
}

# Test 7: Check agent permissions
Write-Host "`n7. Checking agent permissions..." -ForegroundColor Yellow
$permissionIssues = @()

foreach ($agentFile in $agentFiles) {
    $content = Get-Content $agentFile.FullName -Raw
    
    # Check for permission section
    if ($content -notmatch "permission:") {
        $permissionIssues += "$($agentFile.Name): Missing permission section"
    }
}

if ($permissionIssues.Count -eq 0) {
    Write-Host "   ✓ All agents have permission sections" -ForegroundColor Green
} else {
    Write-Host "   ✗ Permission issues:" -ForegroundColor Red
    foreach ($issue in $permissionIssues) {
        Write-Host "     - $issue" -ForegroundColor Red
    }
}

# Summary
Write-Host "`n=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Agent files found: $($agentFiles.Count)" -ForegroundColor White
Write-Host "Expected agents: $expectedAgentCount" -ForegroundColor White
Write-Host "Validation errors: $($validationErrors.Count + $permissionIssues.Count)" -ForegroundColor White

if ($validationErrors.Count -eq 0 -and $permissionIssues.Count -eq 0 -and $actualAgentCount -eq $expectedAgentCount) {
    Write-Host "`nRESULT: PASS" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`nRESULT: FAIL" -ForegroundColor Red
    exit 1
}