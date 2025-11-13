set -o vi

source ~/.bash_aliases

# Source brew stuff if required
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Source git command completions
autoload -Uz compinit && compinit


eval "$(starship init zsh)"
# Bind ctrl-r but not up arrow
eval "$(atuin init zsh --disable-up-arrow)"

. "$HOME/.atuin/bin/env"
