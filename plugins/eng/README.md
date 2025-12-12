# Engineering Plugin

PostSharp/Metalama engineering workflows: git conventions, PRs, releases, TeamCity CI/CD, build diagnostics.

## Commands

| Command | Description |
|---------|-------------|
| `/create-pr` | Create a pull request with proper metadata |
| `/prepare-release` | Prepare a GitHub release for a milestone |
| `/tc-build` | Trigger a TeamCity build |
| `/tc-check-build` | Check TeamCity build status |
| `/fix-binlog-warnings` | Fix compiler warnings from MSBuild binlog files |
| `/reflect` | Review session and capture learnings |

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
