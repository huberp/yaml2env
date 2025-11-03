# Test script to demonstrate proper yaml2env usage patterns
Write-Host "=== Testing yaml2env usage patterns ===" -ForegroundColor Cyan

# Create test YAML
$testYaml = @"
app:
  name: test-app
  version: 1.0.0
database:
  host: localhost
  port: 5432
"@

$testYaml | Out-File -FilePath "$env:TEMP\usage-test.yaml" -Encoding utf8

Write-Host ""
Write-Host "❌ WRONG: Using --set in interactive shell (will show warning)" -ForegroundColor Red
.\yaml2env.exe "$env:TEMP\usage-test.yaml" --set

Write-Host ""
Write-Host "✅ CORRECT: Using eval pattern for PowerShell" -ForegroundColor Green
$envScript = .\yaml2env.exe "$env:TEMP\usage-test.yaml" --shell powershell | Out-String
Invoke-Expression $envScript
Write-Host "APP_NAME = $env:APP_NAME"
Write-Host "DATABASE_HOST = $env:DATABASE_HOST"

Write-Host ""
Write-Host "✅ CORRECT: Generating shell script for sourcing" -ForegroundColor Green
Write-Host "For bash/sh, you would run: eval `"`$(yaml2env file.yaml)`""
.\yaml2env.exe "$env:TEMP\usage-test.yaml" --shell bash | Select-Object -First 3

Write-Host ""
Write-Host "✅ CORRECT: CI/CD usage (simulated with GITHUB_ENV)" -ForegroundColor Green
$env:GITHUB_ENV = "$env:TEMP\github_env_test"
$env:CI = "true"
.\yaml2env.exe "$env:TEMP\usage-test.yaml" --set
Write-Host "Content written to GITHUB_ENV:"
Get-Content $env:GITHUB_ENV

# Cleanup
Remove-Item "$env:TEMP\usage-test.yaml" -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\github_env_test" -ErrorAction SilentlyContinue
Remove-Item Env:GITHUB_ENV -ErrorAction SilentlyContinue
Remove-Item Env:CI -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=== Usage pattern tests completed ===" -ForegroundColor Green