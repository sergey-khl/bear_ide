curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
rm nvim-linux-x86_64.tar.gz

sudo apt-get update && sudo apt-get install -y ripgrep

# make sure no one else has nvim before running
rm -rf ~/.config/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim

ln -s "$(pwd)"/nvim ~/.config/nvim

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
mkdir -p $HOME/.local/share/fonts
mv "$(pwd)"/*.ttf $HOME/.local/share/fonts/
rm LICENSE.md README.md
fc-cache -fv
fc-list

rm Hack.zip

gsettings set org.gnome.desktop.interface font-name 'Hack Nerd Font Regular 10'

