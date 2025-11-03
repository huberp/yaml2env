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

### Build

```bash
make build
```

### Test

```bash
make test
```

### Cross-Compile

```bash
# Linux AMD64
make build-linux-amd64

# Linux ARM64
make build-linux-arm64

# Windows AMD64
make build-windows-amd64

# Windows ARM64
make build-windows-arm64

# All platforms
make build-all
```

## Testing Scripts

Test scripts are provided for both Unix and Windows:

```bash
# Unix/Linux
./scripts/test.sh

# PowerShell
./scripts/test.ps1
```

## License

See LICENSE file.
