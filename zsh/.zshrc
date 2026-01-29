set -o vi

source ~/.bash_aliases

# For vim mode to work
bindkey "^H" backward-delete-char
bindkey "^?" backward-delete-char

# --- Start of converted .inputrc settings ---

# C-L: clear-display
bindkey '^L' clear-screen

# set bell-style none
setopt NO_BEEP

# set completion-ignore-case on
setopt NO_CASE_GLOB

# set show-all-if-ambiguous on
# Automatically show the completion menu if there are multiple options
setopt AUTO_MENU

# set show-all-if-unmodified on
# Complete common part, then enter menu to allow cycling through options
setopt MENU_COMPLETE

# --- End of converted .inputrc settings ---

# Source brew stuff if required
[ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Source git command completions
autoload -Uz compinit && compinit

# PATH additions
path+=('/Users/apb/bin')


eval "$(starship init zsh)"
