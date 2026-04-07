# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What Is Paperclip

Control plane for AI-agent companies. Orchestrates agents, enforces budgets, manages approvals, tracks issues with audit trails. Multi-company isolation.

## Essential Commands

```sh
pnpm install          # install deps
pnpm dev              # full dev (API + UI, watch mode, auto-migrates)
pnpm dev:once         # single run, no watch
pnpm dev:server       # backend only
pnpm dev:ui           # frontend only

pnpm typecheck        # typecheck entire monorepo (pnpm -r typecheck)
pnpm test:run         # run all tests once (vitest)
pnpm test             # tests in watch mode
pnpm build            # build all packages

pnpm test:e2e         # Playwright E2E tests
pnpm test:e2e:headed  # E2E with visible browser
```

### Single test file
```sh
pnpm vitest run server/src/__tests__/app-hmr-port.test.ts
```

### Single package
```sh
pnpm --filter @paperclipai/server test:run
pnpm --filter @paperclipai/db typecheck
```

### Database
```sh
pnpm db:generate    # generate Drizzle migration after schema change
pnpm db:migrate     # apply pending migrations
pnpm db:backup      # one-off backup
```

Leave `DATABASE_URL` unset for dev — embedded PGlite auto-creates at `~/.paperclip/instances/default/db/`. Reset by deleting that dir and rerunning `pnpm dev`.

### Verification before hand-off
```sh
pnpm -r typecheck && pnpm test:run && pnpm build
```

## Architecture

**Monorepo (pnpm workspaces), ES modules throughout, Node 20+, pnpm 9+.**

| Path | Package | Purpose |
|------|---------|---------|
| `server/` | `@paperclipai/server` | Express 5 REST API + orchestration services |
| `ui/` | `@paperclipai/ui` | React 19 + Vite 6 board UI |
| `packages/db/` | `@paperclipai/db` | Drizzle ORM schema, migrations, DB clients (PostgreSQL 17) |
| `packages/shared/` | `@paperclipai/shared` | Shared types, constants, Zod validators, API path constants |
| `packages/adapters/` | various | Agent adapter implementations (Claude, Codex, Cursor, Gemini, etc.) |
| `packages/adapter-utils/` | `@paperclipai/adapter-utils` | Shared adapter utilities |
| `packages/plugins/` | various | Plugin system (SDK, examples, create-paperclip-plugin) |
| `cli/` | `paperclipai` | CLI tool |
| `doc/` | — | Product specs, planning docs, operational docs |

### Key docs to read before making changes
1. `doc/GOAL.md` — product vision
2. `doc/PRODUCT.md` — product requirements
3. `doc/SPEC-implementation.md` — V1 build contract (the authority on intended behavior)
4. `doc/DEVELOPING.md` — local dev setup
5. `doc/DATABASE.md` — DB configuration modes

### Backend (server/)
- **Routes:** `server/src/routes/` — Express routers, one per domain entity
- **Services:** `server/src/services/` — business logic layer called by routes
- **Auth:** `server/src/routes/authz.ts` — access control (`assertBoard()`, `assertCompanyAccess()`, `assertInstanceAdmin()`)
- **Activity log:** `server/src/services/activity-log.ts` — `logActivity()` for all mutations
- **Realtime:** WebSocket live events (`server/src/realtime/`)
- Board auth = full-control operator. Agent auth = bearer API keys (hashed at rest, company-scoped).
- Base API path: `/api`. Consistent errors: 400/401/403/404/409/422/500.

### Frontend (ui/)
- React Router v7, TanStack Query v5, Radix UI + Tailwind CSS v4
- Rich text: Lexical + MDXEditor
- Company context scoping via React context providers
- Adapter-specific UI renderers in `ui/src/adapters/`

### Database (packages/db/)
- Drizzle ORM with `pgTable()` definitions in `packages/db/src/schema/`
- New tables must be exported from `packages/db/src/schema/index.ts`
- `drizzle.config.ts` reads compiled schema from `dist/schema/*.js`
- `pnpm db:generate` compiles the package first, then generates migration SQL

