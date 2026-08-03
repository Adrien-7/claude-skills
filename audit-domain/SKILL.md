---
name: audit-domain
description: Cross-layer consistency audit of a zoom module — entities vs DTOs vs validators vs repositories vs tests vs Liquibase changesets. Use when asked to check, compare, or align any of these layers in zoom-tenant, zoom-foundation, or a similar module.
argument-hint: [module] [layers to compare, e.g. "entities dtos" — default all]
---

# Domain consistency audit

Audit the requested module for cross-layer drift. Conventions and layout are in `~/providus/CLAUDE.md` (zoom-parent section) — follow them; do not re-derive.

## Ground rules
1. **Report only.** Never edit files during the audit. Fixes happen only after an explicit "fix them", and then only in the layers Adrien names.
2. Before starting, confirm which side is the **source of truth** for this task (entities or changesets) if not stated — it varies by task.
3. Adrien often has uncommitted IntelliJ edits: read current files from disk; if he says he changed something mid-audit, re-read before comparing.
4. If comparing against a remote branch: `git fetch origin <branch>` inside the submodule first (each submodule is its own repo).

## The matrix
For each entity in `domain/entities`, check its counterparts:

| Layer | Location | Check |
|---|---|---|
| DTO | `domain/model` | exists; fields mirror entity (names + types); plain Lombok, no extra deps |
| Validator | `domain/validators` | exists; validates entity fields; messages without `is` prefix |
| Repository | `domain/repositories` (tenant: `domain/repository`) | exists; ID type matches entity (`Long` for IDENTITY, `UUID` for UUID strategy) |
| Unit tests | `src/test/...` | validator/repo tests exist and match current fields |
| Changesets | `src/main/resources/db/changelog/changesets/` | columns, types, nullability, FKs, constraints match entity; `LocalDateTime`→TIMESTAMP; createdBy/updatedBy VARCHAR(50) |

Enumerate files once with Glob per layer; don't run per-file cat loops.

## Output
A single findings report:
- One table per layer pair with columns: entity | issue | detail (expected vs actual) | file:line.
- A "missing artifacts" list (entity lacking DTO/validator/repo/test/changeset coverage).
- End with a count summary. No fixes, no diffs, no edits.
