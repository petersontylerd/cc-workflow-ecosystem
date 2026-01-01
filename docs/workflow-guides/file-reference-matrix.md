# File Reference Matrix

This document provides a complete inventory of all files in the workflow ecosystem plugin and tracks which usage pattern documents reference them.

---

## Quick Statistics

| Category | Total Files | Referenced | Coverage |
|----------|-------------|------------|----------|
| Plugin Config | 2 | 2 | 100% |
| Commands | 8 | 8 | 100% |
| Skills | 12 | 12 | 100% |
| Agents | 3 | 3 | 100% |
| Hooks | 18 | 18 | 100% |
| Scripts | 2 | 2 | 100% |
| Templates | 1 | 1 | 100% |
| Tests | 8 | 8 | 100% |
| Documentation | 8 | 8 | 100% |
| Config | 5 | 5 | 100% |
| **Total** | **69** | **69** | **100%** |

---

## Core Plugin Components

### Plugin Configuration (2 files)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `.claude-plugin/plugin.json` | | [x] | Plugin manifest (name, version, lists components) |
| `.claude-plugin/marketplace.json` | | [x] | Marketplace metadata (description, author) |

**Notes**: These files are primarily referenced in the release process (Expert pattern). They define what the plugin exposes to Claude Code.

---

### Commands (8 files)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `commands/brainstorm.md` | [x] | | Entry point for requirements exploration |
| `commands/branch.md` | [x] | | Entry point for branch creation |
| `commands/backlog-development.md` | [x] | | Entry point for backlog creation |
| `commands/implement.md` | [x] | [x] | Entry point for subagent orchestration |
| `commands/verify.md` | [x] | | Entry point for pre-completion verification |
| `commands/commit.md` | [x] | | Entry point for atomic commits |
| `commands/pr.md` | [x] | | Entry point for pull request creation |
| `commands/workflow.md` | | [x] | Entry point for workflow state management |

**Coverage**: All 8 commands are referenced across both patterns.

---

### Skills (12 files)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `skills/using-ecosystem/SKILL.md` | [x] | [x] | Ecosystem orientation (auto-injected) |
| `skills/brainstorming/SKILL.md` | [x] | | Requirements exploration discipline |
| `skills/developing-backlogs/SKILL.md` | [x] | | Backlog creation discipline |
| `skills/orchestrating-subagents/SKILL.md` | [x] | [x] | Subagent dispatch patterns |
| `skills/verification/SKILL.md` | [x] | [x] | Evidence-based completion |
| `skills/git-workflow/SKILL.md` | [x] | | Branch/commit/PR discipline |
| `skills/workflow-management/SKILL.md` | | [x] | State management operations |
| `skills/subagent-state-management/SKILL.md` | [x] | [x] | Subagent startup/handoff patterns |
| `skills/systematic-debugging/SKILL.md` | [x] | [x] | Debugging methodology |
| `skills/python-development/SKILL.md` | [x] | | Python coding standards |
| `skills/typescript-development/SKILL.md` | | [x] | TypeScript coding standards |
| `skills/angular-development/SKILL.md` | | [x] | Angular coding standards |

**Coverage**: All 12 skills are referenced across both patterns.

---

### Agents (3 files)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `agents/code-implementer.md` | [x] | [x] | TDD implementation executor |
| `agents/spec-reviewer.md` | [x] | [x] | Requirements compliance reviewer |
| `agents/quality-reviewer.md` | [x] | [x] | Code quality assessor |

**Notes**: Agents are used in automated workflows (both Intermediate and Expert patterns).

---

