" Gvim specific settings
set guifont=Cascadia_Code:h12:cANSI:qDRAFT

" Remaps for hardmode
nnoremap <up> <NOP>
nnoremap <down> <NOP>
nnoremap <left> <NOP>
nnoremap <right> <NOP>
inoremap <up> <NOP>
inoremap <down> <NOP>
inoremap <left> <NOP>
inoremap <right> <NOP>

" Synchronise registers `"+` (used by system for C-c, C-v) and `""` (default
" register used by yank and put
set clipboard^=unnamedplus

nnoremap <space> :

set foldmethod=indent
set foldnestmax=2
set foldminlines=10


" Display all matching files when we tab complete.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

syntax on

" Add numbers to each line on the left-hand side.
set number relativenumber

" Highlight cursor line underneath the cursor horizontally.
set cursorline
hi CursorLine   cterm=NONE ctermbg=236

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" Allows removing 4 spaces when backspace is pressed
set softtabstop=4

" Use space characters instead of tabs.
set expandtab

" Copy indent from current line when starting a new line.
set autoindent

" Allow backspacing to work as expected.
set backspace=indent,eol,start

" Do not let cursor scroll below or above N number of lines when scrolling.
set scrolloff=10

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Override the ignorecase option if searching for capital letters.
" This will allow you to search specifically for capital letters.
set smartcase

" Show matching words during a search.
set showmatch

" Set title of window to the name of the file.
set title

" Only wrap lines at word boundaries
set linebreak

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Set the commands to save in history default number is 20.
set history=1000

