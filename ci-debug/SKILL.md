---
name: ci-debug
description: Triage a failing GitLab CI pipeline in the providus repos (LMS, zoom). Fetches logs via glab when available and maps failures to known infra facts (Artifact Registry auth, CORS templating, Liquibase versions, runner setup). Use when a pipeline, CI job, or deployment fails.
---

# GitLab CI triage

Infra facts (registries, SAs, project IDs, runners, images, URLs) are in `~/providus/CLAUDE.md` — check there before hunting.

## Getting the log
1. If `glab` is installed: `glab ci status`, `glab ci view`, then `glab ci trace <job>` for the failing job. Work from the repo whose pipeline failed.
2. If `glab` is missing, ask Adrien to install it (`sudo snap install glab` then `glab auth login` — gitlab.com) rather than pasting logs; as a fallback ask for **only the failing job's last ~50 lines**.
3. Never quote a full runner log back. Extract: job name, image, runner, and the first real error line. If a large log was pasted, summarize it once into those fields and work from that.

## Known failure modes — check these before generic debugging
- **`Unauthenticated request` / denied pulling an image** → the job's SA lacks `artifactregistry.reader` on `worksheet-tool-common`, or the wrong `GOOGLE_APPLICATION_CREDENTIALS_JSON_<env>` var is set. Env suffix is `test`, not staging. Check which GitLab project actually defines the variable (group vs project level).
- **CORS still failing after a "fix"** → the gateway's `globalcors` is templated by the DEPLOYMENT repo (`scripts/deploy_service_reworked.sh`); inspect the rendered config, and watch for substitution artifacts (e.g. trailing `.` in URLs).
- **"Job succeeded" but no image in the registry** → job pushed to the wrong repo path or the build/push step was skipped by rules; verify the full image path `europe-west1-docker.pkg.dev/worksheet-tool-common/docker-repo/<name>:<tag>` in the log.
- **Liquibase job errors** → CI image runs Liquibase 3.10.2 (no `--search-path`; use `--classpath`) driven by `apply_migration.py` inside the image. Local 4.x flags will not work.
- **Terraform: vars "already taken" / lock errors** → GCS state may have a stale lock or drifted state; propose import/unlock commands for Adrien to run himself — never run them.

## Boundaries
- Pipeline changes: image-build jobs must be MR-only + manually triggered.
- `gcloud` and any state-mutating command: hand to Adrien to run, don't execute.
