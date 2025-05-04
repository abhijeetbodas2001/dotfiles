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
" Key bindings for quickfix and grep (cg = command grep)
nnoremap <leader>cg :grep<space>
vnoremap <leader>cg "ey:grep<space><c-r>e   " Grep for selected text in visual

" keybinds to move between items in quickfix list
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>

" in = Insert (timestamp for) Notes
nnoremap <leader>in :r! date "+\%F \%T \%a"<CR>I#<space><esc>o
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

" the later is hard to reach
nnoremap <A-j> <C-6>

" enable "copy mode"  sc = Settings Copy
nnoremap <leader>sc :set nonumber<CR>:set norelativenumber<CR>:set mouse=<CR>
" disable "copy mode" sc = Settings Copy (disable)
nnoremap <leader>sC :set number<CR>:set relativenumber<CR>:set mouse=a<CR>

" Format current file
autocmd FileType python nnoremap <buffer> <leader>f :!ruff format % && ruff check --fix --select I %<CR>
autocmd FileType markdown nnoremap <buffer> <leader>f :!mdformat --wrap 80 %<CR>

" Run / execute current file
autocmd FileType python nnoremap <buffer> <leader>e :!LOCAL=1 python % <CR>

call plug#begin()
Plug 'https://github.com/nvim-telescope/telescope.nvim'
Plug 'https://github.com/nvim-lua/plenary.nvim'
Plug 'https://github.com/lewis6991/gitsigns.nvim'
Plug 'https://github.com/0x00-ketsu/autosave.nvim'
Plug 'https://github.com/nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
"Plug 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects'
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

require'nvim-treesitter.configs'.setup {
    ensure_installed = {"markdown", "python", "rust", "lua", "yaml", "toml", "json"},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    fold = {
        enable = true,
    },
    textobjects = {
        enable = true,
    },
}
vim.wo.foldmethod = 'expr'
vim.wo.foldlevel = 99
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- Enabling this from the above config does not work for some reason
-- so explicitly enable and set the keymaps
inc_selection = require('nvim-treesitter.incremental_selection')
vim.keymap.set("n", "\\", inc_selection.node_incremental)
vim.keymap.set("v", "\\", inc_selection.node_incremental)
vim.keymap.set("v", "|", inc_selection.node_decremental)

ts_utils = require("nvim-treesitter.ts_utils")

local function goto_parent()
  local current_node = ts_utils.get_node_at_cursor()
  local parent = current_node:parent()

  -- Some nodes are useless as far as jumping is converned
  -- Making sure that the range changes skips these nodes
  while parent and parent:range() == current_node:range() do
      parent = parent:parent()
  end
  ts_utils.goto_node(parent)
end
vim.keymap.set("n", "<Enter>", goto_parent)



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

-- lspconfig.red_knot.setup {}

lspconfig.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            numThreads = 2,
            checkOnSave = false,
            cachePriming = {
                numThreads = 2
            },
            cargo = {
                extraEnv = {
                    RUST_TEST_THREADS = 2,
                    CARGO_BUILD_JOBS = 2,
                }
            }
        }
    }
})

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
require("multigrep").setup()
vim.keymap.set('n', '<leader>rw', telescope_builtin.grep_string, {})   -- grep for word under cursor
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

