# Zsh autocomplete and history setup.
if type brew >/dev/null 2>&1; then
  brew_prefix="$(brew --prefix)"
  FPATH="$brew_prefix/share/zsh-completions:$FPATH"
fi

# PATH entries from previous zsh config.
export PATH="$PATH:$HOME/bin"
if command -v go >/dev/null 2>&1; then
  export PATH="$(go env GOPATH)/bin:$PATH"
fi

autoload -Uz compinit
compinit

# Better completion behavior.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

if [[ -t 0 && -t 1 ]]; then
  # fzf key bindings and shell integration.
  if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  fi

  # Fuzzy tab completion.
  if [[ -n "$brew_prefix" && -r "$brew_prefix/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh" ]]; then
    source "$brew_prefix/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
  fi

  # Inline autosuggestions from shell history.
  if [[ -n "$brew_prefix" && -r "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$brew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  # Atuin history search.
  if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
  fi

  # Smarter directory jumping.
  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
  fi

  # Terragrunt alias from previous config.
  if command -v terragrunt >/dev/null 2>&1; then
    alias tg="terragrunt"
  fi

  # Terraform completion from previous config.
  if [[ -x /opt/homebrew/bin/terraform ]]; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /opt/homebrew/bin/terraform terraform
  fi

  # Edit the current command line in Neovim with Ctrl-x Ctrl-e.
  if command -v nvim >/dev/null 2>&1; then
    export EDITOR="nvim"
    export VISUAL="nvim"
    autoload -Uz edit-command-line
    zle -N edit-command-line
    bindkey "^X^E" edit-command-line
  fi

  # Starship prompt.
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi

fi
