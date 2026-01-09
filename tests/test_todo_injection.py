"""Tests for TODO:BACKLOG injection hooks behavior."""

import json
import os
import subprocess
import tempfile
from pathlib import Path

import pytest


class TestTodoInjectorBehavior:
    """Behavioral tests for todo-injector.sh hook."""

    def test_todo_injector_exists_and_executable(self, plugin_root: Path) -> None:
        """todo-injector.sh must exist and be executable."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        assert script.exists(), "Missing todo-injector.sh"

        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "todo-injector.sh not executable"

    def test_todo_injector_checks_implementing_phase(self, plugin_root: Path) -> None:
        """todo-injector.sh must check for implementing phase."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        assert "implementing" in content, (
            "todo-injector.sh should check for implementing phase"
        )
        assert ".workflow_phase" in content, (
            "todo-injector.sh should read .workflow_phase file"
        )

    def test_todo_injector_respects_workflow_skip(self, plugin_root: Path) -> None:
        """todo-injector.sh must respect the .workflow_skip file."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        assert ".workflow_skip" in content, (
            "todo-injector.sh should check for .workflow_skip"
        )

    def test_todo_injector_extracts_task_number(self, plugin_root: Path) -> None:
        """todo-injector.sh must extract task number from input."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        assert "Task" in content, "todo-injector.sh should look for Task pattern"
        assert "TASK_NUM" in content, "todo-injector.sh should extract TASK_NUM"

    def test_todo_injector_parses_test_file(self, plugin_root: Path) -> None:
        """todo-injector.sh must parse Test: line from Files section."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        assert "Test:" in content, "todo-injector.sh should look for Test: line"
        assert "TEST_FILE" in content, "todo-injector.sh should extract TEST_FILE"

    def test_todo_injector_uses_correct_format(self, plugin_root: Path) -> None:
        """todo-injector.sh must use TODO:BACKLOG[task-N] format."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        assert "TODO:BACKLOG" in content, (
            "todo-injector.sh should use TODO:BACKLOG marker"
        )
        assert "task-${TASK_NUM}" in content or "task-$TASK_NUM" in content, (
            "todo-injector.sh should include task number in marker"
        )

    def test_todo_injector_tracks_injections(self, plugin_root: Path) -> None:
        """todo-injector.sh must track injections in session state."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        assert ".backlog_todos" in content, (
            "todo-injector.sh should track injections in .backlog_todos"
        )

    def test_todo_injector_is_idempotent(self, plugin_root: Path) -> None:
        """todo-injector.sh must check for existing TODO before injecting."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        # Should check if TODO already exists
        assert "grep" in content and "TODO:BACKLOG" in content, (
            "todo-injector.sh should check for existing TODO marker"
        )

    def test_todo_injector_handles_comment_syntax(self, plugin_root: Path) -> None:
        """todo-injector.sh must handle different comment syntaxes."""
        script = plugin_root / "hooks" / "todo-injector.sh"
        content = script.read_text()

        # Should have comment prefix logic
        assert "COMMENT_PREFIX" in content or "get_comment_prefix" in content, (
            "todo-injector.sh should determine comment prefix"
        )
        # Should handle Python (#) and JS (//)
        assert '"//"' in content or "'//'", (
            "todo-injector.sh should support // comments"
        )
        assert '"#"' in content or "'#'" in content, (
            "todo-injector.sh should support # comments"
        )


