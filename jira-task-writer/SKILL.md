---
name: jira-task-writer
description: Writes a Jira-ready task title and description from a short brief, bug report, feature idea, or meeting note. Always use this when the user invokes /jiratask, asks to "write a Jira ticket/task", "draft a ticket", "turn this into a task", or gives a small/medium chunk of raw info (a bug, a feature idea, notes from a call) and wants it turned into something they can paste into Jira. Reusable across any project — checks the current repo's CLAUDE.md and ~/providus for team-specific conventions before writing, but works fine without them.
---

# Jira Task Writer

Turns a short piece of raw input (a bug description, feature idea, meeting note, or Slack message) into a Jira task **title** and **description** that are descriptive enough to act on, but short enough to read in one pass.

## Step 1 — Load project context (if it exists)

Before writing anything, look for team/project conventions in this order and use the first one found:

1. `CLAUDE.md` in the current repo — search the working directory and walk up to the repo root (e.g. `git rev-parse --show-toplevel` if available).
2. `~/providus` — check for a `CLAUDE.md` or similar conventions file there. This holds cross-project conventions that apply even when the current repo has none.

If found, pull out anything relevant to ticket writing: component/module names, terminology, ticket prefixes, definition-of-done checklist, labels, priority scheme, tech stack. Use these to make the ticket sound like it belongs in this project instead of generic.

If neither exists, proceed with sensible defaults — don't ask the user to create one, don't block on it.

## Step 2 — Read the input

The input is usually short (a sentence to a paragraph): a bug, a feature ask, a snippet of a conversation, or notes. Identify:

- **What's the actual problem or request?** (strip filler, keep the substance)
- **Type**: bug, feature, chore, or task — infer from wording ("broken", "error" → bug; "add", "support" → feature; "clean up", "update dep" → chore)
- **Scope signals**: component names, file paths, error messages, user-facing vs internal
- If the input is genuinely too thin to act on (e.g. just "fix the thing"), ask one clarifying question instead of guessing wildly. Otherwise, fill reasonable gaps yourself and note any assumption in the description rather than stopping to ask.

## Step 3 — Write the title

Rules:
- One line, ideally under 10 words, hard cap ~80 characters.
- Lead with a verb: Fix, Add, Update, Remove, Investigate, Support.
- Include the component/area if known (from context or the input itself), e.g. `[Auth] Fix token refresh failing on Safari`.
- No vague titles like "Bug fix" or "Improve performance" — name the actual thing.

## Step 4 — Write the description

Keep it scannable. Use this structure, but drop any section that would be empty or redundant for something this small — don't pad:

```
**Summary**
1–2 sentences: what's wrong or what's needed, and why it matters.

**Details** (only if there's real signal to include — logs, repro steps, links, affected component)
- bullet points, not prose paragraphs

**Acceptance Criteria** (skip for trivial chores)
- [ ] Concrete, checkable outcomes — not "works correctly"
```

Guidelines:
- Prefer bullets over paragraphs everywhere.
- Every sentence should earn its place — if removing it loses no information, remove it.
- Use terminology from CLAUDE.md / `~/providus` if it was found, instead of generic phrasing.
- Don't invent acceptance criteria that weren't implied by the input — write what's reasonably inferable, and flag genuine assumptions with a short "(assuming X)" note rather than presenting guesses as fact.

## Step 5 — Output

Reply in chat (no file/artifact needed — this is meant to be copy-pasted straight into Jira):

```
**Title:** <title>

**Description:**
<description>
```

Keep the surrounding chat reply minimal — the ticket itself is the deliverable, not a write-up about it.
