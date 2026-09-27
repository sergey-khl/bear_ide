--=============================================================================
-- Keymaps
--=============================================================================
-- NeoVim keymaps added on top of nvchad's defaults. Plugin-local keymaps
-- (oil, gitsigns, diffview, lazygit, ...) live next to their plugin config.

local map = vim.keymap.set

-- Buffers --------------------------------------------------------------------
map("n", "<A-]>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-[>", "<cmd>bprev<cr>", { desc = "Previous buffer" })
map("n", "<A-0>", "<cmd>b#<cr>", { desc = "Last buffer" })
map("n", "<A-->", "<cmd>buffermove -1<cr>", { desc = "Move buffer left" })
map("n", "<A-=>", "<cmd>buffermove +1<cr>", { desc = "Move buffer right" })
map("n", "<A-'>", "<cmd>vsplit<cr>", { desc = "Split buffer" })
for i = 1, 9 do
  map("n", "<A-" .. i .. ">", "<cmd>buffer " .. i .. "<cr>", { desc = "Go to buffer " .. i })
end

-- Windows / terminals --------------------------------------------------------
map("n", "<C-w>e", "<cmd>term<cr>", { desc = "Terminal" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Quickfix / location lists --------------------------------------------------
map("n", "<leader>k", "<cmd>cprev<cr><cmd>cclose<cr>", { desc = "Prev quickfix", silent = true })
map("n", "<leader>j", "<cmd>cnext<cr><cmd>cclose<cr>", { desc = "Next quickfix", silent = true })
map("n", "<leader>K", "<cmd>lprev<cr><cmd>lclose<cr>", { desc = "Prev location list", silent = true })
map("n", "<leader>J", "<cmd>lnext<cr><cmd>lclose<cr>", { desc = "Next location list", silent = true })

-- LSP / symbols --------------------------------------------------------------
map("n", "gs", "<cmd>Telescope lsp_document_symbols<cr>", { desc = "Symbols in file", silent = true })
map("n", "<leader>fs", function()
  require("telescope.builtin").lsp_workspace_symbols()
end, { desc = "Symbols in workspace", silent = true })
map("n", "<leader>ct", ":set filetype=", { desc = "Set filetype manually" })

-- Git ------------------------------------------------------------------------
map("n", "<leader>gb", function()
  require("gitsigns").blame_line()
end, { desc = "Blame line" })

-- Files / markdown -----------------------------------------------------------
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })
map("n", "<leader>mp", "<cmd>Markview toggle<cr>", { desc = "Toggle markdown preview" })
