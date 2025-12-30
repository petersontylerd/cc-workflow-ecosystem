# Phase 3: CI/CD and Integration Tests Design

**Goal:** Add GitHub Actions CI/CD and integration tests for the workflow-ecosystem plugin

**Architecture:** Copy-friendly CI template with pytest-based load validation tests

**Tech Stack:** GitHub Actions, uv, pytest, pre-commit

---

## Requirements

| Requirement | Decision |
|-------------|----------|
| CI triggers | PR validation + push to any branch |
| Test scope | Structural + load testing |
| Runner | Ubuntu latest only |
| Merge blockers | pytest + pre-commit (ruff, mypy, markdownlint) |
| Reusability | Copy-friendly template with CUSTOMIZE comments |

---

## Implementation Plan

### Task 1: Create GitHub Actions CI Workflow

**File:** `.github/workflows/ci.yml`

Copy-friendly template with:
- Clear CUSTOMIZE comments for per-repo changes
- Uses uv for Python environment management
- Runs pre-commit for linting/formatting
- Runs pytest for tests
- Triggers on push and PR to main

### Task 2: Create Skill Loading Tests

**File:** `tests/test_skill_loading.py`

Validates each SKILL.md:
- Has valid YAML frontmatter
- Required fields: name, description
- Content is non-empty

### Task 3: Create Command Loading Tests

**File:** `tests/test_command_loading.py`

Validates each COMMAND.md:
- Has valid structure
- Usage examples exist

### Task 4: Create Agent Loading Tests

**File:** `tests/test_agent_loading.py`

Validates each AGENT.md:
- Has valid frontmatter
- Role definition exists

### Task 5: Create Hooks Loading Tests

**File:** `tests/test_hooks_loading.py`

Validates hooks.json:
- Commands reference valid script paths
- Scripts exist on disk

---

## Success Criteria

- [ ] GitHub Actions runs on push and PR
- [ ] All pre-commit checks pass in CI
- [ ] All pytest tests pass in CI
- [ ] PR cannot merge if checks fail
- [ ] Integration tests validate all 7 skills, 7 commands, 3 agents
