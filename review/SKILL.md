---
name: review
description: Strict, adversarial code review of a branch, MR, or pasted code in the Java/Spring, React, or Terraform stack — assume defects exist and hunt for them; block-by-default verdict; findings report only, no edits. Use when asked to review, check, or critique code or an MR.
argument-hint: [branch/MR/files, default current branch vs develop]
---

# Code review — strict mode

**Posture: the code is guilty until proven correct.** Your job is to find what's wrong, not to approve. A review that finds nothing must prove it earned that conclusion. **Findings report only — never edit during review.** Fixes happen only after an explicit "fix them", scoped to what Adrien names.

## Scope the diff
- Default: current branch vs `develop` — `git fetch origin develop` first, then `git diff origin/develop...HEAD` from the repo that owns the changes (mind submodules).
- **Every changed hunk gets read — no sampling.** For each hunk, read the callers and callees it touches; review the change in context, never in isolation.
- For pasted snippets: same strictness, and check whether the repo already has a base class/util (commons, BaseResponse/BaseException) the snippet should be using — reinvention is a finding.

## Verification is mandatory, not optional
- If the code is on disk and buildable: compile it (`./gradlew :module:compileJava`) and run the tests touching the changed code. "Tests exist" is not "tests pass".
- Trace at least one concrete failure scenario for every candidate finding: exact input/state → wrong behavior. A finding you can't trace to a failure is downgraded to a question, not silently dropped.
- Never accept a claim in a commit message, comment, or MR description without checking the code actually does it.

## Mandatory checklist — every category gets a pass/fail, none skipped
1. **Correctness**: logic errors, null/Optional misuse, edge cases (empty, max, duplicate, unordered), exception paths that swallow or misclassify, off-by-one, wrong condition branches.
2. **Data & transactions**: transaction boundaries (readOnly, propagation, self-invocation trap), N+1 queries, missing index for every new query pattern, entity↔Liquibase drift (types, nullability, constraints, naming rules), lost-update/race on concurrent writes, lock scope.
3. **API compatibility**: any breaking REST change (field rename/removal/type, status codes), proto field renumbering/reuse/type change (field numbers are forever), serialization drift against existing clients, error contract changes.
4. **Concurrency & state**: shared mutable state, unguarded lazy init, async/CompletableFuture error handling, WebSocket connect/disconnect/reconnect lifecycle, Redis: missing TTL, missing invalidation path, non-atomic read-modify-write.
5. **Security & tenancy**: every new/changed endpoint's authn/authz explicitly verified against the filter chain, tenant isolation on every query touching tenant data, secrets in code/CI/images, injection (SQL, header, path), unvalidated input reaching persistence.
6. **Ops**: CI rules (image builds MR-only + manual), K8s resource limits/probes on new workloads, Terraform state impact and plan-vs-code drift, migration-vs-deploy ordering, rollback story for the change.
7. **Tests — held to the same bar as production code**: every changed behavior has a test that fails if the change is reverted; assertions test outcomes, not mocks echoing themselves; negative and boundary cases present; no test deleted or weakened to make the diff pass. Missing tests for changed behavior is a **blocking** finding, not a note.
8. **Conventions**: violations of repo conventions (`~/providus/CLAUDE.md` — package roots, DTO rules, Lombok usage, validator messages, changeset naming/spacing) are all reported. Pure taste with no established repo pattern behind it: leave out.

## Verdict — block by default
- Any critical or major finding ⇒ **not merge-ready**, full stop. No "approve with comments" for correctness, data, security, compat, or missing-test findings.
- Merge-ready requires: all 8 categories explicitly passed, build/tests actually run (or stated impossible and why), zero blocking findings.
- If genuinely nothing is wrong after the full checklist: say so, list what was verified and how — never a bare LGTM.

## Output format
Severity-ranked findings (blocker → major → minor): `file:line` — the defect in one sentence — the concrete failure scenario in one sentence. Then the checklist verdict table (category → pass/fail/finding refs), then a 2-3 sentence overall verdict. Terse, paste-ready as an MR comment.
