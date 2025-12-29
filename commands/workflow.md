---
description: Manage workflow enforcement state
argument-hint: "<subcommand> (skip|status|reset)"
---

# /workflow Command

Manage the workflow enforcement system.

## Usage

```
/workflow skip     # Bypass enforcement for current session
/workflow status   # Show current workflow state
/workflow reset    # Reset to idle state
```

## Workflow

This command manages the workflow state machine directly rather than invoking a skill.

### Subcommands

### `/workflow skip`

Bypass workflow enforcement for the current session.

**When to use:**
- Experienced users who understand the risks
- Quick hotfixes where full workflow is overkill
- Learning/exploration where enforcement is counterproductive

**Effect:**
- Disables all blocking hooks (main branch protection, phase checks, TDD)
- Creates `.workflow_skip` marker in session directory
- Lasts until session ends or `/workflow reset`

**Output:**
"WORKFLOW ENFORCEMENT SKIPPED: All checks bypassed for this session."

### `/workflow status`

Show current workflow state.

**Output includes:**
- Current phase: idle | brainstorming | branched | planned | implementing | verifying
- Current branch name
- Whether skip mode is active
- Plan path (if set)

**Example output:**
```
Workflow Status:
  Phase: planned
  Branch: feat/42-user-auth
  Skip mode: inactive
  Plan: docs/plans/2025-01-15-user-auth.md
```

### `/workflow reset`

Reset workflow state to idle.

**Effect:**
- Removes all session markers (.workflow_phase, .workflow_skip)
- Returns to fresh state
- Re-enables enforcement if previously skipped

**When to use:**
- After completing a PR and starting fresh
- To re-enable enforcement after using skip
- To clear stuck state

## Implementation

### For `/workflow skip`:

1. Create skip marker file at `$CLAUDE_SESSION_DIR/.workflow_skip`
2. Output confirmation with discipline reminder

### For `/workflow status`:

1. Read `$CLAUDE_SESSION_DIR/.workflow_phase` (default: "idle")
2. Check for `$CLAUDE_SESSION_DIR/.workflow_skip` existence
3. Run `git branch --show-current` for branch name
4. Read `$CLAUDE_SESSION_DIR/.plan_path` if exists
5. Format and output status

### For `/workflow reset`:

1. Remove `$CLAUDE_SESSION_DIR/.workflow_phase`
2. Remove `$CLAUDE_SESSION_DIR/.workflow_skip`
3. Remove `$CLAUDE_SESSION_DIR/.plan_path`
4. Output confirmation

## State Files

| File | Purpose |
|------|---------|
| `.workflow_phase` | Current workflow phase (idle/brainstorming/branched/planned/implementing/verifying) |
| `.workflow_skip` | If exists, enforcement is bypassed |
| `.plan_path` | Path to current implementation plan |
| `.brainstorming_active` | Legacy marker (still used by brainstorm-mode-check) |

All files stored in `$CLAUDE_SESSION_DIR` (session-scoped).

## Related

- `/brainstorm` - Enter brainstorming phase
- `/branch` - Enter branched phase
- `/plan` - Enter planned phase
- `/implement` - Enter implementing phase
- `/verify` - Enter verifying phase
