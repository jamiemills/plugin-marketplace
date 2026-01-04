# Plugin Marketplace

A collection of Claude Code agent skills and plugins for enhanced AI capabilities.

## Installation

Add this marketplace to your Claude Code installation:

```bash
/plugin marketplace add jamiemills/plugin-marketplace
```

Browse available plugins:

```bash
/plugin
```

## Available Plugins

### handoff

Extract context from your current thread and start a new focused session. Intelligently replicates [Amp's handoff feature](https://ampcode.com/news/handoff) for Claude Code.

**Installation:**

```bash
/plugin install jamiemills/plugin-marketplace#plugins/handoff
```

**Features:**
- Goal-driven context extraction using Haiku model
- Selective extraction (not lossy summarisation)
- Persistent memory files for context preservation
- User-reviewed handoff prompts before new session
- Automatic file and decision identification
- Complete workflow documentation

**Usage:**

```bash
/handoff <your next goal>
```

**Examples:**

```bash
/handoff now implement the user profile component using the auth system we just built
/handoff identify all places in the codebase where this pattern is used
/handoff verify the fix works across all related components
```

**Testing:**

The plugin includes 56+ automated tests. Run locally:

```bash
cd plugins/handoff
./tests/run_tests.sh all
```

See the [handoff plugin documentation](plugins/handoff/README.md) and [testing guide](plugins/handoff/TESTING.md) for detailed information.

---

### perplexity-cli

Query Perplexity.ai directly from the terminal. Provides structured JSON output with source references.

**Installation:**

```bash
/plugin install perplexity-cli@plugin-marketplace
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

This marketplace is maintained by Jamie Mills. For issues, questions, or suggestions, please open an issue on the [GitHub repository](https://github.com/jamiemills/plugin-marketplace).

## License

MIT License - see [LICENSE](LICENSE) for details.
