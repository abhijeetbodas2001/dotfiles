alias mkdir='mkdir -v'
alias less='less -R'
alias jdate='echo "date: $(date "+%F %T") +5:30"'
alias wp="which python"
alias nv="nvim"
alias nvc="nvim --clean"
alias f="vifm"
alias suu='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'
alias python='python3'
alias clangd='clangd-18'
alias nvc='nvim -u ~/.vimrc' # nvim "clean" (but with some basic config)

# Compile and run last updated C++ file
# luc = Last Updated C++ (file)
luc() {
    if [[ "$PWD" == /home/apb/code/dsa/codeforces ]]; then
        clang-format -i *.cpp -style=file
        clang++ -std=c++20 $(ls -alt | grep \.cpp | rev | cut --delimiter=\  --fields=1 | rev | head -n1) && ./a.out
    else
        echo "luc should be run only from /code/dsa/codeforces"
    fi
}

# Create new file from template for a new CodeForces problem
# np = New Problem
np() {
    cat ~/code/dsa/codeforces/template.cpp > ~/code/dsa/codeforces/$1.cpp
}

alias leetcode='vim "$(find leetcode/solutions/ -mindepth 1 -type d | fzf)"/sol.py'
