# dotfiles

Personal dotfiles managed with GNU Stow.

## Install

Install dependencies:

```sh
brew install stow neovim git ripgrep fd lazygit starship tmux go node python jq
```

Clone and stow:

```sh
git clone git@github.com:Tomerfi1210/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow */
```

Stow one package:

```sh
stow nvim
```

## Notes

`stow` only creates symlinks. Install app-specific tools separately if needed, like Ghostty, WezTerm, AeroSpace, SketchyBar, K9s, and Raycast.
