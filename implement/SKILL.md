---
name: implement
description: Disciplined implementation of a planned change in the Java/Spring, Next.js/React, or Terraform stack — small verified steps, repo conventions, honest verification. Use when asked to build, code, or apply an agreed plan or feature.
argument-hint: [what to implement]
---

# Implementation

## Before writing code
1. If there's an agreed plan (from /engineer or the conversation), follow it; if not, state a 3-5 line mini-plan first, then proceed.
2. Read the files you'll change and one existing sibling to copy patterns from (naming, Lombok usage, test style). Conventions live in `~/providus/CLAUDE.md`.
3. Adrien may have uncommitted IntelliJ edits — work from disk state, and re-read anything he says he touched.

## While coding
- Targeted edits only: no drive-by refactors, no formatting sweeps, no touching unrelated files. If something unrelated is broken, flag it, don't fix it.
- Build order: contract/schema → data layer → service logic → wiring/controllers → tests updated per step, not at the end.
- Compile early and often (`./gradlew :module:compileJava` is allowlisted); don't stack unverified edits.
- Stack specifics to get right the first time:
  - **Spring**: transaction boundaries at the service layer; constructor injection via Lombok; exceptions through the existing handler hierarchy, not ad-hoc try/catch.
  - **JPA/Postgres**: watch N+1 on new relations; new query patterns need index consideration; entity changes need a matching Liquibase changeset (repo naming rules apply).
  - **gRPC**: never renumber or reuse proto fields; regenerating stubs may require the mavenLocal publish chain (zoom).
  - **Redis**: every new key gets a TTL and a documented invalidation path.
  - **WebSockets**: handle disconnect/reconnect and per-tenant/session scoping explicitly.
  - **React/Next.js**: respect existing eslint config; never "fix" CRLF tree-wide.
  - **Terraform/K8s**: always show the plan/diff; resource limits on new workloads; secrets stay in env/Secret Manager.

## Verification & reporting
- Run the relevant tests and builds yourself; long-running apps go to background or to Adrien (IntelliJ).
- Report honestly: what ran, what passed, what was NOT run and why. Failing tests are reported with output, never papered over.
- Finish with a one-paragraph summary of what changed (files + behavior), ready to feed `/mr`.
