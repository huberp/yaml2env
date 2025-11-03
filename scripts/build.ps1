# PowerShell build script for yaml2env
param(
    [string]$Target = "local",
    [string]$Version = "dev"
)

Write-Host "=== Building yaml2env ===" -ForegroundColor Cyan
Write-Host "Target: $Target" -ForegroundColor White
Write-Host "Version: $Version" -ForegroundColor White

# Get build info
$commit = try { 
    git rev-parse --short HEAD 2>$null 
} catch { 
    "unknown" 
}
$date = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$ldflags = "-X main.version=$Version -X main.commit=$commit -X main.date=$date"

Write-Host ""
Write-Host "Build info:" -ForegroundColor Yellow
Write-Host "  Version: $Version"
Write-Host "  Commit:  $commit"
Write-Host "  Date:    $date"

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
go mod download
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to download dependencies"
    exit 1
}

go mod tidy
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to tidy dependencies"
    exit 1
}

Write-Host ""
Write-Host "Running go vet..." -ForegroundColor Yellow
go vet ./...
if ($LASTEXITCODE -ne 0) {
    Write-Error "go vet failed"
    exit 1
}

Write-Host ""
Write-Host "Running go fmt..." -ForegroundColor Yellow
$fmtResult = go fmt ./...
if ($fmtResult) {
    Write-Warning "Code formatting issues found: $fmtResult"
}

Write-Host ""
Write-Host "Building..." -ForegroundColor Yellow

switch ($Target) {
    "local" {
        Write-Host "Building for local platform..."
        go build -ldflags $ldflags -o yaml2env.exe .
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Built yaml2env.exe" -ForegroundColor Green
        }
    }
    "all" {
        Write-Host "Building for all platforms..."
        
        # Windows AMD64
        $env:GOOS = "windows"; $env:GOARCH = "amd64"
        go build -ldflags $ldflags -o yaml2env-windows-amd64.exe .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-windows-amd64.exe" -ForegroundColor Green }
        
        # Windows ARM64
        $env:GOOS = "windows"; $env:GOARCH = "arm64"
        go build -ldflags $ldflags -o yaml2env-windows-arm64.exe .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-windows-arm64.exe" -ForegroundColor Green }
        
        # Linux AMD64
        $env:GOOS = "linux"; $env:GOARCH = "amd64"
        go build -ldflags $ldflags -o yaml2env-linux-amd64 .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-linux-amd64" -ForegroundColor Green }
        
        # Linux ARM64
        $env:GOOS = "linux"; $env:GOARCH = "arm64"
        go build -ldflags $ldflags -o yaml2env-linux-arm64 .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-linux-arm64" -ForegroundColor Green }
        
        # Reset env vars
        Remove-Item Env:GOOS -ErrorAction SilentlyContinue
        Remove-Item Env:GOARCH -ErrorAction SilentlyContinue
    }
    "windows" {
        Write-Host "Building for Windows platforms..."
        
        # Windows AMD64
        $env:GOOS = "windows"; $env:GOARCH = "amd64"
        go build -ldflags $ldflags -o yaml2env-windows-amd64.exe .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-windows-amd64.exe" -ForegroundColor Green }
        
        # Windows ARM64
        $env:GOOS = "windows"; $env:GOARCH = "arm64"
        go build -ldflags $ldflags -o yaml2env-windows-arm64.exe .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-windows-arm64.exe" -ForegroundColor Green }
        
        # Reset env vars
        Remove-Item Env:GOOS -ErrorAction SilentlyContinue
        Remove-Item Env:GOARCH -ErrorAction SilentlyContinue
    }
    "linux" {
        Write-Host "Building for Linux platforms..."
        
        # Linux AMD64
        $env:GOOS = "linux"; $env:GOARCH = "amd64"
        go build -ldflags $ldflags -o yaml2env-linux-amd64 .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-linux-amd64" -ForegroundColor Green }
        
        # Linux ARM64
        $env:GOOS = "linux"; $env:GOARCH = "arm64"
        go build -ldflags $ldflags -o yaml2env-linux-arm64 .
        if ($LASTEXITCODE -eq 0) { Write-Host "[OK] Built yaml2env-linux-arm64" -ForegroundColor Green }
        
        # Reset env vars
        Remove-Item Env:GOOS -ErrorAction SilentlyContinue
        Remove-Item Env:GOARCH -ErrorAction SilentlyContinue
    }
    default {
        Write-Error "Unknown target: $Target. Use: local, all, windows, linux"
        exit 1
    }
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed"
    exit 1
}

Write-Host ""
Write-Host "=== Build completed successfully ===" -ForegroundColor Green