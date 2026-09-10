---
name: sql
description: Ad-hoc Postgres work — write and run SELECT/EXPLAIN queries, inspect schema, design indexes, write idempotent seed SQL. Read-only by default; DDL is printed rather than executed, and schema changes go through Liquibase. Use when asked for a query, an index, a schema question, or seed/test data.
argument-hint: [question, table, or query]
---

# SQL and schema work

## Read-only by default
- `SELECT` and `EXPLAIN` freely.
- **Anything that writes or changes schema is printed for Adrien to run, never executed** — INSERT/UPDATE/DELETE, DDL, GRANT.
- A schema change belongs in a **Liquibase changeset**, not ad-hoc DDL. When the answer is "add a column or index", write the changeset following the repo's naming and spacing rules; don't run the DDL and call it done.

## Reaching the database, in this order
1. **IDE MCP, when connected**: `mcp__idea__list_database_connections`, then `introspect_schema` / `list_schema_objects` / `execute_sql_query` / `preview_table_data`. Fastest path and it already holds his credentials.
2. **Otherwise**: produce SQL formatted to paste into DBeaver, or a `psql` invocation. Say which path was taken — don't degrade silently.

Connection details differ per machine: read them from the app config, the compose file, or `CLAUDE.md`. Never hardcode a host, port or password. When the database runs in a container, `localhost` resolves differently natively, under Docker Desktop and under WSL2 — rule that out before blaming credentials.

## Rules that have bitten before
- **Schema-qualify every object.** These databases carry several schemas and the session default is not reliable.
- **`TIMESTAMP`, not `TIMESTAMPTZ`.** If a timestamp looks wrong in DBeaver, that is the client rendering a timezone, not the stored value.
- **Postgres identifiers truncate at 63 characters.** Long index and constraint names get silently cut, which then breaks the drop. Check the length of every name generated.
- Every new query pattern gets an explicit index consideration: which index serves it, or why a scan is acceptable. Composite column order follows the query's filter order, and sort direction matters when the query orders (`changed_at DESC`).
- Partial and unique indexes: state the predicate and the uniqueness scope it actually enforces. Code-level uniqueness and index-level uniqueness are different claims — don't blur them.

## Seed and test data
- Idempotent, always — `ON CONFLICT ... DO NOTHING` — since these databases get reset repeatedly.
- Put it where the repo already keeps such files (e.g. a `docs/api/test-seed` style location) rather than inventing a path, and reference it from the doc or test that consumes it.

## Output
Paste-ready SQL in a fenced block. For results, the rows that answer the question, not the whole set. For an `EXPLAIN`, the plan line that matters and what it means, not the full tree.
