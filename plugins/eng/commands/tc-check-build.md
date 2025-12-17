---
description: Check the status of a TeamCity build
argument-hint: "<buildId> [continuous]"
---

# Check TeamCity Build Status

Check the status of a TeamCity build and display results.

## Arguments

$ARGUMENTS - Build ID or "latest" to check the most recent build for current branch (default: latest)

## Instructions

### 1. Determine Build to Check

If argument is a build ID (numeric), use it directly. Otherwise:
1. Get current branch: `git rev-parse --abbrev-ref HEAD`
2. Read `.teamcity/settings.kts` to find:
   - VCS root ID: `AbsoluteId("...")` in vcs block
   - Build type prefix from VCS root (e.g., `Metalama_Metalama20260_Metalama`)
3. Construct build type ID: `<Prefix>_DebugBuild` (e.g., `Metalama_Metalama20260_Metalama_DebugBuild`)
4. Query latest build using the API

### 2. Query Build Status

**Get Specific Build by ID:**
```bash
curl -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
     -H "Accept: application/json" \
     "https://postsharp.teamcity.com/app/rest/builds/id:<buildId>"
```

**Get Latest Build for Branch/BuildType:**
```bash
curl -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
     -H "Accept: application/json" \
     "https://postsharp.teamcity.com/app/rest/builds?locator=buildType:<buildTypeId>,branch:<branchName>,count:1"
```

### 3. Parse and Display Results

**Key Fields in Response:**

| Field | Description | Values |
|-------|-------------|--------|
| `id` | Build ID | Numeric |
| `status` | Build result | `SUCCESS`, `FAILURE`, `ERROR` |
| `state` | Build state | `queued`, `running`, `finished` |
| `statusText` | Detailed status message | Text description of error/success |
| `webUrl` | Link to build in TC UI | URL |
| `branchName` | Git branch | Branch name |
| `startDate` | When build started | ISO 8601 timestamp |
| `finishDate` | When build finished | ISO 8601 timestamp (null if running) |
| `queuedDate` | When build was queued | ISO 8601 timestamp |
| `buildType.name` | Build configuration name | e.g., "Build [Debug]" |
| `agent.name` | Build agent | Agent name |
| `problemOccurrences.count` | Number of problems | Numeric |

### 4. Display Build Status

**Format output as:**
```
Build #<number> (<buildType.name>)
Status: <status> (<state>)
Branch: <branchName>
<statusText>

Started:  <startDate>
Finished: <finishDate> (or "Still running" if state=running)
Duration: <calculated from dates>
Agent: <agent.name>

Problems: <problemOccurrences.count>
URL: <webUrl>
```

### 5. Handle Running Builds

If `state == "running"`:
- Display "Build is still running"
- Show elapsed time since `startDate`
- Optionally poll every 30 seconds with `--wait` flag
- Use `finishDate == null` to detect running state

### 6. Get Problem Details (Optional)

If `problemOccurrences.count > 0`, fetch details:
```bash
curl -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
     -H "Accept: application/json" \
     "https://postsharp.teamcity.com/app/rest/problemOccurrences?locator=build:(id:<buildId>)"
```

**Problem fields:**
- `type`: Problem type (e.g., `TC_EXIT_CODE`, `TC_COMPILATION_ERROR`, `TC_FAILED_TESTS`)
- `identity`: Step that failed
- `details`: Additional information

### 7. Get Test Results

**Test Summary in Build Response:**

The build response includes a `testOccurrences` field with summary:
```json
{
  "count": 6553,
  "failed": 2,
  "passed": 6368,
  "ignored": 183,
  "href": "/app/rest/testOccurrences?locator=build:(id:311629)"
}
```

**Get All Test Results:**
```bash
curl -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
     -H "Accept: application/json" \
     "https://postsharp.teamcity.com/app/rest/testOccurrences?locator=build:(id:<buildId>)"
```

**Get Failed Tests Only:**
```bash
curl -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
     -H "Accept: application/json" \
     "https://postsharp.teamcity.com/app/rest/testOccurrences?locator=build:(id:<buildId>),status:FAILURE"
```

**Get Detailed Test Information:**
```bash
curl -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
     -H "Accept: application/json" \
     "https://postsharp.teamcity.com/app/rest/testOccurrences/build:(id:<buildId>),id:<testId>"
```

**Test Occurrence Fields:**

| Field | Description | Example |
|-------|-------------|---------|
| `id` | Test occurrence ID | `2000007320` |
| `name` | Full test name | `TargetCode.Method()` |
| `status` | Test result | `SUCCESS`, `FAILURE`, `UNKNOWN` |
| `duration` | Test duration in ms | `45` |
| `details` | Full failure details including stack trace | Multi-line string with exception and stack |
| `test.name` | Short test name | Method name only |
| `muted` | Whether test is muted | `true`/`false` |
| `currentlyMuted` | Whether currently muted | `true`/`false` |
| `href` | Link to full test info | API URL |

