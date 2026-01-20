# NOTES
# after install make sure to :Lazy and then sync
# also make sure to do :MasonToolsInstall and check mason that 
# everything you need is there

# neovim install 
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

ln -sfn "$(pwd)"/nvim "$HOME/.config/nvim"

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
ln -sfn "$(pwd)"/.tmux.conf $HOME/.tmux.conf

# git manager
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit
rm lazygit.tar.gz

# encrypted syncing
# install v1.70.3 from https://rclone.org/downloads/
sudo npm install @dotenvx/dotenvx --save -g

