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
echo -e "\nexport PATH=\"\$HOME/.local/nvim/bin:\$PATH\"" >> ~/.bashrc
rm nvim-linux-x86_64.tar.gz

cd ~/.local/bin || exit
sudo apt-get update && sudo apt-get install -y ripgrep

# make sure no one else has nvim before running
sudo rm -rf ~/.config/nvim
sudo rm -rf ~/.local/state/nvim
sudo rm -rf ~/.local/share/nvim

ln -sfn "$INSTALL_DIR"/nvim "$HOME/.config/nvim"

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
mkdir -p $HOME/.local/share/fonts
mv "$(pwd)"/*.ttf $HOME/.local/share/fonts/
rm LICENSE.md README.md
fc-cache -fv

rm Hack.zip

gsettings set org.gnome.desktop.interface font-name 'Hack Nerd Font Regular 10'

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
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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

