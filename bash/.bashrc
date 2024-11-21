export TZ="Asia/Kolkata"

# Customize the prompt
light_green="\[\e[1;32m\]"
light_red="\[\e[1;31m\]"
yellow="\[\033[1;33m\]"
gray="\[\e[0;37m\]"
reset="\[\e[m\]"
export PROMPT_DIRTRIM=2
export PS1="${yellow}[\w] ${light_green}\$ ${reset}"

# Source the aliases file if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Use vi mode
set -o vi
# Use vim everywhere!
export EDITOR=vim

# Make concurrent bash history updates work correctly
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Save more history
HISTSIZE=1000000000
HISTFILESIZE=100000000
HISTCONTROL=$HISTCONTROL:ignoredups

# Make sound input work
amixer set "Capture" 25% > /dev/null

# Source git command completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

# FZF shell magic
eval "$(fzf --bash)"

# Modifying the $PATH variable
export GEM_HOME="$HOME/rubygems"
export PATH="/var/lib/flatpak/exports/bin:$PATH"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

