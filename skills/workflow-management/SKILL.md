---
name: workflow-management
description: Manages workflow enforcement state including bypassing checks, checking current phase, and resetting to idle. Use when needing to skip enforcement for quick fixes, when checking current workflow status, or when resetting after completing work.
---

# Workflow State Management

This skill handles management of the workflow enforcement system, including bypassing enforcement, checking status, and resetting state.

## Overview

The workflow ecosystem enforces discipline through blocking hooks. Sometimes you need to:
- Bypass enforcement for experienced users or quick fixes
- Check current workflow state
- Reset to a clean state

## Operations

### Skip Enforcement

Bypass workflow enforcement for the current session.

**When to use:**
- Experienced users who understand the risks
- Quick hotfixes where full workflow is overkill
- Learning/exploration where enforcement is counterproductive

**Effect:**
- Disables all blocking hooks (main branch protection, phase checks, TDD)
- Creates `.workflow_skip` marker in session directory
- Lasts until session ends or reset

**Implementation:**
1. Create skip marker file at `$CLAUDE_SESSION_DIR/.workflow_skip`
2. Output confirmation with discipline reminder

**Output:**
```
WORKFLOW ENFORCEMENT SKIPPED: All checks bypassed for this session.
```

### Check Status

Show current workflow state.

**Output includes:**
- Current phase: idle | brainstorming | branched | backlog-ready | implementing | verifying
- Current branch name
- Whether skip mode is active
- Backlog path (if set)

**Implementation:**
1. Read `$CLAUDE_SESSION_DIR/.workflow_phase` (default: "idle")
2. Check for `$CLAUDE_SESSION_DIR/.workflow_skip` existence
3. Run `git branch --show-current` for branch name
4. Read `$CLAUDE_SESSION_DIR/.backlog_path` if exists
5. Format and output status

**Example output:**
```
Workflow Status:
  Phase: backlog-ready
  Branch: feat/42-user-auth
  Skip mode: inactive
  Backlog: docs/backlogs/2025-01-15-user-auth-backlog.md
```

### Reset State

Reset workflow state to idle.

**Effect:**
- Removes all session markers (.workflow_phase, .workflow_skip)
- Returns to fresh state
- Re-enables enforcement if previously skipped

**When to use:**
- After completing a PR and starting fresh
- To re-enable enforcement after using skip
- To clear stuck state

**Implementation:**
1. Remove `$CLAUDE_SESSION_DIR/.workflow_phase`
2. Remove `$CLAUDE_SESSION_DIR/.workflow_skip`
3. Remove `$CLAUDE_SESSION_DIR/.backlog_path`
4. Output confirmation

## State Files

| File | Purpose |
|------|---------|
| `.workflow_phase` | Current workflow phase (idle/brainstorming/branched/backlog-ready/implementing/verifying) |
| `.workflow_skip` | If exists, enforcement is bypassed |
| `.backlog_path` | Path to current backlog |
| `.brainstorming_active` | Legacy marker (still used by brainstorm-mode-check) |

All files stored in `$CLAUDE_SESSION_DIR` (session-scoped).

## Workflow Phases

```
idle → brainstorming → branched → backlog-ready → implementing → verifying → idle
       (blocks edits)   (blocks edits)   (allows edits)
```

### Phase Transitions

| From | To | Triggered By |
|------|-----|--------------|
| idle | brainstorming | `/brainstorm` command |
| brainstorming | branched | `/branch` command |
| branched | backlog-ready | `/backlog-development` command |
| backlog-ready | implementing | `/implement` command |
| implementing | verifying | `/verify` command |
| verifying | idle | PR created or reset |

## Related Skills

**SEE ALSO:** These skills work together in the workflow ecosystem:
- `brainstorming` - Enter brainstorming phase
- `git-workflow` - Branch and commit management
- `developing-backlogs` - Create implementation backlogs
- `orchestrating-subagents` - Execute backlogs with subagents
- `verification` - Pre-completion verification

**REQUIRED BACKGROUND:** Understand `using-ecosystem` for full workflow context.
