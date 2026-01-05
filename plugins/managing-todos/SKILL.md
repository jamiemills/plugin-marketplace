---
name: managing-todos
description: Manages personal todo lists in the local to-dos repository with checkbox formatting. Adds, updates, deletes, and views todos in daily txt files, syncing with git. Use ONLY when user explicitly references their personal todos, todo list, or todo repo.
---

# Managing Todos Skill

Manages personal todo items stored in the local to-dos repository at `$HOME/projects/wip/to-dos/`.

## Scope & Usage

**This skill applies ONLY to personal todo management.** Use it when the user explicitly references:
- "my todos", "my todo list", "my todo repo", "my personal todos"
- "add to my todos", "move this to my todo list", "check my todos"

**Never use this skill for:**
- Conversation planning or task planning
- Amp thread task tracking or deliverables
- Action items or next steps discussed in conversations
- Project tasks, sprints, or team workflows
- Any context where you're tracking work FOR the conversation rather than the user's personal todo system

If unsure, ask: "Do you want to add this to your personal todo repo, or track it as a conversation task?"

## How It Works

- Todos are stored in daily txt files (named `YYYY.MM.DD.txt`) or in `later.txt` for uncertain dates
- Each todo item has a `[ ]` checkbox prefix (unchecked) or `[x]` (completed)
- Completed todos stay in the file with `[x]` prefix; they are never deleted or archived
- All todos must be single-line; no multi-line descriptions
- When todos are modified, the file is automatically committed and pushed to the repo
- Only one todo file exists per date; never create duplicate files for the same date
- `later.txt` holds todos with uncertain or unspecified dates

## File Format

Each line in the txt file is a todo item with checkbox:
```
[ ] Buy groceries
[ ] Fix bug in login
[x] Review PR #42
```

## Todo Identifiers

Every todo has a unique identifier based on the first 7 characters of a SHA-1 hash, appended at the end:
```
[ ] Buy groceries (2e9d244)
[x] Review PR #42 (a1b2c3d)
```

### ID Rules
- Always append the ID in parentheses at the end of the todo text
- If a todo doesn't have an ID, generate and add one
- Do not validate or check IDs; assume they are correct if listed
- Duplicates are acceptable; no action needed
- Do not ask the user about IDs unless they ask you to review or change them

## Core Rules

### When to Use This Skill
Only trigger this skill when the user explicitly uses language like:
- "add to my todos"
- "move this to my todo list"
- "show me my todos"
- "mark complete in my todos"
- "to my personal todo repo"

Do NOT trigger based on casual mentions of tasks or plans.

### Default Behavior
- When adding a todo without specifying a date, add it to **today's date**
- If the user explicitly says they're unsure of the date or adds to "later", add it to `later.txt`
- Always add the checkbox prefix `[ ]` to every new todo, regardless of what the user types
- The only valid file naming scheme is `YYYY.MM.DD.txt` (e.g., `2026.01.05.txt`) or `later.txt`
- There is exactly one todo file per date in the repo; `later.txt` is a single shared file for uncertain dates
- Todos must always be single-line text only; no multi-line descriptions

### Date Specification
When a user specifies a date, interpret it flexibly:
- **Day names**: "Monday", "Wednesday", etc. (next occurrence of that day)
- **Absolute dates**: "6 Jan", "January 6", "2026-01-06"
- **Relative dates**: "next week" (1 week from today), "tomorrow", "in 3 days"
- **Other natural language**: "this Friday", "next Tuesday", etc.

If unclear about intent, ask for clarification. However, prefer making reasonable assumptions and advising the user of assumptions made rather than asking for every ambiguous case.

### Past Dates
- Never add todo items to past dates unless **explicitly requested**
- If a user refers to a past date ambiguously, assume they mean the future occurrence

### Moving Todos
When a todo is moved:
1. Add the todo item to the target date's file
2. Remove it from the original date's file
3. Never create duplicate todo items unless explicitly requested
4. Commit with message reflecting the move

### Git Sync
- On the first todo operation of the day, run `git pull` before making changes
- After any change (add, update, delete, move), run `git pull` to sync, then commit and push
- This ensures the local repo is always up to date before and after changes

## Automatic Daily Review Trigger

At the first interaction after 0600 am local time (different from the last conversation):
1. Automatically run the daily review workflow
2. Do not wait for the user to ask about todos
3. Run it proactively as part of conversation initialization
4. This ensures the daily review happens automatically every morning

## Daily Review

At the first interaction after 0600 am local time, check for incomplete todos from yesterday:
1. Run `git pull` to get latest changes
2. Read yesterday's todo file
3. Identify all items with `[ ]` prefix (incomplete)
4. By default, automatically move all incomplete todos from yesterday to `later.txt`
5. Update files accordingly and commit/push changes with message: "Move: [N] incomplete todos from yesterday to later"
6. List the moved todos for the user
7. Ask: "Do you want any of these moved to today or another day?"
8. Only move todos out of later if the user explicitly requests it (specify date or "today")
9. If the user ignores the question, take no further action
10. If user requests moves, update files, commit and push

## Workflows

### View todos for a date
1. Run `git pull` to sync (if first operation of the day)
2. Read the txt file for that date (e.g., `2026.01.05.txt`)
3. Display all todos with their checkbox status

