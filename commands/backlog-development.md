---
description: Create a bite-sized backlog with exact file paths, complete code, and test commands
argument-hint: "[feature name or design document path]"
---

# /backlog-development Command

Create a detailed backlog from a design or requirements.

**IMPORTANT**: This command uses plan mode for exploration, then EXITS plan mode before writing the backlog.

## Workflow

1. Enter plan mode (shift+tab twice) - enables exploration subagents
2. Run `/backlog-development <feature>` - explores codebase, creates detailed tasks
3. **Claude will EXIT plan mode** before writing the backlog document
4. Backlog is written to `docs/backlogs/YYYY-MM-DD-<feature>-backlog.md`
5. Command **STOPS** - user must run `/implement` to continue

**CRITICAL**: Once the user selects "auto-accept edits" and you ExitPlanMode, write the design to `docs/backlogs/` as a markdown file. Then, you **MUST** stop and await the next command. Do **NOT** proceed directly to executing the backlog.

## Usage

```
/backlog-development user-authentication
/backlog-development docs/designs/2024-01-15-auth-design.md
/backlog-development "add email validation to registration"
```

**ESSENTIAL REQUIREMENT** Use the **developing-backlogs** skill for the full exploration and design process.