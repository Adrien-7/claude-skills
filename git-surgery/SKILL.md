---
name: git-surgery
description: Branch and submodule operations — cherry-pick between branches, take specific files from another branch, split an oversized MR into stacked branches, rebase vs merge, fix a wrong upstream, initialise or bump submodule pointers. Produces commands for Adrien to run; never commits, never pushes.
argument-hint: [what to move, split, or fix]
---

# Git surgery

## Absolute rules
1. **Never run `git commit` or `git push`.** Not after an approved plan, not "just this once". Print the exact commands and let Adrien run them.
2. **Never leave a branch tracking a different remote branch.** `git checkout -b <new> origin/develop` silently sets the upstream to `origin/develop`, which points a bare `git push` at develop. Use `git switch -c <new> --no-track origin/develop`, which leaves no upstream; he sets it himself with `git push -u origin <new>`. If a branch already has the wrong upstream: `git branch --unset-upstream`, and say so.
3. **Never stage or touch unrelated files.** No `git add -A`.
4. No interactive flags (`-i`) — they don't work in this environment.
5. Destructive operations (`reset --hard`, `clean -fd`, force-push, branch delete) are printed with their consequence spelled out, never run.

## Environment (check, don't assume)
- Shell: bash on Ubuntu/WSL, PowerShell on native Windows. Print blocks for the shell he's in; avoid quoting tricks that only work in bash when he's in PowerShell.
- Forge by remote host: `git remote get-url origin` → `gitlab.com` is work (`glab`), `github.com` is personal (`gh`).
- **Which repo owns this change?** `git rev-parse --show-toplevel`. In a submodule monorepo that is usually the submodule — its own repo, remote and branches. Run git inside it, and `git fetch origin <branch>` there before diffing anything remote.

## Preflight — every time, before proposing anything
```
git status --short
git branch --show-current
git rev-parse --abbrev-ref --symbolic-full-name @{upstream}   # failing here is correct for a fresh --no-track branch
git log --oneline -5
git stash list
```
Record the current HEAD SHA and hand it back as the way out (`git reset --hard <sha>` — printed, never run). Uncommitted work is resolved by Adrien, stashed or committed, before any history operation is proposed.

## Recipes
**Take one commit from another branch** — `git cherry-pick <sha>`. Prefer this to merging a whole branch when the goal is a single layer of changes; it is what avoids the large conflict sets.

**Take specific files, not a whole branch** — `git restore --source=<branch> -- <paths>` (older git: `git checkout <branch> -- <paths>`). Everything else stays untouched and the files land modified, ready for review.

**Rebase vs merge** — rebase when the branch is unpushed or private and a linear base on `origin/develop` is wanted. Merge when it is shared or already has an open MR. With an open MR, default to merge and say why.

**Split an oversized MR** — one branch per layer, each off `origin/develop` with `--no-track`, moving each layer across by cherry-pick or file-scoped restore. State the intended merge order explicitly: stacked MRs merged out of order create exactly the conflicts the split was meant to avoid.

**Drop a layer that shouldn't be on this branch** — when earlier MRs will already have landed those files on develop, this branch should remove them rather than carry them. Confirm what develop will actually contain at merge time before removing anything.

**Submodules** — `git submodule status --recursive` first. If git inside a submodule directory reports parent-repo paths, it is uninitialised: `git submodule update --init <path>`. A pointer bump is a commit **in the parent** recording the child's SHA — call that out, it is a separate MR on a separate repo.

## Output
A numbered list of commands for his current shell. Per step: the command, one line on what it does, and how to undo it. End with the recovery SHA. Nothing is executed beyond read-only inspection.
