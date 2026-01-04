"""
Pytest configuration and fixtures for handoff plugin testing.
"""

import os
import sys
import pytest
from pathlib import Path

# Add plugin root to path
PLUGIN_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PLUGIN_ROOT))


@pytest.fixture(scope="session")
def plugin_path():
    """Path to the handoff plugin directory."""
    return PLUGIN_ROOT


@pytest.fixture(scope="session")
def plugin_name():
    """Plugin name for testing."""
    return "handoff"


@pytest.fixture
def test_artifacts_dir(tmp_path):
    """Temporary directory for test artifacts."""
    return tmp_path


@pytest.fixture
def mock_conversation_history():
    """Mock conversation history for testing context extraction."""
    return [
        {
            "role": "user",
            "content": "Build a user authentication system with OAuth"
        },
        {
            "role": "assistant",
            "content": "I'll help you build OAuth authentication. Let me design the architecture..."
        },
        {
            "role": "user",
            "content": "Include JWT tokens and refresh mechanisms"
        },
        {
            "role": "assistant",
            "content": """
Here's the authentication architecture:
1. OAuth2 flow for initial authentication
2. JWT tokens for API access
3. Refresh token mechanism
4. Token expiration and revocation

Key files:
- src/auth/oauth.ts
- src/auth/jwt.ts
- src/middleware/auth.ts
- db/schema.sql
            """
        }
    ]


@pytest.fixture
def plugin_options():
    """Standard plugin options for SDK testing."""
    # Check for API key
    if "ANTHROPIC_API_KEY" not in os.environ:
        pytest.skip("ANTHROPIC_API_KEY environment variable not set")

    try:
        from claude_agent_sdk import ClaudeAgentOptions
    except ImportError:
        pytest.skip("Claude Agent SDK not installed. Install with: pip install claude-agent-sdk")

    return ClaudeAgentOptions(
        plugins=[{"type": "local", "path": str(PLUGIN_ROOT)}],
        setting_sources=["user", "project"],
        permission_mode="bypassPermissions",
        allowed_tools=["Read", "Write", "Bash", "Glob", "Grep", "WebFetch"]
    )


@pytest.fixture(autouse=True)
def ensure_api_key_available():
    """Ensure API key is available for all tests."""
    if "ANTHROPIC_API_KEY" not in os.environ:
        if "CLAUDE_API_KEY" in os.environ:
            os.environ["ANTHROPIC_API_KEY"] = os.environ["CLAUDE_API_KEY"]
        else:
            # Check if running in CI with secrets
            if "GITHUB_ACTIONS" not in os.environ:
                pytest.skip("API key not configured")
