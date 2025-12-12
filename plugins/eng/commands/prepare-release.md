---
description: Prepare a GitHub release for a milestone with proper release notes
argument-hint: "<milestone URL or number>"
---

# Prepare GitHub Release

Prepare a GitHub release for a milestone. Requires user approval before execution.

## Arguments

$ARGUMENTS - Milestone URL or number (e.g., `https://github.com/metalama/Metalama/milestone/31` or `31`)

## Phase 1: Analysis

Gather all information first:

1. **Fetch milestone details**:
   ```bash
   gh api repos/metalama/Metalama/milestones/<NUMBER> --jq '{title, state, open_issues, closed_issues}'
   ```

2. **List all issues** (open and closed):
   ```bash
   gh issue list --repo metalama/Metalama --milestone "<TITLE>" --state all --json number,title,state,labels
   ```

3. **Check project status** for each issue:
   ```bash
   gh api graphql -f query='{ repository(owner: "metalama", name: "Metalama") { issue(number: <NUMBER>) { projectItems(first: 10) { nodes { id project { title } fieldValues(first: 10) { nodes { ... on ProjectV2ItemFieldSingleSelectValue { name field { ... on ProjectV2SingleSelectField { name } } } } } } } } } }'
   ```

4. **Check branch status**:
   - Compare `develop/YYYY.N` with `release/YYYY.N`
   - Check version bump in MainVersion.props
   - Identify previous release tag

5. **Check upstream version lines** (e.g., 2025.1 merged into 2026.0):
   ```bash
   # Latest releases per version line
   git tag -l "release/2025.1.*" --sort=-v:refname | head -1
   git tag -l "release/2026.0.*" --sort=-v:refname | head -1

   # Check ancestry
   git merge-base --is-ancestor release/<UPSTREAM> <TARGET_COMMIT>
   git merge-base --is-ancestor release/<UPSTREAM> release/<PREV_VERSION>
   ```

## Phase 2: Present Plan

Present to user for approval:

1. **Milestone status**: Open/closed issues, blockers
2. **Issues**: Categorized as Breaking/New/Enhancements/Fixes
3. **Branch status**: Sync state, version bump
4. **Project status**: Flag issues not in "Merged" or "Done"

5. **Proposed release notes**:

   Single base:
   ```
   Metalama <VERSION> is based on [<PREV>](https://github.com/metalama/Metalama/releases/tag/release/<PREV>), plus the following changes.
   ```

   Multiple bases (upstream merged):
   ```
   Metalama <VERSION> is based on [<PREV_SAME_LINE>](...) and [<UPSTREAM>](...), plus the following changes.
   ```

   Then:
   ```
   ### Breaking Changes
   - [#XXXX](https://github.com/metalama/Metalama/issues/XXXX) Description

   ### New
   - [#XXXX](https://github.com/metalama/Metalama/issues/XXXX) Description

   ### Enhancements
   - [#XXXX](https://github.com/metalama/Metalama/issues/XXXX) Description

   ### Fixes
   - [#XXXX](https://github.com/metalama/Metalama/issues/XXXX) Description

   ### Resources
   - [Milestone](https://github.com/metalama/Metalama/milestone/<NUMBER>?closed=1)
   - **Full Changelog**: [release/<PREV>...release/<VERSION>](https://github.com/metalama/Metalama/compare/release/<PREV>...release/<VERSION>)
   ```

**STOP and wait for user approval.**

## Phase 3: Execute

After approval:

1. **Create release**:
   ```bash
   gh release create release/<VERSION> --target <COMMIT> --title "Metalama <VERSION>" --notes "<NOTES>"
   ```

2. **Close milestone**:
   ```bash
   gh api repos/metalama/Metalama/milestones/<NUMBER> -X PATCH -f state=closed
   ```

3. **Update project status to "Done"** for each issue:
   ```bash
   # Done option: 98236657
   gh api graphql -f query='mutation { updateProjectV2ItemFieldValue(input: { projectId: "PVT_kwDOC7gkgc4A030b" itemId: "<ITEM_ID>" fieldId: "PVTSSF_lADOC7gkgc4A030bzgqb1vQ" value: { singleSelectOptionId: "98236657" } }) { projectV2Item { id } } }'
   ```

4. **Add release comment** to each issue:
   ```bash
   gh issue comment <NUMBER> --repo metalama/Metalama --body "Released in [<VERSION>](https://github.com/metalama/Metalama/releases/tag/release/<VERSION>).

   — Claude"
   ```

## Release Notes Guidelines

- **Do NOT mention PRs** if PR implements a listed issue
- **Categorize by labels**: `breaking` → Breaking, `enhancement` → New/Enhancements, `bug` → Fixes
- **Use full issue links**: `[#1247](https://github.com/metalama/Metalama/issues/1247)`
- **Sign comments**: `— Claude`