### Hooks (18 files)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `hooks/hooks.json` | [x] | [x] | Hook configuration (defines all triggers) |
| `hooks/run-hook.cmd` | [x] | [x] | Cross-platform hook execution wrapper |
| `hooks/session-start.sh` | [x] | [x] | Injects `using-ecosystem` skill on startup, auto-detects feature branch |
| `hooks/main-branch-protection.sh` | [x] | [x] | **BLOCKS** edits on main/master branch |
| `hooks/workflow-phase-check.sh` | [x] | [x] | **BLOCKS** edits before backlog-ready phase |
| `hooks/phase-transition.sh` | [x] | [x] | Updates `.workflow_phase` on skill completion, resets state on /branch |
| `hooks/tdd-precommit-check.sh` | [x] | [x] | **BLOCKS** commits without test files, detects trivial tests |
| `hooks/verify-before-commit.sh` | [x] | | Reminds about verification before commit |
| `hooks/validate-task-description.sh` | [x] | [x] | Validates subagent task descriptions |
| `hooks/workflow-skip-set.sh` | | [x] | Sets `.workflow_skip` marker for escape hatch |
| `hooks/subagent-dispatch-tracker.sh` | [x] | [x] | Tracks subagent dispatches, detects fix cycles |
| `hooks/subagent-review-check.sh` | [x] | [x] | **WARNS** if task completed without reviewers or re-review |
| `hooks/backlog-task-counter.sh` | [x] | [x] | Counts tasks at /implement, warns on large backlogs |
| `hooks/verify-task-count.sh` | [x] | [x] | Compares completed vs expected tasks at /verify |
| `hooks/backlog-lint.sh` | [x] | | Scans backlogs for placeholders and missing test commands |
| `hooks/implementer-evidence-check.sh` | [x] | [x] | Validates completion reports contain evidence |
| `hooks/brainstorm-phase-start.sh` | [x] | | Sets phase when brainstorming skill starts |
| `hooks/brainstorm-exit-plan-mode.sh` | [x] | | Phase transition after ExitPlanMode |

**Coverage**: All 18 hooks are referenced across both patterns.

---

### Scripts (2 files)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `scripts/release.sh` | | [x] | Version bump, commit, and tag creation |
| `scripts/pre-push-version-check.sh` | | [x] | Validates version sync before push |

**Notes**: Scripts are developer tools for plugin maintainers, only relevant in Expert pattern.

---

### Templates (1 file)

| File | Intermediate | Expert | Purpose |
|------|:------------:|:------:|---------|
| `templates/pr-description.md` | [x] | | Pull request template |

**Coverage**: Template is referenced in Intermediate pattern for PR creation.

---

## Supporting Files

### Tests (8 files)

| File | Referenced In | Purpose |
|------|---------------|---------|
| `tests/__init__.py` | Matrix only | Package marker |
| `tests/conftest.py` | Matrix only | Pytest fixtures (defines expected components) |
| `tests/test_plugin_structure.py` | Matrix only | Validates plugin directory structure |
| `tests/test_skill_loading.py` | Matrix only | Validates skill YAML parsing |
| `tests/test_command_loading.py` | Matrix only | Validates command YAML parsing |
| `tests/test_agent_loading.py` | Matrix only | Validates agent YAML parsing |
| `tests/test_hooks_loading.py` | Matrix only | Validates hooks.json format |
| `tests/test_schemas.py` | Matrix only | JSON schema validation |

**Notes**: Test files validate plugin structure but don't participate in runtime workflow. They are referenced here for completeness.

### Test Schemas (2 files)

| File | Referenced In | Purpose |
|------|---------------|---------|
| `tests/schemas/plugin.schema.json` | Matrix only | JSON schema for plugin.json validation |
| `tests/schemas/hooks.schema.json` | Matrix only | JSON schema for hooks.json validation |

---

### Documentation (8 files)

| File | Referenced In | Purpose |
|------|---------------|---------|
| `README.md` | Matrix only | Project overview |
| `CLAUDE.md` | Matrix only | Claude Code instructions |
| `RELEASING.md` | Matrix only | Release process documentation |
| `LICENSE` | Matrix only | MIT license |
| `docs/tutorials/getting-started.md` | Matrix only | User onboarding tutorial |
| `docs/tutorials/first-feature.md` | Matrix only | First feature walkthrough |
| `docs/skill-pressure-scenarios.md` | Matrix only | Skill testing scenarios |
| `docs/workflow-guides/README.md` | Matrix only | Workflow guide index (this directory) |

