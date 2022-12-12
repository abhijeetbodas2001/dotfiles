# Source the aliases file if it exists
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Use vi mode
set -o vi

# Save more history
HISTSIZE=10000
HISTFILESIZE=10000

# Install Ruby gems to ~/rubygems
export GEM_HOME="$HOME/rubygems"
export PATH="$HOME/rubygems/bin:$PATH"

# For CS631 project
# Edit: Instead of using environment variables, add the PGJDBC build in VSCode,
# and run from VSC, which will use the appropriate command line options
# export CLASSPATH=/home/abhijeetbodas2001/code/pgjdbc/pgjdbc/build/libs/postgresql-42.5.1-SNAPSHOT.jar:/home/abhijeetbodas2001/code/CS631-java-app

# Check is fzf is installed. Only is yes, activate the keybindings
if command -v fzf &> /dev/null
then
# Search bash history using fzf
# Copied from https://github.com/junegunn/fzf/blob/master/shell/key-bindings.bash
__fzfcmd() {
  [[ -n "${TMUX_PANE-}" ]] && { [[ "${FZF_TMUX:-0}" != 0 ]] || [[ -n "${FZF_TMUX_OPTS-}" ]]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

__fzf_history__() {
  local output opts script
  opts="--height ${FZF_TMUX_HEIGHT:-40%} --bind=ctrl-z:ignore ${FZF_DEFAULT_OPTS-} -n2..,.. --bind=ctrl-r:toggle-sort ${FZF_CTRL_R_OPTS-} +m --read0"
  script='BEGIN { getc; $/ = "\n\t"; $HISTCOUNT = $ENV{last_hist} + 1 } s/^[ *]//; print $HISTCOUNT - $. . "\t$_" if !$seen{$_}++'
  output=$(
    builtin fc -lnr -2147483648 |
      last_hist=$(HISTTIMEFORMAT='' builtin history 1) perl -n -l0 -e "$script" |
      FZF_DEFAULT_OPTS="$opts" $(__fzfcmd) --query "$READLINE_LINE"
  ) || return
  READLINE_LINE=${output#*$'\t'}
  if [[ -z "$READLINE_POINT" ]]; then
    echo "$READLINE_LINE"
  else
    READLINE_POINT=0x7fffffff
  fi
}
bind -m vi-command -x '"\C-r": __fzf_history__'
bind -m vi-insert -x '"\C-r": __fzf_history__'
fi



# Use the starship prompt. Keep this line at the end
# of the .bashrc
eval "$(starship init bash)"

# Only comments here on.
# !$ -> last argument of last command
# !! -> the entire last command