### View all completed todos
When user asks for "completed", "done", or similar:
1. Run `git pull` to sync (if first operation of the day)
2. Read all todo files
3. Filter for items with `[x]` prefix
4. Display as list **without checkboxes** (remove the `[x]` prefix)

### View all incomplete todos
When user asks for "incomplete", "uncompleted", "pending", or similar:
1. Run `git pull` to sync (if first operation of the day)
2. Read all todo files
3. Filter for items with `[ ]` prefix
4. Display as list **without checkboxes** (remove the `[ ]` prefix)

### View all todos
When user asks for "all todos", "list todos", or general todo list:
1. Run `git pull` to sync (if first operation of the day)
2. Read all todo files
3. Display all items **with checkboxes** (include `[ ]` or `[x]` prefix)

### Add a new todo (today)
1. Run `git pull` to sync if this is the first operation of the day
2. Get today's date (e.g., 2026.01.05)
3. Read or create the file for today's date (e.g., `2026.01.05.txt`)
4. Generate a unique ID (first 7 chars of a SHA-1 hash)
5. Append a new line: `[ ] Task description (id)`
6. Commit and push: `git add YYYY.MM.DD.txt && git commit -m "Add: Task description" && git push`

### Add a todo to later.txt (uncertain date)
1. Run `git pull` to sync if this is the first operation of the day
2. Read or create `later.txt`
3. Generate a unique ID (first 7 chars of a SHA-1 hash)
4. Append a new line: `[ ] Task description (id)`
5. Commit and push: `git add later.txt && git commit -m "Add: Task description to later" && git push`

### Add a todo for a specific date
1. Parse the user's date specification (e.g., "Wednesday", "next Friday")
2. Determine the target date, advising the user of assumptions made
3. Run `git pull` to sync if this is the first operation of the day
4. Read or create the file for that date (e.g., `2026.01.08.txt`)
5. Generate a unique ID (first 7 chars of a SHA-1 hash)
6. Append: `[ ] Task description (id)`
7. Commit and push: `git add YYYY.MM.DD.txt && git commit -m "Add: Task description to YYYY.MM.DD" && git push`

### Mark a todo as completed
1. Run `git pull` to sync if this is the first operation of the day
2. Read the file containing the todo
3. Change `[ ]` to `[x]` for the completed item
4. Commit and push: `git add YYYY.MM.DD.txt && git commit -m "Complete: Task description" && git push`

### Move a todo to another date
1. Run `git pull` to sync if this is the first operation of the day
2. Identify the source file and target date (or `later.txt`)
3. Remove the line from the source file
4. Add the line to the target date's file or `later.txt` (with checkbox preserved)
5. Commit both files and push: `git add source.txt target.txt && git commit -m "Move: Task description to YYYY.MM.DD" && git push`

### Move a todo from later.txt to a specific date
1. Run `git pull` to sync if this is the first operation of the day
2. Remove the todo from `later.txt`
3. Add it to the target date's file (with checkbox preserved)
4. Commit both files and push: `git add later.txt YYYY.MM.DD.txt && git commit -m "Move: Task description to YYYY.MM.DD" && git push`

### Remove a todo
1. Run `git pull` to sync if this is the first operation of the day
2. Read the file containing the todo
3. Delete the line
4. Commit and push: `git add YYYY.MM.DD.txt && git commit -m "Remove: Task description" && git push`

## Git Operations

All changes automatically:
1. Run `git pull` (on first operation of the day and after each change)
2. Stage the modified file(s) with `git add`
3. Commit with descriptive message (`Add:`, `Complete:`, `Remove:`, `Move:`)
4. Push to remote with `git push`

Repo location: `$HOME/projects/wip/to-dos/`

## File Naming Convention

- **Always** use format: `YYYY.MM.DD.txt`
- Today (2026-01-05): `2026.01.05.txt`
- January 6: `2026.01.06.txt`
- Never use alternative naming schemes (no `01-05-2026.txt`, no `todo-2026-01-05.txt`, etc.)
- No files are created for dates with no todos; this is acceptable

## Todo Display Format

Always display todos using this exact format unless otherwise instructed:

**Box Structure:**
```
┌─ My ToDos ───────────────────────────────┐
│ - todo item one                          │
│ - todo item two                          │
│ - todo item three that is very long and  │
│   wraps to the next line                 │
└──────────────────────────────────────────┘
```

**Specifications:**
- Top border: `┌─ My ToDos ` followed by dashes to fill, then `┐`
- Left border: `│ ` (pipe + space)
- Right border: ` │` (space + pipe)
- Bottom border: `└` + dashes to match width + `┘`
- Total width: 42 characters (40 chars content + 2 for borders)
- Content width: 40 characters
- Each todo item starts with `- ` (dash + space)
- Text alignment: left-justified with 2-space indent for wrapped lines
- Text wrapping: if a todo exceeds 38 characters (40 content width minus `- `), wrap to next line with 2 spaces indent
- Line spacing: one todo per line (no blank lines between todos)
- Indentation on wrapped lines: 2 spaces (aligns under the todo text, not the dash)
- Ordering: for any single date, display incomplete todos ([ ]) first, then completed todos ([x])

**Examples of wrapping:**
- Single line: `│ - short todo item                       │`
- Wrapped: `│ - very long todo that wraps to the next │` followed by `│   line with proper indentation        │`

Always use this display format for all todo list outputs.
