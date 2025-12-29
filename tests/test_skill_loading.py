"""Tests for skill loading validation."""

import re
from pathlib import Path

import pytest
import yaml


class TestSkillLoading:
    """Validate that all skills can be loaded correctly."""

    def test_all_skills_have_valid_frontmatter(
        self, plugin_root: Path, expected_skills: list[str]
    ) -> None:
        """Each SKILL.md must have valid YAML frontmatter."""
        skills_dir = plugin_root / "skills"

        for skill_name in expected_skills:
            skill_file = skills_dir / skill_name / "SKILL.md"
            assert skill_file.exists(), f"Missing SKILL.md for {skill_name}"

            content = skill_file.read_text()
            frontmatter = self._extract_frontmatter(content)
            assert frontmatter is not None, f"No frontmatter in {skill_name}/SKILL.md"

            # Parse YAML
            try:
                data = yaml.safe_load(frontmatter)
            except yaml.YAMLError as e:
                pytest.fail(f"Invalid YAML in {skill_name}/SKILL.md: {e}")

            assert isinstance(data, dict), f"Frontmatter must be a dict in {skill_name}"

    def test_all_skills_have_required_fields(
        self, plugin_root: Path, expected_skills: list[str]
    ) -> None:
        """Each skill must have name and description in frontmatter."""
        skills_dir = plugin_root / "skills"

        for skill_name in expected_skills:
            skill_file = skills_dir / skill_name / "SKILL.md"
            content = skill_file.read_text()
            frontmatter = self._extract_frontmatter(content)
            assert frontmatter is not None, f"No frontmatter in {skill_name}"
            data = yaml.safe_load(frontmatter)

            assert "name" in data, f"Missing 'name' in {skill_name}/SKILL.md"
            assert "description" in data, (
                f"Missing 'description' in {skill_name}/SKILL.md"
            )
            assert len(data["name"]) > 0, f"Empty name in {skill_name}"
            assert len(data["description"]) > 0, f"Empty description in {skill_name}"

    def test_all_skills_have_content(
        self, plugin_root: Path, expected_skills: list[str]
    ) -> None:
        """Each skill must have non-empty content after frontmatter."""
        skills_dir = plugin_root / "skills"

        for skill_name in expected_skills:
            skill_file = skills_dir / skill_name / "SKILL.md"
            content = skill_file.read_text()

            # Remove frontmatter and check content
            body = self._extract_body(content)
            assert len(body.strip()) > 100, (
                f"Content too short in {skill_name}/SKILL.md"
            )

    def test_skill_names_match_directory(
        self, plugin_root: Path, expected_skills: list[str]
    ) -> None:
        """Skill name in frontmatter should match directory name."""
        skills_dir = plugin_root / "skills"

        for skill_name in expected_skills:
            skill_file = skills_dir / skill_name / "SKILL.md"
            content = skill_file.read_text()
            frontmatter = self._extract_frontmatter(content)
            assert frontmatter is not None, f"No frontmatter in {skill_name}"
            data = yaml.safe_load(frontmatter)

            assert data["name"] == skill_name, (
                f"Name mismatch: frontmatter has '{data['name']}' "
                f"but directory is '{skill_name}'"
            )

    def _extract_frontmatter(self, content: str) -> str | None:
        """Extract YAML frontmatter from markdown content."""
        match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
        return match.group(1) if match else None

    def _extract_body(self, content: str) -> str:
        """Extract body content after frontmatter."""
        match = re.match(r"^---\s*\n.*?\n---\s*\n(.*)$", content, re.DOTALL)
        return match.group(1) if match else content
