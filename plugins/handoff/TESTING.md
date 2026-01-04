# Handoff Plugin Testing Guide

Complete automated testing setup for the handoff Claude Code plugin. No manual testing required!

## Quick Start

### Run All Tests

```bash
cd plugins/handoff
./tests/run_tests.sh all
```

### Run Specific Test Suites

```bash
# Structure validation only
./tests/run_tests.sh structure

# Unit tests
./tests/run_tests.sh unit

# Integration tests (requires API key)
./tests/run_tests.sh integration

# Shell tests (requires BATS)
./tests/run_tests.sh shell

# Coverage report
./tests/run_tests.sh coverage

# Check dependencies
./tests/run_tests.sh deps
```

## Test Architecture

The handoff plugin uses a **three-layer testing strategy**:

### 1. Structure Tests (Unit)
**What**: Verify plugin files, configuration, and format
**Tool**: pytest
**Location**: `tests/test_plugin_structure.py`
**Coverage**:
- Plugin directory structure
- plugin.json validation
- Command file format
- Documentation completeness

**Run**:
```bash
pytest tests/test_plugin_structure.py -v
```

**Example Tests**:
```python
def test_plugin_json_exists()
def test_commands_directory_exists()
def test_handoff_command_has_frontmatter()
def test_readme_has_usage_section()
```

### 2. Integration Tests (SDK)
**What**: Test plugin functionality within Claude Code SDK
**Tool**: Python Claude Agent SDK + pytest
**Location**: `tests/test_integration_sdk.py`
**Coverage**:
- Plugin loading
- Slash command execution
- Context extraction
- Error handling
- Complete workflows

**Run**:
```bash
# Requires ANTHROPIC_API_KEY
export ANTHROPIC_API_KEY="sk-ant-..."
pytest tests/test_integration_sdk.py -v
```

**Example Tests**:
```python
async def test_plugin_loads_without_error()
async def test_handoff_command_accepts_goal()
async def test_handoff_extracts_context()
async def test_handoff_creates_memory_file()
```

**Requirements**:
```bash
pip install claude-agent-sdk pytest pytest-asyncio
```

### 3. Shell Tests (CLI)
**What**: Test plugin via Claude Code CLI interface
**Tool**: BATS (Bash Automated Testing System)
**Location**: `tests/test_plugin.bats`
**Coverage**:
- File structure
- JSON validation
- Command recognition
- Error handling
- CLI integration

**Run**:
```bash
# Requires BATS installed
bats tests/test_plugin.bats
```

**Example Tests**:
```bash
@test "plugin.json exists and is valid"
@test "handoff.md has YAML frontmatter"
@test "README.md has installation section"
@test "plugin loads with claude code"
```

**Requirements**:
```bash
# macOS
brew install bats-core

# Ubuntu/Debian
apt-get install bats

# Other
npm install -g bats
```

## Dependencies

### Required

```bash
# Python 3.10+
python3 --version

# pytest
pip install pytest pytest-asyncio
```

### Optional

```bash
# Claude Agent SDK (for SDK integration tests)
pip install claude-agent-sdk

# BATS (for shell tests)
brew install bats-core  # macOS
apt-get install bats    # Ubuntu

# Coverage reporting
pip install pytest-cov

# API key for integration tests
export ANTHROPIC_API_KEY="sk-ant-..."
```

### Quick Setup

```bash
# Install all test dependencies
cd plugins/handoff
pip install pytest pytest-asyncio pytest-cov claude-agent-sdk

# macOS: install BATS
brew install bats-core
```

## Running Tests

### All Tests

```bash
cd plugins/handoff
./tests/run_tests.sh all
```

**Output**:
```
========================================
Checking Dependencies
========================================
✓ Python 3 found: Python 3.11.7
✓ pytest found: pytest 7.4.3
✓ Claude Agent SDK found
✓ BATS found: bats 1.10.1
✓ API key configured

========================================
Validating Plugin Structure
========================================
✓ plugin.json is valid JSON
✓ commands/handoff.md exists
✓ README.md exists
...

========================================
Running Unit Tests
========================================
tests/test_plugin_structure.py::test_plugin_json_exists PASSED
tests/test_plugin_structure.py::test_commands_directory_exists PASSED
...

========================================
Test Summary
========================================
✅ All tests passed!
```

### Individual Test Files

```bash
# Unit tests only
pytest tests/test_plugin_structure.py -v

# Integration tests only
pytest tests/test_integration_sdk.py -v -s

# BATS tests only
bats tests/test_plugin.bats
```

### With Coverage

```bash
pytest tests/ --cov=. --cov-report=html --cov-report=term-missing
open htmlcov/index.html
```

### Specific Test

```bash
# Run one test
pytest tests/test_plugin_structure.py::TestPluginStructure::test_plugin_json_exists -v

# Run tests matching pattern
pytest tests/ -k "handoff_command" -v

# Run tests with asyncio only
pytest tests/ -m asyncio -v
```

### Watch Mode

```bash
# Automatically rerun tests on file changes
pip install pytest-watch
ptw tests/
```

## Test Structure

```
tests/
├── conftest.py                 # Pytest fixtures and configuration
├── test_plugin_structure.py    # Structure and format tests
├── test_integration_sdk.py     # SDK integration tests
├── test_plugin.bats           # Shell/CLI tests
├── run_tests.sh               # Test runner script
└── fixtures/                  # Test data (optional)
    ├── conversation.json
    └── sample_code.py
```

## Fixtures & Mock Data

### Using Mock Conversation History

