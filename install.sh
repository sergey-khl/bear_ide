#!/bin/bash

# NOTES
# after install make sure to :Lazy and then sync
# also make sure to do :MasonToolsInstall and check mason that 
# everything you need is there

mkdir -p ~/.local
mkdir -p ~/.local/bin
mkdir -p ~/.config

INSTALL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# neovim install 
UBUNTU_VER=$(lsb_release -rs | cut -d. -f1)
if [ "$UBUNTU_VER" -gte 22 ]; then
    echo "Version is >= 22. Installing latest stable Neovim..."
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
else
    echo "Version is < 22. Installing Neovim for older Linux..."
    curl -LO https://github.com/neovim/neovim-releases/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz
fi

sudo rm -rf ~/.local/nvim
sudo tar -C ~/.local -xzf nvim-linux-x86_64.tar.gz
mv ~/.local/nvim-linux-x86_64 ~/.local/nvim
rm nvim-linux-x86_64.tar.gz

cd ~/.local/bin || exit
sudo apt-get update && sudo apt-get install -y ripgrep

# make sure no one else has nvim before running
sudo rm -rf ~/.config/nvim
sudo rm -rf ~/.local/state/nvim
sudo rm -rf ~/.local/share/nvim
sudo rm -rf "$HOME/.oh-my-zsh"

ln -sfn "$INSTALL_DIR"/nvim "$HOME/.config/nvim"

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
mkdir -p $HOME/.local/share/fonts
mv "$(pwd)"/*.ttf $HOME/.local/share/fonts/
rm -f LICENSE.md README.md Hack.zip
fc-cache -fv

# kitty terminal
sudo apt install kitty
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

# fzf
export FZF_BASE="$HOME/.fzf"
[ -f "$HOME/.fzf/key-bindings.zsh" ] && source "$HOME/.fzf/key-bindings.zsh"
[ -f "$HOME/.fzf/completion.zsh" ] && source "$HOME/.fzf/completion.zsh"

# nvim + local bin on PATH
export PATH="$HOME/.local/nvim/bin:$HOME/.local/bin:$PATH"

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
sudo apt install tmux
ln -sfn "$INSTALL_DIR"/.tmux.conf "$HOME/.tmux.conf"

# git manager
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit
rm lazygit.tar.gz

# ensure npm installed
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# load nvm immediately
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

nvm install v18.19.1
nvm use v18.19.1

# load node immediately
export PATH="$NVM_DIR/versions/node/v18.19.1/bin:$PATH"

sudo apt install python3-venv # needed for some lsp
npm install -g npm@9.2.0

if [ "$UBUNTU_VER" -gte 22 ]; then
    echo "Version is >= 22. Installing latest stable treesitter..."
    npm install -g tree-sitter-cli@0.26.3
else
    echo "Version is < 22. Installing treesitter for older Linux..."
    npm install -g tree-sitter-cli@0.22.6
fi

echo "Done! Log out and back in for zsh to become your default shell."
