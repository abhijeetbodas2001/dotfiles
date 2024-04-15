vim.cmd([[
let mapleader=" "
" set scrolloff=20
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
set mouse=a
set nofixeol
set nofixendofline

call plug#begin('~/.config/nvim/plugins')
Plug '~/.config/nvim/plugins/telescope.nvim-0.1.6'
Plug '~/.config/nvim/plugins/plenary.nvim'
Plug '~/.config/nvim/plugins/gitsigns.nvim-0.7'
Plug '~/.config/nvim/plugins/autosave.nvim'
Plug '~/.config/nvim/plugins/treesitter.nvim'
Plug '~/.config/nvim/plugins/nvim-lspconfig-master'
Plug '~/.config/nvim/plugins/onedark.nvim-master'
Plug '~/.config/nvim/plugins/mini.nvim-0.12.0'
call plug#end()
]])

-- Setup for theme
require('onedark').setup {
  style = 'darker',
  transparent = true,
  colors = {
    white = "#ffffff",
    fg = "#ffffff",
    black = "#000000",
  },
  highlights = {
    ["@comment"] = {fg = '$green'},
    ["@string"] = {fg = '$orange'},
    ["@variable"] = {fg = '$white'},
    MiniStatuslineFilename ={fg='$white'}
  },
}
vim.cmd([[colorscheme onedark]])
vim.cmd([[hi vertsplit guifg=fg guibg=bg]])     -- make vsplit line pure white

-- Setup for Tree sitter
vim.treesitter.language.add('python', { path = "/home/bodaab/.config/nvim/TSInstall/python.so" })
vim.treesitter.language.add('bash', { path = "/home/bodaab/.config/nvim/TSInstall/bash.so" })
vim.treesitter.language.add('markdown', { path = "/home/bodaab/.config/nvim/TSInstall/markdown.so" })
vim.treesitter.language.add('java', { path = "/home/bodaab/.config/nvim/TSInstall/java.so" })
require("nvim-treesitter.configs").setup({
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
})

-- Setup for LSPs
vim.lsp.set_log_level("debug")
require('lspconfig').pyright.setup({
  capabilities = vim.lsp.protocol.make_client_capabilities(),
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
  }
})
require('lspconfig').ruff_lsp.setup {
  on_attach = function(client, bufnr)
    if client.name == 'ruff_lsp' then
      -- Disable hover in favor of Pyright
      client.server_capabilities.hoverProvider = false
    end
  end,
  init_options = {
    settings = {
      args = {},
    }
  }
}
local format_python_with_ruff = function()
  vim.lsp.buf.format()
  vim.lsp.buf.code_action({
    context = { only = { "source.organizeImports" } },
    apply = true,
  })
end
require('lspconfig').jdtls.setup({})
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
        vim.keymap.set('n', '<leader>f', format_python_with_ruff, opts)
  end,
})

-- Setup for Gitsigns plugin
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

-- Setup for telescope plugin
require('telescope').setup({
      defaults = {
      layout_config = {
            horizontal = { width = 0.9, preview_cutoff = 100 },
      },
    },
})
telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<c-p>', telescope_builtin.find_files, {})  -- fuzzy find files
vim.keymap.set('n', '<c-g>', telescope_builtin.live_grep, {})   -- grep
vim.keymap.set('n', '<c-f>', telescope_builtin.grep_string, {})   -- grep for word under cursor
vim.keymap.set('n', '<c-b>', telescope_builtin.buffers, {})   -- buffers
vim.keymap.set('n', '<leader>gs', telescope_builtin.git_status, {}) -- git status
vim.keymap.set('n', '<leader>gc', telescope_builtin.git_commits, {})    -- git commits
vim.keymap.set('n', 'gr', telescope_builtin.lsp_references, {})    -- LSP references
vim.keymap.set('n', 'gb', telescope_builtin.lsp_document_symbols, {})    -- bread-crumbs

-- Autosave files
require('autosave').setup()

-- Setup for mini plugins
require('mini.files').setup()
vim.keymap.set('n', '<leader>e', MiniFiles.open, {})    -- explorer
require('mini.sessions').setup({
    autowrite = true,
})
vim.keymap.set('n', '<leader>s', MiniSessions.select, {})
require('mini.comment').setup() -- Comment/uncomment code (gcc, gc in visual)
require('mini.completion').setup() -- Auto-complete
require('mini.cursorword').setup() -- Automatic highlighting of word under cursor
require('mini.statusline').setup() -- Status line at bottom
require('mini.trailspace').setup() -- highlight trailing whitespace

-- Auto-commands
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = "Highlight text which was yanked",
    group = vim.api.nvim_create_augroup("test", {clear=false}),
    callback = function()
        vim.highlight.on_yank()
    end,
})
-- vim.api.nvim_create_autocmd('TermOpen', {
--     desc = "In terminal buffers, turn off line numbers",
--     group = vim.api.nvim_create_augroup("test", {clear=false}),
--     callback = function()
--         vim.cmd([[
--         setlocal nonumber norelativenumber
--         ]])
--     end,
-- })


-- Key bindings (plugin-independent)
vim.cmd([[
" insert current timestamp, start insert on next line
nnoremap <leader>t :r! date "+\%F \%T"<CR>I#<space><esc>o
" copy file path of current file
nnoremap <leader>yf :let @" = expand("%")<CR>
" clear search highlights
nnoremap <leader>h :nohlsearch<CR>
" close window
nnoremap <leader>w :close<CR>
" easily jump between window splits
nnoremap <c-h> <c-w><c-h>
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
" move current buffer to a vsplit
nnoremap <leader>v :vsplit<CR><c-w><c-h><c-o><c-w><c-l>
" Go to terminal mode
tnoremap <esc><esc> <c-\><c-N>
" Enable "copy" mode
nnoremap <leader>c :set nonumber<CR>:set norelativenumber<CR>:set mouse=<CR>
" Disable "copy" mode (default)
nnoremap <leader>C :set number<CR>:set relativenumber<CR>:set mouse=a<CR>
" Run Python test
" Working: copies the Unittest class name in register-c, the method name in register-m and the
" relative path of the test file in register-f. Contructs to pytest command and runs it.
nnoremap <leader>T ?def <CR>w"myw?class <CR>w"cyw:let @f = expand("%")<CR>:nohlsearch<CR>:!pytest <C-r>f::<C-r>c::<C-r>m<CR>
]])
