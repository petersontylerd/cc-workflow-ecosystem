---
name: status
description: Gathers and displays comprehensive workflow status including phase, git context, and backlog progress. Use when you need to understand current workflow state, before starting work on a feature, or when resuming a session.
---

# Workflow Status

## Overview

The status skill provides a comprehensive snapshot of the current workflow state, enabling quick orientation and decision-making.

## Output Format

Display status in this structured format:

```
═══════════════════════════════════════════════════════
                    WORKFLOW STATUS
═══════════════════════════════════════════════════════

Phase: [phase]
   Write/Edit: [allowed/blocked]

Git:
   Branch: [branch-name]
   Changes: [N modified, M untracked]
   Origin: [N commits ahead/behind]

Backlog: [path or "none"]
   Progress: [N/M tasks complete (X%)]

   Recently Completed:
      [Task name]
      [Task name]
      [Task name]

   Up Next:
      [Task name]
      [Task name]
      [Task name]

Skip Mode: [active/inactive]

═══════════════════════════════════════════════════════
```

## Data Sources

| Info | Source | Read Method |
|------|--------|-------------|
| Workflow phase | `$SESSION_DIR/.workflow_phase` | `cat` with "idle" default |
| Skip mode | `$SESSION_DIR/.workflow_skip` | File existence check |
| Backlog path | `$SESSION_DIR/.backlog_path` | `cat` if exists |
| Git branch | `git branch --show-current` | Command output |
| Git changes | `git status --porcelain` | Count lines by type |
| Git ahead/behind | `git rev-list --left-right --count @{u}...HEAD` | Parse output |
| Task status | Backlog markdown file | Parse `### Task N:` headers and status markers |

## Gathering Status

Follow these steps to collect and display status:

### Step 1: Read Workflow Phase

```bash
# Read current phase (default to "idle" if not set)
if [ -f "$SESSION_DIR/.workflow_phase" ]; then
    PHASE=$(cat "$SESSION_DIR/.workflow_phase")
else
    PHASE="idle"
fi
```

The phase determines whether Write/Edit tools are allowed:
- `backlog-ready` or `implementation` = allowed
- All other phases = blocked (unless skip mode active)

### Step 2: Check Skip Mode

```bash
# Skip mode is active if file exists
if [ -f "$SESSION_DIR/.workflow_skip" ]; then
    SKIP_MODE="active"
else
    SKIP_MODE="inactive"
fi
```

### Step 3: Gather Git Context

```bash
# Get current branch
BRANCH=$(git branch --show-current 2>/dev/null)

# Count modified and untracked files
MODIFIED=$(git status --porcelain | grep -c "^ M\|^M ")
UNTRACKED=$(git status --porcelain | grep -c "^??")

# Get ahead/behind counts (requires upstream)
COUNTS=$(git rev-list --left-right --count @{u}...HEAD 2>/dev/null)
BEHIND=$(echo "$COUNTS" | cut -f1)
AHEAD=$(echo "$COUNTS" | cut -f2)
```

### Step 4: Parse Backlog Progress

```bash
# Read backlog path if set
if [ -f "$SESSION_DIR/.backlog_path" ]; then
    BACKLOG_PATH=$(cat "$SESSION_DIR/.backlog_path")
fi
```

Then parse the backlog file for task status.

## Backlog Parsing Logic

Parse task headers from the backlog markdown file:

1. **Find all task headers** matching pattern: `### Task N:`
2. **Determine task status** by checking markers in the header line:
   - Contains `[COMPLETED]` = completed task
   - Contains `[IN_PROGRESS]` = in-progress task
   - No marker = pending task
3. **Extract task name** from the header (text after `### Task N:`)
4. **Build progress summary**:
   - Count total tasks
   - Count completed tasks
   - Calculate percentage: `(completed / total) * 100`
5. **Select display tasks**:
   - Show last 3 completed tasks
   - Show next 3 pending tasks (or in-progress task first)

### Example Backlog Header Patterns

```markdown
### Task 1: Create utility module [COMPLETED]
### Task 2: Add validation logic [COMPLETED]
### Task 3: Implement form integration [IN_PROGRESS]
### Task 4: Write unit tests
### Task 5: Add error handling
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No `.workflow_phase` file | Show "Phase: idle (no active workflow)" |
| No `.backlog_path` file | Show "Backlog: none" (omit task details) |
| Backlog file doesn't exist | Show "Backlog: [path] (file not found)" |
| Backlog has 0 completed tasks | Show "No tasks completed yet" |
| Backlog has 0 pending tasks | Show "All tasks complete!" |
| Not in a git repo | Show "Git: not a git repository" |
| Detached HEAD | Show "Git: detached HEAD at [sha]" |
| No remote tracking | Show "Origin: no upstream configured" |

## When to Use

Use the status skill:
- At the start of a new session to orient yourself
- When resuming work after a break
- Before making decisions about what to work on next
- When debugging workflow hook behavior
- To verify phase transitions occurred correctly

## Integration with Workflow

The status display helps enforce workflow discipline:
- **Phase awareness**: Know if editing is blocked before attempting changes
- **Git context**: See if you're on the right branch with expected changes
- **Progress tracking**: Understand how far along the current backlog is
- **Skip mode visibility**: Be aware if workflow enforcement is bypassed
