# Plugin Marketplace

A collection of Claude Code agent skills and plugins for enhanced AI capabilities.

## What's Included

| Item | Type | Version | Purpose |
|------|------|---------|---------|
| handoff | Plugin | v0.1.0 | Context extraction and intelligent session handoff |
| managing-todos | Skill | Active | Task management with git-synced todo lists |
| perplexity-cli | Plugin | v1.0.0 | Query Perplexity.ai with source citations |

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

### managing-todos

Manage task lists in a local git-synced repository with checkbox formatting. Perfect for tracking work items, daily tasks, and project planning.

**Features:**
- Checkbox-based task management (`[ ]` unchecked, `[x]` completed)
- Daily todo files with automatic date handling (YYYY.MM.DD.txt format)
- Flexible date specifications ("tomorrow", "next Friday", "in 3 days", etc.)
- Automatic git synchronisation on every change
- Completed todos preserved in files (never deleted)
- Support for uncertain dates using `later.txt`

**Usage:**

Claude Code automatically invokes managing-todos when managing your task list. Examples:

```
Add a todo for tomorrow: "Create unit tests for the auth module"
Mark as complete: "Buy groceries"
Move to next week: "Refactor the database schema"
View todos: "Show my tasks for Friday"
```

**Workflow Examples:**
- Add today: "Add a task" → added to today's date file
- Add specific date: "Add 'Review design' for next Monday" → added to 2026.01.06.txt
- Mark complete: "Done with the database migration" → marks checkbox as `[x]`
- Move todo: "Reschedule 'Team meeting prep' to Thursday" → updates file and date
- Uncertain dates: "Learn Rust later" → added to `later.txt` for future scheduling

See the [managing-todos skill documentation](plugins/managing-todos/SKILL.md) for complete workflows and detailed instructions.

---

### perplexity-cli

Query Perplexity.ai directly from the terminal. Provides structured JSON output with source references.

**Installation:**

```bash
/plugin install jamiemills/plugin-marketplace#plugins/perplexity-cli
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

**Task Management:**
- Add, update, or schedule todos
- Track work items and daily tasks
- Manage project planning and task organisation

**Research & Information:**
- Current information or recent events
- Detailed explanations with source references
- Research topics with verified citations
- Structured data parsing in JSON format

**Session Workflow:**
- Extract context and hand off to focused new sessions
- Preserve important decisions and findings
- Continue complex work across sessions

## Contributing

This marketplace is maintained by Jamie Mills. For issues, questions, or suggestions, please open an issue on the [GitHub repository](https://github.com/jamiemills/plugin-marketplace).

## License

MIT License - see [LICENSE](LICENSE) for details.
