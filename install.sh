curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
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

ln -s "$(pwd)"/nvim ~/.config/nvim

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Hack.zip
unzip Hack.zip
mkdir -p $HOME/.local/share/fonts
mv "$(pwd)"/*.ttf $HOME/.local/share/fonts/
rm LICENSE.md README.md
fc-cache -fv

rm Hack.zip

gsettings set org.gnome.desktop.interface font-name 'Hack Nerd Font Regular 10'

sudo apt install tmux
