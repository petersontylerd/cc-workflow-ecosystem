"""Shared pytest fixtures for workflow-ecosystem tests."""

from pathlib import Path

import pytest


@pytest.fixture
def plugin_root() -> Path:
    """Return the plugin root directory."""
    return Path(__file__).parent.parent


@pytest.fixture
def skills_dir(plugin_root: Path) -> Path:
    """Return the skills directory."""
    return plugin_root / "skills"


@pytest.fixture
def commands_dir(plugin_root: Path) -> Path:
    """Return the commands directory."""
    return plugin_root / "commands"


@pytest.fixture
def agents_dir(plugin_root: Path) -> Path:
    """Return the agents directory."""
    return plugin_root / "agents"


@pytest.fixture
def hooks_dir(plugin_root: Path) -> Path:
    """Return the hooks directory."""
    return plugin_root / "hooks"


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
        "subagent-state-management",
        "systematic-debugging",
        "typescript-development",
        "using-ecosystem",
        "verification",
        "workflow-management",
    ]


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
        "verify",
        "workflow",
    ]


@pytest.fixture
def expected_agents() -> list[str]:
    """Return list of expected agent names."""
    return [
        "code-implementer",
        "quality-reviewer",
        "spec-reviewer",
    ]


@pytest.fixture
def expected_hooks() -> list[str]:
    """Return list of expected hook script names."""
    return [
        "brainstorm-end.sh",
        "brainstorm-mode-check.sh",
        "brainstorm-start.sh",
        "main-branch-protection.sh",
        "phase-transition.sh",
        "run-hook.cmd",
        "session-start.sh",
        "tdd-precommit-check.sh",
        "validate-context-packet.sh",
        "verify-before-commit.sh",
        "workflow-phase-check.sh",
        "workflow-skip-set.sh",
    ]
