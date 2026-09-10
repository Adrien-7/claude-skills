---
name: astro
description: Build and learn Astro — pages, layouts, islands and client directives, content collections, API endpoints, actions, SSG vs SSR adapters, React interop. Teaching posture: explains the concept behind each change, not just the code. Use for any .astro work, island/hydration questions, content collections, or "how does Astro do X".
argument-hint: [what to build, or the concept to learn]
---

# Astro

Adrien is a Java/Spring backend engineer learning frontend. **Teach while building.** Every change gets 2-3 lines on the concept it demonstrates and the trade-off it makes — a working file he can't explain is a failed deliverable. Don't scaffold a whole app when one page proves the point.

## Environment (check, don't assume)
- Usually the **Windows 11 + WSL** box. Keep the project **inside the WSL filesystem** (`~/…`), never under `/mnt/c/…` — npm installs crawl and file-watching/HMR breaks across the mount.
- Node comes from nvm **inside** WSL; don't mix in Windows-side node or npm.
- Dev server is `npm run dev` on **:4321**. If the Windows browser can't reach it, `npm run dev -- --host`.
- Line endings: he has been bitten by CRLF tripping lint on a shared repo. `.gitattributes` with `* text=auto eol=lf` up front; never reformat a tree to fix it after the fact.
- Paths from `git rev-parse --show-toplevel`; nearest `CLAUDE.md` for project conventions.

## Check the installed version before writing a line
`cat package.json` for the `astro` major. The API moved meaningfully across majors — content collection config location and loaders, `ViewTransitions` vs `ClientRouter`, how Tailwind is wired, typed env. **Write against the version that's installed, not from memory**, and when unsure of an API's current shape, check `node_modules/astro` or the docs for that major rather than guessing. Say which version you targeted.

## The mental model (translate from what he knows)
- A `.astro` file's frontmatter fence runs **once, on the server, at build or request time** — then it's gone. It is closer to a Spring controller method assembling a model than to a React component. There is no re-render, no state, no hooks in `.astro`.
- The output is **HTML with zero JavaScript by default.** JS ships only where explicitly asked for.
- An **island** is a component you opted into shipping JS for. Everything else is static HTML.
- File-based routing: `src/pages/**` maps to URLs. `[slug].astro` is a path variable, `[...rest].astro` a catch-all.

## Islands and hydration — the core decision
Choosing the directive *is* the skill. Never reach for `client:load` by default; state why the chosen one fits.

| Directive | Hydrates | Use when |
|---|---|---|
| *(none)* | never | the component is output-only — the default, and the right answer most of the time |
| `client:visible` | when scrolled into view | below-the-fold interactivity |
| `client:idle` | when the browser is idle | interactive, but not needed instantly |
| `client:load` | immediately | genuinely needed on first paint |
| `client:media` | at a breakpoint | mobile-only or desktop-only widgets |
| `client:only="react"` | client only, no SSR | the component touches `window`/`document` at render |

Consequences to state when adding one:
- Props crossing into an island must be **JSON-serializable** — no functions, class instances, or Dates-as-objects surviving the boundary.
- Two islands are **separate roots and share no state.** Cross-island state needs a shared store (nanostores is the common answer); lifting state into a parent `.astro` file does not work, because that file has no runtime.

## Where a backend dev gets traction fastest
Start here — it maps onto things he already knows and pays off immediately:
1. **Layouts and `<slot />`** — template inheritance. One layout, a couple of pages.
2. **Content collections** — schema-validated Markdown with a Zod schema. This is the piece that will feel familiar: a typed contract that fails the **build** when data drifts, not at runtime.
3. **API endpoints** (`src/pages/api/*.ts` exporting `GET`/`POST` and returning a `Response`) — a plain HTTP handler with no framework ceremony.
4. **Actions** — type-safe server functions callable from the client with validated input. The closest thing to a typed RPC, and the natural bridge to his gRPC instincts.
5. **React islands last** — once the zero-JS baseline is understood. `npx astro add react`, then a single island, so the contrast is visible.

## Static vs server — settle this before building anything
A static build produces files and **has no runtime**: API endpoints, actions, and per-request logic need SSR, which needs an **adapter** (node, vercel, netlify, cloudflare) and the page opted out of prerendering. Decide which mode the thing needs up front — discovering it after the fact means rework.

**Secrets:** any env var exposed to the client (`PUBLIC_` prefix) is public, permanently. In a fully static build there is no server at all, so nothing on the page is secret. Never put a credential where the browser can reach it — check this every time an env var is introduced.

## Pitfalls to call out when they come up
- Writing `.astro` frontmatter as if it re-runs. It doesn't. Interactivity means an island.
- `client:load` on everything — that's shipping a SPA and losing the entire reason to use Astro.
- Reaching for `window`/`document` in a component that server-renders — needs `client:only`, or the access moved into an effect.
- Scoped `<style>` in `.astro` applies only to that component; a selector "not working" is usually scoping, not specificity.
- Content collection schema failures surface at build time — read the schema, not the template.

## Verify and report
- Run `npm run build` before claiming anything works — it catches schema and type errors that `dev` tolerates.
- `npm run dev` for anything visual, and say plainly that visual confirmation is his to do; don't assert how it looks.
- Close with: what was built, the one concept it teaches, and the doc page for that concept so he can go deeper.
