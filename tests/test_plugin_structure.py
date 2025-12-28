"""Tests for plugin directory structure and file presence."""

import json
from pathlib import Path


class TestPluginManifest:
    """Tests for .claude-plugin/plugin.json."""

    def test_plugin_json_exists(self, plugin_root: Path) -> None:
        """Plugin manifest file must exist."""
        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        assert plugin_json.exists(), f"Missing: {plugin_json}"

    def test_plugin_json_valid(self, plugin_root: Path) -> None:
        """Plugin manifest must be valid JSON."""
        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        content = plugin_json.read_text()
        data = json.loads(content)
        assert isinstance(data, dict)

    def test_plugin_json_has_name(self, plugin_root: Path) -> None:
        """Plugin manifest must have name field."""
        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())
        assert "name" in data, "plugin.json missing 'name' field"
        assert data["name"] == "workflow-ecosystem"

    def test_plugin_json_has_version(self, plugin_root: Path) -> None:
        """Plugin manifest must have version field."""
        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())
        assert "version" in data, "plugin.json missing 'version' field"


class TestSkillsDirectory:
    """Tests for skills/ directory."""

    def test_skills_directory_exists(self, skills_dir: Path) -> None:
        """Skills directory must exist."""
        assert skills_dir.exists(), f"Missing: {skills_dir}"
        assert skills_dir.is_dir()

    def test_all_expected_skills_exist(
        self, skills_dir: Path, expected_skills: list[str]
    ) -> None:
        """All expected skills must have directories."""
        for skill_name in expected_skills:
            skill_dir = skills_dir / skill_name
            assert skill_dir.exists(), f"Missing skill: {skill_name}"
            assert skill_dir.is_dir()

    def test_all_skills_have_skill_md(
        self, skills_dir: Path, expected_skills: list[str]
    ) -> None:
        """Each skill must have a SKILL.md file."""
        for skill_name in expected_skills:
            skill_file = skills_dir / skill_name / "SKILL.md"
            assert skill_file.exists(), f"Missing: {skill_file}"

    def test_skill_md_has_frontmatter(
        self, skills_dir: Path, expected_skills: list[str]
    ) -> None:
        """Each SKILL.md must have YAML frontmatter with name and description."""
        for skill_name in expected_skills:
            skill_file = skills_dir / skill_name / "SKILL.md"
            content = skill_file.read_text()
            assert content.startswith("---"), f"{skill_file} missing frontmatter"
            assert "name:" in content, f"{skill_file} missing 'name' in frontmatter"
            assert (
                "description:" in content
            ), f"{skill_file} missing 'description' in frontmatter"


class TestCommandsDirectory:
    """Tests for commands/ directory."""

    def test_commands_directory_exists(self, commands_dir: Path) -> None:
        """Commands directory must exist."""
        assert commands_dir.exists(), f"Missing: {commands_dir}"
        assert commands_dir.is_dir()

    def test_all_expected_commands_exist(
        self, commands_dir: Path, expected_commands: list[str]
    ) -> None:
        """All expected commands must exist."""
        for cmd_name in expected_commands:
            cmd_file = commands_dir / f"{cmd_name}.md"
            assert cmd_file.exists(), f"Missing command: {cmd_file}"


class TestAgentsDirectory:
    """Tests for agents/ directory."""

    def test_agents_directory_exists(self, agents_dir: Path) -> None:
        """Agents directory must exist."""
        assert agents_dir.exists(), f"Missing: {agents_dir}"
        assert agents_dir.is_dir()

    def test_all_expected_agents_exist(
        self, agents_dir: Path, expected_agents: list[str]
    ) -> None:
        """All expected agents must exist."""
        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            assert agent_file.exists(), f"Missing agent: {agent_file}"


class TestHooksDirectory:
    """Tests for hooks/ directory."""

    def test_hooks_directory_exists(self, hooks_dir: Path) -> None:
        """Hooks directory must exist."""
        assert hooks_dir.exists(), f"Missing: {hooks_dir}"
        assert hooks_dir.is_dir()

    def test_hooks_json_exists(self, hooks_dir: Path) -> None:
        """hooks.json must exist."""
        hooks_json = hooks_dir / "hooks.json"
        assert hooks_json.exists(), f"Missing: {hooks_json}"

    def test_hooks_json_valid(self, hooks_dir: Path) -> None:
        """hooks.json must be valid JSON."""
        hooks_json = hooks_dir / "hooks.json"
        content = hooks_json.read_text()
        data = json.loads(content)
        assert isinstance(data, dict)
        assert "hooks" in data

    def test_session_start_hook_configured(self, hooks_dir: Path) -> None:
        """SessionStart hook must be configured."""
        hooks_json = hooks_dir / "hooks.json"
        data = json.loads(hooks_json.read_text())
        assert "SessionStart" in data["hooks"], "Missing SessionStart hook"

    def test_session_start_script_exists(self, hooks_dir: Path) -> None:
        """session-start.sh must exist."""
        script = hooks_dir / "session-start.sh"
        assert script.exists(), f"Missing: {script}"

    def test_run_hook_cmd_exists(self, hooks_dir: Path) -> None:
        """run-hook.cmd must exist."""
        cmd = hooks_dir / "run-hook.cmd"
        assert cmd.exists(), f"Missing: {cmd}"

    def test_session_start_script_executable(self, hooks_dir: Path) -> None:
        """session-start.sh must be executable."""
        import os
        import stat

        script = hooks_dir / "session-start.sh"
        mode = os.stat(script).st_mode
        assert mode & stat.S_IXUSR, f"{script} not executable"
