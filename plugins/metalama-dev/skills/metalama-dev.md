---
description: Metalama framework development. Use when working on Metalama itself - aspect testing, test directives, code model, templates, diagnostics.
---

# Metalama Development

Guide for developing the Metalama framework itself.

**Note**: For writing aspects, templates, and using Metalama APIs, use the `metalama` skill (installed separately). This skill is specifically for developing the Metalama framework code.

## Testing

| Type | Description | Project suffix | Output |
|------|-------------|----------------|--------|
| Aspect tests | Snapshot-based, runs through Metalama pipeline | `*AspectTests` | `Foo.t.cs` |
| Unit tests | Classic xUnit | `*UnitTests` | - |
| Standalone tests | Self-contained projects | - | Optional `test.json` |

Aspect tests support: code transformations, diagnostics, code fixes, live templates, design-time code generation, diff preview. Can execute `Program.Main` and compare output.

Docs: [Aspect testing](https://doc.metalama.net/conceptual/aspects/testing/aspect-testing)

## Test Directives

For test directive documentation, use the `metalama` skill which has complete reference for all `@` directives and `metalamaTests.json` options.

Quick reference: `Metalama.Testing.AspectTesting/TestOptions.cs` contains all options with XML documentation.

## Key Paths

| Path | Contents |
|------|----------|
| `%TEMP%\Metalama\CompileTimeTroubleshooting\` | Build error details |
| `Metalama.Testing.AspectTesting/TestOptions.cs` | Test options documentation |
| `../Metalama.Documentation/content` | Conceptual documentation |

## Debugging Build Issues

1. **Check troubleshooting files**: Look at `%TEMP%\Metalama\CompileTimeTroubleshooting\...\errors.txt` for actual errors
2. **Trace data flow**: For MSBuild issues, trace from `.csproj` → `.targets` → Engine code

## Pre-PR Checklist

1. Document all new/modified public APIs
2. Search `../Metalama.Documentation/content` for affected articles
3. Create issue at https://github.com/metalama/Metalama.Documentation for doc changes
4. Check that all changes in the PR are documented in related issues
