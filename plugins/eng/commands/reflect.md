---
description: Review session and capture learnings for future sessions
---

# Self-Improvement and Reflection

Review the current session and identify learnings that should be captured for future sessions.

## Instructions

1. **Review the session**: Look back at the conversation and identify:
   - Mistakes made and how they were resolved
   - Patterns that worked well
   - Knowledge gaps that caused inefficiency
   - User corrections or feedback

2. **Categorize learnings**:
   - **Critical rules**: Things that must always/never be done
   - **Patterns**: Reusable approaches for common tasks
   - **Domain knowledge**: Codebase-specific information
   - **Debugging techniques**: How to diagnose specific issues

3. **Update documentation**:
   - Add critical rules to `CLAUDE.md` under appropriate sections
   - Add domain-specific learnings to relevant `CLAUDE.md` files in subdirectories
   - Keep entries concise and actionable

4. **Consider scope** - where should the improvement go?

   **Repo-specific (`CLAUDE.md` in the repo)**:
   - Codebase structure and architecture
   - Project-specific patterns and conventions
   - Build quirks for this specific repo
   - Domain knowledge about the code

   **Directory-specific (`CLAUDE.md` in subdirectory)**:
   - Context-specific patterns (e.g., `Standalone/CLAUDE.md` for standalone test patterns)
   - Component-specific rules

   **AI Skills repo (`PostSharp.Engineering.AISkills`)**:
   - General devops and git workflow knowledge
   - How the team works (PR process, release workflow)
   - Cross-repo conventions and patterns
   - Build system (Build.ps1) improvements
   - GitHub/TeamCity API patterns

5. **Format**:
   - Use bullet points or numbered lists
   - Include concrete examples where helpful
   - Avoid verbose explanations - future Claude instances should quickly scan and apply

## Output

Summarize:
- What learnings were added
- Where they were added
- Why they're valuable for future sessions
