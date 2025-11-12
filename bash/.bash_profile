# .bash_profile
[ -r ~/.bashrc ] && . ~/.bashrc
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi


. "$HOME/.atuin/bin/env"
