#!/bin/bash
# Apply U7 patches to paperclip-plugin-telegram inside the Docker container.
# Run after plugin install/update:
#   docker compose exec server bash /paperclip/paperclip/server/src/u7/patches/apply-telegram-patches.sh
#
# Target version: paperclip-plugin-telegram 0.2.8
# These patches fix:
#   1. sendLabeledOutput crash on undefined text (acp-bridge.js)
#   2. companyId not passed to handleAcpCommand (commands.js + worker.js)

set -euo pipefail

PLUGIN_DIR="/paperclip/.paperclip/plugins/node_modules/paperclip-plugin-telegram/dist"
PATCH_DIR="$(dirname "$0")"

if [ ! -d "$PLUGIN_DIR" ]; then
  echo "ERROR: Plugin directory not found: $PLUGIN_DIR"
  exit 1
fi

echo "Applying U7 patches to paperclip-plugin-telegram..."

for patch in telegram-plugin-acp-bridge.patch telegram-plugin-commands.patch telegram-plugin-worker.patch; do
  echo "  Applying $patch..."
  patch -p0 -d / -N < "$PATCH_DIR/$patch" 2>/dev/null || echo "  (already applied or conflict)"
done

echo "Done. Restart the server to reload the plugin."
