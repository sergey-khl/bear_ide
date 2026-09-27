#!/bin/bash

# NOTES
# after install make sure to :Lazy and then sync
# also make sure to do :MasonToolsInstall and check mason that 
# everything you need is there

mkdir -p ~/.local
mkdir -p ~/.local/bin
mkdir -p ~/.config

INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ARCH="$(uname -m)"
NVIM_ARCH="x86_64"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    NVIM_ARCH="arm64"
fi

# neovim install 
UBUNTU_VER=$(lsb_release -rs 2>/dev/null | cut -d. -f1)
if [ -z "$UBUNTU_VER" ] && [ -f /etc/os-release ]; then
    UBUNTU_VER=$(. /etc/os-release && echo "${VERSION_ID%%.*}")
fi
if [ -n "$UBUNTU_VER" ] && [ "$UBUNTU_VER" -ge 22 ]; then
    curl -LO "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${NVIM_ARCH:-x86_64}.tar.gz"
else
    echo "Version is < 22 (or unknown). Installing Neovim for older Linux..."
    curl -LO "https://github.com/neovim/neovim-releases/releases/download/v0.11.5/nvim-linux-${NVIM_ARCH:-x86_64}.tar.gz"
fi

rm -rf ~/.local/nvim
tar -C ~/.local -xzf "nvim-linux-${NVIM_ARCH}.tar.gz"
mv "$HOME/.local/nvim-linux-${NVIM_ARCH}" ~/.local/nvim
rm "nvim-linux-${NVIM_ARCH}.tar.gz"

cd ~/.local/bin || exit
sudo apt-get update && sudo apt-get install -y ripgrep xsel wl-clipboard

# make sure no one else has nvim before running
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
rm -rf "$HOME/.oh-my-zsh"

ln -sfn "$INSTALL_DIR"/nvim "$HOME/.config/nvim"

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
mkdir -p $HOME/.local/share/fonts
mv "$(pwd)"/*.ttf $HOME/.local/share/fonts/
rm -f LICENSE.md README.md Hack.zip
fc-cache -fv

# kitty terminal
sudo apt install -y kitty
mkdir -p ~/.config/kitty
cat > ~/.config/kitty/kitty.conf << 'EOF'
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

clipboard_control write-clipboard read-clipboard write-primary read-primary

# new windows/tabs inherit cwd
map ctrl+shift+enter launch --cwd=current
map ctrl+shift+t launch --cwd=current --type=tab
map ctrl+shift+y launch --type=tab
EOF

cat > ~/.config/kitty/ssh.conf << 'EOF'
hostname *

color_scheme Dimmed Monokai
env KITTY_IS_REMOTE=true
EOF

# zsh + oh-my-zsh + plugins
sudo apt install -y zsh

# install oh-my-zsh unattended
RUNZSH=no CHSH=no sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

curl -fsSL https://github.com/junegunn/fzf/releases/download/v0.54.3/fzf-0.54.3-linux_amd64.tar.gz | \
  tar -xz -C "$HOME/.local/bin"
mkdir -p "$HOME/.fzf"
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/v0.54.3/shell/key-bindings.zsh \
  -o ~/.fzf/key-bindings.zsh
curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/v0.54.3/shell/completion.zsh \
  -o ~/.fzf/completion.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# write ~/.zshrc
cat > ~/.zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# -- Environment tag in prompt --
# Capture robbyrussell's prompt before we touch it
_BASE_PROMPT="$PROMPT"

_get_env_tag() {
  # SSH: check standard vars + kitty's remote marker
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

export DEEPSEEK_API_KEY=""
export DEEPSEEK_USE_LOCAL=false

alias lg="lazygit"
alias ssh="kitten ssh"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF

# make zsh default shell
chsh -s "$(which zsh)"

# terminal multiplexer
sudo apt install -y tmux
ln -sfn "$INSTALL_DIR"/.tmux.conf "$HOME/.tmux.conf"

# git manager
LG_ARCH="x86_64"
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    LG_ARCH="arm64"
fi
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit -D -t /usr/local/bin/
rm lazygit
rm lazygit.tar.gz

# ensure npm installed
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# load nvm immediately
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm install v22.23.3
nvm install v18.19.1
nvm use v18.19.1

# load node immediately
export PATH="$NVM_DIR/versions/node/v18.19.1/bin:$PATH"

sudo apt install -y python3-venv # needed for some lsp
npm install -g npm@9.2.0

if [ -n "$UBUNTU_VER" ] && [ "$UBUNTU_VER" -ge 22 ]; then
    echo "Version is >= 22. Installing latest stable treesitter..."
    npm install -g tree-sitter-cli@0.26.3
else
    echo "Version is < 22 (or unknown). Installing treesitter for older Linux..."
    npm install -g tree-sitter-cli@0.22.6
fi

echo "Done! Log out and back in for zsh to become your default shell."