**Display Test Results:**

When displaying failed tests:
1. Show test count summary from `testOccurrences` in build
2. If `failed > 0`, fetch failed test details
3. For each failed test, display:
   - Test name
   - Status
   - Duration
   - First few lines of error message (from `details` field)
   - Option to show full stack trace

## PowerShell Implementation Example

```powershell
# Get build info
$build = Invoke-RestMethod -Method GET `
    -Uri "https://postsharp.teamcity.com/app/rest/builds/id:$buildId" `
    -Headers @{
        "Authorization" = "Bearer $env:TEAMCITY_CLOUD_TOKEN"
        "Accept" = "application/json"
    }

# Display status
Write-Host "Build #$($build.number) - $($build.buildType.name)" -ForegroundColor Cyan
Write-Host "Status: $($build.status) ($($build.state))" -ForegroundColor $(
    if ($build.status -eq "SUCCESS") { "Green" } else { "Red" }
)
Write-Host "Branch: $($build.branchName)"
Write-Host $build.statusText
Write-Host ""
Write-Host "Started:  $($build.startDate)"
if ($build.state -eq "finished") {
    Write-Host "Finished: $($build.finishDate)"
    $duration = [DateTime]::Parse($build.finishDate) - [DateTime]::Parse($build.startDate)
    Write-Host "Duration: $($duration.ToString('hh\:mm\:ss'))"
} else {
    Write-Host "Still running..."
    $elapsed = [DateTime]::UtcNow - [DateTime]::Parse($build.startDate)
    Write-Host "Elapsed:  $($elapsed.ToString('hh\:mm\:ss'))"
}
Write-Host ""
Write-Host "Agent: $($build.agent.name)"
if ($build.problemOccurrences.count -gt 0) {
    Write-Host "Problems: $($build.problemOccurrences.count)" -ForegroundColor Yellow
}

# Display test results summary
if ($build.testOccurrences) {
    Write-Host ""
    Write-Host "Tests: $($build.testOccurrences.count) total, " -NoNewline
    Write-Host "$($build.testOccurrences.passed) passed, " -NoNewline -ForegroundColor Green
    if ($build.testOccurrences.failed -gt 0) {
        Write-Host "$($build.testOccurrences.failed) failed, " -NoNewline -ForegroundColor Red
    }
    Write-Host "$($build.testOccurrences.ignored) ignored" -ForegroundColor Gray

    # Show failed tests if any
    if ($build.testOccurrences.failed -gt 0) {
        Write-Host ""
        Write-Host "Failed Tests:" -ForegroundColor Red

        $failedTests = Invoke-RestMethod -Method GET `
            -Uri "https://postsharp.teamcity.com/app/rest/testOccurrences?locator=build:(id:$buildId),status:FAILURE" `
            -Headers @{
                "Authorization" = "Bearer $env:TEAMCITY_CLOUD_TOKEN"
                "Accept" = "application/json"
            }

        foreach ($test in $failedTests.testOccurrence) {
            Write-Host "  - $($test.name)" -ForegroundColor Yellow
            if ($test.details) {
                # Show first line of error
                $errorLine = ($test.details -split "`n")[0]
                Write-Host "    $errorLine" -ForegroundColor DarkGray
            }
        }
    }
}

Write-Host ""
Write-Host "URL: $($build.webUrl)" -ForegroundColor Cyan
```

## API Reference

**Base URL:** `https://postsharp.teamcity.com/app/rest`

**Authentication:** Bearer token via `TEAMCITY_CLOUD_TOKEN` environment variable

**Common Locators:**
- By ID: `id:<buildId>`
- Latest by type: `buildType:<buildTypeId>,count:1`
- Latest by type+branch: `buildType:<buildTypeId>,branch:<branchName>,count:1`
- Running builds: `buildType:<buildTypeId>,running:true`
- By status: `buildType:<buildTypeId>,status:FAILURE,count:10`

**Useful Endpoints:**
- `/app/rest/builds/id:<id>` - Get specific build
- `/app/rest/builds?locator=...` - Query builds
- `/app/rest/problemOccurrences?locator=build:(id:<id>)` - Get problems
- `/app/rest/testOccurrences?locator=build:(id:<id>)` - Get test results
- `/app/rest/builds/id:<id>/statistics` - Get build statistics

## Error Handling

- If `TEAMCITY_CLOUD_TOKEN` not set, display error
- If build ID not found, API returns 404
- If branch has no builds, API returns empty array
- Invalid locator syntax returns 400 with error details
