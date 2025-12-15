# Agent Skills Marketplace

A collection of Claude Code agent skills and plugins for enhanced AI capabilities.

## Installation

Add this marketplace to your Claude Code installation:

```bash
/plugin marketplace add jamiemills/agent-skills
```

Browse available plugins:

```bash
/plugin
```

## Available Plugins

### perplexity-cli

Query Perplexity.ai directly from the terminal. Provides structured JSON output with source references.

**Installation:**

```bash
/plugin install perplexity-cli@agent-skills
```

**Features:**
- Question answering with comprehensive source citations
- Structured JSON output for programmatic parsing
- Multiple output formats (plain, JSON, markdown)
- Stream responses in real-time
- Current information and recent events

**Setup:**

Before first use, authenticate with Perplexity:

```bash
perplexity-cli auth
```

See the [perplexity-cli plugin documentation](plugins/perplexity-cli/README.md) for detailed setup and usage instructions.

## Usage

Once installed, Claude Code will automatically invoke the relevant skill when you need:
- Current information or recent events
- Detailed explanations with source references
- Research topics with verified citations
- Structured data parsing in JSON format

## Contributing

This marketplace is maintained by Jamie Mills. For issues, questions, or suggestions, please open an issue on the [GitHub repository](https://github.com/jamiemills/agent-skills).

## License

MIT License - see [LICENSE](LICENSE) for details.
