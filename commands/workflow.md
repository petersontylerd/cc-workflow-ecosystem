---
description: Manage workflow enforcement state
argument-hint: "<subcommand> (skip|status|reset|help)"
---

# /workflow Command

Manage the workflow enforcement system.

## Usage

```
/workflow skip     # Bypass enforcement for current session
/workflow status   # Show current workflow state
/workflow reset    # Reset to idle state
/workflow help     # Show workflow guide and current state
```

## /workflow help

When invoked with "help", provide a comprehensive guide including:

### 1. Current Workflow State

Read the phase file from session state and report:

```
CURRENT STATE:
- Phase: [current phase]
- Branch: [current git branch]
- Next step: [what to do next]
```

### 2. The Complete Workflow

```
┌──────────────────────────────────────────────────────────────┐
│ THE WORKFLOW ECOSYSTEM                                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. /branch       Create feature branch                     │
│         ↓         (feat/<issue>-<slug> or fix/<issue>-<slug>)│
│                                                              │
│  2. /brainstorm   Explore requirements (IN PLAN MODE)       │
│         ↓         Press shift+tab twice BEFORE running      │
│                   Outputs to: docs/designs/                 │
│                                                              │
│  3. /backlog-development  Create bite-sized tasks (PLAN MODE)│
│         ↓         Press shift+tab twice BEFORE running      │
│                   Outputs to: docs/backlogs/                │
│                                                              │
│  4. /implement    Execute with subagent orchestration       │
│         ↓         Three-stage: implement → spec → quality   │
│                                                              │
│  5. /verify       Final validation before PR                │
│         ↓         Full test suite, lint, type check         │
│                                                              │
│  6. Create PR     Done! Ready for human review              │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 3. Phase-Specific Guidance

Based on current phase, explain what's blocked and what to do:

| Phase | Status | Next Command | Why |
|-------|--------|--------------|-----|
| idle | Code edits blocked | `/branch` | Create feature branch first |
| branched | Code edits blocked | `/brainstorm` (plan mode) | Explore requirements before coding |
| brainstorming | Code edits blocked | `/backlog-development` (plan mode) | Define precise tasks before coding |
| backlog-ready | **Code edits allowed** | `/implement` or manual work | Backlog approved, ready to code |
| implementing | **Code edits allowed** | Continue work | Implementation in progress |
| verifying | **Code edits allowed** | Create PR when /verify passes | Final validation |

### 4. Common Issues and Solutions

| Problem | Solution |
|---------|----------|
| "Edit blocked on main branch" | Run `/branch feat/<issue>-<slug>` |
| "Edit blocked - design phase not complete" | Run `/brainstorm` in plan mode (shift+tab twice first) |
| "Edit blocked - backlog phase not complete" | Run `/backlog-development` in plan mode |
| "Can't run /implement" | Must complete /brainstorm and /backlog-development first |
| "Phase stuck" | Run `/workflow reset` to clear state |
| "I know what I'm doing" | Run `/workflow skip` for current session only |

### 5. The Escape Hatch

For experienced users who understand the risks:

```
/workflow skip    # Bypass all enforcement this session
```

**Warning:** Skipping removes guardrails. Bugs, incomplete features, and quality issues become your responsibility.

Use the **workflow-management** skill for detailed subcommand documentation and implementation guidance.
