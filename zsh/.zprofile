# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
# Q pre block. Keep at the top of this file.
eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="/Applications/PyCharm.app/Contents/MacOS:${PATH}"

# if [ -d ".venv" ]; then
#     source .venv/bin/activate
# fi

source ~/zesty/tomer/.venv/bin/activate

code() { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args "$*"; }

export K9S_CONFIG_DIR="$HOME/.config/k9s"
export TERM="tmux-256color"
export NVIM_THEME="catppuccin"
export KUBE_EDITOR="nvim"
alias sso='aws sso login --sso-session zesty'
alias k='kubecolor'
alias ctx='kubectx'

source ~/.local/scripts/bind_session.sh

source <(fzf --zsh)

# Q post block. Keep at the bottom of this file.
# Setting PATH for Python 3.11
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.11/bin:${PATH}"
export PATH

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
