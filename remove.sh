#!/bin/bash

set -e

# remove nvm
rm -rf "$HOME/.nvm"
sed -i '/export NVM_DIR="\$HOME\/.nvm"/d' "$HOME/.bashrc"
sed -i '/\[ -s "\$NVM_DIR\/nvm.sh" \] && \\. "\$NVM_DIR\/nvm.sh"/d' "$HOME/.bashrc"
sed -i '/\[ -s "\$NVM_DIR\/bash_completion" \] && \\. "\$NVM_DIR\/bash_completion"/d' "$HOME/.bashrc"

echo "Removing Tmux..."
sudo apt-get remove -y tmux
# Remove the configuration symlink
if [ -L "$HOME/.tmux.conf" ]; then
    rm "$HOME/.tmux.conf"
    echo "Tmux config symlink removed."
fi

echo "Removing Hack Nerd Fonts..."
rm -f "$HOME/.local/share/fonts/Hack"*.ttf
rm -f "$HOME/.local/share/fonts/NerdFontMono-Regular.ttf" 2>/dev/null
fc-cache -fv

echo "Resetting Gnome terminal font to system default..."
gsettings reset org.gnome.desktop.interface font-name

sudo rm -rf "$HOME/.local/nvim"

if [ -L "$HOME/.config/nvim" ]; then
    sudo rm "$HOME/.config/nvim"
    echo "Neovim config symlink removed."
fi

sudo rm -rf "$HOME/.local/state/nvim"
sudo rm -rf "$HOME/.local/share/nvim"

sed -i '\|export PATH="\$HOME/.local/nvim/bin:\$PATH"|d' "$HOME/.bashrc"


# im still keeping lg and some other packages since they shouldnt interfere with reinstall
