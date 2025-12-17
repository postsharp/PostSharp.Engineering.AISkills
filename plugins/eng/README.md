# Engineering Plugin

PostSharp/Metalama engineering workflows: git conventions, PRs, releases, TeamCity CI/CD, build diagnostics.

## Prerequisites

- Git repository with GitHub remote
- GitHub authentication (via MCP authorization server when running in Docker)
- TeamCity access (for CI/CD commands)
- PowerShell (for cache updates on Windows hosts)

## Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/eng:create-pr [issue numbers]` | Create a pull request with proper metadata, milestone, and issue linking | `/eng:create-pr 123 456` |
| `/eng:prepare-release <milestone>` | Prepare a GitHub release for a milestone with proper release notes | `/eng:prepare-release 2024.1` |
| `/eng:tc-build [BuildType]` | Trigger a TeamCity build for the current branch | `/eng:tc-build` |
| `/eng:tc-check-build <buildId>` | Check the status of a TeamCity build | `/eng:tc-check-build 12345` |
| `/eng:fix-binlog-warnings` | Fix compiler warnings found in MSBuild binlog files | `/eng:fix-binlog-warnings` |
| `/eng:reflect` | Review session and capture learnings for future sessions | `/eng:reflect` |
| `/eng:update-cache` | Update the local Claude plugin cache from source | `/eng:update-cache` |

## Skills

The `eng` skill provides:
- Git workflow conventions (branching, commits, merge targets)
- GitHub API patterns (milestones, project status, issue linking)
- TeamCity integration

## Installation

Add to your project's `.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "postsharp-engineering": {
      "source": {
        "source": "github",
        "repo": "postsharp/PostSharp.Engineering.AISkills"
      }
    }
  },
  "enabledPlugins": ["eng@postsharp-engineering"]
}
```

Or install interactively:
```bash
/plugin marketplace add postsharp/PostSharp.Engineering.AISkills
/plugin install eng@postsharp-engineering
```

## Troubleshooting

### GitHub Authentication

Claude's authentication method depends on the execution environment (check `RUNNING_IN_DOCKER` environment variable).

**When Claude runs in Docker** (environment variable `RUNNING_IN_DOCKER=true`):
- GitHub operations (`gh` commands, `git push`) use an **MCP authorization server**
- Claude will prompt for authorization when needed
- No manual `gh auth login` required
- The MCP server handles authentication securely

**When Claude runs on host machine** (no `RUNNING_IN_DOCKER` or `RUNNING_IN_DOCKER=false`):
- Ensure GitHub CLI is authenticated:
  ```bash
  gh auth status
  gh auth login
  ```

### Git Push Operations
Most git operations work automatically, but `git push` requires authentication:
- In Docker: Uses MCP authorization server (automatic prompting)
- On host: Uses your local git credentials

### TeamCity Access
TeamCity commands require proper authentication. Ensure your TeamCity credentials are configured in your environment.

### Cache Updates
If plugin updates aren't reflected, run:
```bash
/eng:update-cache
```

### Docker Container Context
To check if Claude is running in Docker, check the `RUNNING_IN_DOCKER` environment variable.

When running in Docker:
- Authenticated operations use MCP authorization server
- File paths are relative to the container's mounted workspace
- Some host-specific tools may not be available

When running on host:
- Authentication uses local credentials (`gh auth`, git config)
- Direct access to all host tools and paths
