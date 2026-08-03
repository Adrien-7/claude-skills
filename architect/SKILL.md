---
name: architect
description: Software architecture planning — design a system, service, or major feature; choose between approaches; produce an architecture doc and ADR. Use when asked how to structure something, which technology/pattern to use, or to plan a new service/integration.
argument-hint: [what to design]
---

# Architecture planning

Deliverable: a terse architecture doc + a recommendation. Not code.

## Process
1. Gather constraints from what exists first — repo layout, `~/providus/CLAUDE.md`, current services, existing patterns. Ask Adrien only for constraints that change the design (scale, tenancy, SLAs, team ownership) and aren't discoverable.
2. Present **at most 2-3 options** with a tradeoff table, then recommend one. Never an option survey without a recommendation.
3. If the repo has `docs/adr/`, draft the decision as an ADR there (same numbering/format as existing ones). ADRs must be updated later if the implementation diverges.

## Default stack (prefer boring choices already in use)
Java 17+/Spring Boot services; Gradle (zoom) or Maven where established; PostgreSQL + Liquibase migrations; Redis for caching/ephemeral state; gRPC for service-to-service, REST for external/edge, WebSockets for push; Next.js/React frontends; Docker images → K8s on GCP, deployed via GitLab CI; Terraform for infra; Grafana/Graphite for metrics. Deviating from this stack is an ADR-worthy decision — justify it explicitly.

## Every design must address
- **Data**: ownership, schema, migration path (Liquibase, expand-contract for zero-downtime), retention.
- **Contracts**: REST/gRPC/WebSocket surface; versioning and backward compatibility (proto field numbers are forever).
- **State & caching**: what lives in Postgres vs Redis; invalidation strategy; TTLs.
- **Multi-tenancy**: how tenant isolation is enforced (schema, row-level, service-level).
- **Failure modes**: idempotency, retries, timeouts, partial-failure behavior, what happens on redeploy.
- **Observability**: what metrics (Graphite naming: dot-separated, lowercase), dashboards, alerts; log volume.
- **Security**: authn/authz boundaries, secrets via env/Secret Manager — never in code or images.
- **Deployment & rollback**: CI pipeline shape, migration ordering vs app rollout, how to roll back.

## Output format
Terse doc: context (3-4 sentences) → options table (option | pros | cons | cost) → recommendation with rationale → one Mermaid component or sequence diagram → open questions. Fits in a GitLab issue/comment.