class TestTodoSweepBehavior:
    """Behavioral tests for todo-sweep.sh hook."""

    def test_todo_sweep_exists_and_executable(self, plugin_root: Path) -> None:
        """todo-sweep.sh must exist and be executable."""
        script = plugin_root / "hooks" / "todo-sweep.sh"
        assert script.exists(), "Missing todo-sweep.sh"

        import stat

        mode = os.stat(script).st_mode
        is_executable = mode & (stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        assert is_executable, "todo-sweep.sh not executable"

    def test_todo_sweep_respects_workflow_skip(self, plugin_root: Path) -> None:
        """todo-sweep.sh must respect the .workflow_skip file."""
        script = plugin_root / "hooks" / "todo-sweep.sh"
        content = script.read_text()

        assert ".workflow_skip" in content, (
            "todo-sweep.sh should check for .workflow_skip"
        )

    def test_todo_sweep_searches_for_markers(self, plugin_root: Path) -> None:
        """todo-sweep.sh must search for TODO:BACKLOG markers."""
        script = plugin_root / "hooks" / "todo-sweep.sh"
        content = script.read_text()

        assert "TODO:BACKLOG" in content, (
            "todo-sweep.sh should search for TODO:BACKLOG markers"
        )
        assert "grep" in content, "todo-sweep.sh should use grep to search"

    def test_todo_sweep_excludes_common_dirs(self, plugin_root: Path) -> None:
        """todo-sweep.sh must exclude .venv, node_modules, .git, etc."""
        script = plugin_root / "hooks" / "todo-sweep.sh"
        content = script.read_text()

        assert "exclude-dir" in content, (
            "todo-sweep.sh should use --exclude-dir for grep"
        )
        assert ".venv" in content or "venv" in content, (
            "todo-sweep.sh should exclude .venv"
        )
        assert "node_modules" in content, (
            "todo-sweep.sh should exclude node_modules"
        )
        assert ".git" in content, "todo-sweep.sh should exclude .git"

    def test_todo_sweep_outputs_warning_when_markers_remain(
        self, plugin_root: Path
    ) -> None:
        """todo-sweep.sh must output warning when markers remain."""
        script = plugin_root / "hooks" / "todo-sweep.sh"
        content = script.read_text()

        assert "WARNING" in content, (
            "todo-sweep.sh should output WARNING when markers remain"
        )
        assert "hookSpecificOutput" in content, (
            "todo-sweep.sh should output JSON with hookSpecificOutput"
        )


class TestTodoInjectionIntegration:
    """Integration tests that actually run the hooks."""

    def test_todo_injector_skips_when_not_code_implementer(
        self, plugin_root: Path
    ) -> None:
        """todo-injector.sh should skip when not code-implementer dispatch."""
        with tempfile.TemporaryDirectory() as tmpdir:
            env = os.environ.copy()
            env["CLAUDE_TOOL_NAME"] = "Task"
            env["CLAUDE_TOOL_INPUT"] = "spec-reviewer task description"
            env["CLAUDE_SESSION_DIR"] = tmpdir

            result = subprocess.run(
                [str(plugin_root / "hooks" / "todo-injector.sh")],
                capture_output=True,
                text=True,
                env=env,
            )

            assert result.returncode == 0
            assert result.stdout.strip() == "{}"

    def test_todo_injector_skips_when_not_implementing_phase(
        self, plugin_root: Path
    ) -> None:
        """todo-injector.sh should skip when not in implementing phase."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Set phase to something other than implementing
            Path(tmpdir, ".workflow_phase").write_text("brainstorming")

            env = os.environ.copy()
            env["CLAUDE_TOOL_NAME"] = "Task"
            env["CLAUDE_TOOL_INPUT"] = "code-implementer ## Task 1: Test"
            env["CLAUDE_SESSION_DIR"] = tmpdir

            result = subprocess.run(
                [str(plugin_root / "hooks" / "todo-injector.sh")],
                capture_output=True,
                text=True,
                env=env,
            )

            assert result.returncode == 0
            assert result.stdout.strip() == "{}"

    def test_todo_injector_injects_into_existing_file(
        self, plugin_root: Path
    ) -> None:
        """todo-injector.sh should inject TODO into existing test file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a test file
            test_file = Path(tmpdir) / "test_example.py"
            test_file.write_text("import pytest\n\ndef test_something():\n    pass\n")

            # Set up session state
            Path(tmpdir, ".workflow_phase").write_text("implementing")

            task_input = f"""code-implementer dispatch
## Task 3: Add feature
### Files
- Test: {test_file}
"""

            env = os.environ.copy()
            env["CLAUDE_TOOL_NAME"] = "Task"
            env["CLAUDE_TOOL_INPUT"] = task_input
            env["CLAUDE_SESSION_DIR"] = tmpdir

            result = subprocess.run(
                [str(plugin_root / "hooks" / "todo-injector.sh")],
                capture_output=True,
                text=True,
                env=env,
                cwd=tmpdir,
            )

            assert result.returncode == 0

            # Check file was modified
            content = test_file.read_text()
            assert "TODO:BACKLOG[task-3]" in content, f"TODO not injected. Content: {content}"

            # Check tracking file
            tracker = Path(tmpdir) / ".backlog_todos"
            assert tracker.exists(), "Tracker file not created"
            assert "task-3" in tracker.read_text()

    def test_todo_sweep_finds_remaining_markers(self, plugin_root: Path) -> None:
        """todo-sweep.sh should find and report remaining TODO:BACKLOG markers."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a file with a TODO marker
            test_file = Path(tmpdir) / "test_example.py"
            test_file.write_text(
                "# TODO:BACKLOG[task-5]: See backlog for requirements\n"
                "def test_something():\n    pass\n"
            )

            env = os.environ.copy()
            env["CLAUDE_TOOL_INPUT"] = "verification skill"
            env["CLAUDE_SESSION_DIR"] = tmpdir

            result = subprocess.run(
                [str(plugin_root / "hooks" / "todo-sweep.sh")],
                capture_output=True,
                text=True,
                env=env,
                cwd=tmpdir,
            )

            assert result.returncode == 0
            output = result.stdout

            # Should find the marker and report it
            assert "WARNING" in output, f"Expected WARNING in output: {output}"
            assert "task-" in output, f"Expected task reference in output: {output}"

    def test_todo_sweep_clean_when_no_markers(self, plugin_root: Path) -> None:
        """todo-sweep.sh should report clean when no TODO:BACKLOG markers exist."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a file without TODO markers
            test_file = Path(tmpdir) / "test_example.py"
            test_file.write_text("def test_something():\n    pass\n")

            env = os.environ.copy()
            env["CLAUDE_TOOL_INPUT"] = "verification skill"
            env["CLAUDE_SESSION_DIR"] = tmpdir

            result = subprocess.run(
                [str(plugin_root / "hooks" / "todo-sweep.sh")],
                capture_output=True,
                text=True,
                env=env,
                cwd=tmpdir,
            )

            assert result.returncode == 0
            output = result.stdout

            # Should report all clear
            assert "No task markers remain" in output or "SWEEP" in output


class TestHooksJsonRegistration:
    """Tests that new hooks are properly registered in hooks.json."""

    def test_todo_injector_registered_in_hooks_json(self, plugin_root: Path) -> None:
        """todo-injector.sh must be registered in hooks.json."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        posttool_hooks = data.get("hooks", {}).get("PostToolUse", [])

        # Collect all commands from PostToolUse hooks
        all_commands = []
        for hook_entry in posttool_hooks:
            for hook in hook_entry.get("hooks", []):
                all_commands.append(hook.get("command", ""))
        commands_str = " ".join(all_commands)

        assert "todo-injector.sh" in commands_str, (
            "todo-injector.sh not registered in PostToolUse hooks"
        )

    def test_todo_sweep_registered_in_hooks_json(self, plugin_root: Path) -> None:
        """todo-sweep.sh must be registered in hooks.json."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())

        pretool_hooks = data.get("hooks", {}).get("PreToolUse", [])

        # Collect all commands from PreToolUse hooks matching verification
        verification_commands = []
        for hook_entry in pretool_hooks:
            matcher = hook_entry.get("matcher", "")
            if "verification" in matcher or "verify" in matcher:
                for hook in hook_entry.get("hooks", []):
                    verification_commands.append(hook.get("command", ""))

        commands_str = " ".join(verification_commands)

        assert "todo-sweep.sh" in commands_str, (
            "todo-sweep.sh not registered in PreToolUse verification hooks"
        )
