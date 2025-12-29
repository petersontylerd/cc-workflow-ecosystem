"""Tests for JSON schema validation."""

import json
from pathlib import Path

import jsonschema
import pytest


@pytest.fixture
def plugin_schema() -> dict:
    """Load the plugin.json schema."""
    schema_path = Path(__file__).parent / "schemas" / "plugin.schema.json"
    return json.loads(schema_path.read_text())


@pytest.fixture
def hooks_schema() -> dict:
    """Load the hooks.json schema."""
    schema_path = Path(__file__).parent / "schemas" / "hooks.schema.json"
    return json.loads(schema_path.read_text())


class TestPluginJsonSchema:
    """Tests for plugin.json schema compliance."""

    def test_plugin_json_matches_schema(
        self, plugin_root: Path, plugin_schema: dict
    ) -> None:
        """plugin.json must match the schema."""
        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())
        jsonschema.validate(instance=data, schema=plugin_schema)

    def test_plugin_name_is_kebab_case(self, plugin_root: Path) -> None:
        """Plugin name must be kebab-case."""
        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())
        name = data.get("name", "")
        assert name == name.lower(), f"Name '{name}' must be lowercase"
        assert " " not in name, f"Name '{name}' must not contain spaces"
        assert "_" not in name, f"Name '{name}' should use hyphens, not underscores"

    def test_plugin_version_is_semver(self, plugin_root: Path) -> None:
        """Plugin version must follow semver."""
        import re

        plugin_json = plugin_root / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())
        version = data.get("version", "")
        semver_pattern = r"^\d+\.\d+\.\d+(-[a-zA-Z0-9.]+)?$"
        assert re.match(semver_pattern, version), (
            f"Version '{version}' is not valid semver"
        )


class TestHooksJsonSchema:
    """Tests for hooks.json schema compliance."""

    def test_hooks_json_matches_schema(
        self, plugin_root: Path, hooks_schema: dict
    ) -> None:
        """hooks.json must match the schema."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())
        jsonschema.validate(instance=data, schema=hooks_schema)

    def test_hooks_uses_plugin_root_variable(self, plugin_root: Path) -> None:
        """Hook commands should use CLAUDE_PLUGIN_ROOT variable."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        content = hooks_json.read_text()
        # Should use CLAUDE_PLUGIN_ROOT for plugins, not CLAUDE_PROJECT_DIR
        assert "CLAUDE_PLUGIN_ROOT" in content, "Hooks should use ${CLAUDE_PLUGIN_ROOT}"

    def test_session_start_has_valid_matcher(self, plugin_root: Path) -> None:
        """SessionStart hook should have a valid matcher pattern."""
        hooks_json = plugin_root / "hooks" / "hooks.json"
        data = json.loads(hooks_json.read_text())
        session_start = data.get("hooks", {}).get("SessionStart", [])
        assert len(session_start) > 0, "No SessionStart hooks defined"

        for entry in session_start:
            if "matcher" in entry:
                # Verify the matcher is a valid regex
                import re

                pattern = entry["matcher"]
                try:
                    re.compile(pattern)
                except re.error as e:
                    pytest.fail(f"Invalid matcher regex '{pattern}': {e}")
