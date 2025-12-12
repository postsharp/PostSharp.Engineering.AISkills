# Metalama Development Plugin

For developing the Metalama framework itself.

## Features

- **Aspect testing** - Snapshot-based testing through Metalama pipeline
- **Test directives** - `@TestScenario`, `@IgnoredDiagnostic`, etc.
- **Debugging** - Troubleshooting paths and techniques

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
  "enabledPlugins": ["metalama-dev@postsharp-engineering"]
}
```
