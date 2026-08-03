---
name: engineer
description: Engineering design and work breakdown — turn a requirement or approved architecture into a concrete, verifiable implementation plan: contracts, schema changes, touched modules, ordered tasks, test strategy. Use when asked to plan how to build a feature, break down work, or spec a change before coding.
argument-hint: [feature or requirement]
---

# Engineering design & breakdown

Deliverable: an executable plan someone (or a later session) can follow without re-deriving context. Not code.

## Ground rules
1. Read the actual code before planning: entry points, the module's existing patterns, build files. New code must mirror in-repo patterns (existing validators, services, tests as templates) — don't invent parallel structures.
2. Respect repo conventions from `~/providus/CLAUDE.md` (package roots, DTO rules, Liquibase naming `YYYYMMDDHHmm0000_author_task`, layout).
3. Every step must be independently verifiable — name the exact command (`./gradlew :module:test --tests <FQCN>`, `mvn -pl <module> test`, `npm run lint`, `terraform plan`).
4. Flag unknowns as explicit open questions instead of assuming.

## The plan must cover
- **Contract first**: endpoint/proto/WebSocket message definitions with request/response shapes; note backward-compat impact (proto field numbers, existing clients).
- **Schema**: Liquibase changesets needed (new vs edit-in-place per repo phase), index needs for new query patterns, expand-contract if the service can't have downtime.
- **Touched code**: modules and files per layer (entity → repository → service → controller/handler → DTO/mapper → validator), and which existing file to model each on.
- **Task sequence**: numbered steps ordered so each compiles and its tests pass before the next starts; call out steps that can be parallelized or split into separate MRs.
- **Tests**: which unit/integration tests to add or update, per step — not as a final phase.
- **Ops**: config/env vars, CI pipeline changes (image-build jobs: MR-only + manual), K8s/Terraform changes, metrics to emit, rollback story.
- **Risks**: concurrency, cache invalidation, migration-vs-deploy ordering, multi-tenant leakage.

## Output format
Terse numbered plan; each step = goal, files, model-after reference, verify command. Risks and open questions at the end. Short enough to paste into a GitLab issue.
