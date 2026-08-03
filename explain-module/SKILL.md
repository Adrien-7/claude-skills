---
name: explain-module
description: Write or refresh an explanation.md for a module — purpose, architecture, key classes, Mermaid diagrams, integration points. Use when asked to explain a module, document a library, or create/update explanation.md.
argument-hint: [module-path, default cwd]
---

# Module explanation doc

Write `explanation.md` at the module root (rewrite the whole file if it exists — no incremental patching).

## Structure
1. **Purpose** — what the module is for, 2-3 sentences.
2. **Where it fits** — which sibling modules/services consume it and how (see workspace map in `~/providus/CLAUDE.md`).
3. **Architecture** — one Mermaid diagram (flowchart or sequence, whichever fits the module better). Keep it to the load-bearing classes; not every class.
4. **Key classes/files** — table: file → role. Entry points first.
5. **Data / message flow** — how a request or event traverses the module; a second Mermaid diagram if the flow is non-trivial.
6. **Configuration & runtime** — ports, env vars, external deps (DB schema, Kafka/PubSub topics, Redis).

## Style
- Terse and factual; written for a teammate who has never opened the module.
- Facts from actual code, not inference — read the entry points and build files before writing.
- Mermaid must render on GitLab (use ```mermaid fences, no exotic syntax).
