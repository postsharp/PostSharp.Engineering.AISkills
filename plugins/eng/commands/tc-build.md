---
description: Trigger a TeamCity build for the current branch
argument-hint: "[BuildType]"
allowed-tools:
  - Bash
  - Read
---

# Trigger TeamCity Build

Trigger a build on TeamCity for the current branch.

## Arguments

$ARGUMENTS - Optional build type (default: DebugBuild). Common types: DebugBuild, ReleaseBuild

## Instructions

### 1. Determine Build Configuration

1. Read `.teamcity/settings.kts` to find:
   - Available build types: `object <Name> : BuildType`
   - VCS root ID: `AbsoluteId("...")` in vcs block - extract project prefix
2. Get current branch: `git rev-parse --abbrev-ref HEAD`
3. Ask user which build configuration to trigger (if not specified)
4. Build type ID format: `<ProjectPrefix>_<BuildTypeName>` (e.g., if VCS root is `Metalama_Metalama20260_Metalama`, build type ID is `Metalama_Metalama20260_Metalama_DebugBuild`)

### 2. Authentication Context

Check `RUNNING_IN_DOCKER` environment variable to determine authentication method:

**When running in Docker** (`RUNNING_IN_DOCKER=true`):
- TeamCity API calls require MCP authorization
- Claude will prompt for authorization when needed
- Use PowerShell `Invoke-RestMethod` for API calls
- The MCP server accesses `TEAMCITY_CLOUD_TOKEN` on the host

**When running on host** (`RUNNING_IN_DOCKER` not set or false):
- Use `TEAMCITY_CLOUD_TOKEN` environment variable for authentication
- Use PowerShell `Invoke-RestMethod` for API calls
- Token must be set in the environment

### 3. Trigger Build Using PowerShell

**Construct Request Body:**
```powershell
$body = @{
    buildType = @{id = $buildTypeId}
    branchName = $branchName
} | ConvertTo-Json -Compress
```

**Trigger Build:**
```powershell
$result = Invoke-RestMethod `
    -Uri 'https://postsharp.teamcity.com/app/rest/buildQueue' `
    -Method Post `
    -Headers @{
        Authorization = "Bearer $env:TEAMCITY_CLOUD_TOKEN"
        Accept = 'application/json'
    } `
    -ContentType 'application/json' `
    -Body $body
```

### 4. Display Results

Extract and display build information from the response:

```powershell
Write-Host "Build queued successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Build #$($result.id) - $($result.buildType.name)" -ForegroundColor Cyan
Write-Host "Branch: $($result.branchName)"
Write-Host "Status: $($result.state)" -ForegroundColor Yellow
Write-Host ""
Write-Host "Build URL: $($result.webUrl)" -ForegroundColor Cyan
```

**Key Response Fields:**

| Field | Description | Example |
|-------|-------------|---------|
| `id` | Build ID | 12345 |
| `buildType.id` | Build type ID | `Metalama_DebugBuild` |
| `buildType.name` | Build configuration name | "Build [Debug]" |
| `branchName` | Git branch | `topic/2026.0/1234-fix` |
| `state` | Build state | `queued` |
| `webUrl` | Link to build in TC UI | Full URL |
| `queuedDate` | When build was queued | ISO 8601 timestamp |

### 5. Usage Notes

**Docker Environment:**
- Use `mcp__host-approval__ExecuteCommand` tool for PowerShell commands
- MCP authorization prompt will appear for API calls
- Token is accessed from host environment

**Host Environment:**
- Can use Bash tool with PowerShell commands directly
- Ensure `TEAMCITY_CLOUD_TOKEN` is set in environment
- No MCP authorization needed

## Error Handling

**Authentication Errors:**
- When running on host: If `TEAMCITY_CLOUD_TOKEN` not set, display error message
- When running in Docker: If MCP authorization fails or is denied, display error message
- Check `RUNNING_IN_DOCKER` environment variable to provide appropriate error context

**API Errors:**
- If build type not found, API returns 404 - display "Build type not found: <id>"
- If branch doesn't exist, API may return 400 - display error details
- Invalid JSON or missing fields returns 400 - display the error message
- Network errors should be caught and displayed clearly

**Common Issues:**
- **Build already queued**: TeamCity may reject if same build is already queued
- **Permission denied**: Token may not have permission for this build type
- **Invalid branch name**: Branch must exist in the repository

## Example Complete Workflow

```powershell
# 1. Get current branch
$branch = git rev-parse --abbrev-ref HEAD

# 2. Construct build type ID (example)
$buildTypeId = "Metalama_Metalama20260_Metalama_DebugBuild"

# 3. Build request body
$body = @{
    buildType = @{id = $buildTypeId}
    branchName = $branch
} | ConvertTo-Json -Compress

# 4. Trigger build
try {
    $result = Invoke-RestMethod `
        -Uri 'https://postsharp.teamcity.com/app/rest/buildQueue' `
        -Method Post `
        -Headers @{
            Authorization = "Bearer $env:TEAMCITY_CLOUD_TOKEN"
            Accept = 'application/json'
        } `
        -ContentType 'application/json' `
        -Body $body

    # 5. Display success
    Write-Host "Build queued successfully!" -ForegroundColor Green
    Write-Host "Build #$($result.id) - $($result.buildType.name)"
    Write-Host "URL: $($result.webUrl)" -ForegroundColor Cyan
}
catch {
    Write-Host "Error triggering build: $($_.Exception.Message)" -ForegroundColor Red
}
```
