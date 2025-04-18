vim.cmd([[
let mapleader=" "
set scrolloff=20
let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"
set wildmenu
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
syntax on
set number relativenumber
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
set title
set linebreak
set nocompatible
set showcmd
set showmode
set history=1000

" Use ripgrep while doing :grep
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif
" Key bindings for quickfix and grep (gt = do grep, and "t"pye out the search term)
nnoremap <leader>gt :grep<space>
" yank word under the cursor, search for it
" always use the "e" register to put things which will be pasted in the exec mode,
" so that the default register is not polluted
nnoremap <leader>gw "eyaw:grep<space><c-r>e
" in visual mode, yank whatever is highlighted and search for it
vnoremap <leader>gw "ey:grep<space><c-r>e
" keybinds to move between items in quickfix list
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>
" insert current timestamp, start writing on next line (for taking notes)
" in = Insert (timestamp for) Notes
nnoremap <leader>in :r! date "+\%F \%T \%a"<CR>I#<space><esc>o
" prepend timestamp to current line (for writing todos)
" it = Insert Timestamp
nnoremap <leader>it I<c-r>=strftime('%Y%m%d %H:%M')<CR><space>\|<space>
" sh = Set (or unset) Highlights off
nnoremap <leader>sh :nohlsearch<CR>
" cp = Copy, for Pasting outside
nnoremap <leader>cp gg0"+yG
" jump between window splits
nnoremap <c-h> <c-w>h
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-l> <c-w>l
" go to normal mode when in terminal mode
tnoremap <esc><esc> <c-\><c-N>
" enable "copy mode"
" sc = Settings Copy
nnoremap <leader>sc :set nonumber<CR>:set norelativenumber<CR>:set mouse=<CR>
" disable "copy mode"
" sc = Settings Copy (disable)
nnoremap <leader>sC :set number<CR>:set relativenumber<CR>:set mouse=a<CR>

" Format current file
autocmd FileType python nnoremap <buffer> <leader>f :!ruff format % && ruff check --fix --select I %<CR>
autocmd FileType markdown nnoremap <buffer> <leader>f :!mdformat --wrap 80 %<CR>

" Run / execute current file
autocmd FileType python nnoremap <buffer> <leader>e :!LOCAL=1 python % <CR>

" Remove trailing whitespace (cs = clean space)
nnoremap <leader>cs :%s/\s\+$//<CR>


call plug#begin()
Plug 'https://github.com/nvim-telescope/telescope.nvim'
Plug 'https://github.com/nvim-lua/plenary.nvim'
Plug 'https://github.com/lewis6991/gitsigns.nvim'
Plug 'https://github.com/0x00-ketsu/autosave.nvim'
Plug 'https://github.com/nvim-treesitter/nvim-treesitter'
Plug 'https://github.com/neovim/nvim-lspconfig'
Plug 'https://github.com/navarasu/onedark.nvim'
Plug 'https://github.com/echasnovski/mini.nvim'
Plug 'https://github.com/theprimeagen/vim-be-good'
call plug#end()
]])



-- Auto commands
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Highlight text which was yanked",
    group = vim.api.nvim_create_augroup("test", {clear=false}),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99 -- Start with all folds open
vim.treesitter.language.add('python')
vim.treesitter.language.add('bash')
vim.treesitter.language.add('markdown')
vim.treesitter.language.add('lua')
vim.treesitter.language.add('java')
vim.treesitter.language.add('rust')
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  fold = {
      enable = true,
  }
})


require('onedark').setup {
  style = 'darker',
  transparent = true,
  term_colors = false,
  colors = {
    white = "#ffffff",
    black = "#000000"
  },
  highlights = {
    ["@comment"] = {fg = '$green'},
    ["@string"] = {fg = '$orange'},
    ["@variable"] = {fg = '$white'},
  },
}
vim.cmd([[colorscheme onedark]])

local lspconfig = require('lspconfig')
local configs = require('lspconfig.configs')

configs.red_knot = {
  default_config = {
    cmd = { '/home/apb/code/ruff/target/debug/red_knot', 'server' },
    root_dir = lspconfig.util.root_pattern('pyproject.toml', '.git'),
    filetypes = { 'python' },
  },
}

lspconfig.red_knot.setup {}

lspconfig.rust_analyzer.setup{}

require('lspconfig').pyright.setup({
  capabilities = vim.lsp.protocol.make_client_capabilities(),
})
require'lspconfig'.clangd.setup{}
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Only enable the keybindings in the current buffer
    -- (so that, default vim keybindings can be used on buffers where LSP is not attached)
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, opts) -- LSP Rename
  end,
})

vim.cmd([[:highlight DiffAdd guifg=#a4cf69]])
vim.cmd([[:highlight DiffChange guifg=#63c1e6]])
vim.cmd([[:highlight DiffDelete guifg=#d74f56]])
require('gitsigns').setup{
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, {expr=true})
    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, {expr=true})

    map('n', '<leader>ga', gs.stage_hunk)       -- add
    map('n', '<leader>gr', gs.reset_hunk)       -- reset
    map('n', '<leader>gu', gs.undo_stage_hunk)  -- unstage
    map('n', '<leader>gA', gs.stage_buffer)     -- ADD
    map('n', '<leader>gR', gs.reset_buffer)     -- RESET
    map('n', '<leader>gd', gs.preview_hunk)     -- diff
    map('n', '<leader>gh', gs.toggle_deleted)   -- github (like diff)
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>') -- "in" and "around" hunk
  end
}

require('telescope').setup({
      defaults = {
      layout_config = {
            horizontal = { width = 0.9, preview_width = 100 },
      },
    },
})
telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>p', telescope_builtin.find_files, {})  -- fuzzy find files
vim.keymap.set('n', '<leader>g', telescope_builtin.live_grep, {})   -- grep
vim.keymap.set('n', '<leader>w', telescope_builtin.grep_string, {})   -- grep for word under cursor
vim.keymap.set('n', '<leader>gs', telescope_builtin.git_status, {}) -- git status
vim.keymap.set('n', '<leader>gc', telescope_builtin.git_commits, {})    -- git commits
vim.keymap.set('n', '<leader>lr', telescope_builtin.lsp_references, {})    -- LSP references
local partial_func = function(func, opts)
    return function()
        func(opts)
    end
end
vim.keymap.set('n', '<leader>ls', partial_func(telescope_builtin.lsp_document_symbols, {symbols = {"function","class","method"}}), {})    -- LSP symbols

require('autosave').setup()

-- mini plugin config
require('mini.fuzzy').setup()
require('mini.cursorword').setup() -- Automatic highlighting of word under cursor
require('mini.trailspace').setup() -- highlight trailing whitespace

