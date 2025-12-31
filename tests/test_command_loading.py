"""Tests for command loading validation."""

import re
from pathlib import Path


class TestCommandLoading:
    """Validate that all commands can be loaded correctly."""

    def test_all_commands_exist(
        self, plugin_root: Path, expected_commands: list[str]
    ) -> None:
        """Each expected command must have a .md file."""
        commands_dir = plugin_root / "commands"

        for command_name in expected_commands:
            command_file = commands_dir / f"{command_name}.md"
            assert command_file.exists(), f"Missing {command_name}.md"

    def test_all_commands_have_title(
        self, plugin_root: Path, expected_commands: list[str]
    ) -> None:
        """Each command must have a markdown title after frontmatter."""
        commands_dir = plugin_root / "commands"

        for command_name in expected_commands:
            command_file = commands_dir / f"{command_name}.md"
            content = command_file.read_text()
            body = self._extract_body(content)

            # Should have # title after frontmatter
            first_line = body.strip().split("\n")[0]
            assert first_line.startswith("# "), (
                f"Command {command_name} should have '# ' title after frontmatter"
            )

    def test_all_commands_have_usage_section(
        self, plugin_root: Path, expected_commands: list[str]
    ) -> None:
        """Each command should have a Usage section with examples."""
        commands_dir = plugin_root / "commands"

        for command_name in expected_commands:
            command_file = commands_dir / f"{command_name}.md"
            content = command_file.read_text()

            assert "## Usage" in content, f"Missing '## Usage' in {command_name}"
            assert "```" in content, f"Missing code examples in {command_name}"

    def test_all_commands_reference_skill(
        self, plugin_root: Path, expected_commands: list[str]
    ) -> None:
        """Each command should reference a skill (thin wrapper pattern)."""
        commands_dir = plugin_root / "commands"

        for command_name in expected_commands:
            command_file = commands_dir / f"{command_name}.md"
            content = command_file.read_text()

            # Commands should reference a skill they delegate to
            assert "skill" in content.lower(), (
                f"Missing skill reference in {command_name}"
            )

    def test_all_commands_have_sufficient_content(
        self, plugin_root: Path, expected_commands: list[str]
    ) -> None:
        """Each command should have meaningful content (thin wrappers ~200+ chars)."""
        commands_dir = plugin_root / "commands"

        for command_name in expected_commands:
            command_file = commands_dir / f"{command_name}.md"
            content = command_file.read_text()

            # Commands are thin wrappers - lower threshold than before
            assert len(content) > 200, (
                f"Command {command_name} has insufficient documentation "
                f"({len(content)} chars, expected >200)"
            )

    def test_command_names_in_title(
        self, plugin_root: Path, expected_commands: list[str]
    ) -> None:
        """Command title should reference the command name."""
        commands_dir = plugin_root / "commands"

        for command_name in expected_commands:
            command_file = commands_dir / f"{command_name}.md"
            content = command_file.read_text()
            body = self._extract_body(content)
            first_line = body.strip().split("\n")[0].lower()

            # Title should contain the command name or /command
            assert command_name in first_line or f"/{command_name}" in first_line, (
                f"Title doesn't reference command name in {command_name}"
            )

    def _extract_body(self, content: str) -> str:
        """Extract body content after frontmatter."""
        match = re.match(r"^---\s*\n.*?\n---\s*\n(.*)$", content, re.DOTALL)
        return match.group(1) if match else content