### Adapter system
- Each adapter at `packages/adapters/{type}-local/` exports main, `/server`, `/ui`, `/cli` entry points
- External adapters loaded via `~/.paperclip/adapter-plugins.json`

## Core Engineering Rules

1. **Company scoping** — every domain entity has `companyId` and must be access-checked in routes/services.

2. **Contract synchronization** — schema/API changes must update all layers: `packages/db` schema + exports → `packages/shared` types/validators → `server/` routes/services → `ui/` API clients/pages.

3. **Control-plane invariants** — single-assignee tasks, atomic issue checkout, approval gates, budget hard-stop auto-pause, activity logging for mutations.

4. **Lockfile policy** — do NOT commit `pnpm-lock.yaml` in PRs. CI regenerates it on master.

5. **Import style** — `.js` extensions required for relative imports (ES modules). Workspace packages imported as `@paperclipai/{pkg}`.

## PR Requirements

Every PR must follow `.github/PULL_REQUEST_TEMPLATE.md` with all sections filled:
- **Thinking Path** — trace reasoning from project context to this change
- **What Changed** — bullet list
- **Verification** — how to confirm it works
- **Risks** — what could go wrong
- **Model Used** — AI model that assisted (required, even if "None — human-authored")
- **Checklist** — all items checked

Greptile score must be 5/5 with all comments addressed.

## Definition of Done

1. Behavior matches `doc/SPEC-implementation.md`
2. `pnpm -r typecheck && pnpm test:run && pnpm build` all pass
3. Contracts synced across db/shared/server/ui
4. Docs updated if behavior or commands changed
5. PR follows template with Thinking Path + Model Used

---

## Fork: Ultima7 (ultima7dev/paperclip)

Este é o fork da Ultima7 Tecnologia do Paperclip oficial (`paperclipai/paperclip`).

### Git remotes

```
origin   → github.com/ultima7dev/paperclip.git   (nosso fork)
upstream → github.com/paperclipai/paperclip.git   (repo oficial)
```

### Convenções de branch

- `master` — sincronizado com upstream + cherry-picks + nossos fixes
- `u7/*` — branches de customização exclusiva da Ultima7 (não vão pro upstream)
- Sem prefixo — bugfixes genéricos que podem virar PR upstream

### Regra de isolamento para customizações

Customizações Ultima7 devem ficar em caminhos isolados para minimizar conflitos no merge com upstream:

| Tipo | Caminho |
|------|---------|
| Adapters | `packages/adapters/u7-*/` |
| Plugins | `packages/plugins/u7-*/` |
| Skills | `skills/u7-*/` |
| Configs/serviços server | `server/src/u7/` |

**Evitar ao máximo alterar arquivos core do upstream.** Quando inevitável (bugfix), manter o diff mínimo e cirúrgico.

### Cherry-picks do upstream

PRs abertos no upstream que já aplicamos localmente estão rastreados em `doc/UPSTREAM-CHERRY-PICKS.md`. Sempre atualizar esse arquivo ao aplicar ou remover cherry-picks.

### Sincronização com upstream

A cada release oficial (~semanal):

```sh
git fetch upstream
git checkout master
git merge upstream/master
# resolver conflitos se houver
git push origin master
# remover de doc/UPSTREAM-CHERRY-PICKS.md os PRs que foram mergeados
```

### Commits

Seguir conventional commits: `fix:`, `feat:`, `chore:`, `refactor:`, `docs:`

### Ambiente

- **Produção:** VPS SaveInCloud (Ubuntu, Caddy) — NUNCA rodar test suite aqui
- **Database:** PostgreSQL 17 externo para produção
- **Acesso UI:** via Caddy em subdomínio ou Tailscale
- **Node:** 20+ (NVM), pnpm 9+
