"""Tests for agent loading validation."""

import re
from pathlib import Path

import pytest
import yaml


class TestAgentLoading:
    """Validate that all agents can be loaded correctly."""

    def test_all_agents_exist(
        self, plugin_root: Path, expected_agents: list[str]
    ) -> None:
        """Each expected agent must have a .md file."""
        agents_dir = plugin_root / "agents"

        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            assert agent_file.exists(), f"Missing {agent_name}.md"

    def test_all_agents_have_valid_frontmatter(
        self, plugin_root: Path, expected_agents: list[str]
    ) -> None:
        """Each agent .md must have valid YAML frontmatter."""
        agents_dir = plugin_root / "agents"

        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            content = agent_file.read_text()
            frontmatter = self._extract_frontmatter(content)
            assert frontmatter is not None, f"No frontmatter in {agent_name}.md"

            try:
                data = yaml.safe_load(frontmatter)
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML in {agent_name}.md: {e}")

            assert isinstance(data, dict), f"Frontmatter must be a dict in {agent_name}"

    def test_all_agents_have_required_fields(
        self, plugin_root: Path, expected_agents: list[str]
    ) -> None:
        """Each agent must have name and description in frontmatter."""
        agents_dir = plugin_root / "agents"

        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            content = agent_file.read_text()
            frontmatter = self._extract_frontmatter(content)
            assert frontmatter is not None, f"No frontmatter in {agent_name}"
            data = yaml.safe_load(frontmatter)

            assert "name" in data, f"Missing 'name' in {agent_name}.md"
            assert "description" in data, f"Missing 'description' in {agent_name}.md"

    def test_all_agents_have_role_definition(
        self, plugin_root: Path, expected_agents: list[str]
    ) -> None:
        """Each agent should define its role clearly in content."""
        agents_dir = plugin_root / "agents"

        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            content = agent_file.read_text()
            body = self._extract_body(content)

            # Should have some role/responsibility section
            has_role = any(
                marker in body
                for marker in [
                    "## Role",
                    "## Your Role",
                    "## Core Role",
                    "## Responsibilities",
                    "# Role",
                    "Role:",
                ]
            )
            assert has_role, f"Missing role definition in {agent_name}.md"

    def test_all_agents_have_sufficient_content(
        self, plugin_root: Path, expected_agents: list[str]
    ) -> None:
        """Each agent should have meaningful prompt content."""
        agents_dir = plugin_root / "agents"

        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            content = agent_file.read_text()
            body = self._extract_body(content)

            # Agent prompts should be substantial
            assert len(body.strip()) > 500, (
                f"Agent {agent_name} has insufficient prompt content "
                f"({len(body.strip())} chars, expected >500)"
            )

    def test_agent_names_match_filename(
        self, plugin_root: Path, expected_agents: list[str]
    ) -> None:
        """Agent name in frontmatter should match filename."""
        agents_dir = plugin_root / "agents"

        for agent_name in expected_agents:
            agent_file = agents_dir / f"{agent_name}.md"
            content = agent_file.read_text()
            frontmatter = self._extract_frontmatter(content)
            assert frontmatter is not None, f"No frontmatter in {agent_name}"
            data = yaml.safe_load(frontmatter)

            assert data["name"] == agent_name, (
                f"Name mismatch: frontmatter has '{data['name']}' "
                f"but filename is '{agent_name}.md'"
            )

    def _extract_frontmatter(self, content: str) -> str | None:
        """Extract YAML frontmatter from markdown content."""
        match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
        return match.group(1) if match else None

    def _extract_body(self, content: str) -> str:
        """Extract body content after frontmatter."""
        match = re.match(r"^---\s*\n.*?\n---\s*\n(.*)$", content, re.DOTALL)
        return match.group(1) if match else content
