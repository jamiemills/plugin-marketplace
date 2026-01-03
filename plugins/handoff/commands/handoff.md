---
description: Extract context from current thread and start a new focused session
argument-hint: <goal-description>
allowed-tools: [Read, Glob, Bash]
---

# Handoff Command

You are implementing the handoff feature for Claude Code. This command extracts relevant context from the current thread and prepares it for a new, focused session.

## User's Handoff Goal

The user wants to handoff to a new session with the following goal:

**Goal**: $ARGUMENTS

## Workflow

Follow these steps to complete the handoff:

### Step 1: Understand Current Context

First, gather information about the current conversation state:

1. Ask Claude (using thinking) to summarise the current thread based on what's visible in the conversation
2. Use the `/context` command to understand the current state of tokens and context
3. Identify the key files and decisions from the conversation

### Step 2: Extract Relevant Context using Haiku

Create a prompt for Haiku model to extract context relevant to the user's goal:

**Task for Haiku model:**
```
Based on this conversation and the stated goal, extract the minimal but sufficient context needed for a new session.

Stated Goal: $ARGUMENTS

From the current conversation, extract:
1. Key technical decisions and architecture choices
2. Current state of work (what's been done, what's in progress)
3. List of the most relevant files (max 10)
4. Critical code snippets or states
5. Any important configurations or setup steps

Format the output as structured markdown.
```

Invoke Haiku to extract this context. Ask Claude to formulate the extraction request and handle the model invocation.

### Step 3: Create Handoff Memory File

Based on Haiku's extraction, create a memory file to preserve context:

1. Generate filename: `.claude/handoff-memory.$(date '+%Y-%m-%d-%H-%M-%S').md`
2. Create the file with this structure:

```markdown
# Handoff Memory

**Created**: <timestamp>
**Goal**: $ARGUMENTS
**Source Thread**: <current session identifier if available>

## Extracted Context

### Key Decisions
<from Haiku extraction>

### Current State
<what's been completed, what's in progress>

### Relevant Files
<list of files with brief descriptions>

### Technical Details
<architecture decisions, configurations, dependencies>

### Next Steps to Consider
<suggestions for continuing work in new session>
```

3. Save this file to `.claude/handoff-memory.<date>.md` in the project root

### Step 4: Generate Handoff Prompt

Create a comprehensive prompt for the new session:

```markdown
# Handoff from Previous Session

**Goal**: $ARGUMENTS

A context extraction has been performed on the previous thread to help you start focused on your next objective.

## Quick Context Summary

Review the memory file created at `.claude/handoff-memory.<date>.md` for the full extracted context.

Key points:
- See "Key Decisions" section for important architectural choices
- See "Current State" section to understand what's been done
- See "Relevant Files" section for files to review
- See "Technical Details" for configuration and setup information

## Files to Review

These are the most relevant files to your goal:
- [files from extraction]

## Next Action

Your goal is: **$ARGUMENTS**

Review the context above, then proceed with your work. The memory file contains all extracted context from the previous thread.
```

### Step 5: Present Handoff Draft

1. Display the generated handoff memory file so the user can see what was extracted
2. Display the handoff prompt for the new session
3. Ask the user to confirm they want to proceed with this context
4. Explain that once confirmed, a new session will start with this prompt

### Step 6: Completion

Once the user approves:
1. Confirm that handoff memory file has been created
2. Provide instructions for starting the new session with the handoff prompt
3. Note the memory file location for reference

## Important Notes

- The handoff process is transparent—user can review all extracted context before proceeding
- Memory files are persistent and can be referenced across sessions
- The Haiku extraction is optimised for speed and cost while maintaining quality
- Keep extracted context focused on the stated goal to avoid context window bloat in the new session

## Example Usage

```
/handoff now implement the user profile component using the auth system we just built
```

This would:
1. Extract context about the auth implementation
2. Create a memory file with that context
3. Generate a prompt focused on implementing the user profile component
4. Present everything for user review before starting new session
