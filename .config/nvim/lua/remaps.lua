local function map(m, k, v)
	vim.keymap.set(m, k, v, { silent = true })
end

-- Example use of above function
-- map("n", "<leader>fr", "<CMD>Telescope oldfiles<CR>")
-- Hardmode - disable arrow keys
map("n", "<up>", "")
map("n", "<down>", "")
map("n", "<left>", "")
map("n", "<right>", "")
map("i", "<up>", "")
map("i", "<down>", "")
map("i", "<left>", "")
map("i", "<right>", "")
