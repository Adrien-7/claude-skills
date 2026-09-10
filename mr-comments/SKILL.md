---
name: mr-comments
description: Work the review threads on a merge request or pull request — list every comment against its file and line, say which are addressed and which are still open, and draft replies in Adrien's voice. Works on GitLab (glab) and GitHub (gh). Drafts only, never posts. Use when asked about MR/PR comments, review feedback, or whether every comment has been handled.
argument-hint: [MR/PR number or URL, default the current branch's]
---

# MR / PR review threads

**Draft only. Never post, reply or resolve through the CLI.** Output text for Adrien to paste.

## Pick the forge by remote, not by habit
`git remote get-url origin`:
- **`gitlab.com`** → work repos → `glab`: `glab mr view <id> --comments`, `glab mr diff <id>`, `glab mr list`.
- **`github.com`** → personal repos → `gh`: `gh pr view <id> --comments`, `gh pr diff <id>`, `gh pr list`.

Never point one CLI at the other's host. If neither is installed or authenticated, say so and work from a pasted comment — don't guess at thread contents.

In a submodule monorepo the MR belongs to the **submodule's** project, not the parent: run the CLI from the repo that owns the branch (`git rev-parse --show-toplevel`).

## Build the picture before writing a word
Resolve each thread against the code **as it stands on disk** — Adrien often addresses a comment in IntelliJ without pushing, so the remote diff is not the current truth.

| # | file:line | what's asked | status | evidence |
|---|---|---|---|---|

Status is one of **addressed** (with the `file:line` that proves it), **open**, **needs a decision from Adrien**, or **rejected** (with the reason). Every thread appears in the table. The real question behind this task is usually completeness — "did we handle every comment on MR 26?" — so a silently omitted thread is the failure mode, not a wrong reply.

## Drafting replies
Terse, first-person, plain. Must fit a comment box. No emoji, no AI-flavoured prose, no restating the reviewer's point back at them.
- **Agreeing** — what changed and where, in a sentence or two.
- **Disagreeing** — the technical reason, stated once, without hedging or apology. If the reviewer is right, say so plainly and move on.
- **Deferring** — name the destination (another MR, a ticket). Deferral without one reads as a dodge.
- **Checking his own draft** — when Adrien has already written a reply and wants it reviewed, check it against the code for accuracy first, tone second. Say plainly if it claims something the code doesn't do.

## Requesting changes on someone else's MR
Same voice. Per finding: `file:line`, the defect in one sentence, the concrete failure it causes. Severity-rank, and separate blocking from optional — an unranked pile of nitpicks reads as noise and gets ignored.

## Output
The thread table, then each draft reply in its own fenced block labelled with the thread it answers, then one line on what remains open.
