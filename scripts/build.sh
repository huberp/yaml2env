#!/bin/bash
set -e

TARGET="${1:-local}"
VERSION="${2:-dev}"

echo "=== Building yaml2env ==="
echo "Target: $TARGET"
echo "Version: $VERSION"

# Get build info
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE=$(date -u +%Y-%m-%dT%H:%M:%SZ)

LDFLAGS="-X main.version=$VERSION -X main.commit=$COMMIT -X main.date=$DATE"

echo ""
echo "Build info:"
echo "  Version: $VERSION"
echo "  Commit:  $COMMIT"
echo "  Date:    $DATE"

echo ""
echo "Installing dependencies..."
go mod download
go mod tidy

echo ""
echo "Running go vet..."
go vet ./...

echo ""
echo "Running go fmt..."
FMT_RESULT=$(go fmt ./...)
if [ -n "$FMT_RESULT" ]; then
    echo "Warning: Code formatting issues found: $FMT_RESULT"
fi

echo ""
echo "Building..."

case $TARGET in
    "local")
        echo "Building for local platform..."
        go build -ldflags "$LDFLAGS" -o yaml2env .
        echo "✓ Built yaml2env"
        ;;
    "all")
        echo "Building for all platforms..."
        
        # Linux AMD64
        GOOS=linux GOARCH=amd64 go build -ldflags "$LDFLAGS" -o yaml2env-linux-amd64 .
        echo "✓ Built yaml2env-linux-amd64"
        
        # Linux ARM64
        GOOS=linux GOARCH=arm64 go build -ldflags "$LDFLAGS" -o yaml2env-linux-arm64 .
        echo "✓ Built yaml2env-linux-arm64"
        
        # Windows AMD64
        GOOS=windows GOARCH=amd64 go build -ldflags "$LDFLAGS" -o yaml2env-windows-amd64.exe .
        echo "✓ Built yaml2env-windows-amd64.exe"
        
        # Windows ARM64
        GOOS=windows GOARCH=arm64 go build -ldflags "$LDFLAGS" -o yaml2env-windows-arm64.exe .
        echo "✓ Built yaml2env-windows-arm64.exe"
        ;;
    "linux")
        echo "Building for Linux platforms..."
        
        # Linux AMD64
        GOOS=linux GOARCH=amd64 go build -ldflags "$LDFLAGS" -o yaml2env-linux-amd64 .
        echo "✓ Built yaml2env-linux-amd64"
        
        # Linux ARM64
        GOOS=linux GOARCH=arm64 go build -ldflags "$LDFLAGS" -o yaml2env-linux-arm64 .
        echo "✓ Built yaml2env-linux-arm64"
        ;;
    "windows")
        echo "Building for Windows platforms..."
        
        # Windows AMD64
        GOOS=windows GOARCH=amd64 go build -ldflags "$LDFLAGS" -o yaml2env-windows-amd64.exe .
        echo "✓ Built yaml2env-windows-amd64.exe"
        
        # Windows ARM64
        GOOS=windows GOARCH=arm64 go build -ldflags "$LDFLAGS" -o yaml2env-windows-arm64.exe .
        echo "✓ Built yaml2env-windows-arm64.exe"
        ;;
    *)
        echo "Error: Unknown target: $TARGET. Use: local, all, windows, linux"
        exit 1
        ;;
esac

echo ""
echo "=== Build completed successfully ==="