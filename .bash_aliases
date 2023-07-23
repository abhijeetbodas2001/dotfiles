alias diff="diff --color=always"

# Use visual mode
alias mkdir='mkdir -v'

alias less='less -R'

alias suu='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'

alias jdate='echo "date: $(date "+%F %T") +5:30"'

alias nv='io.neovim.nvim'

# To be used as:
# `gd 0` to see diff of the latest commit
# `gd 1` to see the diff of the second last commit, and so on.
# Make sure that git's `diff.tool` config is set to something like `vimdiff`
gd() {
    git diff-tree --no-commit-id --name-only -r HEAD~$1 | fzf | xargs -o git difftool --no-prompt --extcmd="vimdiff" HEAD~$1..HEAD~$1^;
}
