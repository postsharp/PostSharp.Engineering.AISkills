---
description: PostSharp/Metalama engineering workflows. Use for git operations (commit, branch, PR, merge, release), TeamCity CI/CD, build diagnostics, and development utilities.
---

# PostSharp Engineering Workflows

Git workflow conventions and commands for PostSharp/Metalama repositories.

## Updating This Skill

To make permanent changes, edit the source files under `X:\src\PostSharp.Engineering.AISkills\plugins\`, then run `/eng:update-cache` to update the local cache.

## Repository Info

- **Organization**: `metalama` (GitHub) / `postsharp` (legacy)
- **Default branch**: Usually `release/YYYY.N` (e.g., `release/2025.1`)
- **Development branches**: `develop/YYYY.N` (e.g., `develop/2026.0`)
- **Development project ID**: `PVT_kwDOC7gkgc4A030b`
- **Status field ID**: `PVTSSF_lADOC7gkgc4A030bzgqb1vQ`
- **Status options**: Backlog (`f75ad846`), Planned (`08afe404`), In progress (`47fc9ee4`), In review (`4cc61d42`), Merged (`9d4ab054`), Done (`98236657`)

## Commands to use

Use the following commands or read their instructions on demand:

- `/eng:create-pr`: create (prepare) a pull request
- `/eng:fix-binlog-warnings`: analyze warnings from binlog output of `Build.ps1 build`
- `/eng:prepare-release`: on demand, when user asks to prepare release, github release, release notes. typically done after deployment
- `/eng:reflect`: self-improvement after a difficult task. you should do it automatically after a problem has been solved and you did mistakes before
- `/eng:tc-build`: schedule a teamcity (TC, CI) build
- `/eng:tc-check-build`: check the status of the last TC build
- `/eng:update-cache`: update the local plugin cache from source

## Branch Strategy

Each major version has two long-lived branches:
- `release/YYYY.N` - Updated only during deployment (GitHub default branch per version line)
- `develop/YYYY.N` - Continuous CI/CD development branch

**Workflow:**
1. `topic/YYYY.N/XXX-description` → `develop/YYYY.N` (PR)
2. `develop/YYYY.N` → `release/YYYY.N` (after successful deployment)

## Branch Naming

Pattern: `topic/YYYY.N/XXXX-short-description`

- `YYYY.N` - Version/milestone (e.g., 2026.0)
- `XXXX` - Issue number (required). If no issue, use date: `YY-MM-DD`
- `short-description` - Brief, hyphenated description
- If branch exists, add numeric suffix: `-2`

## Merge Target

For `topic/YYYY.N/*`, merge target is ALWAYS `develop/YYYY.N`. **Never use the release branch directly.**

## Commit Messages

1. Keep short (50-72 chars)
2. Include issue number: `(#XXXX)`
3. **Never sign commits** (no "Generated with Claude Code")
4. Use imperative mood: "Fix bug" not "Fixed bug"

Examples:
- `Fix cache invalidation on timeout (#1234)`
- `Add retry logic for API calls (#5678)`

## Milestone Format

Always use `YYYY.N.B-suffix` format (e.g., `2026.0.8-rc`), never `YYYY.N` alone.

Suffix conventions:
- `-preview` - Early preview releases
- `-rc` - Release candidates
- (no suffix) - Stable releases

Never assign anything to a closed milestone.
Never reopen a closed milestone.
Propose the user to create a new milestone with incremented version number.

## Build System (Build.ps1)

PostSharp.Engineering is the build orchestration SDK. Each repo is a **product** made of multiple **solutions**.

### Key Concepts

- **Product**: A repo, configured in `eng/src/Program.cs`
- **Solution**: First-level directories (e.g., `Metalama.Framework`, `Metalama.Patterns`)
- **Build.ps1**: PowerShell front-end to `eng/src`, self-generated via `Build.ps1 generate-scripts`

### Reference Types

| Scope | Reference Type | Notes |
|-------|---------------|-------|
| Within solution | `ProjectReference` | Standard .NET references |
| Between solutions | `PackageReference` | Requires `Build.ps1 build` to update packages |
| Cross-repo | `PackageReference` | Uses TeamCity artifacts by default |

### Common Commands

```powershell
# Full build - creates unique package versions, slow (~10-30 min)
Build.ps1 build

# Kill locked processes after failed build
Build.ps1 tools kill

# List cross-repo dependencies
Build.ps1 dependencies list

# Use local repo instead of TeamCity artifacts
Build.ps1 dependencies set local <product>

# Revert to TeamCity artifacts
Build.ps1 dependencies reset --all
```

### When to Use Build.ps1

- **Cross-solution changes**: When modifying code in one solution that's consumed by another
- **After pulling updates**: To ensure all inter-solution packages are current
- **Before creating PR**: To verify full build succeeds

**IMPORTANT**: `Build.ps1 build` is slow. Always ask the user before running it. For single-solution changes, prefer `dotnet build` / `dotnet test`.

### Building Quick Reference

| Scenario | Command |
|----------|---------|
| Single solution changes | `dotnet build` / `dotnet test` |
| Cross-solution changes | Ask user to run `Build.ps1 build` |
| Kill locked processes | `Build.ps1 tools kill` |

### Build Notes

- When adding package references, also add `PackageVersion` to `Directory.Packages.props`
- Two `Build.ps1 build` runs cannot run in parallel
- Don't build full solution just to run a single test - ask user first
- After `Build.ps1 build`, MSBuild binlogs are under `artifacts/logs`

### Local Dependencies

By default, cross-repo `PackageReference` dependencies resolve from TeamCity (last successful build). To use local changes:

```powershell
# In consuming repo, point to local dependency
Build.ps1 dependencies set local Metalama.Premium

# Now PackageReference resolves from local repo's Build.ps1 build output
# Requires Build.ps1 build in the dependency repo first
```

## API Notes

### Getting Node IDs

```bash
# PR node ID
gh api graphql -f query='{ repository(owner: "metalama", name: "Metalama") { pullRequest(number: 1228) { id } } }' --jq '.data.repository.pullRequest.id'

# Issue node ID
gh api graphql -f query='{ repository(owner: "metalama", name: "Metalama") { issue(number: 1226) { id } } }' --jq '.data.repository.issue.id'
```

## Breaking Changes

- **Breaking changes**: Add comment to issue describing the change, add `breaking` label
- **Not breaking**: Adding members to interfaces marked with `[InternalImplement]` (including inherited) is NOT a breaking change

## Working on GitHub Issues

When starting work on a GitHub issue:

1. **Read issue details**: Fetch full issue content from GitHub
2. **Check documentation**: Look for related conceptual docs
3. **Create branch**: `topic/YYYY.N/XXXX-short-description`
4. **Assign issue**: Assign the issue to the user in GitHub
5. **Set milestone**: Assign to the latest open milestone for the current YYYY.N version (e.g., `YYYY.N.B-maturity`)
6. **Set issue status**: Mark as "In Progress" in the Development project
7. **Track progress**: Create `<issue-number>-TODO.md` file (don't commit it)
8. **Discover bugs**: Create issues promptly when finding bugs during development

## Critical Rules

- **NEVER** run `Build.ps1 build` yourself - ask the user to run it (timeout too low, causes retries)
- **NEVER** run `Build.ps1 prepare` - it deletes all built artifacts and requires a subsequent `Build.ps1 build`
- **NEVER** clear global NuGet packages - it's never needed
- **Never sign commits** with "Generated with Claude Code" - only sign PRs, issues, and comments modestly with "— Claude for <user>"
- **Prefer `pwsh`** (PowerShell 7), never use old `cmd`
- **No hardcoded delays in tests** - use barriers, TaskCompletionSource, sync points
- **Never await without cancellation token**
- **Don't fix cosmetic warnings** (redundant usings, etc.) until finalizing stage
- **Focus on green tests first** before addressing warnings

## Writing Documentation

- Use `<see>` tags for type/member references
- Maintain consistent lexicon within class families (same suffix)
- Keep code examples short
- Cross-reference conceptual docs via `<seealso href="@..."/>` tags
- Use api-docs-reviewer subagent when writing XML doc or API doc
- **NEVER** replace `<see>` tags with `<c>` to fix XML doc errors - fix the reference or add `using` instead
- 
## AI Continuous Improvement

Use the `/reflect` command after difficult tasks where you made many unsuccessful attempts. This captures learnings for future sessions:

- Mistakes made and how they were resolved
- Patterns that worked well
- Knowledge gaps that caused inefficiency
- User corrections or feedback

Learnings are added to `CLAUDE.md` or to the current plug-in files for future Claude instances to benefit from.


## MCP Approval Server (Docker Support)

When running Claude Code inside Docker containers (environmenr variable `RUNNING_IN_DOCKER` set ), certain operations require host-level access (git push, GitHub CLI, etc.). The MCP Approval Server provides a secure, human-in-the-loop workflow for these operations.

### Architecture

```
┌─────────────────────────────────────────┐
│ Docker Container                        │
│  ┌─────────────┐                        │
│  │ Claude Code │──▶ MCP Client         │
│  └─────────────┘    (execute_command)   │
└──────────────────────┬──────────────────┘
                       │ HTTP/SSE
                       ▼
┌─────────────────────────────────────────┐
│ Host: MCP Approval Server               │
│  1. Receive request                     │
│  2. AI risk analysis (Claude CLI)       │
│  3. Auto-approve/reject or prompt user  │
│  4. Execute if approved                 │
│  5. Return result                       │
└─────────────────────────────────────────┘
```

The MCP server starts automatically with `DockerBuild.ps1 -Claude`. To disable:

```powershell
.\DockerBuild.ps1 -Claude -NoMcp
```

Inside the container, privileged commands are routed through the MCP server automatically via the `host-approval` MCP configuration.

### Supported Operations

Any powershell command is allowed.