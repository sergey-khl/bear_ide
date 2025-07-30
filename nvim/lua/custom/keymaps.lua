local str = string.format
local map = vim.keymap.set

vim.keymap.set("n", "<C-w>e", "<CMD>term<CR>", { desc = "Terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit Terminal" })
vim.keymap.set("n", "<A-]>", "<CMD>bnext<CR>", { desc = "Goto next buffer" })
vim.keymap.set("n", "<A-[>", "<CMD>bprev<CR>", { desc = "Goto prev buffer" })
vim.keymap.set("n", "<A-0>", "<CMD>b#<CR>", { desc = "Goto last buffer" })
vim.keymap.set("n", "<A-->", "<CMD>buffermove -1<CR>", { desc = "Move buffer to the left" })
vim.keymap.set("n", "<A-=>", "<CMD>buffermove +1<CR>", { desc = "Move buffer to the right" })
vim.keymap.set("n", "<A-'>", "<CMD>vsplit<CR>", { desc = "Split buffer into new window" })
for i = 1, 9 do
  vim.keymap.set("n", str("<A-%d>", i), str("<CMD>buffer %d<CR>", i), {
    desc = str("Goto buffer %d", i)
  })
end


map("n", "<leader>k", "<cmd>cprev<CR><cmd>cclose<CR>", { desc = "Jump prev of quick fix list", silent = true })
map("n", "<leader>j", "<cmd>cnext<CR><cmd>cclose<CR>", { desc = "Jump next of quick fix list", silent = true })
map("n", "<leader>K", "<cmd>lprev<CR><cmd>lclose<CR>", { desc = "Jump prev of location list", silent = true })
map("n", "<leader>J", "<cmd>lnext<CR><cmd>lclose<CR>", { desc = "Jump next of location list", silent = true })

map("n", "gs", "<cmd>Telescope lsp_document_symbols<CR>", { desc = "Search symbols in file", silent = true })
map('n', '<leader>fs', function()
    require('telescope.builtin').lsp_workspace_symbols()
end, { noremap = true, silent = true, desc = "Search symbols in workspace" }
)
map('n', "<leader>ct", ":set filetype=", { desc = "Set file type for lsp" })

map("n", "<leader>gb",
    function()
        package.loaded.gitsigns.blame_line()
    end,
    { desc = "Blame line" })
