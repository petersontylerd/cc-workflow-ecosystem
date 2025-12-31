# /status Command Backlog

**Goal:** Add an enhanced `/status` command that shows workflow phase, git context, and detailed backlog progress.

**Architecture:** Create a new `status` skill defining how to gather and format status info, plus a thin `status` command wrapper. The skill reads from session state files, git commands, and parses backlog markdown for task status.

**Tech Stack:** Markdown skill/command definitions, bash for git commands, regex for backlog parsing.

**Prerequisites:**
- [x] Design document reviewed and approved
- [x] Feature branch created (`feat/999-status-command`)
- [x] Development environment ready

---

## Task 1: Update test fixtures to expect new skill and command

**Files:**
- Modify: `tests/conftest.py:41-54` (expected_skills)
- Modify: `tests/conftest.py:60-69` (expected_commands)

**Step 1: Add "status" to expected_skills list**

In `tests/conftest.py`, update the `expected_skills` fixture to include "status":

```python
@pytest.fixture
def expected_skills() -> list[str]:
    """Return list of expected skill names."""
    return [
        "angular-development",
        "brainstorming",
        "developing-backlogs",
        "git-workflow",
        "orchestrating-subagents",
        "python-development",
        "status",
        "subagent-state-management",
        "systematic-debugging",
        "typescript-development",
        "using-ecosystem",
        "verification",
        "workflow-management",
    ]
```

**Step 2: Add "status" to expected_commands list**

```python
@pytest.fixture
def expected_commands() -> list[str]:
    """Return list of expected command names."""
    return [
        "backlog-development",
        "brainstorm",
        "branch",
        "commit",
        "implement",
        "pr",
        "status",
        "verify",
        "workflow",
    ]
```

**Step 3: Run tests to verify they fail**

Run: `uv run pytest tests/test_skill_loading.py tests/test_command_loading.py -v`
Expected: FAIL - skill directory "status" not found, command file "status.md" not found

**Step 4: Commit test fixture updates**

```bash
git add tests/conftest.py
git commit -m "test(status): add status to expected skills and commands"
```

---

## Task 2: Create status skill file

**Files:**
- Create: `skills/status/SKILL.md`

**Step 1: Create the skill directory and file**

Create `skills/status/SKILL.md` with the following content:

```markdown
---
name: status
description: Displays comprehensive workflow status including phase, git context, and backlog progress. Use when you want to see the current state of your workflow session.
---

# Workflow Status

## Overview

Display a comprehensive view of the current workflow state, git context, and backlog progress.

**Core principle:** Know where you are before deciding where to go.

## Output Format

The status display follows this structure:

```
═══════════════════════════════════════════════════════
                    WORKFLOW STATUS
═══════════════════════════════════════════════════════

📍 Phase: [phase]
   └─ Write/Edit: [allowed/blocked]

🌿 Git:
   └─ Branch: [branch-name]
   └─ Changes: [N modified, M untracked]
   └─ Origin: [N commits ahead/behind]

📋 Backlog: [path or "none"]
   └─ Progress: [N/M tasks complete (X%)]

   ✅ Recently Completed:
      • [Task name]
      • [Task name]
      • [Task name]

   ⏳ Up Next:
      • [Task name]
      • [Task name]
      • [Task name]

⚡ Skip Mode: [active/inactive]

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
| Git ahead/behind | `git rev-list --left-right --count` | Parse output |
| Task status | Backlog markdown file | Parse headers |

## Gathering Status

### Step 1: Read Workflow State

```bash
SESSION_DIR="${CLAUDE_SESSION_DIR:-${TMPDIR:-/tmp}/claude-session}"
PHASE=$(cat "$SESSION_DIR/.workflow_phase" 2>/dev/null || echo "idle")
SKIP_ACTIVE=$([[ -f "$SESSION_DIR/.workflow_skip" ]] && echo "active" || echo "inactive")
BACKLOG_PATH=$(cat "$SESSION_DIR/.backlog_path" 2>/dev/null || echo "")
```

### Step 2: Gather Git Context

```bash
BRANCH=$(git branch --show-current 2>/dev/null || echo "not a git repo")
CHANGES=$(git status --porcelain 2>/dev/null | wc -l)
AHEAD_BEHIND=$(git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null || echo "0 0")
```

### Step 3: Parse Backlog Progress

If backlog path exists, parse the markdown file:
1. Find all lines matching `### Task \d+:`
2. Check for `[COMPLETED]` marker → completed
3. Check for `[IN_PROGRESS]` marker → in progress
4. Otherwise → pending
5. Show last 3 completed and next 3 pending

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

## Phase to Edit Permission Mapping

| Phase | Write/Edit |
|-------|------------|
| idle | ⚠️ advisory only |
| branched | ❌ blocked |
| brainstorming | ❌ blocked |
| backlog-ready | ✅ allowed |
| implementing | ✅ allowed |
| verifying | ✅ allowed |
```

**Step 2: Run tests to verify skill is found**

Run: `uv run pytest tests/test_skill_loading.py -v`
Expected: PASS for skill tests (status skill now exists)

**Step 3: Commit skill file**

```bash
git add skills/status/SKILL.md
git commit -m "feat(status): add status skill with output format and data sources"
```

---

## Task 3: Create status command file

**Files:**
- Create: `commands/status.md`

**Step 1: Create the command file**

Create `commands/status.md` with the following content:

```markdown
---
description: Display comprehensive workflow status including phase, git context, and backlog progress
---

# /status Command

Show the current state of your workflow session at a glance.

## Usage

```
/status
```

## What It Shows

- **Workflow phase** - Current phase and whether Write/Edit is allowed
- **Git context** - Branch, uncommitted changes, ahead/behind origin
- **Backlog progress** - Current backlog file with task completion status
- **Skip mode** - Whether workflow enforcement is bypassed

Use the **status** skill for the full status display.
```

**Step 2: Run tests to verify command is found**

Run: `uv run pytest tests/test_command_loading.py -v`
Expected: PASS for command tests (status command now exists)

**Step 3: Commit command file**

```bash
git add commands/status.md
git commit -m "feat(status): add status command entry point"
```

---

## Task 4: Run full verification

**Step 1: Run all tests**

Run: `uv run pytest tests/ -v`
Expected: All tests pass

**Step 2: Run linter**

Run: `uv run ruff check .`
Expected: No errors

**Step 3: Run type checker**

Run: `uv run mypy tests/`
Expected: No errors (or only pre-existing warnings)

---

## Final Verification

**Run all tests:**
```bash
uv run pytest tests/ -v
```
Expected: All tests pass

**Run linter:**
```bash
uv run ruff check .
```
Expected: No errors

**Run type checker:**
```bash
uv run mypy tests/
```
Expected: No errors
