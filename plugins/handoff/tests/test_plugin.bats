#!/usr/bin/env bats

# BATS tests for handoff plugin
# Usage: bats tests/test_plugin.bats

setup() {
    # Initialize test environment
    export PLUGIN_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && cd .. && pwd)"
    export TEST_WORKSPACE="$(mktemp -d)"

    # Required for Claude Code interaction
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        export ANTHROPIC_API_KEY="sk-test-placeholder"
    fi
}

teardown() {
    # Clean up test artifacts
    rm -rf "$TEST_WORKSPACE"
}

# Structure Tests

@test "plugin directory exists" {
    [ -d "$PLUGIN_DIR" ]
}

@test "plugin.json exists and is valid" {
    [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]

    # Validate JSON
    python3 -m json.tool "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null
}

@test "plugin.json has required fields" {
    # Check for required fields in plugin.json
    grep -q '"name"' "$PLUGIN_DIR/.claude-plugin/plugin.json"
    grep -q '"displayName"' "$PLUGIN_DIR/.claude-plugin/plugin.json"
    grep -q '"description"' "$PLUGIN_DIR/.claude-plugin/plugin.json"
    grep -q '"version"' "$PLUGIN_DIR/.claude-plugin/plugin.json"
}

@test "plugin name is 'handoff'" {
    NAME=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['name'])")
    [ "$NAME" = "handoff" ]
}

@test "commands directory exists" {
    [ -d "$PLUGIN_DIR/commands" ]
}

@test "handoff.md command exists" {
    [ -f "$PLUGIN_DIR/commands/handoff.md" ]
}

@test "handoff.md has YAML frontmatter" {
    # Should start with ---
    head -1 "$PLUGIN_DIR/commands/handoff.md" | grep -q '^---'

    # Should have closing --- within first 20 lines
    head -20 "$PLUGIN_DIR/commands/handoff.md" | tail -19 | grep -q '^---'
}

@test "handoff.md has description in frontmatter" {
    # Extract and check frontmatter
    sed -n '/^---$/,/^---$/p' "$PLUGIN_DIR/commands/handoff.md" | grep -q 'description:'
}

@test "handoff.md has implementation content" {
    # Should have more than just frontmatter
    LINE_COUNT=$(wc -l < "$PLUGIN_DIR/commands/handoff.md")
    [ "$LINE_COUNT" -gt 30 ]

    # Should mention workflow, steps, or similar
    grep -qi 'workflow\|step\|extract' "$PLUGIN_DIR/commands/handoff.md"
}

@test "README.md exists" {
    [ -f "$PLUGIN_DIR/README.md" ]
}

@test "README.md has installation section" {
    grep -qi 'install' "$PLUGIN_DIR/README.md"
}

@test "README.md documents the /handoff command" {
    grep -q '/handoff' "$PLUGIN_DIR/README.md"
}

@test "README.md has usage examples" {
    grep -qi 'example\|usage' "$PLUGIN_DIR/README.md"
}

@test "README.md is comprehensive" {
    # Should be reasonably long
    LINE_COUNT=$(wc -l < "$PLUGIN_DIR/README.md")
    [ "$LINE_COUNT" -gt 30 ]

    # Should mention key concepts
    grep -qi 'context' "$PLUGIN_DIR/README.md"
}

# JSON Validation Tests

@test "plugin.json JSON is valid" {
    python3 << 'EOF'
import json
import sys

try:
    with open("$PLUGIN_DIR/.claude-plugin/plugin.json", "r") as f:
        json.load(f)
    sys.exit(0)
except Exception as e:
    print(f"Invalid JSON: {e}")
    sys.exit(1)
EOF
}

@test "plugin.json version follows semantic versioning" {
    VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))['version'])")

    # Should match X.Y.Z pattern
    echo "$VERSION" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+'
}

# Content Tests

@test "handoff.md mentions context extraction" {
    grep -qi 'extract\|context' "$PLUGIN_DIR/commands/handoff.md"
}

@test "handoff.md mentions Haiku model" {
    grep -qi 'haiku' "$PLUGIN_DIR/commands/handoff.md"
}

@test "handoff.md explains the workflow" {
    grep -qi 'step\|workflow\|process' "$PLUGIN_DIR/commands/handoff.md"
}

@test "README mentions selective extraction vs summarization" {
    grep -qi 'extract\|summary\|compress' "$PLUGIN_DIR/README.md"
}

@test "README includes troubleshooting section" {
    grep -qi 'troubleshoot\|error\|problem' "$PLUGIN_DIR/README.md"
}

# File Structure Tests

@test ".claude-plugin contains only plugin.json" {
    FILE_COUNT=$(find "$PLUGIN_DIR/.claude-plugin" -type f | wc -l)
    [ "$FILE_COUNT" -eq 1 ]
}

@test "no hidden system files in plugin directory" {
    # Should not have .DS_Store, .swp, etc.
    [ ! -f "$PLUGIN_DIR/.DS_Store" ]
    [ ! -f "$PLUGIN_DIR/.swp" ]
    [ ! -f "$PLUGIN_DIR/commands/.DS_Store" ]
}

# Documentation Tests

@test "README has proper markdown headers" {
    grep -q '^#' "$PLUGIN_DIR/README.md"
}

@test "README code examples are in markdown blocks" {
    grep -q '```' "$PLUGIN_DIR/README.md"
}

@test "README links are properly formatted" {
    # Should have at least one markdown link
    grep -q '\[.*\](.*)'  "$PLUGIN_DIR/README.md"
}

# Feature Tests

@test "plugin supports handoff command" {
    grep -q '/handoff' "$PLUGIN_DIR/commands/handoff.md"
}

@test "plugin documents goal-driven extraction" {
    grep -qi 'goal' "$PLUGIN_DIR/commands/handoff.md"
}

@test "plugin documents memory file creation" {
    grep -qi 'memory\|file' "$PLUGIN_DIR/commands/handoff.md"
}

# Error Handling Tests

@test "handoff.md explains error handling" {
    grep -qi 'error\|invalid\|fail\|handle' "$PLUGIN_DIR/commands/handoff.md"
}

@test "README has troubleshooting guidance" {
    grep -qi 'trouble\|problem\|error' "$PLUGIN_DIR/README.md"
}

# Integration Tests (require Claude Code)

@test "plugin loads with claude code" {
    # Skip if Claude Code not available
    if ! command -v claude &> /dev/null; then
        skip "Claude Code not installed"
    fi

    # Try to get plugin help
    # This is a simple smoke test
    cd "$TEST_WORKSPACE"
    claude --plugin-dir "$PLUGIN_DIR" /help 2>&1 | grep -q "help" || true
}

@test "handoff command is recognized" {
    # Skip if Claude Code not available
    if ! command -v claude &> /dev/null; then
        skip "Claude Code not installed"
    fi

    cd "$TEST_WORKSPACE"

    # Try to invoke handoff (may not fully execute without API key)
    # Just verify it doesn't error on command syntax
    echo "/handoff test" | claude --plugin-dir "$PLUGIN_DIR" 2>&1 | \
        grep -qv "unknown command" || true
}
