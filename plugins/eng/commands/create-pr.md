---
description: Create a pull request with proper metadata, milestone, and issue linking
argument-hint: "[issue numbers to close]"
---

# Create Pull Request

Create a PR with proper metadata, milestone, and issue linking for Metalama/PostSharp repos.

## Arguments

$ARGUMENTS - Optional issue numbers to close (e.g., `1234 1235`)

## Workflow

1. **Commit and push** any remaining changes

2. **Check for breaking changes** compared to `develop/YYYY.N`:
   - If breaking: add `breaking` label to PR and linked issues
   - Add comment describing the breaking change

3. **Create PR** targeting `develop/YYYY.N` (NOT default branch):
   ```bash
   gh pr create --base develop/YYYY.N --title "<title>" --body "<body>"
   ```

   PR body format:
   ```
   ## Summary
   - Bullet points describing key changes

   ## Breaking Changes (if applicable)
   - List new interface members or behavioral changes

   ## Issues Fixed
   - #1226 - Brief description
   - #1232 - Brief description
   ```

   **NO test plan section** - tests are verified through CI.

4. **Assign to milestone** - find latest open `YYYY.N.B-suffix`:
   ```bash
   gh api "repos/metalama/Metalama/milestones?state=all&per_page=100" --jq '.[] | "\(.number) \(.title) - \(.state)"' | grep "YYYY.N" | sort -V

   # Assign (use milestone NUMBER)
   gh api repos/metalama/Metalama/issues/<PR_NUMBER> -X PATCH -f milestone=<NUMBER>
   ```

   If no open milestone exists, propose creating one.

5. **Assign to current user**:
   ```bash
   gh api repos/metalama/Metalama/issues/<PR_NUMBER> -X PATCH -f assignees[]="<username>"
   ```

6. **Link issues** (workaround for non-default base branch):
   ```bash
   # Get PR node ID
   PR_ID=$(gh api graphql -f query='{ repository(owner: "metalama", name: "Metalama") { pullRequest(number: <PR_NUMBER>) { id } } }' --jq '.data.repository.pullRequest.id')

   # Temporarily change base to release branch (GitHub default), then back - links persist!
   gh api graphql -f query="mutation { updatePullRequest(input: { pullRequestId: \"$PR_ID\" baseRefName: \"release/YYYY.N\" }) { pullRequest { id } } }"
   gh api graphql -f query="mutation { updatePullRequest(input: { pullRequestId: \"$PR_ID\" baseRefName: \"develop/YYYY.N\" }) { pullRequest { id } } }"
   ```

7. **Set project status to "In Review"**:
   ```bash
   # Get project item ID
   ITEM_ID=$(gh api graphql -f query='{ repository(owner: "metalama", name: "Metalama") { pullRequest(number: <PR_NUMBER>) { projectItems(first: 10) { nodes { id project { title } } } } } }' --jq '.data.repository.pullRequest.projectItems.nodes[] | select(.project.title == "Development") | .id')

   # Set status (In review: 4cc61d42)
   gh api graphql -f query="mutation { updateProjectV2ItemFieldValue(input: { projectId: \"PVT_kwDOC7gkgc4A030b\" itemId: \"$ITEM_ID\" fieldId: \"PVTSSF_lADOC7gkgc4A030bzgqb1vQ\" value: { singleSelectOptionId: \"4cc61d42\" } }) { projectV2Item { id } } }"
   ```

8. **Trigger TeamCity build**: Use `/tc-build` or ask user.

## Error Handling

- **No open milestone**: Propose creating one with format `YYYY.N.B-rc`
- **PR not in Development project**: Skip project status update, note in output
- **Issue linking fails**: Note that issues will need manual linking after merge
