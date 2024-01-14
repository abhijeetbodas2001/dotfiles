# Use visual mode
alias mkdir='mkdir -v'

alias less='less -R'

alias suu='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'

alias jdate='echo "date: $(date "+%F %T") +5:30"'
alias vf="fzf | xargs vim"
alias nv="nvim"

# Compile and run last updated C++ file in the current directory
# luc = Last Updated C++ (file)
luc() {
    if [[ "$PWD" == /home/apb/code/dsa/codeforces ]]; then
        clang++ -std=c++17 -fsanitize=address $(ls -alt | grep \.cpp | rev | cut --delimiter=\  --fields=1 | rev | head -n1) && ./a.out
    else
        echo "luc should be run only from /code/dsa/codeforces"
    fi
}

# Create new file from template for a new problem
# np = New Problem
np() {
    cat ~/code/dsa/codeforces/template.cpp > ~/code/dsa/codeforces/$1.cpp
}

# To be used as:
# `gd 0` to see diff of the latest commit
# `gd 1` to see the diff of the second last commit, and so on.
# Make sure that git's `diff.tool` config is set to something like `vimdiff`
gd() {
    git diff-tree --no-commit-id --name-only -r HEAD~$1 | fzf | xargs -o git difftool --no-prompt --extcmd="vimdiff" HEAD~$1..HEAD~$1^;
}

# Start and stop keyd daemon
alias k="sudo systemctl start keyd"
alias K="sudo systemctl stop keyd"
