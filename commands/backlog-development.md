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

**WARNING**: Do NOT use "auto-accept edits" with this command. Wait for Claude to exit plan mode and write the backlog to `docs/backlogs/`.

## Usage

```
/backlog-development user-authentication
/backlog-development docs/designs/2024-01-15-auth-design.md
/backlog-development "add email validation to registration"
```

Use the **developing-backlogs** skill for the full backlog creation process.
