#!/usr/bin/env bash
# install.sh — registers scientifix-council with Claude Code
# Requires: python3, jq (or pure python3 fallback)
# Usage: bash install.sh [--marketplace-id ID] [--marketplace-path PATH]

set -euo pipefail

PLUGIN_NAME="scientifix-council"
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKETPLACE_ID="${1:-eyal-local}"
MARKETPLACE_PATH="${2:-$(dirname "$(dirname "$PLUGIN_DIR")")}"

CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
INSTALLED_FILE="$CLAUDE_DIR/plugins/installed_plugins.json"
KNOWN_FILE="$CLAUDE_DIR/plugins/known_marketplaces.json"
MARKETPLACE_JSON="$MARKETPLACE_PATH/.claude-plugin/marketplace.json"

echo "Installing $PLUGIN_NAME from $PLUGIN_DIR"
echo "Marketplace: $MARKETPLACE_ID at $MARKETPLACE_PATH"

# ── 1. installed_plugins.json ──────────────────────────────────────────────
python3 - <<PYEOF
import json, os, sys
from datetime import datetime

path = "$INSTALLED_FILE"
plugin_key = "$PLUGIN_NAME@$MARKETPLACE_ID"
plugin_dir = "$PLUGIN_DIR"

with open(path) as f:
    data = json.load(f)

plugins = data.setdefault("plugins", {})
entry = {
    "scope": "user",
    "installPath": plugin_dir,
    "version": "unknown",
    "installedAt": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.000Z"),
    "lastUpdated": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%S.000Z")
}
plugins[plugin_key] = [entry]

with open(path, "w") as f:
    json.dump(data, f, indent=2)

print(f"  ✓ installed_plugins.json — {plugin_key}")
PYEOF

# ── 2. known_marketplaces.json ──────────────────────────────────────────────
python3 - <<PYEOF
import json

path = "$KNOWN_FILE"
marketplace_id = "$MARKETPLACE_ID"
marketplace_path = "$MARKETPLACE_PATH"

with open(path) as f:
    data = json.load(f)

marketplaces = data.get("marketplaces", data if isinstance(data, list) else [])
if isinstance(data, dict):
    marketplaces = data.setdefault("marketplaces", [])

existing = [m for m in marketplaces if m.get("id") == marketplace_id]
if not existing:
    marketplaces.append({"id": marketplace_id, "path": marketplace_path})
    if isinstance(data, dict):
        data["marketplaces"] = marketplaces
    else:
        data = marketplaces
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print(f"  ✓ known_marketplaces.json — added {marketplace_id}")
else:
    print(f"  ✓ known_marketplaces.json — {marketplace_id} already present")
PYEOF

# ── 3. settings.json/extraKnownMarketplaces ─────────────────────────────────
python3 - <<PYEOF
import json

path = "$SETTINGS_FILE"
marketplace_id = "$MARKETPLACE_ID"
marketplace_path = "$MARKETPLACE_PATH"

with open(path) as f:
    data = json.load(f)

extra = data.setdefault("extraKnownMarketplaces", [])
existing = [m for m in extra if m.get("id") == marketplace_id]
if not existing:
    extra.append({"id": marketplace_id, "path": marketplace_path})
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print(f"  ✓ settings.json/extraKnownMarketplaces — added {marketplace_id}")
else:
    print(f"  ✓ settings.json/extraKnownMarketplaces — {marketplace_id} already present")
PYEOF

# ── 4. settings.json/enabledPlugins ─────────────────────────────────────────
python3 - <<PYEOF
import json

path = "$SETTINGS_FILE"
plugin_key = "$PLUGIN_NAME@$MARKETPLACE_ID"

with open(path) as f:
    data = json.load(f)

enabled = data.setdefault("enabledPlugins", {})
enabled[plugin_key] = True

with open(path, "w") as f:
    json.dump(data, f, indent=2)

print(f"  ✓ settings.json/enabledPlugins — {plugin_key}: true")
PYEOF

# ── 5. marketplace.json index entry ─────────────────────────────────────────
if [ -f "$MARKETPLACE_JSON" ]; then
python3 - <<PYEOF
import json

path = "$MARKETPLACE_JSON"
plugin_name = "$PLUGIN_NAME"
plugin_dir = "$PLUGIN_DIR"
marketplace_path = "$MARKETPLACE_PATH"

# Compute relative source path
import os
rel = os.path.relpath(plugin_dir, marketplace_path)

with open(path) as f:
    data = json.load(f)

plugins = data.get("plugins", [])
existing = [p for p in plugins if p.get("name") == plugin_name]
if not existing:
    plugins.append({
        "name": plugin_name,
        "description": "5-agent epistemic council — /scientifix evaluates ideas, /scientifix-plan converts them into ranked build sequences.",
        "category": "productivity",
        "source": f"./{rel}"
    })
    data["plugins"] = plugins
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
    print(f"  ✓ marketplace.json — {plugin_name} added")
else:
    print(f"  ✓ marketplace.json — {plugin_name} already listed")
PYEOF
else
    echo "  ⚠ $MARKETPLACE_JSON not found — create it manually if loader rejects install"
fi

echo ""
echo "Installation complete. Run /reload-plugins in Claude Code to activate."
echo "Verify with /plugin — look for scientifix-council with 2 commands, 5 agents, 2 skills."
