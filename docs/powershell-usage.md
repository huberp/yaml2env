# PowerShell Usage Patterns for yaml2env

This document demonstrates various working methods to set environment variables from YAML in PowerShell.

## Method 1: Invoke-Expression with Out-String (Recommended)

```powershell
Invoke-Expression (yaml2env config.yaml --shell powershell | Out-String)
```

**Pros:**
- Single command
- All variables set at once
- Clean and simple

**Cons:**
- Executes arbitrary code (security consideration)

## Method 2: ForEach-Object Line-by-Line

```powershell
yaml2env config.yaml --shell powershell | ForEach-Object { Invoke-Expression $_ }
```

**Pros:**
- Processes each line individually
- Good for debugging (can see which line fails)

**Cons:**
- Slightly more verbose

## Method 3: Temporary File

```powershell
yaml2env config.yaml --shell powershell | Out-File -FilePath $env:TEMP\env.ps1 -Encoding utf8
& $env:TEMP\env.ps1
Remove-Item $env:TEMP\env.ps1
```

**Pros:**
- Can inspect the generated script
- Good for debugging complex YAML files

**Cons:**
- Creates temporary file
- More commands needed

## Method 4: String Join and Execute

```powershell
$envCommands = yaml2env config.yaml --shell powershell
$envScript = $envCommands -join "; "
Invoke-Expression $envScript
```

**Pros:**
- Explicit string handling
- Good for understanding what's happening

**Cons:**
- More verbose than Method 1

## Testing Your Setup

Create a simple test:

```powershell
# Create test YAML
@"
test:
  var1: hello
  var2: world
"@ | Out-File test.yaml

# Method 1 (recommended)
Invoke-Expression (yaml2env test.yaml --shell powershell | Out-String)

# Verify
Write-Host "TEST_VAR1: $env:TEST_VAR1"
Write-Host "TEST_VAR2: $env:TEST_VAR2"

# Cleanup
Remove-Item test.yaml
```

## Common Issues and Solutions

### Issue: "System.Object[] cannot be converted to System.String"

**Cause:** Missing `| Out-String` when using `Invoke-Expression`

**Solution:** Always use `| Out-String` with `Invoke-Expression`:
```powershell
# Wrong
Invoke-Expression (yaml2env file.yaml --shell powershell)

# Correct  
Invoke-Expression (yaml2env file.yaml --shell powershell | Out-String)
```

### Issue: Variables not persisting after script

**Cause:** Variables are set in the correct scope

**Solution:** This is expected behavior. Variables are set in your current PowerShell session and will persist until you close the session or explicitly remove them.

## Best Practices

1. **Use Method 1** for most cases (simple and reliable)
2. **Quote file paths** with spaces: `yaml2env "C:\path with spaces\config.yaml"`
3. **Test with simple YAML** first before using complex configurations
4. **Use `--prefix`** to avoid conflicts: `yaml2env config.yaml --shell powershell --prefix MYAPP`