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


class TestEnforcementHooks:
    """Tests for workflow enforcement hooks."""

    def test_main_branch_protection_exists(self, plugin_root: Path) -> None:
        """main-branch-protection.sh must exist and be executable."""
        script = plugin_root / "hooks" / "main-branch-protection.sh"
        assert script.exists(), "Missing main-branch-protection.sh"

        import os
        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "main-branch-protection.sh not executable"

    def test_workflow_phase_check_exists(self, plugin_root: Path) -> None:
        """workflow-phase-check.sh must exist and be executable."""
        script = plugin_root / "hooks" / "workflow-phase-check.sh"
        assert script.exists(), "Missing workflow-phase-check.sh"

        import os
        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "workflow-phase-check.sh not executable"

    def test_phase_transition_exists(self, plugin_root: Path) -> None:
        """phase-transition.sh must exist and be executable."""
        script = plugin_root / "hooks" / "phase-transition.sh"
        assert script.exists(), "Missing phase-transition.sh"

        import os
        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "phase-transition.sh not executable"

    def test_workflow_skip_set_exists(self, plugin_root: Path) -> None:
        """workflow-skip-set.sh must exist and be executable."""
        script = plugin_root / "hooks" / "workflow-skip-set.sh"
        assert script.exists(), "Missing workflow-skip-set.sh"

        import os
        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "workflow-skip-set.sh not executable"

    def test_hooks_json_has_write_edit_enforcement(self, plugin_root: Path) -> None:
        """hooks.json must have main-branch-protection and workflow-phase-check for Write|Edit."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        pretool_hooks = data.get("hooks", {}).get("PreToolUse", [])
        write_edit_hooks = [
            h for h in pretool_hooks if h.get("matcher") == "Write|Edit"
        ]

        assert len(write_edit_hooks) == 1, "Expected exactly one Write|Edit hook entry"

        commands = [
            hook.get("command", "") for hook in write_edit_hooks[0].get("hooks", [])
        ]
        commands_str = " ".join(commands)

        assert "main-branch-protection.sh" in commands_str, (
            "Write|Edit hooks missing main-branch-protection.sh"
        )
        assert "workflow-phase-check.sh" in commands_str, (
            "Write|Edit hooks missing workflow-phase-check.sh"
        )

    def test_hooks_json_has_phase_transitions(self, plugin_root: Path) -> None:
        """hooks.json must have phase-transition.sh for skill completions."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        posttool_hooks = data.get("hooks", {}).get("PostToolUse", [])

        # Extract all commands from PostToolUse hooks
        commands = []
        for hook_entry in posttool_hooks:
            for hook in hook_entry.get("hooks", []):
                cmd = hook.get("command", "")
                if cmd:
                    commands.append(cmd)

        commands_str = " ".join(commands)
        assert "phase-transition.sh" in commands_str, (
            "PostToolUse hooks missing phase-transition.sh"
        )


