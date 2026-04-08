# U7 Plugin Patches

Patches applied to third-party Paperclip plugins installed via npm.
These live outside git (inside the Docker volume at `/paperclip/.paperclip/plugins/`)
so they must be re-applied after plugin updates.

## paperclip-plugin-telegram v0.2.8

**Date:** 2026-04-08
**Bugs fixed:**

### 1. `sendLabeledOutput` crash on undefined text (`acp-bridge.js`)
- `handleAcpOutput` now defaults `text` to `""` via `event.text ?? ""`
- `sendLabeledOutput` returns early with a warning if `text` is falsy
- **Root cause:** ACP output events can arrive with `text: undefined`

### 2. `companyId` not passed through command chain (`commands.js` + `worker.js`)
- `handleCommand()` now accepts `companyId` as 9th parameter
- `worker.js` passes the already-resolved `companyId` to `handleCommand()`
- `handleCommand` forwards it to `handleAcpCommand()`
- **Root cause:** ACP plugin needs `companyId` to emit events; without it, spawning ACP sessions fails with "must provide a companyId when emitting events"

### How to apply

```bash
docker compose exec server bash /paperclip/paperclip/server/src/u7/patches/apply-telegram-patches.sh
docker compose restart server
```

### When to re-apply

After any of:
- `npm install` / `npm update` of `paperclip-plugin-telegram`
- Docker volume recreation
- Plugin reinstall via Paperclip UI

### Upstream status

These bugs should be reported to [mvanhorn/paperclip-plugin-telegram](https://github.com/mvanhorn/paperclip-plugin-telegram).
