# =========================
# ZSHRC (fixed + ordered)
# =========================

# If this isn't an interactive shell (e.g., zsh -c, some tools, nvim jobs),
# don't run completion/plugin init that can explode.
[[ -o interactive ]] || return 0

# --- Zsh completion (must be early) ---
autoload -Uz compinit
compinit

# -------------------------
# Kiro CLI pre block. Keep at the top of this file.
# -------------------------
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# -------------------------
# PATH
# -------------------------
export PATH="$PATH:$HOME/bin"
export PATH="$(go env GOPATH)/bin:$PATH"

# -------------------------
# Plugins (if you're using oh-my-zsh / similar)
# NOTE: this line alone doesn't load plugins unless a framework loads them.
# -------------------------
plugins=(
  git
  aws
  terraform
  kubectl
  vscode
  azure
  terragrunt
)

# -------------------------
# Aliases
# -------------------------
alias tg="terragrunt"

# -------------------------
# Tools init
# -------------------------
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# -------------------------
# Terraform completion
# Prefer native terraform autocomplete when possible.
# (Avoid bash 'complete' unless you truly need it.)
# -------------------------
if command -v terraform >/dev/null 2>&1; then
  # Try terraform native autocomplete (recommended)
  # If your terraform doesn't support this, comment it and use the bashcompinit block below.
  terraform -install-autocomplete >/dev/null 2>&1

  # OPTIONAL fallback (only if you *must* use the bash-style completion):
  # autoload -U +X bashcompinit && bashcompinit
  # complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

# -------------------------
# Kiro CLI post block. Keep at the bottom of this file.
# -------------------------
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
