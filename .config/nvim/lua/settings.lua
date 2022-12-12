local o = vim.o

-- Synchronise registers `"+` (used by system for C-c, C-v) and `""` (default
-- register used by yank and put
o.clipboard = "unnamedplus"

-- Tab/spaces related
o.tabstop = 4 -- Set tab width to 4 columns.
o.softtabstop = 4 -- Allows removing 4 spaces when backspace is pressed
o.expandtab = true -- Use space characters instead of tabs.

---- Search related
o.ignorecase = true -- Ignore capital letters during search.
o.smartcase = true -- Override the ignorecase option if searching for capital letters. This will allow searching specifically for capital letters.
o.hlsearch = false -- Don't highlight search results

