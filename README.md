dotfiles
My personal dotfiles

Pre-requisite
sudo apt install stow

Installation
Clone the repo to your $HOME directory: git@github.com:Tomerfi1210/.dotfiles.git
Run stow on the folders: cd ~/.dotfiles && for dir in */; do stow "$dir"; done
