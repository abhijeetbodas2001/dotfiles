vim.g.mapleader = " "
vim.o.wildmenu = true
vim.o.wildmode = "list:longest"
vim.o.syntax = "on"
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.backspace = "indent,eol,start"
vim.o.incsearch = true
vim.o.smartcase = true
vim.o.showmatch = true
vim.o.title = true
vim.o.linebreak = true
vim.g.nocompatible = true
vim.o.showcmd = true
vim.o.showmode = true
vim.o.history = 10000
vim.o.cmdheight = 0

vim.cmd([[
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
hi CursorLine   cterm=NONE ctermbg=236

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
nnoremap <A-i> <C-6>

" enable "copy mode"  sc = Settings Copy
nnoremap <leader>sc :set nonumber<CR>:set norelativenumber<CR>:set mouse=<CR>
" disable "copy mode" sc = Settings Copy (disable)
nnoremap <leader>sC :set number<CR>:set relativenumber<CR>:set mouse=a<CR>

" Format current file
autocmd FileType python nnoremap <buffer> <leader>f :!uv tool run ruff format % && uv tool run ruff check --fix --select I %<CR>

autocmd FileType markdown set shiftwidth=2 tabstop=2
autocmd FileType markdown nnoremap <buffer> <leader>f :!uv tool run mdformat --wrap 80 %<CR>

autocmd FileType rust nnoremap <buffer> <leader>f :!cargo-fmt %<CR>

autocmd FileType lua nnoremap <buffer> <leader>f :%!stylua -<CR>


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
Plug 'https://github.com/nvim-lualine/lualine.nvim'
" Completion
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'

" Snippets (recommended)
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

Plug 'mfussenegger/nvim-dap'
Plug 'mfussenegger/nvim-dap-python'
Plug 'rcarriga/nvim-dap-ui'
Plug 'nvim-neotest/nvim-nio'   " required by dap-ui
Plug 'theHamsta/nvim-dap-virtual-text'  " optional, nice inline values
call plug#end()
]])

-- Auto commands
vim.api.nvim_create_augroup("test", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight text which was yanked",
	group = "test",
	callback = function()
		vim.highlight.on_yank()
	end,
})

require("nvim-treesitter.configs").setup({
	ensure_installed = { "markdown", "python", "rust", "lua", "yaml", "toml", "json" },
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
})
vim.wo.foldmethod = "expr"
vim.wo.foldlevel = 99
vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Enabling this from the above config does not work for some reason
-- so explicitly enable and set the keymaps
inc_selection = require("nvim-treesitter.incremental_selection")
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
-- Unset it for qfixlist buffers
-- In a "quickfix" buffer, Enter is used to go to the location represented by
-- that entry. Don't remap in such buffers.
vim.api.nvim_create_autocmd("BufEnter", {
	group = "test",
	callback = function()
		if vim.bo.filetype == "qf" then
			vim.cmd([[nnoremap <buffer> <Enter> <nop>]])
		end
	end,
})

require("onedark").setup({
	style = "darker",
	transparent = true,
	term_colors = false,
	colors = {
		white = "#ffffff",
		black = "#000000",
	},
	highlights = {
		["@comment"] = { fg = "$green" },
		["@string"] = { fg = "$orange" },
		["@variable"] = { fg = "$white" },
	},
})
vim.cmd([[colorscheme onedark]])

-- Jump diagnostics
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })

-- Rust
vim.lsp.config("rust_analyzer", {
	settings = {
		["rust-analyzer"] = {
			diagnostics = {
				enable = true,
			},
		},
	},
})
vim.lsp.enable("rust_analyzer")

-- Python
vim.lsp.enable("ty")
-- vim.lsp.enable('pyright')

-- LSP keybinds
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Only enable the keybindings in the current buffer
		-- (so that, default vim keybindings can be used on buffers where LSP is not attached)

		local opts = { buffer = ev.buf }

		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<leader>lR", vim.lsp.buf.rename, opts) -- LSP Rename
	end,
})

