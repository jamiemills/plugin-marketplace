---
name: managing-todos
description: Manages todo lists in the local to-dos repository with checkbox formatting. Adds, updates, deletes, and views todos in daily txt files, syncing with git. Use for task management and organizing work items.
---

# Managing Todos Skill

Manages todo items stored in the local to-dos repository at `/Users/jamie.mills/projects/wip/to-dos/`.

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

## Core Rules

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

## Workflows

### View todos for a date
1. Run `git pull` to sync (if first operation of the day)
2. Read the txt file for that date (e.g., `2026.01.05.txt`)
3. Display all todos with their checkbox status

### Add a new todo (today)
1. Run `git pull` to sync if this is the first operation of the day
2. Get today's date (e.g., 2026.01.05)
3. Read or create `2026.01.05.txt`
4. Append a new line: `[ ] Task description`
5. Commit and push: `git add 2026.01.05.txt && git commit -m "Add: Task description" && git push`

### Add a todo to later.txt (uncertain date)
1. Run `git pull` to sync if this is the first operation of the day
2. Read or create `later.txt`
3. Append a new line: `[ ] Task description`
4. Commit and push: `git add later.txt && git commit -m "Add: Task description to later" && git push`

### Add a todo for a specific date
1. Parse the user's date specification (e.g., "Wednesday", "next Friday")
2. Determine the target date, advising the user of assumptions made
3. Run `git pull` to sync if this is the first operation of the day
4. Read or create the file for that date (e.g., `2026.01.08.txt`)
5. Append: `[ ] Task description`
6. Commit and push: `git add YYYY.MM.DD.txt && git commit -m "Add: Task description to YYYY.MM.DD" && git push`

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

Repo location: `/Users/jamie.mills/projects/wip/to-dos/`

## File Naming Convention

- **Always** use format: `YYYY.MM.DD.txt`
- Today (2026-01-05): `2026.01.05.txt`
- January 6: `2026.01.06.txt`
- Never use alternative naming schemes (no `01-05-2026.txt`, no `todo-2026-01-05.txt`, etc.)
- No files are created for dates with no todos; this is acceptable
