#!/usr/bin/env bash
set -euo pipefail

: "${HOME:?HOME is not set}"

npm install -g @vegamo/deepcode-cli

umask 077 # dir 700, file 600 from the start instead of chmod afterwards
mkdir -p "$HOME/.deepcode"

SETTINGS="$HOME/.deepcode/settings.json"

# Default to local ds4 model if no API key is provided
if [ -z "${DEEPSEEK_API_KEY:-}" ]; then
  printf 'DEEPSEEK_API_KEY is not set, defaulting to local ds4 model.\n'
  MODEL="DeepSeek-V4.1-Flash"
  BASE_URL="http://127.0.0.1:8008"
  API_KEY="local"
else
  MODEL="deepseek-v4-pro"
  BASE_URL="https://api.deepseek.com"
  API_KEY="$DEEPSEEK_API_KEY"
fi

if command -v python3 >/dev/null 2>&1; then
  MODEL="$MODEL" BASE_URL="$BASE_URL" API_KEY="$API_KEY" python3 - "$SETTINGS" <<'PY'
import json, os, sys

settings = {
    "env": {
        "MODEL": os.environ["MODEL"],
        "BASE_URL": os.environ["BASE_URL"],
        "API_KEY": os.environ["API_KEY"],
    },
    "thinkingEnabled": True,
    "reasoningEffort": "max",
}

with open(sys.argv[1], "w", encoding="utf-8") as fh:
    json.dump(settings, fh, indent=2)
    fh.write("\n")
PY
else
  esc_model="$(printf '%s' "$MODEL" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  esc_base_url="$(printf '%s' "$BASE_URL" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  esc_key="$(printf '%s' "$API_KEY" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  cat > "$SETTINGS" <<EOF
{
  "env": {
    "MODEL": "$esc_model",
    "BASE_URL": "$esc_base_url",
    "API_KEY": "$esc_key"
  },
  "thinkingEnabled": true,
  "reasoningEffort": "max"
}
EOF
fi

chmod 600 "$SETTINGS"
printf 'Wrote %s\n' "$SETTINGS"
