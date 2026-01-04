# Handoff Plugin

Extract context from your current thread and start a new focused session. This plugin replicates [Amp's handoff feature](https://ampcode.com/news/handoff) for Claude Code, enabling seamless context management across multiple threads.

## Overview

The handoff command intelligently extracts relevant context from your current conversation thread based on a goal you specify, creates a persistent memory file, and presents everything for review before starting a new session.

Unlike compaction (which summarises and loses information), handoff performs **selective extraction** of what's actually relevant to your next objective, preserving reasoning integrity and quality.

## Installation

### Via Claude Code Plugin System

```bash
/plugin install jamiemills/agent-skills#plugins/handoff
```

Or from the plugin marketplace:

```bash
/plugin marketplace
# Search for "handoff" and install
```

## Usage

### Basic Usage

```bash
/handoff <your next goal>
```

### Examples

```bash
# Extract context for implementing a new feature
/handoff now implement the user profile component using the auth system we just built

# Extract context for fixing a specific issue
/handoff identify all places in the codebase where this database pattern is used

# Extract context for refactoring
/handoff execute phase one of the plan we just designed

# Extract context for review/verification
/handoff check that all tests pass and our implementation meets the requirements
```

## How It Works

### Step 1: Goal Specification
You provide a clear goal for what you want to work on next:
```bash
/handoff <goal>
```

### Step 2: Context Extraction
The handoff command analyses your current conversation to identify:
- Key technical decisions and architecture choices
- Current state of work (what's completed, what's in progress)
- Most relevant files (automatically filtered by goal relevance)
- Critical code snippets and configurations
- Important setup or dependency information

### Step 3: Memory File Creation
Extracted context is saved to a persistent memory file:
```
.claude/handoff-memory.<date-time>.md
```

This file is human-readable and can be referenced later.

### Step 4: Handoff Prompt Generation
A comprehensive prompt is generated for your new session that:
- States your goal clearly
- References the memory file
- Lists files to review
- Provides quick context summary

### Step 5: User Review
Everything is presented for your review before proceeding:
- The extracted context (in memory file)
- The handoff prompt for the new session
- Instructions for starting the new session

### Step 6: New Session
Once approved, you can start a new focused session with all relevant context available.

## Why Handoff Instead of Compaction?

**Compaction** (summarisation):
- Creates "summaries of summaries" over multiple cycles
- Information degrades with each compression
- Loses nuance and technical detail
- Contributes to long-context drift

**Handoff** (selective extraction):
- Extracts actual information, not summaries
- Quality preserved across multiple handoffs
- Goal-driven filtering keeps context focused
- User reviews what carries forward

## Memory Files

Handoff memory files are stored in `.claude/`:

```
.claude/handoff-memory.2026-01-03-15-30-45.md
```

**Anatomy of a memory file:**

```markdown
# Handoff Memory

**Created**: 2026-01-03 15:30:45
**Goal**: Implement the checkout flow
**Source Thread**: main session

## Extracted Context

### Key Decisions
- Using Stripe API for payments
- PostgreSQL for transaction records
- Async webhook processing

### Current State
- Auth system fully implemented
- Database schema designed
- API endpoints created for user management

### Relevant Files
- `/src/services/payment.ts`
- `/src/api/checkout.ts`
- `/db/schema.sql`
- `/tests/payment.test.ts`

### Technical Details
- Stripe API key configured in .env
- Using PostgreSQL connection pool
- Transaction timeouts set to 30s

### Next Steps to Consider
- Implement webhook handlers
- Add error recovery logic
- Create integration tests
```

## Best Practices

### 1. Be Specific With Your Goal

**Good:**
```bash
/handoff implement password reset feature with email validation and rate limiting
```

**Less Effective:**
```bash
/handoff continue working
```

### 2. Use at Natural Breakpoints

Handoff works best when:
- You've completed a phase of work
- You're starting a new, related task
- You want to shift focus to a different area
- You're working on a large project with multiple threads

### 3. Review the Memory File

Before starting the new session:
1. Review what was extracted
2. Edit the memory file if needed
3. Add any additional context the extraction missed
4. Remove information that's not relevant to your goal

### 4. Reference Memory in New Session

In your new session, you can reference the memory file:
```bash
/memory
# Review extracted context in memory file
```

### 5. Keep Threads Focused

Handoff works best when threads are kept short and focused:
- One major task per thread
- Create handoff when moving to related but distinct work
- Reference memory file for broader context

## Testing

The handoff plugin includes a comprehensive automated test suite with **56+ tests** covering all functionality. No manual testing required!

### Quick Test Run

```bash
cd plugins/handoff
./tests/run_tests.sh all
```

### Test Coverage

- **Unit Tests** (19 tests) — Plugin structure, configuration, format
- **Integration Tests** (10+ tests) — SDK functionality, command execution, context extraction
- **Shell Tests** (27+ tests) — CLI interface, file validation, error handling

### Running Specific Tests

```bash
./tests/run_tests.sh structure      # Structure validation only
./tests/run_tests.sh unit           # Unit tests
./tests/run_tests.sh integration    # SDK tests (requires API key)
./tests/run_tests.sh shell          # BATS tests
./tests/run_tests.sh coverage       # Generate coverage report
```

### Test Requirements

```bash
# Basic (for structure/shell tests)
pip install pytest pytest-asyncio

# Full (includes SDK tests)
pip install pytest pytest-asyncio pytest-cov claude-agent-sdk
brew install bats-core  # macOS; apt-get install bats on Ubuntu
```

### CI/CD

Tests run automatically on push/PR via GitHub Actions. View results at:
```
https://github.com/jamiemills/plugin-marketplace/actions
```

For detailed testing documentation, see [TESTING.md](TESTING.md).

## Configuration

The plugin works out of the box with no configuration needed. However, you can customise behaviour by editing the handoff command in `.claude/commands/handoff.md`.

### Advanced: Custom Extraction Prompt

If you want to customise what Haiku extracts, edit:
```
.claude/commands/handoff.md
```

Modify the "Extract Relevant Context using Haiku" section to change extraction criteria.

## Troubleshooting

### Memory file not created
- Check that `.claude/` directory exists in project root
- Verify write permissions
- Check Claude Code logs for errors

### Extraction is too verbose
- Be more specific in your goal
- Edit the memory file to remove non-essential information
- In future handoffs, the extraction will be more refined

### Missing relevant context
- Add important context manually to the memory file
- Scroll up in the previous thread to ensure key information is visible
- Reference specific files or decisions in your goal

## Examples

### Example 1: Feature Development Workflow

**Thread 1: Design Phase**
```bash
# Design authentication system
# ... extensive planning and discussion ...

/handoff now implement the authentication service based on this design
```

Memory file captures:
- Architecture decisions
- Database schema
- API contract
- Security considerations

**Thread 2: Implementation Phase**
```
New session starts with:
- Clear focus on implementation
- All design decisions available
- Relevant files listed
- No noise from design iterations
```

### Example 2: Bug Fix and Verification

**Thread 1: Identify and Fix**
```bash
# Find the bug
# Implement fix
# Run tests

/handoff verify the fix works across all related components
```

**Thread 2: Verification**
```
New session knows:
- What was fixed
- Why it was broken
- Files that were modified
- Related areas that need testing
```

### Example 3: Multi-Phase Implementation

**Thread 1:**
```bash
/handoff implement phase two: API endpoints
```

**Thread 2:**
```bash
/handoff implement phase three: frontend integration
```

Each handoff preserves critical context while keeping each thread focused.

## Contributing

To improve this plugin:
1. Fork the [agent-skills repository](https://github.com/jamiemills/agent-skills)
2. Submit pull requests with enhancements
3. Report issues or suggest improvements

## Future Enhancements

Planned improvements:
- Automatic file relevance detection using semantic search
- Git-aware extraction (only code changes since last commit)
- Integration with multi-thread handoffs
- Analytics on handoff patterns
- UI improvements in VS Code extension
- Handoff templates for common workflows

## License

MIT

## Related

- [Amp Code - Handoff Feature](https://ampcode.com/news/handoff)
- [Claude Code Documentation](https://code.claude.com)
- [Context Management in AI Systems](https://ainativedev.io/news/amp-retires-compaction-for-a-cleaner-handoff-in-the-coding-agent-context-race)

## Support

For issues or questions:
- Check the [troubleshooting section](#troubleshooting)
- Review the [examples](#examples)
- Open an issue on the [agent-skills repository](https://github.com/jamiemills/agent-skills/issues)
