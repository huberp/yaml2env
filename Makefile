.PHONY: build test clean build-all build-linux-amd64 build-linux-arm64 build-windows-amd64 build-windows-arm64

# Build variables
VERSION ?= dev
COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
DATE ?= $(shell date -u +%Y-%m-%dT%H:%M:%SZ)
LDFLAGS := -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE)

# Build the binary
build:
	go build -ldflags "$(LDFLAGS)" -o yaml2env .

# Run tests
test:
	go test -v -race -coverprofile=coverage.txt -covermode=atomic ./...

# Run tests with coverage report
test-coverage: test
	go tool cover -html=coverage.txt

# Clean build artifacts
clean:
	rm -f yaml2env yaml2env-* coverage.txt

# Install dependencies
deps:
	go mod download
	go mod tidy

# Run linter
lint:
	golangci-lint run

# Build for all platforms
build-all: build-linux-amd64 build-linux-arm64 build-windows-amd64 build-windows-arm64

# Build for Linux AMD64
build-linux-amd64:
	GOOS=linux GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o yaml2env-linux-amd64 .

# Build for Linux ARM64
build-linux-arm64:
	GOOS=linux GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o yaml2env-linux-arm64 .

# Build for Windows AMD64
build-windows-amd64:
	GOOS=windows GOARCH=amd64 go build -ldflags "$(LDFLAGS)" -o yaml2env-windows-amd64.exe .

# Build for Windows ARM64
build-windows-arm64:
	GOOS=windows GOARCH=arm64 go build -ldflags "$(LDFLAGS)" -o yaml2env-windows-arm64.exe .

# Run the application
run:
	go run -ldflags "$(LDFLAGS)" . $(ARGS)

# Install the binary
install:
	go install -ldflags "$(LDFLAGS)" .

# Format code
fmt:
	go fmt ./...

# Vet code
vet:
	go vet ./...

# Run all checks
check: fmt vet lint test
