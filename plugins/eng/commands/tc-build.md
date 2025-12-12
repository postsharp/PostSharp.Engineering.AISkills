---
description: Trigger a TeamCity build for the current branch
argument-hint: "[BuildType]"
---

# Trigger TeamCity Build

Trigger a build on TeamCity for the current branch.

## Arguments

$ARGUMENTS - Optional build type (default: DebugBuild). Common types: DebugBuild, ReleaseBuild

## Instructions

1. Read `.teamcity/settings.kts` to find:
   - Available build types: `object <Name> : BuildType`
   - VCS root ID: `AbsoluteId("...")` in vcs block - extract project prefix
2. Get current branch: `git rev-parse --abbrev-ref HEAD`
3. Ask user which build configuration to trigger (if not specified)
4. Build type ID format: `<ProjectPrefix>_<BuildTypeName>` (e.g., if VCS root is `Metalama_Metalama20260_Metalama`, build type ID is `Metalama_Metalama20260_Metalama_DebugBuild`)

## Prerequisites

Before triggering a build, verify `$TEAMCITY_CLOUD_TOKEN` is set:
```bash
if [ -z "$TEAMCITY_CLOUD_TOKEN" ]; then echo "Error: TEAMCITY_CLOUD_TOKEN not set"; fi
```

If not set, ask the user to configure it.

## TeamCity API

**Server:** https://postsharp.teamcity.com
**Endpoint:** POST `/app/rest/buildQueue`
**Auth:** Bearer token from `$TEAMCITY_CLOUD_TOKEN`

```bash
curl -X POST \
  -H "Authorization: Bearer $TEAMCITY_CLOUD_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"buildType":{"id":"<BuildTypeId>"},"branchName":"<branch>"}' \
  https://postsharp.teamcity.com/app/rest/buildQueue
```

After triggering, provide the build URL.
