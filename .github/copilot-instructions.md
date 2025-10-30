# GitHub Copilot Instructions for yaml2env

## Communication Style
- Be blunt.
- Write short sentences.
- Use bullet points.
- Avoid useless filler phrases.
- Avoid useless explanations.
- Write like giving instructions to a machine not writing to a human.

## Project Overview
- Golang CLI tool
- Converts YAML files to environment variables
- Supports multiple shell formats: bash, sh, PowerShell, cmd
- Cross-platform: Linux, Windows
- Cross-architecture: AMD64, ARM64

## Code Standards
- Follow Go best practices
- Use standard project layout
- Keep functions small and focused
- Write tests for all new code
- Maintain test coverage above 80%
- Use table-driven tests

## Dependencies
- Use minimal external dependencies
- Prefer standard library when possible
- Current dependencies:
  - github.com/spf13/cobra: CLI framework
  - gopkg.in/yaml.v3: YAML parsing

## Testing
- Write tests before implementation (TDD)
- Use Go standard testing package
- Run tests with race detector: `go test -race ./...`
- Use test scripts in `scripts/` directory
- Test on both Unix and Windows shells

## Building
- Use Makefile for build tasks
- Support cross-compilation for all target platforms
- Version info from git tags
- Build flags in LDFLAGS

## CLI Design
- Follow Unix conventions
- Implement `--help` and `--version` flags
- Use flags for options, arguments for required inputs
- Exit codes: 0 for success, 1 for errors
- Error messages to stderr

## File Organization
- `main.go`: Entry point only
- `cmd/`: CLI command definitions
- `internal/converter/`: Core conversion logic
- `scripts/`: Test and build scripts
- `.github/workflows/`: CI/CD pipelines

## Git Workflow
- Use conventional commits
- Keep commits atomic
- Write descriptive commit messages
- Use feature branches
- Test before committing

## CI/CD
- All commits must pass tests
- Run linter on all code
- Build for all target platforms
- Upload artifacts for releases
- Tag releases with semantic versioning

## Code Review Focus
- Correctness of YAML parsing
- Shell escaping and security
- Cross-platform compatibility
- Error handling
- Test coverage
- Performance for large YAML files
