###############################################################################################
# COMMON THINGS

export TZ="Asia/Kolkata"

# Command prompt
light_green="\[\e[1;32m\]"
light_red="\[\e[1;31m\]"
yellow="\[\e[0;33m\]"
gray="\[\e[0;37m\]"
reset="\[\e[m\]"
prompt_command() {
  local status="$?"
  local status_color=""
  if [ $status != 0 ]; then
    status_color=$light_red
  else
    status_color=$light_green
  fi
  export PS1="[${yellow}\w${reset}]${gray}${reset} ${status_color}\$${reset} "
}
export PROMPT_DIRTRIM=2
export PROMPT_COMMAND=prompt_command
# Command prompt end

# Make sound input work
amixer set "Capture" 25% > /dev/null

# Source the aliases file if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Use vi mode
set -o vi

# Update bash history in realtime (useful when multiple terminals open)
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Save more history
HISTSIZE=1000000000000000
HISTFILESIZE=100000000000000000

HISTCONTROL=$HISTCONTROL:ignoredups

##########################################################################################
# LAPTOP ONLY THINGS

# Source git command completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    . /usr/share/bash-completion/completions/git
fi

# Modifying the $PATH variable
export GEM_HOME="$HOME/rubygems"
export PATH="$HOME/rubygems/bin:$PATH"
export PATH="/var/lib/flatpak/exports/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Enable fzf keybindings
source /usr/share/doc/fzf/examples/key-bindings.bash
