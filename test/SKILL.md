---
name: test
description: Write, run and fix tests in a Gradle/Java composite build — unit, validator, repository, Liquibase changeset and gRPC/REST integration tests with Testcontainers. Use when asked to write tests, run tests, fix a failing test, or check whether a change is covered.
argument-hint: [module or class under test]
---

# Tests

## Environment (check, don't assume)
- Run Gradle from the **composite build root** — the directory whose `settings.gradle.kts` carries the `includeBuild()` lines. Running inside a submodule fails on unresolved sibling dependencies.
  - bash: `./gradlew :<module>:test --tests <FQCN>`
  - PowerShell: `.\gradlew.bat :<module>:test --tests <FQCN>`
- Toolchain and Java version come from the build files, never a hardcoded JDK path — those differ per machine.
- Conventions: nearest `CLAUDE.md` from the repo root upward, plus `~/providus/CLAUDE.md` if present.

## Before running anything
1. **Docker check first, not after a confusing failure**: `docker info`. Testcontainers-backed tests need a live daemon — on Windows that means Docker Desktop running, and under WSL2 the integration must be enabled for that distro.
2. Confirm whether the change under test is on disk or still uncommitted in IntelliJ, and re-read before asserting anything about current behaviour.

## Writing tests
- **Copy the nearest existing sibling test as the template** — base class, fixture style, naming, assertion library. Inventing a parallel structure is a defect, not a preference.
- The bar: every changed behaviour gets a test that **fails if the change is reverted**. Assertions check outcomes, not mocks echoing themselves. Negative and boundary cases are part of the deliverable, not a follow-up.
- Where each kind belongs:
  - **validator / unit** — pure, no Spring context, no container.
  - **repository / changeset** — integration against a real Postgres container. Assert columns, types, nullability, constraints and indexes, plus a round-trip; "save returned without throwing" is not a test.
  - **gRPC / REST controller** — integration through the real mapper and exception translation, asserting the status or error code the caller actually receives.
- Never weaken, delete or `@Disabled` a test to get a green build. If an existing test is genuinely wrong now, say why before touching it.

## Container cost — check on every new integration test
A test class that stands up its own container adds a full Postgres startup to every run, and that compounds fast across a suite. Before adding one, look at how the module's existing integration tests get their container — shared base class, `@ServiceConnection` singleton, or Testcontainers reuse — and use the same route. If the suite is already slow, say plainly that per-class containers are the cause instead of tuning around it.

## Reporting
- State exactly what ran, what passed, what failed, and what was **not** run and why. "Tests exist" is never "tests pass".
- On failure, quote the assertion and the relevant frames only — never the whole Gradle log.
- If tests can't run at all here (no Docker, no toolchain, machine differences), say so plainly rather than reasoning about what they would have done.