class TestSubagentTrackingHooks:
    """Tests for subagent dispatch tracking hooks."""

    def test_subagent_dispatch_tracker_exists(self, plugin_root: Path) -> None:
        """subagent-dispatch-tracker.sh must exist and be executable."""
        script = plugin_root / "hooks" / "subagent-dispatch-tracker.sh"
        assert script.exists(), "Missing subagent-dispatch-tracker.sh"

        import os
        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "subagent-dispatch-tracker.sh not executable"

    def test_subagent_review_check_exists(self, plugin_root: Path) -> None:
        """subagent-review-check.sh must exist and be executable."""
        script = plugin_root / "hooks" / "subagent-review-check.sh"
        assert script.exists(), "Missing subagent-review-check.sh"

        import os
        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "subagent-review-check.sh not executable"

    def test_hooks_json_has_task_posttool_hook(self, plugin_root: Path) -> None:
        """hooks.json must have Task PostToolUse hooks for subagent tracking and evidence checks."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        posttool_hooks = data.get("hooks", {}).get("PostToolUse", [])
        task_hooks = [h for h in posttool_hooks if h.get("matcher") == "Task"]

        # Two Task hooks: subagent-dispatch-tracker.sh and implementer-evidence-check.sh
        assert len(task_hooks) == 2, "Expected two Task PostToolUse hook entries"

        # Collect all commands from all Task hooks
        all_commands = []
        for hook_entry in task_hooks:
            for hook in hook_entry.get("hooks", []):
                all_commands.append(hook.get("command", ""))
        commands_str = " ".join(all_commands)

        assert "subagent-dispatch-tracker.sh" in commands_str, (
            "Task PostToolUse hooks missing subagent-dispatch-tracker.sh"
        )
        assert "implementer-evidence-check.sh" in commands_str, (
            "Task PostToolUse hooks missing implementer-evidence-check.sh"
        )

    def test_hooks_json_has_todowrite_posttool_hook(self, plugin_root: Path) -> None:
        """hooks.json must have subagent-review-check.sh for TodoWrite PostToolUse."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        posttool_hooks = data.get("hooks", {}).get("PostToolUse", [])
        todowrite_hooks = [h for h in posttool_hooks if h.get("matcher") == "TodoWrite"]

        assert len(todowrite_hooks) == 1, (
            "Expected exactly one TodoWrite PostToolUse hook entry"
        )

        commands = [
            hook.get("command", "") for hook in todowrite_hooks[0].get("hooks", [])
        ]
        commands_str = " ".join(commands)

        assert "subagent-review-check.sh" in commands_str, (
            "TodoWrite PostToolUse hooks missing subagent-review-check.sh"
        )

    def test_dispatch_tracker_checks_implementing_phase(
        self, plugin_root: Path
    ) -> None:
        """subagent-dispatch-tracker.sh must check for implementing phase."""
        script = plugin_root / "hooks" / "subagent-dispatch-tracker.sh"
        content = script.read_text()

        assert "implementing" in content, (
            "subagent-dispatch-tracker.sh should check for implementing phase"
        )
        assert ".workflow_phase" in content, (
            "subagent-dispatch-tracker.sh should read .workflow_phase file"
        )

    def test_review_check_checks_implementing_phase(self, plugin_root: Path) -> None:
        """subagent-review-check.sh must check for implementing phase."""
        script = plugin_root / "hooks" / "subagent-review-check.sh"
        content = script.read_text()

        assert "implementing" in content, (
            "subagent-review-check.sh should check for implementing phase"
        )
        assert ".workflow_phase" in content, (
            "subagent-review-check.sh should read .workflow_phase file"
        )

    def test_both_hooks_respect_workflow_skip(self, plugin_root: Path) -> None:
        """Both tracking hooks must respect the .workflow_skip file."""
        tracker = plugin_root / "hooks" / "subagent-dispatch-tracker.sh"
        checker = plugin_root / "hooks" / "subagent-review-check.sh"

        tracker_content = tracker.read_text()
        checker_content = checker.read_text()

        assert ".workflow_skip" in tracker_content, (
            "subagent-dispatch-tracker.sh should check for .workflow_skip"
        )
        assert ".workflow_skip" in checker_content, (
            "subagent-review-check.sh should check for .workflow_skip"
        )

    def test_review_check_warns_on_missing_reviewers(self, plugin_root: Path) -> None:
        """subagent-review-check.sh must warn when reviewers are missing."""
        script = plugin_root / "hooks" / "subagent-review-check.sh"
        content = script.read_text()

        assert "spec-reviewer" in content, (
            "subagent-review-check.sh should check for spec-reviewer"
        )
        assert "quality-reviewer" in content, (
            "subagent-review-check.sh should check for quality-reviewer"
        )
        assert "SUBAGENT DISPATCH WARNING" in content, (
            "subagent-review-check.sh should output warning when reviewers missing"
        )
