"""
Unit tests for handoff plugin structure and configuration.
"""

import pytest
import json
from pathlib import Path


class TestPluginStructure:
    """Test plugin directory structure and files."""

    def test_plugin_json_exists(self, plugin_path):
        """Verify plugin.json exists."""
        plugin_json = plugin_path / ".claude-plugin" / "plugin.json"
        assert plugin_json.exists(), "plugin.json not found"
        assert plugin_json.is_file(), "plugin.json is not a file"

    def test_plugin_json_valid(self, plugin_path):
        """Verify plugin.json is valid JSON."""
        plugin_json = plugin_path / ".claude-plugin" / "plugin.json"
        content = plugin_json.read_text()

        data = json.loads(content)
        assert isinstance(data, dict), "plugin.json should be an object"

    def test_plugin_json_required_fields(self, plugin_path):
        """Verify plugin.json has all required fields."""
        plugin_json = plugin_path / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())

        required_fields = ["name", "displayName", "description", "version"]
        for field in required_fields:
            assert field in data, f"Missing required field: {field}"
            assert data[field], f"Field {field} is empty"

    def test_plugin_json_metadata(self, plugin_path):
        """Verify plugin.json has correct metadata."""
        plugin_json = plugin_path / ".claude-plugin" / "plugin.json"
        data = json.loads(plugin_json.read_text())

        # Verify name
        assert data["name"] == "handoff", "Plugin name should be 'handoff'"

        # Verify description mentions context
        assert "context" in data["description"].lower(), "Description should mention context"

        # Verify version is semantic
        version = data["version"]
        parts = version.split(".")
        assert len(parts) >= 3, "Version should follow semantic versioning"

    def test_commands_directory_exists(self, plugin_path):
        """Verify commands directory exists."""
        commands_dir = plugin_path / "commands"
        assert commands_dir.exists(), "commands directory not found"
        assert commands_dir.is_dir(), "commands should be a directory"

    def test_handoff_command_exists(self, plugin_path):
        """Verify handoff.md command file exists."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        assert handoff_cmd.exists(), "handoff.md command not found"
        assert handoff_cmd.is_file(), "handoff.md should be a file"

    def test_handoff_command_has_frontmatter(self, plugin_path):
        """Verify handoff command has YAML frontmatter."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        content = handoff_cmd.read_text()

        # Should start and contain frontmatter delimiters
        assert content.startswith("---"), "Command should start with ---"
        assert content.count("---") >= 2, "Should have opening and closing ---"

        # Extract frontmatter
        parts = content.split("---", 2)
        assert len(parts) >= 3, "Should have frontmatter section"

        frontmatter = parts[1]
        assert "description:" in frontmatter, "Should have description"
        assert "handoff" in frontmatter.lower() or "context" in frontmatter.lower(), \
            "Description should mention handoff or context"

    def test_handoff_command_has_instructions(self, plugin_path):
        """Verify handoff command has implementation instructions."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        content = handoff_cmd.read_text()

        # Should have workflow steps
        assert "workflow" in content.lower() or "step" in content.lower(), \
            "Should have workflow or steps"

        # Should mention context extraction
        assert "extract" in content.lower() or "context" in content.lower(), \
            "Should mention context extraction"

    def test_readme_exists(self, plugin_path):
        """Verify README.md exists."""
        readme = plugin_path / "README.md"
        assert readme.exists(), "README.md not found"
        assert readme.is_file(), "README.md should be a file"

    def test_readme_has_installation_section(self, plugin_path):
        """Verify README has installation instructions."""
        readme = plugin_path / "README.md"
        content = readme.read_text()

        assert "install" in content.lower(), "Should have installation section"
        assert "/plugin" in content or "install" in content.lower(), \
            "Should mention how to install"

    def test_readme_has_usage_section(self, plugin_path):
        """Verify README has usage section."""
        readme = plugin_path / "README.md"
        content = readme.read_text()

        assert "usage" in content.lower() or "example" in content.lower(), \
            "Should have usage or examples section"
        assert "/handoff" in content, "Should mention /handoff command"

    def test_readme_has_documentation(self, plugin_path):
        """Verify README is comprehensive."""
        readme = plugin_path / "README.md"
        content = readme.read_text()

        # Should explain what it does
        assert "context" in content.lower(), "Should explain context management"
        assert "extraction" in content.lower() or "extract" in content.lower(), \
            "Should mention extraction"

        # Should have reasonable length
        assert len(content) > 1000, "README should be comprehensive (>1000 chars)"

    def test_no_extra_files_in_plugin_metadata(self, plugin_path):
        """Verify only plugin.json exists in .claude-plugin."""
        plugin_metadata_dir = plugin_path / ".claude-plugin"

        files = list(plugin_metadata_dir.glob("*"))
        assert len(files) == 1, ".claude-plugin should only contain plugin.json"
        assert files[0].name == "plugin.json", "Only file should be plugin.json"


class TestCommandFormat:
    """Test slash command formatting."""

    def test_handoff_command_markdown_valid(self, plugin_path):
        """Verify handoff command is valid markdown."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        content = handoff_cmd.read_text()

        # Should have headers
        assert "#" in content, "Should have markdown headers"

        # Should have code blocks or structured text
        assert "```" in content or "-" in content or "*" in content, \
            "Should have structured content"

    def test_command_frontmatter_description(self, plugin_path):
        """Verify command has proper description."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        content = handoff_cmd.read_text()

        # Extract frontmatter
        parts = content.split("---", 2)
        frontmatter = parts[1]

        # Extract description
        for line in frontmatter.split("\n"):
            if "description:" in line:
                description = line.split(":", 1)[1].strip()

                # Should be meaningful
                assert len(description) > 10, "Description too short"
                assert "context" in description.lower() or "handoff" in description.lower(), \
                    "Description should mention context or handoff"
                break

    def test_command_frontmatter_argument_hint(self, plugin_path):
        """Verify command has argument hint if needed."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        content = handoff_cmd.read_text()

        parts = content.split("---", 2)
        frontmatter = parts[1]

        # May have argument-hint
        if "argument-hint:" in frontmatter:
            for line in frontmatter.split("\n"):
                if "argument-hint:" in line:
                    hint = line.split(":", 1)[1].strip()
                    assert len(hint) > 0, "Argument hint should not be empty"

    def test_command_allowed_tools(self, plugin_path):
        """Verify command declares required tools."""
        handoff_cmd = plugin_path / "commands" / "handoff.md"
        content = handoff_cmd.read_text()

        parts = content.split("---", 2)
        frontmatter = parts[1]

        # Should have allowed-tools if it uses them
        if "allowed-tools:" in frontmatter:
            # Tools should be valid
            for line in frontmatter.split("\n"):
                if "allowed-tools:" in line:
                    tools_str = line.split(":", 1)[1].strip()
                    # Should be a list
                    assert "[" in tools_str and "]" in tools_str, \
                        "allowed-tools should be a list"
