#!/usr/bin/env bash
set -euo pipefail

: "${HOME:?HOME is not set}"

if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
  printf 'DEEPSEEK_API_KEY is not set, nothing to do.\n'
  exit 0
fi

npm install -g @vegamo/deepcode-cli

umask 077 # dir 700, file 600 from the start instead of chmod afterwards
mkdir -p "$HOME/.deepcode"

SETTINGS="$HOME/.deepcode/settings.json"

# API keys are arbitrary strings; a plain heredoc breaks the JSON if the key
# contains a quote or backslash. Prefer python's json writer, fall back to a
# careful sed escape.
if command -v python3 >/dev/null 2>&1; then
  KEY="$DEEPSEEK_API_KEY" python3 - "$SETTINGS" <<'PY'
import json, os, sys

settings = {
    "env": {
        "MODEL": "deepseek-v4-pro",
        "BASE_URL": "https://api.deepseek.com",
        "API_KEY": os.environ["KEY"],
    },
    "thinkingEnabled": True,
    "reasoningEffort": "max",
}

with open(sys.argv[1], "w", encoding="utf-8") as fh:
    json.dump(settings, fh, indent=2)
    fh.write("\n")
PY
else
  esc_key="$(printf '%s' "$DEEPSEEK_API_KEY" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  cat > "$SETTINGS" <<EOF
{
  "env": {
    "MODEL": "deepseek-v4-pro",
    "BASE_URL": "https://api.deepseek.com",
    "API_KEY": "$esc_key"
  },
  "thinkingEnabled": true,
  "reasoningEffort": "max"
}
EOF
fi

chmod 600 "$SETTINGS"
printf 'Wrote %s\n' "$SETTINGS"
