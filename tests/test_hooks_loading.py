"""Tests for hooks configuration validation."""

import json
import re
from pathlib import Path


class TestHooksLoading:
    """Validate that hooks configuration is valid and scripts exist."""

    def test_hooks_json_exists(self, plugin_root: Path) -> None:
        """hooks.json must exist in hooks directory."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        assert hooks_json.exists(), "Missing hooks/hooks.json"

    def test_hooks_json_is_valid_json(self, plugin_root: Path) -> None:
        """hooks.json must be valid JSON."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        content = hooks_json.read_text()

        try:
            json.loads(content)
        except json.JSONDecodeError as e:
            raise AssertionError(f"Invalid JSON in hooks.json: {e}") from e

    def test_hooks_has_required_structure(self, plugin_root: Path) -> None:
        """hooks.json must have the expected top-level structure."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        assert "hooks" in data, "Missing 'hooks' key in hooks.json"
        assert isinstance(data["hooks"], dict), "'hooks' must be an object"

    def test_all_hook_scripts_exist(self, plugin_root: Path) -> None:
        """All scripts referenced in hooks must exist."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        # Extract all commands from hooks
        commands = self._extract_commands(data)

        for command in commands:
            # Commands use ${CLAUDE_PLUGIN_ROOT} variable
            # Pattern: "${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd" session-start.sh
            if "${CLAUDE_PLUGIN_ROOT}" in command:
                # Extract paths from the command
                # Handle quoted paths
                paths = re.findall(r'\$\{CLAUDE_PLUGIN_ROOT\}/([^\s"]+)', command)
                for path in paths:
                    full_path = plugin_root / path
                    assert full_path.exists(), f"Hook script does not exist: {path}"

    def test_hook_scripts_are_executable(self, plugin_root: Path) -> None:
        """Hook scripts in hooks directory should be marked executable."""
        hooks_dir = plugin_root / "hooks"

        # Check .sh and .cmd files
        for pattern in ["*.sh", "*.cmd"]:
            for script in hooks_dir.glob(pattern):
                import os
                import stat

                mode = os.stat(script).st_mode
                is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
                assert is_executable, f"Script not executable: {script.name}"

    def test_session_start_hook_exists(self, plugin_root: Path) -> None:
        """SessionStart hook should be defined for plugin initialization."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        hooks = data.get("hooks", {})
        assert "SessionStart" in hooks, "Missing SessionStart hook"
        assert len(hooks["SessionStart"]) > 0, "SessionStart hook has no entries"

    def test_session_start_references_valid_script(self, plugin_root: Path) -> None:
        """SessionStart hook command should reference existing script."""
        hooks_dir = plugin_root / "hooks"

        # Check that session-start.sh exists
        session_script = hooks_dir / "session-start.sh"
        assert session_script.exists(), "Missing session-start.sh"

        # Check that run-hook.cmd exists
        run_hook = hooks_dir / "run-hook.cmd"
        assert run_hook.exists(), "Missing run-hook.cmd"

    def _extract_commands(self, data: dict) -> list[str]:
        """Extract all command strings from hooks config."""
        commands = []

        hooks = data.get("hooks", {})
        for _hook_type, entries in hooks.items():
            if isinstance(entries, list):
                for entry in entries:
                    if isinstance(entry, dict) and "hooks" in entry:
                        for hook in entry["hooks"]:
                            if isinstance(hook, dict) and "command" in hook:
                                commands.append(hook["command"])

        return commands
