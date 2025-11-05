# yaml2env

[![CI](https://github.com/huberp/yaml2env/workflows/CI/badge.svg)](https://github.com/huberp/yaml2env/actions)
[![Go Report Card](https://goreportcard.com/badge/github.com/huberp/yaml2env)](https://goreportcard.com/report/github.com/huberp/yaml2env)
[![Go Reference](https://pkg.go.dev/badge/github.com/huberp/yaml2env.svg)](https://pkg.go.dev/github.com/huberp/yaml2env)
[![Go Version](https://img.shields.io/github/go-mod/go-version/huberp/yaml2env)](https://github.com/huberp/yaml2env/blob/main/go.mod)
[![License](https://img.shields.io/github/license/huberp/yaml2env)](https://github.com/huberp/yaml2env/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/huberp/yaml2env)](https://github.com/huberp/yaml2env/releases)

Convert YAML files to shell environment variables.

## Overview

`yaml2env` reads YAML configuration files and outputs shell commands to set environment variables. Supports nested structures, arrays, and multiple shell formats.

## Features

- Convert YAML to environment variables
- Support for nested YAML structures
- Array handling
- Multiple shell formats: bash, sh, PowerShell, cmd
- CI/CD environment variable setting with `--set` flag (GitHub Actions)
- GitHub Actions integration via `$GITHUB_ENV`
- Cross-platform (Linux/Windows, AMD64/ARM64)
- Prefix support for variable names

## Installation

### From Release

Download the latest release for your platform from [releases](https://github.com/huberp/yaml2env/releases).

### From Source

```bash
go install github.com/huberp/yaml2env@latest
```

### Build Locally

```bash
git clone https://github.com/huberp/yaml2env.git
cd yaml2env
go build
```

## Usage

### Basic Usage

```bash
# Output bash export statements
yaml2env config.yaml

# Source into current shell
eval "$(yaml2env config.yaml)"
```

### Direct Environment Manipulation (--set)

**⚠️ Important: This flag is primarily designed for CI/CD environments like GitHub Actions.**

For interactive shell usage, use the sourcing/eval approach instead:

```bash
# For interactive shells (recommended)
eval "$(yaml2env config.yaml)"              # Bash/sh
Invoke-Expression (yaml2env config.yaml --shell powershell | Out-String)  # PowerShell

# For CI/CD environments (GitHub Actions)
yaml2env config.yaml --set
```

When using `--set`:
- Variables are set in the current process using `os.Setenv()`
- **Limitation**: Cannot modify parent shell environment in interactive sessions
- **GitHub Actions**: Variables are automatically written to `$GITHUB_ENV` for use in subsequent steps
- This flag is mutually exclusive with `--shell`

**GitHub Actions Example:**

```yaml
steps:
  - name: Set environment from YAML
    run: yaml2env config.yaml --set
  
  - name: Use variables in next step
    run: |
      echo "Database host: $DATABASE_HOST"
      echo "App name: $APP_NAME"
```

### Shell Types

```bash
# Bash/sh (default)
yaml2env config.yaml --shell bash

# PowerShell
yaml2env config.yaml --shell powershell

# Windows CMD
yaml2env config.yaml --shell cmd
```

### Prefix

Add a prefix to all environment variable names:

```bash
yaml2env config.yaml --prefix MYAPP
```

### Example

Given `config.yaml`:

```yaml
database:
  host: localhost
  port: 5432
app:
  name: myapp
  debug: true
```

Running `yaml2env config.yaml` outputs:

```bash
export DATABASE_HOST='localhost'
export DATABASE_PORT='5432'
export APP_NAME='myapp'
export APP_DEBUG='true'
```

## Flags

- `-s, --shell string`: Shell type (bash, sh, powershell, cmd) [default: bash]
- `--set`: Set environment variables in CI/CD environments (GitHub Actions). For interactive shells, use eval/sourcing instead
- `-p, --prefix string`: Prefix for environment variable names
- `-h, --help`: Help information
- `-v, --version`: Version information

## Development

### Prerequisites

- Go 1.25.3 or later
- [goreleaser](https://goreleaser.com/install/) (optional, for local releases)

### Build

```bash
go build
```

### Test

```bash
go test -v ./...
```

### Build for All Platforms (with goreleaser)

```bash
# Install goreleaser if needed
# See: https://goreleaser.com/install/

# Build snapshot (all platforms)
goreleaser build --snapshot --clean

# Binaries will be in dist/ directory
```

### Build Manually

```bash
# Linux AMD64
GOOS=linux GOARCH=amd64 go build -o yaml2env-linux-amd64

# Linux ARM64
GOOS=linux GOARCH=arm64 go build -o yaml2env-linux-arm64

# Windows AMD64
GOOS=windows GOARCH=amd64 go build -o yaml2env-windows-amd64.exe

# Windows ARM64
GOOS=windows GOARCH=arm64 go build -o yaml2env-windows-arm64.exe

# macOS AMD64
GOOS=darwin GOARCH=amd64 go build -o yaml2env-darwin-amd64

# macOS ARM64
GOOS=darwin GOARCH=arm64 go build -o yaml2env-darwin-arm64
```

## Release Process

Releases are automated using [goreleaser](https://goreleaser.com/) and GitHub Actions:

1. Tag a new version: `git tag -a v1.0.0 -m "Release v1.0.0"`
2. Push the tag: `git push origin v1.0.0`
3. GitHub Actions will automatically build and publish the release

The release workflow:
- Runs all tests
- Builds binaries for all supported platforms
- Creates checksums
- Generates release notes
- Publishes to GitHub Releases

## License

See LICENSE file.
