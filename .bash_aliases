alias mkdir='mkdir -v'
alias less='less -R'
alias jdate='echo "date: $(date "+%F %T") +5:30"'
alias wp="which python"
alias nv="nvim"
alias nvc="nvim --clean"
alias f="vifm"
alias suu='sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean'

# Compile and run last updated C++ file
# luc = Last Updated C++ (file)
luc() {
    if [[ "$PWD" == /home/apb/code/dsa/codeforces ]]; then
        clang++ -std=c++17 -fsanitize=address $(ls -alt | grep \.cpp | rev | cut --delimiter=\  --fields=1 | rev | head -n1) && ./a.out
    else
        echo "luc should be run only from /code/dsa/codeforces"
    fi
}

# Create new file from template for a new CodeForces problem
# np = New Problem
np() {
    cat ~/code/dsa/codeforces/template.cpp > ~/code/dsa/codeforces/$1.cpp
}
