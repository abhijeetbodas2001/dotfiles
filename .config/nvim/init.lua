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
set mouse=

call plug#begin('~/.config/nvim/plugins')
Plug 'https://github.com/nvim-telescope/telescope.nvim'
Plug 'https://github.com/nvim-lua/plenary.nvim'
Plug 'https://github.com/lewis6991/gitsigns.nvim'
Plug 'https://github.com/0x00-ketsu/autosave.nvim'
Plug 'https://github.com/nvim-treesitter/nvim-treesitter'
Plug 'https://github.com/neovim/nvim-lspconfig'
Plug 'https://github.com/navarasu/onedark.nvim'
Plug 'https://github.com/echasnovski/mini.nvim'
call plug#end()
]])

vim.treesitter.language.add('python')
vim.treesitter.language.add('bash')
vim.treesitter.language.add('markdown')
vim.treesitter.language.add('java')
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
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

require('lspconfig').pyright.setup({
  capabilities = vim.lsp.protocol.make_client_capabilities(),
})
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
    vim.keymap.set('n', '<leader>lR', vim.lsp.buf.rename, opts)
  end,
})

vim.cmd([[:highlight DiffAdd guifg=#a4cf69]])
vim.cmd([[:highlight DiffChange guifg=#63c1e6]])
vim.cmd([[:highlight DiffDelete guifg=#d74f56]])
require('gitsigns').setup{
    signs = {
      add = {hl = "DiffAdd", text = "▌", numhl = "GitSignsAddNr"},
      change = {hl = "DiffChange", text = "▌", numhl = "GitSignsChangeNr"},
      delete = {hl = "DiffDelete", text = "_", numhl = "GitSignsDeleteNr"},
      topdelete = {hl = "DiffDelete", text = "‾", numhl = "GitSignsDeleteNr"},
      changedelete = {hl = "DiffChange", text = "~", numhl = "GitSignsChangeNr"}
    },
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
vim.keymap.set('n', '<c-p>', telescope_builtin.find_files, {})  -- fuzzy find files
vim.keymap.set('n', '<c-g>', telescope_builtin.live_grep, {})   -- grep
vim.keymap.set('n', '<c-f>', telescope_builtin.grep_string, {})   -- grep for word under cursor
vim.keymap.set('n', '<leader>gs', telescope_builtin.git_status, {}) -- git status
vim.keymap.set('n', '<leader>gc', telescope_builtin.git_commits, {})    -- git commits
vim.keymap.set('n', '<leader>lr', telescope_builtin.lsp_references, {})    -- LSP references
local partial_func = function(func, opts)
    return function()
        func(opts)
    end
end
vim.keymap.set('n', '<leader>bc', partial_func(telescope_builtin.lsp_document_symbols, {symbols = {"function","class","method"}}), {})    -- bread-crumbs

require('mini.files').setup()
vim.keymap.set('n', '<leader>e', MiniFiles.open, {})    -- explorer

require('mini.sessions').setup({
    autowrite = true,
})
vim.keymap.set('n', '<leader>s', MiniSessions.select, {})

require('autosave').setup()

require('mini.tabline').setup()
require('mini.comment').setup() -- Comment/uncomment code (gcc, gc in visual)
require('mini.fuzzy').setup()
require('mini.completion').setup({
    lsp_completion = {
        process_items = MiniFuzzy.process_lsp_items,
    },
})

require('mini.pairs').setup() -- Autoinsert closing bracket/quote
require('mini.cursorword').setup() -- Automatic highlighting of word under cursor
require('mini.indentscope').setup() -- Show line for current indent level
require('mini.statusline').setup() -- Status line at bottom
require('mini.ai').setup() -- better "around" and "in" motions (`a` for function argument, `f` for function call etc)
require('mini.trailspace').setup() -- highlight trailing whitespace
require('mini.splitjoin').setup() -- split and join function arguments
require('mini.starter').setup() -- start screen

local mini_jump = require('mini.jump2d')
mini_jump.setup({
    spotter = mini_jump.gen_pattern_spotter('[%w_]+')   -- hints at the start of words (words can include underscore)
})

-- Key bindings (plugin-independent)
vim.cmd([[
nnoremap <leader>t :r! date "+\%F \%T"<CR>I#<space><esc>o
nnoremap <leader>h :nohlsearch<CR>

nnoremap <leader>w :bd<CR>
nnoremap <c-j> :bp<CR>
nnoremap <c-k> :bn<CR>
tnoremap <c-j> <c-\><c-N>:bp<CR>
tnoremap <c-k> <c-\><c-N>:bn<CR>
]])
