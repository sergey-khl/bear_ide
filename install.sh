#!/usr/bin/env bash
set -euo pipefail

#-- helpers --------------------------------------------------------------------

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# True when version A is the same as or newer than version B. Uses `sort -V`
# so non-numeric / suffixed versions do not explode the script.
ge_ver() { [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]; }

# Move an existing file/dir aside instead of deleting it. Symlinks are removed.
backup() { # backup <path>
  local path="$1"
  { [ -e "$path" ] || [ -L "$path" ]; } || return 0
  if [ -L "$path" ]; then
    rm -f -- "$path"
    return 0
  fi
  local dest="${path}.bak.$(date +%Y%m%d%H%M%S)"
  mv -- "$path" "$dest"
  warn "backed up $path -> $dest"
}

download() { # download <url> <dest>
  log "Downloading $(basename "$2")"
  curl -fL --retry 3 --retry-delay 2 --connect-timeout 15 -o "$2" "$1" \
    || die "download failed: $1"
}

#-- preflight ------------------------------------------------------------------

: "${HOME:?HOME is not set}"
INSTALL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif have sudo; then
  SUDO="sudo"
else
  die "not root and sudo is unavailable; cannot install system packages"
fi

have apt-get || die "this installer targets Debian/Ubuntu (apt-get not found)"
have curl    || die "curl is required"

# Nothing gets unzipped / downloaded into whatever directory you ran this from.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

#-- platform detection ---------------------------------------------------------

case "$(uname -m)" in
  x86_64 | amd64)  NVIM_ARCH="x86_64"; FZF_ARCH="amd64"; LG_ARCH="x86_64" ;;
  aarch64 | arm64) NVIM_ARCH="arm64";  FZF_ARCH="arm64"; LG_ARCH="arm64" ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

OS_ID=""; OS_VER=""
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  OS_ID="${ID:-}"
  OS_VER="${VERSION_ID:-}"
fi

GLIBC_VER="$(ldd --version 2>/dev/null | awk 'NR==1{print $NF}' || true)"
[ -n "$GLIBC_VER" ] || GLIBC_VER="0"

# nvim's current tarballs need glibc >= 2.34 (Ubuntu 22.04+). Older systems
# (20.04, Debian 11, ...) need the "older glibc" release instead.
MODERN=true
if [ "$OS_ID" = "ubuntu" ] && [ -n "$OS_VER" ] && ! ge_ver "${OS_VER%%.*}" 22; then
  MODERN=false
elif ! ge_ver "$GLIBC_VER" 2.34; then
  MODERN=false
fi

log "arch=$NVIM_ARCH os=${OS_ID:-unknown}/${OS_VER:-?} glibc=$GLIBC_VER modern=$MODERN"

#-- system packages ------------------------------------------------------------

export DEBIAN_FRONTEND=noninteractive

log "Installing base packages"
$SUDO apt-get update
$SUDO apt-get install -y --no-install-recommends \
  ca-certificates curl git unzip wget ripgrep tmux zsh python3-venv

# GUI / clipboard helpers are optional: a headless container should not fail
# the whole install just because kitty cannot be installed.
$SUDO apt-get install -y --no-install-recommends kitty xsel wl-clipboard fontconfig \
  || warn "optional packages (kitty / xsel / wl-clipboard / fontconfig) failed to install"

mkdir -p "$HOME/.local/bin" "$HOME/.config" "$HOME/.local/share/fonts"

#-- neovim ---------------------------------------------------------------------

if [ "$MODERN" = true ]; then
  NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${NVIM_ARCH}.tar.gz"
else
  NVIM_URL="https://github.com/neovim/neovim-releases/releases/download/v0.11.5/nvim-linux-${NVIM_ARCH}.tar.gz"
  # The "older glibc" mirror only publishes x86_64 builds. Fall back to the
  # normal arm64 build and let the smoke test below tell us if it runs.
  if [ "$NVIM_ARCH" != "x86_64" ]; then
    warn "no older-glibc neovim build for $NVIM_ARCH; using the regular build"
    NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${NVIM_ARCH}.tar.gz"
  fi
fi
download "$NVIM_URL" "$WORK/nvim.tar.gz"

