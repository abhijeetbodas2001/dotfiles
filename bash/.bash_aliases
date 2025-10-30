alias mkdir='mkdir -v'
alias less='less -R'
alias wp="which python"
alias cf="cargo-fmt"
alias suu='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'
alias nvc='nvim -u ~/.vimrc' # nvim "clean" (but with some basic config)
alias cc='cd $(find ~/repos/ -maxdepth 1 | fzf)'
alias sv='source .venv/bin/activate'
alias sc='conda activate abhijeet_env_dev'
alias clear='/usr/bin/clear'
function rgb()
{
    rg --pretty "$@" | bat
}


