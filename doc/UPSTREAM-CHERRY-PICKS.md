# Upstream Cherry-Picks

PRs do upstream (`paperclipai/paperclip`) aplicados neste fork que ainda não foram mergeados no master oficial.

Quando um PR for mergeado no upstream e chegar via sync (`git merge upstream/master`), remova-o desta lista.

## Aplicados

| PR | Data | Categoria | Descrição |
|----|------|-----------|-----------|
| #3009 | 2026-04-07 | fix/infra | increase Node keepAliveTimeout for reverse proxies |
| #2818 | 2026-04-07 | fix/data | prevent identifier collision in issue creation |
| #2883 | 2026-04-07 | fix/agent | include issue description in wake payload |
| #2825 | 2026-04-07 | fix/ui | fix inbox badge counting all touched instead of unread |
| #2866 | 2026-04-07 | fix/auth | auth fallback to BETTER_AUTH_SECRET |
| #2784 | 2026-04-07 | fix/ui | aggregate dashboard budget from agents |
| #2964 | 2026-04-07 | fix/core | clear execution state when resetting issue to todo |
| #2819 | 2026-04-07 | fix/security | bump multer 2.1.1 fix HIGH CVEs |
| #2857 | 2026-04-07 | fix/security | sanitize Mermaid SVG output (XSS) |
| #3005 | 2026-04-07 | fix/security | block requests to private IPs (SSRF) |
| #2997 | 2026-04-07 | fix/security | require auth for GET /heartbeat-runs/:runId/issues |
| #2856 | 2026-04-07 | fix/security | denylist dangerous env vars in agent config |
| #2987 | 2026-04-07 | fix/ui | fix issue thread typing lag |
| #2973 | 2026-04-07 | fix/adapter | add gemini_local to isLocal check |
| #2841 | 2026-04-07 | fix/adapter | codex-local detect stale rollout |
| #2908 | 2026-04-07 | fix/infra | skip gosu when already target user (Docker) |
| #2985 | 2026-04-07 | fix/adapter | update gemini model list to 3.x |
| #2871 | 2026-04-07 | fix/ui | fix stale SPA fallback shell |
| #2936 | 2026-04-07 | fix/server | Express 5 wildcard syntax for better-auth |
| #2937 | 2026-04-07 | fix/infra | pino-pretty log timestamps honour TZ |
| #2990 | 2026-04-07 | feat | auto-recovery for crashed agents |
| #2950 | 2026-04-07 | feat | global dashboard at / with cross-company view |

## Nossos PRs (abertos no upstream)

| PR | Data | Descrição | Status upstream |
|----|------|-----------|----------------|
| #3022 | 2026-04-07 | cursor-based pagination for issues list (#2553) | aberto |
| #3023 | 2026-04-07 | advisory locks to prevent checkout deadlock (#2516) | aberto |
| #3024 | 2026-04-07 | since filter + context-digest endpoint (#683) | aberto |

## Com conflito (não aplicados)

Tentar novamente após próximo sync com upstream.

| PR | Motivo | Descrição |
|----|--------|-----------|
| #2986 | conflito | fix inbox badge after mark all as read |
| #2827 | conflito | clear execution lock fields on issue release |
| #2864 | conflito | release execution lock when assignee changes mid-run |
| #2815 | conflito | add text/markdown to allowed attachment types |
| #2893 | conflito | prevent stale index.html after ui-dist refresh |
| #2960 | conflito (8k+ linhas) | i18n Portuguese translations |

## Como adicionar novos cherry-picks

```bash
# 1. Criar branch
git checkout master && git checkout -b u7/cherry-pick-batch-YYYY-MM-DD

# 2. Aplicar PR
gh pr diff <PR_NUMBER> --repo paperclipai/paperclip | git apply --3way
git add -A && git commit -m "cherry-pick: PR #<NUMBER> — <descrição>"

# 3. Verificar
pnpm -r typecheck && pnpm build

# 4. Merge
git checkout master && git merge u7/cherry-pick-batch-YYYY-MM-DD

# 5. Atualizar este arquivo
```

## Como sincronizar com upstream

```bash
git fetch upstream
git checkout master
git merge upstream/master
# resolver conflitos se houver
git push origin master
# remover desta lista os PRs que foram mergeados no upstream
```
