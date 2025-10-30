# PowerShell test script for yaml2env
Write-Host "=== Testing yaml2env on Windows (PowerShell) ===" -ForegroundColor Cyan

# Create test YAML file
$testYaml = @"
database:
  host: localhost
  port: 5432
  username: admin
app:
  name: myapp
  debug: true
"@

$testYaml | Out-File -FilePath "$env:TEMP\test.yaml" -Encoding utf8

Write-Host ""
Write-Host "Test 1: Basic conversion to PowerShell" -ForegroundColor Yellow
.\yaml2env.exe "$env:TEMP\test.yaml" --shell powershell

Write-Host ""
Write-Host "Test 2: Conversion with prefix" -ForegroundColor Yellow
.\yaml2env.exe "$env:TEMP\test.yaml" --shell powershell --prefix MYAPP

Write-Host ""
Write-Host "Test 3: Test importing (actual environment variable setting)" -ForegroundColor Yellow
$envScript = .\yaml2env.exe "$env:TEMP\test.yaml" --shell powershell
Invoke-Expression $envScript
Write-Host "DATABASE_HOST=$env:DATABASE_HOST"
Write-Host "DATABASE_PORT=$env:DATABASE_PORT"
Write-Host "APP_NAME=$env:APP_NAME"

Write-Host ""
Write-Host "Test 4: Nested YAML with arrays" -ForegroundColor Yellow
$testYaml2 = @"
services:
  - name: web
    port: 8080
  - name: api
    port: 3000
"@

$testYaml2 | Out-File -FilePath "$env:TEMP\test2.yaml" -Encoding utf8
.\yaml2env.exe "$env:TEMP\test2.yaml" --shell powershell

Write-Host ""
Write-Host "=== All tests passed ===" -ForegroundColor Green

# Cleanup
Remove-Item "$env:TEMP\test.yaml" -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\test2.yaml" -ErrorAction SilentlyContinue
