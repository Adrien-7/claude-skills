---
name: mr
description: Generate a GitLab MR description (and optional Jira task text) for the current branch against develop, in Adrien's terse first-person voice. Use when asked for an MR description, merge request text, or Jira task text.
argument-hint: [target-branch, default develop]
---

# MR description

## Get the right diff (this has gone wrong before — follow exactly)
1. Work in the repo that owns the changes: `git rev-parse --show-toplevel` from cwd. In zoom-parent, that's usually a **submodule** (its own remote), not zoom-parent itself.
2. `git fetch origin <target>` (default `develop`) — never diff against a stale local ref.
3. Base: `git log origin/<target>..HEAD --oneline` and `git diff origin/<target>...HEAD --stat`. If HEAD and target share no history, say so and ask — don't guess a base.

## Voice and format
First-person, terse, plain. Must fit a GitLab comment box (~15 lines max). No emoji, no headers-for-the-sake-of-headers, no "This MR...", no AI-flavored filler.

```
<one-line title, imperative, with ticket ID if branch has one (PD2-xxx)>

<2-3 sentences: what changed and why>

- <notable change 1>
- <notable change 2, only if it needs calling out>

<how it was verified, one line — tests run, or "not run" honestly>
```

Output the description in a fenced block ready to paste. If asked for Jira text too, same voice, even shorter.
