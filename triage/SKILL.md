---
name: triage
description: Diagnose a runtime failure from a stack trace, exception, or application log — Java/Spring, gRPC, Liquibase, Postgres, Docker. Use when a trace or log is pasted, when an app won't start or a call fails, or when asked why something errors, 500s, or "still fails". For a failing CI pipeline use ci-debug instead.
argument-hint: [pasted trace/log, or what is failing]
---

# Runtime failure triage

Diagnose first, fix second: name the cause and the smallest fix, then apply it only when told to. **Never re-quote the log back** — pull the lines that matter and work from those.

## Environment (check, don't assume)
- Shell/OS: bash on Ubuntu or WSL, PowerShell on native Windows. Print commands for the shell Adrien is actually in (`./gradlew` vs `.\gradlew.bat`, `$HOME` vs `$env:USERPROFILE`).
- Project context: the nearest `CLAUDE.md` from the repo root upward, plus `~/providus/CLAUDE.md` if it exists (work box). If neither is there, work from the repo and say so.
- Paths come from `git rev-parse --show-toplevel` — never hardcode a home path.

## 1. Classify the layer before reading anything
Pick one, state it, then look only there:

app logic · framework wiring · schema/migration · database/data · container or network · build/dependency · CI (→ use `ci-debug`).

Guessing the layer wrong is the main way these sessions get long.

## 2. Find the real frame
- The cause is the **last** `Caused by:` in the chain, not the first line of the trace.
- The actionable frame is the first one in the repo's own package root (e.g. `mu.providus.*`) — read that file **from disk**; Adrien edits in IntelliJ and it is often uncommitted.
- If the trace has no frame in his code at all, the fault is configuration, a dependency, or the environment. Say that instead of inventing a code cause.

## 3. Known shapes — rule these out before theorising
| Symptom | Look here first |
|---|---|
| Won't start; bean/context failure | wiring: missing or duplicate bean, profile not active, `application.yaml` key drift |
| Liquibase error on boot; changeset "should have been skipped" | checksum drift — a changeset was edited after being applied; check `databasechangelog` |
| gRPC error reaches the caller as UNKNOWN or swallowed | the exception translator's mapping, not the service method |
| Constraint / DataIntegrityViolation | the changeset's constraint vs what the code writes; unique and partial index scope |
| Connection refused to Postgres/Redis | host vs container networking — `localhost` means different things natively, under Docker Desktop, and under WSL2 |
| Testcontainers failure | Docker daemon down — `docker info` before anything else |
| Port already in use | a previous run still holding it (8084 REST / 9094 gRPC in zoom) |
| CORS or 404 against a deployed URL | the rendered deployment config, not the source — see `ci-debug` |

## 4. The "still failing" rule
When Adrien says *still failing*, *same issue*, or *recheck*: **do not offer a second guess from the same evidence.** The first diagnosis was wrong or incomplete, and more theorising on identical input repeats it. Ask for exactly one new artifact and name it precisely — the new trace, a specific log line, `docker logs <container>`, the query result, the config as actually rendered. Then re-diagnose from that.

## 5. Output
- **Cause** — one or two sentences, with `file:line` or the config key.
- **Evidence** — the 1-3 log lines that prove it. Nothing more.
- **Fix** — the smallest change that addresses the cause.
- **Verify** — the single command or call that confirms it, in his shell.

If the cause can't be proven from what's available, say what's missing rather than presenting a guess as a finding.
