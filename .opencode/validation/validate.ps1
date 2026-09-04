# Simple validation script
Write-Host "=== StoreVoice Orchestration Validation ===" -ForegroundColor Cyan

# Check opencode.json
Write-Host "`n1. Checking opencode.json..." -ForegroundColor Yellow
if (Test-Path "D:\StoreVoice-Source-of-Truth\opencode.json") {
    Write-Host "   ✓ opencode.json exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ opencode.json not found" -ForegroundColor Red
}

# Check agent directory
Write-Host "`n2. Checking agent directory..." -ForegroundColor Yellow
if (Test-Path "D:\StoreVoice-Source-of-Truth\.opencode\agent") {
    $agentCount = (Get-ChildItem "D:\StoreVoice-Source-of-Truth\.opencode\agent" -Filter "*.md").Count
    Write-Host "   ✓ Agent directory exists with $agentCount files" -ForegroundColor Green
} else {
    Write-Host "   ✗ Agent directory not found" -ForegroundColor Red
}

# Check orchestration directory
Write-Host "`n3. Checking orchestration directory..." -ForegroundColor Yellow
if (Test-Path "D:\StoreVoice-Source-of-Truth\.opencode\orchestration") {
    $orchCount = (Get-ChildItem "D:\StoreVoice-Source-of-Truth\.opencode\orchestration" -Filter "*.md").Count
    Write-Host "   ✓ Orchestration directory exists with $orchCount files" -ForegroundColor Green
} else {
    Write-Host "   ✗ Orchestration directory not found" -ForegroundColor Red
}

# Check tests directory
Write-Host "`n4. Checking tests directory..." -ForegroundColor Yellow
if (Test-Path "D:\StoreVoice-Source-of-Truth\.opencode\tests") {
    $testCount = (Get-ChildItem "D:\StoreVoice-Source-of-Truth\.opencode\tests" -Filter "*.md").Count
    Write-Host "   ✓ Tests directory exists with $testCount files" -ForegroundColor Green
} else {
    Write-Host "   ✗ Tests directory not found" -ForegroundColor Red
}

# Check orchestrator agent
Write-Host "`n5. Checking orchestrator agent..." -ForegroundColor Yellow
if (Test-Path "D:\StoreVoice-Source-of-Truth\.opencode\agent\orchestrator.md") {
    Write-Host "   ✓ Orchestrator agent exists" -ForegroundColor Green
} else {
    Write-Host "   ✗ Orchestrator agent not found" -ForegroundColor Red
}

Write-Host "`n=== Validation Complete ===" -ForegroundColor Cyan