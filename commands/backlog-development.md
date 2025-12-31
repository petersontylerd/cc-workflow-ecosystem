---
description: Create a bite-sized backlog with exact file paths, complete code, and test commands
argument-hint: "[feature name or design document path]"
---

# /backlog-development Command

Create a detailed backlog from a design or requirements.

**IMPORTANT**: This command MUST be run in plan mode (shift+tab twice).
After writing the backlog document, this command will STOP and NOT proceed to implementation.

## Usage

```
/backlog-development user-authentication
/backlog-development docs/designs/2024-01-15-auth-design.md
/backlog-development "add email validation to registration"
```

Use the **developing-backlogs** skill for the full backlog creation process.