**Notes**: Documentation files are standalone references. They don't trigger other files in the workflow.

---

### Configuration (5 files)

| File | Referenced In | Purpose |
|------|---------------|---------|
| `pyproject.toml` | Matrix only | Python project configuration (uv, pytest, ruff) |
| `.pre-commit-config.yaml` | Matrix only | Pre-commit hook configuration |
| `.markdownlint.json` | Matrix only | Markdown linting rules |
| `.python-version` | Matrix only | Python version specification |
| `.mcp.json` | Matrix only | MCP server configuration |

**Notes**: Configuration files define development environment but don't participate in runtime workflow.

---

## Analysis

### Files Not Triggered by Workflow

The following files exist in the repository but are **not triggered** by the workflow (they are supporting/infrastructure files):

| Category | Files | Reason |
|----------|-------|--------|
| Tests | 8 files | Validate structure, don't execute at runtime |
| Test Schemas | 2 files | Schema definitions for test validation |
| Documentation | 8 files | Reference material, not workflow components |
| Configuration | 5 files | Development environment, not runtime |

**Total**: 23 files are supporting infrastructure, not workflow-triggered components.

### Workflow-Triggered Files

The following 46 files are **actively triggered** during workflow execution:

| Category | Count | Files |
|----------|-------|-------|
| Plugin Config | 2 | plugin.json, marketplace.json (during releases) |
| Commands | 8 | All 8 commands |
| Skills | 12 | All 12 skills |
| Agents | 3 | All 3 agents |
| Hooks | 18 | All 18 hooks |
| Scripts | 2 | release.sh, pre-push-version-check.sh |
| Templates | 1 | pr-description.md |

### Potential Improvements Identified

1. **Test files**: Currently tests only validate structure. Consider adding runtime tests that verify hooks behave correctly.

2. **Language skills**: `python-development`, `typescript-development`, and `angular-development` are only referenced in task descriptions. They could be auto-invoked based on file extensions in the project.

---

## Trigger Relationships

### What Triggers What

```
User invokes /command
    │
    ▼
commands/<name>.md
    │ "Use <skill-name> skill..."
    ▼
skills/<name>/SKILL.md
    │
    ├── PostToolUse hook fires (matcher: Skill.*<pattern>)
    │   ▼
    │   hooks/<script>.sh
    │   └── Updates $SESSION_DIR state files
    │
    └── May dispatch agents (via Task tool)
        ▼
        agents/<name>.md
        │
        └── PreToolUse hook fires (matcher: Task.*)
            ▼
            hooks/validate-task-description.sh
```

### Session State Files

| File | Created By | Read By |
|------|------------|---------|
| `.workflow_phase` | `phase-transition.sh`, `session-start.sh` | `workflow-phase-check.sh`, `subagent-dispatch-tracker.sh`, `subagent-review-check.sh` |
| `.workflow_skip` | `workflow-skip-set.sh` | All blocking hooks |
| `.backlog_path` | `backlog-task-counter.sh` | Skills, agents, `verify-task-count.sh` |
| `.subagent_dispatch` | `subagent-dispatch-tracker.sh` | `subagent-review-check.sh` |
| `.expected_task_count` | `backlog-task-counter.sh` | `verify-task-count.sh` |
| `.needs_refix` | `subagent-dispatch-tracker.sh` | `subagent-review-check.sh` |

---

## Conclusion

**All 69 files in the repository are accounted for:**

- **46 workflow-triggered files**: Actively participate in the workflow
- **23 supporting files**: Infrastructure, tests, documentation, configuration

**All core plugin components (commands, skills, agents, hooks) are referenced in at least one usage pattern**, demonstrating complete coverage of the workflow ecosystem.

The two-tier documentation (Intermediate, Expert) provides self-contained guides at different complexity levels:
- **Intermediate**: Full subagent orchestration with code-implementer, spec-reviewer, and quality-reviewer
- **Expert**: Advanced features including escape hatches, language skills, and release process

Each pattern document is fully self-contained with complete file traces and Mermaid diagrams—no cross-referencing required.
