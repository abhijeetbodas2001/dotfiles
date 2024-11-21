set guifont=Delugia_Mono:h12

" Cursor: thin line in insert, block in normal mode
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

syntax on
set number relativenumber

" Highlight cursor line underneath the cursor horizontally.
set cursorline
hi CursorLine   cterm=NONE ctermbg=236

set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set autoindent
set backspace=indent,eol,start

set incsearch
set ignorecase
set smartcase
set showmatch

set scrolloff=15
set title
set nowrap
set nocompatible
set showcmd
set showmode
set history=1000

set autoread

let mapleader=" "

" Keymaps
nnoremap <leader>sh :nohlsearch<CR>
nnoremap <leader>cp gg0"+yG
