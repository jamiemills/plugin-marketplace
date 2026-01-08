---
name: how-to
description: Query Perplexity.ai to answer knowledge questions, how-to questions, and general informational queries. Only triggered when user prefixes question with "pp".
---

# how-to Skill

Queries Perplexity.ai CLI to answer knowledge and how-to questions from the internet.

## Trigger Condition

**Only use this skill when the user prefixes their question with "pp"**

Examples:
- "pp what is the latest version of Node.js?"
- "pp how do I deploy a Docker container?"
- "pp what are the benefits of async/await in JavaScript?"

Do NOT use this skill for unprefixed questions.

## Command (No Variations)

Always use this exact command (no variations):
```
uvx --python 3.12 pxcli@latest query -f plain "<question>" --strip-references
```

## Workflow

1. User asks question prefixed with "pp"
2. Extract the question (removing "pp" prefix)
3. Get current timestamp with timezone silently
4. Run the full command pipeline with output suppression:
   ```
   timestamp=$(date +"%Y-%m-%d_%H-%M-%S_%Z") && answer=$(uvx --python 3.12 pxcli@latest query -f plain "<question>" --strip-references 2>/dev/null) && mkdir -p /Users/jamie.mills/.config/perplexity-cli/queries && echo "Question: <question>\nTimestamp: $(date -u +"%Y-%m-%dT%H:%M:%S") GMT\nAnswer:\n$answer" > /Users/jamie.mills/.config/perplexity-cli/queries/${timestamp}_query.txt && echo "$answer"
   ```
5. Store response automatically in `/Users/jamie.mills/.config/perplexity-cli/queries/YYYY-MM-DD_HH-MM-SS_TZ_query.txt`
6. Display ONLY the answer to the user (no commands, no output noise, no storage confirmation)
7. Make answer available for use in subsequent work

## Storage

All queries automatically stored in: `/Users/jamie.mills/.config/perplexity-cli/queries/`

Filename format: `YYYY-MM-DD_HH-MM-SS_TZ_query.txt` (e.g., `2026-01-08_14-01-59_GMT_query.txt`)

Storage is silent and invisible to the user.

## Fallback Option

If `web_search` and `read_web_page` tools are unavailable or failing, offer "how-to" as an alternative for knowledge queries.