```python
# From conftest.py fixture
@pytest.fixture
def mock_conversation_history():
    """Mock conversation history for testing context extraction."""
    return [
        {"role": "user", "content": "Build authentication"},
        {"role": "assistant", "content": "I'll design OAuth..."},
        ...
    ]

# Use in test
async def test_extraction(mock_conversation_history):
    # mock_conversation_history is available
    ...
```

### Creating Test Artifacts

```python
# Temporary directory for test files
def test_handoff_creates_memory_file(tmp_path):
    test_file = tmp_path / "test.py"
    test_file.write_text("def hello(): pass")
    # Use test_file in test
```

## CI/CD Integration

### GitHub Actions

Tests run automatically on:
- Push to `main` or `master`
- Pull requests to `main` or `master`
- Changes to `plugins/handoff/**`

**Workflow**: `.github/workflows/test-handoff-plugin.yml`

**Jobs**:
1. **validate-structure** — Validates plugin files and JSON
2. **python-tests** — Unit and integration tests (Python 3.10-3.12)
3. **shell-tests** — BATS tests
4. **coverage** — Generates coverage reports
5. **test-summary** — Comments results on PR

### View Results

In GitHub:
1. Go to Actions tab
2. Click workflow run
3. View job details
4. Download coverage report artifact

### Local CI/CD Simulation

```bash
# Simulate CI environment
export GITHUB_ACTIONS=true
./tests/run_tests.sh all
```

## Troubleshooting

### pytest not found

```bash
pip install pytest pytest-asyncio
```

### Claude Agent SDK errors

```bash
pip install --upgrade claude-agent-sdk
```

### BATS not found

```bash
# macOS
brew install bats-core

# Ubuntu
apt-get install bats

# Verify installation
bats --version
```

### API key errors

```bash
# Set your API key
export ANTHROPIC_API_KEY="sk-ant-..."

# Or add to ~/.zshrc or ~/.bashrc
echo 'export ANTHROPIC_API_KEY="sk-ant-..."' >> ~/.zshrc
source ~/.zshrc
```

### Async test issues

If you get "no running event loop" errors:

```bash
# Ensure pytest-asyncio is installed
pip install pytest-asyncio

# Verify in conftest.py
# asyncio_mode = auto should be set in pytest.ini
```

## Adding New Tests

### Unit Test

```python
# tests/test_plugin_structure.py
def test_new_feature():
    """Test description."""
    # Arrange
    plugin_path = Path("plugins/handoff")

    # Act
    result = check_something(plugin_path)

    # Assert
    assert result is True
```

### Integration Test

```python
# tests/test_integration_sdk.py
@pytest.mark.asyncio
async def test_new_sdk_feature(plugin_options):
    """Test description."""
    from claude_agent_sdk import query, AssistantMessage

    async for message in query(
        prompt="/handoff test",
        options=plugin_options
    ):
        if isinstance(message, AssistantMessage):
            # Verify something
            assert True
```

### Shell Test

```bash
# tests/test_plugin.bats
@test "new shell feature" {
    # Test implementation
    [ -f "$PLUGIN_DIR/some_file" ]
    grep -q "some_text" "$PLUGIN_DIR/file.md"
}
```

## Best Practices

### 1. Test Isolation
- Each test should be independent
- Use fixtures for setup/teardown
- Clean up temporary files

### 2. Descriptive Names
- Test names should explain what they verify
- Use `test_feature_behavior` pattern

### 3. Assertions
- Use clear assertion messages
- One assertion per test when possible
- Fail fast on first issue

### 4. Fixtures
- Use conftest.py for shared fixtures
- Fixture scope: function > class > module > session
- Don't modify shared fixtures

### 5. Performance
- Keep tests fast (< 1 second each)
- Use mocks for external API calls
- Skip expensive tests by default

## Performance Benchmarks

Expected test execution times:

| Suite | Time | Notes |
|-------|------|-------|
| Structure tests | < 1s | Fast, no API calls |
| Unit tests | 1-2s | File I/O only |
| Integration tests | 5-30s | Calls Claude API |
| Shell tests | 2-5s | CLI invocation |
| **Total** | **10-40s** | Depending on API |

## Monitoring & Reports

### Coverage Report

```bash
./tests/run_tests.sh coverage
open htmlcov/index.html
```

View:
- Line coverage by file
- Functions covered
- Uncovered lines
- Trends over time

### Test Metrics

```bash
# List all tests
pytest tests/ --collect-only

# Run with durations
pytest tests/ --durations=10

# Verbose output
pytest tests/ -vv
```

## Advanced Usage

### Parallel Testing

```bash
pip install pytest-xdist
pytest tests/ -n auto
```

### Repeat Tests

```bash
# Repeat each test 5 times
pytest tests/ --count=5

# Run until first failure
pytest tests/ --lf
```

### Profile Tests

```bash
pytest tests/ --profile
```

### Debug Specific Test

```bash
# Drop into debugger on failure
pytest tests/test_file.py -pdb

# Drop into debugger before running test
pytest tests/test_file.py --pdbcls=IPython.terminal.debugger:TerminalPdb
```

## Resources

- [pytest documentation](https://docs.pytest.org)
- [BATS testing](https://github.com/bats-core/bats-core)
- [Claude Agent SDK](https://platform.claude.com/docs/en/agent-sdk/overview)
- [GitHub Actions documentation](https://docs.github.com/en/actions)

## Support

For issues:
1. Check `troubleshooting` section above
2. Run `./tests/run_tests.sh deps` to verify setup
3. Review test output carefully
4. Open issue on GitHub with full test output
