# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code plugin (`workflow-ecosystem`) that provides skills, commands, and agents for disciplined human-agent co-development. It enforces TDD, verification-before-claims, and feature branch workflows.

## Common Commands

```bash
# Run all tests
uv run pytest tests/ -v

# Run a single test file
uv run pytest tests/test_plugin_structure.py -v

# Run specific test class or function
uv run pytest tests/test_plugin_structure.py::TestPluginManifest -v
uv run pytest tests/test_plugin_structure.py::TestPluginManifest::test_plugin_json_exists -v

# Linting and formatting
uv run ruff check .
uv run ruff format .

# Type checking
uv run mypy tests/

# Security scan (also runs on pre-push)
uv run bandit -r . -q

# Install dependencies (uses uv)
uv sync --all-groups
```

## Pre-commit Hooks

Pre-commit runs ruff-format, ruff, and mypy on `.py` files. Pre-push runs bandit and pip-audit. Install with:
```bash
uv run pre-commit install
```

## Architecture

### Plugin Structure

The plugin follows Claude Code's local plugin structure:

```
.claude-plugin/plugin.json  - Plugin manifest (name, version, lists skills/commands/agents)
hooks/hooks.json            - Hook configurations (SessionStart, PreToolCall, PostToolCall)
hooks/*.sh                  - Hook scripts for workflow enforcement
skills/<name>/SKILL.md      - Skill definitions (YAML frontmatter + markdown)
commands/<name>.md          - Command definitions (user-invokable workflows)
agents/<name>.md            - Agent definitions (subagent prompts)
```

### Three-Tier Automation

| Tier | Directory | Invocation | Purpose |
|------|-----------|------------|---------|
| Skills | `skills/` | `Skill` tool | Core competencies and disciplines |
| Commands | `commands/` | `/command-name` | User-invokable workflow entry points |
| Agents | `agents/` | `Task` tool | Specialized subagents for delegation |

### Component Conventions

**Skills** (`skills/<name>/SKILL.md`):
- Must have YAML frontmatter with `name:` and `description:`
- Define HOW to do something (disciplines, patterns, processes)

**Commands** (`commands/<name>.md`):
- Must have YAML frontmatter with `description:` and optional `argument-hint:`
- Define WHAT workflow to invoke (entry points that reference skills)

**Agents** (`agents/<name>.md`):
- Must have YAML frontmatter with `name:`, `description:`, and `model:`
- Define WHO does a task (specialized subagent prompts)

### Hooks

The plugin uses multiple hook types to enforce workflow discipline:

| Hook Type | Purpose |
|-----------|---------|
| SessionStart | Inject context on startup/resume/clear |
| PreToolCall | Enforce discipline before tool execution |
| PostToolCall | Track workflow state after tool execution |

**Hook Scripts:**

| Script | Hook Type | Purpose |
|--------|-----------|---------|
| `session-start.sh` | SessionStart | Injects `using-ecosystem` skill content |
| `verify-before-commit.sh` | PreToolCall (Bash) | Reminds about verification before git commit |
| `tdd-precommit-check.sh` | PreToolCall (Bash) | TDD discipline reminder for commits |
| `brainstorm-mode-check.sh` | PreToolCall (Write/Edit) | Blocks code changes during brainstorming |
| `validate-context-packet.sh` | PreToolCall (Task) | Validates subagent context packets |
| `brainstorm-start.sh` | PostToolCall (Skill) | Sets brainstorming state marker |
| `brainstorm-end.sh` | PostToolCall (Skill) | Clears brainstorming state marker |

## Testing

Tests validate plugin structure integrity:
- `test_plugin_structure.py` - Directory structure, file presence, frontmatter
- `test_skill_loading.py` - Skill YAML parsing and validation
- `test_command_loading.py` - Command YAML parsing
- `test_agent_loading.py` - Agent YAML parsing
- `test_hooks_loading.py` - Hook JSON validation
- `test_schemas.py` - JSON schema validation

Fixtures in `conftest.py` define expected skills, commands, and agents.

## Core Workflow Disciplines

When contributing, the plugin enforces these disciplines on users:

1. **TDD**: Write test first, watch fail, implement, watch pass
2. **Verification**: Run command, see output, THEN claim result
3. **Feature branches**: Never commit to main; use `feat/<issue>-<slug>` or `fix/<issue>-<slug>`
4. **Atomic commits**: One logical change per commit with conventional format
