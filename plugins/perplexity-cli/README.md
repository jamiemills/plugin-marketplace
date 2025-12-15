# Perplexity CLI Plugin for Claude Code

This plugin provides the perplexity-cli skill for Claude Code, enabling AI-powered question answering with Perplexity.ai directly from the terminal.

## Installation

### Via Marketplace

Add the plugin-marketplace and install the plugin:

```bash
# In Claude Code
/plugin marketplace add jamiemills/plugin-marketplace
/plugin install perplexity-cli@plugin-marketplace
```

### Direct Installation

You can also install directly from the repository:

```bash
/plugin marketplace add jamiemills/plugin-marketplace
/plugin install perplexity-cli@plugin-marketplace
```

## What's Included

This plugin provides the **perplexity-cli skill** which Claude Code will automatically invoke when you need:

- Current information or recent events
- Detailed explanations with source references
- Research topics with verified citations
- Structured data parsing in JSON format

## Prerequisites

Before using this plugin, you need to have `perplexity-cli` installed and configured.

### Installing perplexity-cli

```bash
# Install via npm
npm install -g perplexity-cli

# Or using your package manager of choice
```

### Authentication Setup

Authenticate with Perplexity.ai (one-time setup):

```bash
# Install Chrome for Testing
npx @puppeteer/browsers install chrome@stable

# Create shell alias (add to ~/.bashrc, ~/.zshrc, etc.)
alias chromefortesting='open ~/.local/bin/chrome/mac_arm-*/chrome-mac-arm64/Google\ Chrome\ for\ Testing.app --args "--remote-debugging-port=9222" "about:blank"'

# Terminal 1: Start Chrome
chromefortesting

# Terminal 2: Authenticate
perplexity-cli auth
```

### Verify Setup

Check that authentication succeeded:

```bash
perplexity-cli status
```

## Usage

Once installed and authenticated, Claude Code will automatically use the perplexity-cli skill when appropriate. You don't need to invoke it manually.

### Example Interactions

**User:** What are the latest developments in quantum computing?

**Claude:** Uses the perplexity-cli skill to fetch current information with source citations.

**User:** Can you research the main challenges in renewable energy and provide sources?

**Claude:** Automatically invokes perplexity-cli to get comprehensive answers with verified references.

## Features

### Structured JSON Output

The skill uses perplexity-cli's JSON output format for reliable parsing:

```json
{
  "format_version": "1.0",
  "answer": "Comprehensive answer text...",
  "references": [
    {
      "index": 1,
      "title": "Source Title",
      "url": "https://example.com",
      "snippet": "Relevant excerpt..."
    }
  ]
}
```

### Multiple Output Formats

The skill intelligently selects the appropriate format based on context:
- **JSON**: For programmatic parsing and structured data
- **Plain**: For clean text without formatting
- **Markdown**: For rich terminal output with citations

### Stream Support

For real-time responses, the skill can use streaming mode to show results as they arrive.

### Error Handling

The skill includes comprehensive error handling for:
- Authentication failures
- Rate limiting
- Network errors
- Token expiration

## Troubleshooting

### "Not authenticated" Error

Run the authentication setup:

```bash
perplexity-cli auth
```

### Token Expired

Re-authenticate with Perplexity:

```bash
perplexity-cli auth
```

### perplexity-cli Not Found

Ensure perplexity-cli is installed globally:

```bash
npm install -g perplexity-cli
```

### Debug Mode

Enable debug output for troubleshooting:

```bash
perplexity-cli --debug query "test question"
```

## Advanced Configuration

### Custom Style Prompts

Configure a consistent response style:

```bash
# Set style
perplexity-cli configure "be concise and technical"

# View current style
perplexity-cli view-style

# Remove style
perplexity-cli clear-style
```

### Custom Debug Port

If port 9222 is in use:

```bash
perplexity-cli auth --port 9223
```

## Security

- Token encrypted at rest using Fernet symmetric encryption
- Encryption key derived from system identifiers
- Token stored with restricted permissions (0600)
- No credentials displayed in logs

## Limitations

- Requires initial authentication with Chrome DevTools Protocol
- Rate limited by Perplexity.ai
- Token bound to your machine (not portable)
- Requires active internet connection

## Documentation

For complete documentation on perplexity-cli commands and options, see:
- [SKILL.md](skills/perplexity-cli/SKILL.md) - Complete skill documentation
- [perplexity-cli GitHub](https://github.com/jamiemills/perplexity-cli) - Full CLI documentation

## Version History

See [CHANGELOG.md](../../CHANGELOG.md) for version history and updates.

## License

MIT License - see [LICENSE](../../LICENSE) for details.

## Support

For issues, questions, or feature requests:
- Open an issue on [GitHub](https://github.com/jamiemills/plugin-marketplace/issues)
- Check the [troubleshooting section](#troubleshooting) above
- Review the [complete skill documentation](skills/perplexity-cli/SKILL.md)
