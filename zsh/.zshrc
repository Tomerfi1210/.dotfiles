# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
export PATH=$PATH:~/bin
plugins=(
git
aws
terraform
kubectl
vscode
azure
terragrunt
)

alias tg="terragrunt"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
# Q post block. Keep at the bottom of this file.


# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