vim.cmd([[:highlight DiffAdd guifg=#a4cf69]])
vim.cmd([[:highlight DiffChange guifg=#63c1e6]])
vim.cmd([[:highlight DiffDelete guifg=#d74f56]])
require("gitsigns").setup({
	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns
		local function map(mode, l, r, opts)
			opts = opts or {}
			opts.buffer = bufnr
			vim.keymap.set(mode, l, r, opts)
		end

		map("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				gs.next_hunk()
			end)
			return "<Ignore>"
		end, { expr = true })
		map("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				gs.prev_hunk()
			end)
			return "<Ignore>"
		end, { expr = true })

		map("n", "<leader>ga", gs.stage_hunk) -- add
		map("n", "<leader>gr", gs.reset_hunk) -- reset
		map("n", "<leader>gu", gs.undo_stage_hunk) -- unstage
		map("n", "<leader>gA", gs.stage_buffer) -- ADD
		map("n", "<leader>gR", gs.reset_buffer) -- RESET
		map("n", "<leader>gd", gs.preview_hunk) -- diff
		map("n", "<leader>gh", gs.toggle_deleted) -- github (like diff)
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>") -- "in" and "around" hunk
	end,
})

require("telescope").setup({
	defaults = {
		layout_config = {
			horizontal = {
				width = 0.98,
				preview_width = 0.5, -- Split equally between picker and preview
			},
		},
	},
})

telescope_builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>p", telescope_builtin.find_files, {}) -- fuzzy find files
require("multigrep").setup()
vim.keymap.set("n", "<leader>rw", telescope_builtin.grep_string, {}) -- grep for word under cursor
vim.keymap.set("n", "<leader>gs", telescope_builtin.git_status, {}) -- git status
vim.keymap.set("n", "<leader>gc", telescope_builtin.git_commits, {}) -- git commits
vim.keymap.set("n", "<leader>lr", telescope_builtin.lsp_references, {}) -- LSP references
local partial_func = function(func, opts)
	return function()
		func(opts)
	end
end
vim.keymap.set(
	"n",
	"<leader>ls",
	partial_func(telescope_builtin.lsp_document_symbols, { symbols = { "function", "class", "method" } }),
	{}
) -- LSP symbols

require("autosave").setup()

-- mini plugin config
require("mini.fuzzy").setup()
require("mini.cursorword").setup() -- Automatic underline of word under cursor
require("mini.trailspace").setup() -- highlight trailing whitespace

require("lualine").setup({
	options = {
		theme = "onedark", -- Choose your preferred theme
	},
	sections = {
		lualine_c = {
			{ "lsp_status" },
			{
				"filename",
				path = 1,
			},
		},
	},
})

-- Use lowercase for global marks and uppercase for local marks.
local low = function(i)
	return string.char(97 + i)
end
local upp = function(i)
	return string.char(65 + i)
end

for i = 0, 25 do
	vim.keymap.set("n", "m" .. low(i), "m" .. upp(i))
end
for i = 0, 25 do
	vim.keymap.set("n", "m" .. upp(i), "m" .. low(i))
end
for i = 0, 25 do
	vim.keymap.set("n", "'" .. low(i), "'" .. upp(i))
end
for i = 0, 25 do
	vim.keymap.set("n", "'" .. upp(i), "'" .. low(i))
end

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
	formatting = {
		fields = { "abbr", "kind" }, -- no source text
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp", max_item_count = 8 },
		{ name = "luasnip" },
	}),
})

-- LSP capabilities so ty can feed completions into nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- If you're on Neovim 0.11+, you can also enable via the new API:
-- (ty docs show `vim.lsp.config('ty', ...)` + `vim.lsp.enable('ty')`) :contentReference[oaicite:1]{index=1}
if vim.lsp and vim.lsp.enable and vim.lsp.config then
	vim.lsp.config("ty", {
		capabilities = capabilities,
		cmd = { "ty", "server" },
		settings = { ty = {} },
	})
	vim.lsp.enable("ty")
end

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			format = {
				enable = true,
				defaultConfig = {
					indent_style = "space",
					indent_size = "2",
					column_width = "80",
				},
			},
		},
	},
})
vim.lsp.enable("lua_ls")

local dap = require("dap")
local dapui = require("dapui")

-- Optional: virtual text inline values
pcall(function()
	require("nvim-dap-virtual-text").setup()
end)

-- DAP UI
dapui.setup({
	layouts = {
		{
			elements = {
				{ id = "repl", size = 1.0 },
			},
			size = 15,
			position = "bottom",
		},
	},
})

-- When debugging starts, show the debugger UI.
-- When debugging ends, clean it up.
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Must have the venv / conda activated
python_path = "python"

require("dap-python").setup(python_path)
require("dap-python").test_runner = "pytest"

vim.keymap.set("n", "<leader>dc", dap.continue)
vim.keymap.set("n", "<leader>dso", dap.step_over)
vim.keymap.set("n", "<leader>dsi", dap.step_into)
--vim.keymap.set('n', '<leader>dso', dap.step_out)
vim.keymap.set("n", "<leader>de", function()
	require("dap").repl.execute(vim.api.nvim_get_current_line())
end, { desc = "DAP REPL Execute Line" })

vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dB", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end)

vim.keymap.set("n", "<leader>dr", dap.repl.open)
vim.keymap.set("n", "<leader>dl", dap.run_last)
vim.keymap.set("n", "<leader>du", dapui.toggle)
