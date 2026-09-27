#!/usr/bin/env bash
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

: "${HOME:?HOME is not set}"
INSTALL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

CAN_APT=true
if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
  CAN_APT=false
  warn "not root and no sudo; system packages will be left installed"
fi

remove_path() { # remove_path <path>
  { [ -e "$1" ] || [ -L "$1" ]; } || return 0
  rm -rf -- "$1"
  log "removed $1"
}

# Only delete a symlink if it actually points back into this repo. Anything
# else is left alone so we never nuke a config dir we do not own.
remove_repo_symlink() { # remove_repo_symlink <path>
  [ -L "$1" ] || return 0
  local target
  target="$(readlink -f -- "$1" 2>/dev/null || true)"
  case "$target" in
    "$INSTALL_DIR"/*) rm -f -- "$1"; log "removed $1" ;;
    *) warn "left $1 alone (symlink -> ${target:-?}, not this repo)" ;;
  esac
}

apt_remove() { # apt_remove <pkg>...
  [ "$CAN_APT" = true ] || return 0
  command -v dpkg >/dev/null 2>&1 || return 0
  local pkg
  for pkg in "$@"; do
    if dpkg -s "$pkg" >/dev/null 2>&1; then
      log "removing package: $pkg"
      $SUDO apt-get remove -y "$pkg"
    fi
  done
}

#-- neovim ---------------------------------------------------------------------

remove_repo_symlink "$HOME/.config/nvim"
remove_path "$HOME/.local/nvim"
remove_path "$HOME/.local/state/nvim"
remove_path "$HOME/.local/share/nvim"

#-- tmux / kitty ---------------------------------------------------------------

remove_repo_symlink "$HOME/.tmux.conf"
remove_path "$HOME/.config/kitty"
apt_remove tmux kitty

#-- fonts ----------------------------------------------------------------------

if [ -d "$HOME/.local/share/fonts" ]; then
  log "removing Hack / Nerd fonts"
  rm -f "$HOME/.local/share/fonts/Hack"*.ttf
  rm -f "$HOME/.local/share/fonts/NerdFontMono-Regular.ttf"
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null 2>&1 || true
fi

#-- standalone binaries --------------------------------------------------------

remove_path "$HOME/.local/bin/fzf"
remove_path "$HOME/.local/bin/lazygit"
remove_path "$HOME/.fzf"

#-- node / nvm -----------------------------------------------------------------

remove_path "$HOME/.nvm"

#-- zsh ------------------------------------------------------------------------

# install.sh moves the previous rc files aside before overwriting them; put the
# newest one back if there is one.
newest_backup() { # newest_backup <glob-prefix>
  local candidate="" f
  for f in "$1"*; do
    [ -e "$f" ] || continue
    if [ -z "$candidate" ] || [ "$f" -nt "$candidate" ]; then
      candidate="$f"
    fi
  done
  printf '%s' "$candidate"
}

zshrc_backup="$(newest_backup "$HOME/.zshrc.bak.")"
if [ -n "$zshrc_backup" ]; then
  rm -f "$HOME/.zshrc"
  mv -- "$zshrc_backup" "$HOME/.zshrc"
  log "restored ~/.zshrc from $zshrc_backup"
else
  # No backup: just drop the lines we added, leave the rest of the file intact.
  for rc in "$HOME/.zshrc" "$HOME/.bashrc"; do
    [ -f "$rc" ] || continue
    sed -i -e '/NVM_DIR/d' \
           -e '\|export PATH="\$HOME/.local/nvim/bin:\$PATH"|d' \
           -e '\|export PATH="\$HOME/.local/bin:\$PATH"|d' "$rc"
  done
fi

omz_backup="$(newest_backup "$HOME/.oh-my-zsh.bak.")"
remove_path "$HOME/.oh-my-zsh"
if [ -n "$omz_backup" ]; then
  mv -- "$omz_backup" "$HOME/.oh-my-zsh"
  log "restored ~/.oh-my-zsh from $omz_backup"
fi

log "Removal complete. Restart your shell (or log out) to drop the PATH changes."
