# /status Command Design

**Date:** 2025-12-31
**Feature:** Add enhanced `/status` command showing workflow state, git context, and backlog progress

---

## Overview

Create a standalone `/status` command that provides a comprehensive view of the current workflow state, going beyond the existing `/workflow status` subcommand by including git context and detailed backlog progress.

## Output Format

```
═══════════════════════════════════════════════════════
                    WORKFLOW STATUS
═══════════════════════════════════════════════════════

📍 Phase: backlog-ready
   └─ Write/Edit: ✅ allowed

🌿 Git:
   └─ Branch: feat/42-add-validation
   └─ Changes: 3 modified, 1 untracked
   └─ Origin: 2 commits ahead

📋 Backlog: docs/backlogs/2024-01-15-validation-backlog.md
   └─ Progress: 3/7 tasks complete (43%)

   ✅ Recently Completed:
      • Task 1: Create validation utility module
      • Task 2: Add email format validator
      • Task 3: Add phone number validator

   ⏳ Up Next:
      • Task 4: Integrate validators with registration form
      • Task 5: Add inline error display component
      • Task 6: Write integration tests

⚡ Skip Mode: inactive

═══════════════════════════════════════════════════════
```

## Architecture

### New Files

1. **`skills/status/SKILL.md`** - Skill definition with:
   - How to read workflow state files
   - How to gather git context
   - How to parse backlog markdown for task status
   - Output formatting rules

2. **`commands/status.md`** - Command entry point:
   - YAML frontmatter with description
   - Usage examples
   - Reference to status skill

### Data Sources

| Info | Source | Read Method |
|------|--------|-------------|
| Workflow phase | `$SESSION_DIR/.workflow_phase` | `cat` with "idle" default |
| Skip mode | `$SESSION_DIR/.workflow_skip` | File existence check |
| Backlog path | `$SESSION_DIR/.backlog_path` | `cat` if exists |
| Git branch | `git branch --show-current` | Command output |
| Git changes | `git status --porcelain` | Count lines by type |
| Git ahead/behind | `git rev-list --left-right --count` | Parse output |
| Task status | Backlog markdown file | Parse `### Task N:` headers and `[STATUS]` markers |

### Backlog Parsing Logic

```
1. Read backlog file from .backlog_path
2. Find all lines matching: ### Task \d+:
3. Check if line contains [COMPLETED] → completed
4. Check if line contains [IN_PROGRESS] → in progress
5. Otherwise → pending
6. Return last 3 completed + next 3 pending
```

## Error Handling

| Scenario | Behavior |
|----------|----------|
| No `.workflow_phase` file | Show "Phase: idle (no active workflow)" |
| No `.backlog_path` file | Show "Backlog: none" (omit task details) |
| Backlog file doesn't exist | Show "Backlog: [path] (file not found)" |
| Backlog has 0 completed tasks | Show "No tasks completed yet" |
| Backlog has 0 pending tasks | Show "All tasks complete! 🎉" |
| Not in a git repo | Show "Git: not a git repository" |
| Detached HEAD | Show "Git: detached HEAD at [sha]" |
| No remote tracking | Show "Origin: no upstream configured" |

## Testing

Test cases for `tests/test_status_skill.py`:

1. `test_status_skill_exists` - Skill file exists with valid frontmatter
2. `test_status_command_exists` - Command file exists with valid frontmatter
3. `test_status_skill_references_sources` - Skill documents all data sources

## Decision Log

- **Approach chosen:** Skill-based command (Approach 1) - follows existing three-tier pattern
- **Scope:** Git context + Backlog progress (not session history)
- **Backlog detail:** Shows 3 recently completed + 3 up next tasks
