# Working rules

## Audits & edits
- When asked to check / compare / audit something: produce a findings report first. Do NOT edit files until I explicitly say "fix them" — and then fix only the stated scope (e.g. "only validators").
- No bulk sed/xargs edit loops; make targeted edits.
- I edit files in IntelliJ mid-session, often uncommitted. When I say I changed something or ask you to re-read, re-read the files from disk before continuing analysis.
- Don't touch or stage unrelated files.

## Writing for me (MRs, comments, docs)
- MR descriptions, Jira task texts, GitLab comments, post-mortems: terse, first-person, plain language. Must fit a GitLab comment box. No emoji, no AI-flavored prose.
- MRs target `develop`. Always `git fetch origin develop` first, then diff `origin/develop...HEAD` from the correct repo root (mind git submodules — each has its own remote).
- Doc updates: rewrite the whole file rather than patching fragments.

## Branches
- Never leave a local branch tracking a different remote branch. `git checkout -b <new> origin/develop`
  silently sets the upstream to `origin/develop`, so a bare `git push` would target develop.
  Branch with `git switch -c <new> --no-track origin/develop`, which leaves no upstream at all;
  the upstream gets set later by my own `git push -u origin <new>`.
- If a branch already has the wrong upstream, fix it with `git branch --unset-upstream` and say so.

## Environment & workflow
- GitLab, not GitHub (use `glab`, never `gh`). Jira-style ticket IDs (PD2-xxx).
- Ubuntu. Interactive sudo fails in your shell — when root/auth is needed, give me the command to run myself (I can use the `!` prefix).
- Long-running processes (Spring Boot apps, dev servers): run in background, or leave them to me — I usually run apps from IntelliJ and paste results back.
- New shell helpers go in `~/.bash_functions`, written in the same style as the existing functions there.
- When I paste a large CI/pipeline log, extract the failing job and error lines; don't re-quote the whole log.

## Java navigation (IDE MCP)
- When the `idea` MCP server is connected, use `mcp__idea__*` for Java navigation instead of grep:
  `search_symbol` to locate symbols, `analyze_calls` for callers/callees, `get_symbol_info` for
  resolved types, `search_structural` for pattern sweeps, `get_file_problems` for inspections.
  Text search misses cross-module resolution in composite builds; the PSI index doesn't.
- If it isn't connected, fall back to grep and say so — don't degrade silently.
- Keep using Read/Grep/Bash for non-Java files, logs, Gradle and Liquibase XML, and anything
  outside the IDE's indexed project. The IDE's own file/search/git tools are slower for no gain.
- The PSI tools read IntelliJ's in-memory buffers, so they see my unsaved edits and can disagree
  with what's on disk. When that matters, say which side you're reading.