rm -rf "$HOME/.local/nvim" "$HOME/.local/nvim-linux-${NVIM_ARCH}"
tar -C "$HOME/.local" -xzf "$WORK/nvim.tar.gz"
[ -d "$HOME/.local/nvim-linux-${NVIM_ARCH}" ] \
  || die "unexpected neovim archive layout in $(basename "$NVIM_URL")"
mv "$HOME/.local/nvim-linux-${NVIM_ARCH}" "$HOME/.local/nvim"

# Smoke test: catches a glibc mismatch immediately instead of at first launch.
"$HOME/.local/nvim/bin/nvim" --version \
  || die "installed neovim does not run (likely glibc mismatch)"

#-- nvim config ----------------------------------------------------------------

backup "$HOME/.config/nvim"
rm -rf "$HOME/.local/state/nvim" "$HOME/.local/share/nvim"
ln -sfn "$INSTALL_DIR/nvim" "$HOME/.config/nvim"

#-- nerd fonts -----------------------------------------------------------------

download "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip" "$WORK/Hack.zip"
mkdir -p "$WORK/hack"
unzip -q -o "$WORK/Hack.zip" -d "$WORK/hack"
find "$WORK/hack" -name '*.ttf' -exec cp -f {} "$HOME/.local/share/fonts/" \;
if have fc-cache; then
  fc-cache -f >/dev/null 2>&1 || warn "fc-cache failed"
fi

#-- kitty ----------------------------------------------------------------------

mkdir -p "$HOME/.config/kitty"
cat > "$HOME/.config/kitty/kitty.conf" <<'EOF'
font_family      Hack Nerd Font
bold_font        Hack Nerd Font Bold
italic_font      Hack Nerd Font Italic
bold_italic_font Hack Nerd Font Bold Italic
font_size        11.0

# better for nvim
term xterm-256color
enable_audio_bell no

# start maximized
remember_window_size  no
initial_window_width  1920
initial_window_height 1080

# OSC 52: let programs WRITE (nvim yanks) but not READ the clipboard. Reading
# would let any host you ssh into read your local clipboard. `no-append`
# disables clipboard concatenation, which is what made yanks pile up.
clipboard_control write-clipboard write-primary no-append

# new windows/tabs inherit cwd
map ctrl+shift+enter launch --cwd=current
map ctrl+shift+t launch --cwd=current --type=tab
map ctrl+shift+y launch --type=tab
EOF

# Loaded by kitty's ssh integration; tells nvim it is remote so it shades the
# prompt and can pick the right clipboard strategy.
cat > "$HOME/.config/kitty/ssh.conf" <<'EOF'
hostname *

color_scheme Dimmed Monokai
env KITTY_IS_REMOTE=true
EOF

#-- zsh ------------------------------------------------------------------------

backup "$HOME/.zshrc"
backup "$HOME/.oh-my-zsh"

log "Installing oh-my-zsh"
download "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "$WORK/omz-install.sh"
RUNZSH=no CHSH=no sh "$WORK/omz-install.sh" || die "oh-my-zsh install failed"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  dest="$ZSH_CUSTOM/plugins/$plugin"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull --ff-only || warn "could not update $plugin"
  else
    git clone --depth 1 "https://github.com/zsh-users/$plugin" "$dest"
  fi
done

# fzf (arch aware - the old script always grabbed linux_amd64)
download "https://github.com/junegunn/fzf/releases/download/v0.54.3/fzf-0.54.3-linux_${FZF_ARCH}.tar.gz" "$WORK/fzf.tar.gz"
tar -xzf "$WORK/fzf.tar.gz" -C "$HOME/.local/bin"
mkdir -p "$HOME/.fzf"
download "https://raw.githubusercontent.com/junegunn/fzf/v0.54.3/shell/key-bindings.zsh" "$HOME/.fzf/key-bindings.zsh"
download "https://raw.githubusercontent.com/junegunn/fzf/v0.54.3/shell/completion.zsh" "$HOME/.fzf/completion.zsh"

cat > "$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# -- Environment tag in prompt --
# Capture robbyrussell's prompt before we touch it
_BASE_PROMPT="$PROMPT"

