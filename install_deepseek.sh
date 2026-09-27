echo "Installing deepseek if DEEPSEEK_API_KEY set in rc"
if [ -n "${DEEPSEEK_API_KEY:-}" ]; then
  npm install -g @vegamo/deepcode-cli
 
  mkdir -p "$HOME/.deepcode"
  cat > "$HOME/.deepcode/settings.json" << EOF
{
  "env": {
    "MODEL": "deepseek-v4-pro",
    "BASE_URL": "https://api.deepseek.com",
    "API_KEY": "$DEEPSEEK_API_KEY"
  },
  "thinkingEnabled": true,
  "reasoningEffort": "max"
}
EOF
  chmod 600 "$HOME/.deepcode/settings.json"
fi
