# Solution: --set Flag Limitations and Proper Usage

## Problem Identified

The `--set` flag was using `os.Setenv()` which only sets environment variables in the current process (the yaml2env CLI itself), not in the parent shell process that calls it. This is a fundamental operating system limitation - child processes cannot modify their parent's environment.

## Root Cause

When you run:
```powershell
yaml2env config.yaml --set
```

The environment variables are set **inside** the yaml2env process, but when the process exits, those variables are lost and don't affect the PowerShell session that called it.

## Solution Implemented

### 1. Clarified Purpose and Usage

**Updated the `--set` flag to clearly indicate it's for CI/CD environments:**
- Updated help text: `"Set environment variables in CI/CD (GitHub Actions). For interactive shells, use eval \"$(yaml2env file.yaml)\" instead"`
- Added warning when used outside CI/CD context
- Enhanced documentation with clear usage patterns

### 2. Added Runtime Warnings

When `--set` is used in interactive shells (not CI/CD), the tool now displays:
```
Warning: --set flag only sets variables in the current process.
For interactive shells, use: eval "$(yaml2env example.yaml)"
Or for PowerShell: Invoke-Expression (yaml2env example.yaml --shell powershell)
```

### 3. Documented Correct Usage Patterns

#### ✅ **For Interactive Shells (Recommended)**
```bash
# Bash/sh
eval "$(yaml2env config.yaml)"

# PowerShell  
Invoke-Expression (yaml2env config.yaml --shell powershell)

# Fish shell
yaml2env config.yaml --shell bash | source
```

#### ✅ **For CI/CD (GitHub Actions)**
```yaml
steps:
  - name: Set environment from YAML
    run: yaml2env config.yaml --set
  - name: Use variables
    run: echo $DATABASE_HOST  # Variables available here
```

## Why This Solution Works

### 1. **Preserves Existing Functionality**
- `--set` continues to work correctly in GitHub Actions (writes to `GITHUB_ENV`)
- All existing tests pass
- No breaking changes

### 2. **Educates Users**
- Clear warnings guide users to correct patterns
- Documentation explains limitations
- Examples show proper usage

### 3. **Maintains Tool Philosophy**
- Primary purpose remains generating shell commands for sourcing
- `--set` is a specialized feature for CI/CD contexts
- Tool remains focused and simple

## Alternative Solutions Considered

### 1. **Remove --set entirely**
- **Pros**: Eliminates confusion
- **Cons**: Breaks GitHub Actions workflows, removes legitimate use case

### 2. **Platform-specific solutions**
- **Pros**: Could work for some shells
- **Cons**: Complex, unreliable, platform-dependent

### 3. **Shell integration scripts**
- **Pros**: More convenient
- **Cons**: Complex installation, maintenance burden

## Verification

Created test script (`scripts/test-usage-patterns.ps1`) that demonstrates:
- ❌ Wrong usage (shows warning)
- ✅ Correct interactive usage (PowerShell eval pattern)
- ✅ Correct CI/CD usage (with GITHUB_ENV)

## Files Modified

1. `cmd/root.go` - Updated help text and added warning logic
2. `README.md` - Clarified documentation and usage patterns
3. `scripts/test-usage-patterns.ps1` - Added verification script

The solution maintains backward compatibility while clearly guiding users toward correct usage patterns for their specific environment.