_get_env_tag() {
  # SSH: standard vars, or kitty's remote marker
  if [[ -n "${SSH_CLIENT}${SSH_TTY}" ]] || [[ -n "$KITTY_IS_REMOTE" ]]; then
    printf '%%F{yellow}[ssh:%s]%%f ' "$(hostname -s)"
  # Docker: /.dockerenv exists on all versions; cgroup fallback for edge cases
  elif [[ -f /.dockerenv ]] || grep -qaE 'docker|lxc' /proc/1/cgroup 2>/dev/null; then
    # Pass CONTAINER_NAME via `docker run -e CONTAINER_NAME=foo` for a real name,
    # otherwise falls back to the container's hostname (short ID)
    local cname="${CONTAINER_NAME:-$(hostname -s)}"
    printf '%%F{cyan}[docker:%s]%%f ' "$cname"
  fi
}

_prepend_env_tag() {
  PROMPT="$(_get_env_tag)${_BASE_PROMPT}"
}

add-zsh-hook precmd _prepend_env_tag
# -- end env tag --

# fzf
export FZF_BASE="$HOME/.fzf"
[ -f "$HOME/.fzf/key-bindings.zsh" ] && source "$HOME/.fzf/key-bindings.zsh"
[ -f "$HOME/.fzf/completion.zsh" ] && source "$HOME/.fzf/completion.zsh"

# nvim + local bin on PATH
export PATH="$HOME/.local/nvim/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Don't clobber a key that is already exported.
export DEEPSEEK_API_KEY="${DEEPSEEK_API_KEY:-}"
export DEEPSEEK_USE_LOCAL=false

alias lg="lazygit"

# Use kitty's ssh integration when we are actually inside kitty, otherwise fall
# back to plain ssh. `kitten` only exists as a standalone command in newer kitty;
# older kitty (0.15 on Ubuntu 20.04) only has `kitty +kitten`.
ssh() {
  if [[ -n "$KITTY_PID$KITTY_LISTEN_ON" ]]; then
    if command -v kitten >/dev/null 2>&1; then
      command kitten ssh "$@"
      return
    elif command -v kitty >/dev/null 2>&1; then
      command kitty +kitten ssh "$@"
      return
    fi
  fi
  command ssh "$@"
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

#-- tmux -----------------------------------------------------------------------

backup "$HOME/.tmux.conf"
ln -sfn "$INSTALL_DIR/.tmux.conf" "$HOME/.tmux.conf"

#-- lazygit --------------------------------------------------------------------

LG_API="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
LG_VERSION="$(curl -fsSL "$LG_API" 2>/dev/null \
  | sed -n 's/.*"tag_name":[[:space:]]*"v\([^"]*\)".*/\1/p' | head -n1 || true)"
if [ -z "$LG_VERSION" ]; then
  LG_VERSION="0.65.1"
  warn "could not detect the latest lazygit; falling back to $LG_VERSION"
fi
download "https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_Linux_${LG_ARCH}.tar.gz" "$WORK/lazygit.tar.gz"
tar -xzf "$WORK/lazygit.tar.gz" -C "$WORK" lazygit
install -m 0755 "$WORK/lazygit" "$HOME/.local/bin/lazygit"

#-- node / nvm -----------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  download "https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh" "$WORK/nvm-install.sh"
  bash "$WORK/nvm-install.sh"
fi
# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

nvm install v18.19.1
nvm alias default v18.19.1 >/dev/null
nvm use v18.19.1 >/dev/null
export PATH="$NVM_DIR/versions/node/v18.19.1/bin:$PATH"

npm install -g npm@9.2.0
if [ "$MODERN" = true ]; then
  npm install -g tree-sitter-cli@0.26.3
else
  npm install -g tree-sitter-cli@0.22.6
fi

#-- default shell --------------------------------------------------------------

ZSH_BIN="$(command -v zsh || true)"
if [ -n "$ZSH_BIN" ] && [ "${SHELL:-}" != "$ZSH_BIN" ]; then
  chsh -s "$ZSH_BIN" || warn "could not change your shell; run: chsh -s $ZSH_BIN"
fi

#-- done -----------------------------------------------------------------------

log "Install complete."
cat <<'EOF'

Next steps:
  1. nvim  ->  :Lazy sync
  2. nvim  ->  :MasonToolsInstall
  4. optional: DEEPSEEK_API_KEY=... bash install_deepseek.sh
EOF
