local str = string.format

vim.keymap.set("n", "<C-w>e", "<CMD>term<CR>", { desc = "Terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit Terminal" })
vim.keymap.set("n", "<A-]>", "<CMD>bnext<CR>", { desc = "Goto next buffer" })
vim.keymap.set("n", "<A-[>", "<CMD>bprev<CR>", { desc = "Goto prev buffer" })
vim.keymap.set("n", "<A-0>", "<CMD>b#<CR>", { desc = "Goto last buffer" })
vim.keymap.set("n", "<A-->", "<CMD>buffermove -1<CR>", { desc = "Move buffer to the left" })
vim.keymap.set("n", "<A-=>", "<CMD>buffermove +1<CR>", { desc = "Move buffer to the right" })
vim.keymap.set("n", "<A-'>", "<CMD>split<CR><C-w>T", { desc = "Split buffer into new window" })
for i = 1, 9 do
  vim.keymap.set("n", str("<A-%d>", i), str("<CMD>buffer %d<CR>", i), {
    desc = str("Goto buffer %d", i)
  })
end

vim.keymap.set("n", "<space>t1", ":1ToggleTerm<CR>")
vim.keymap.set("n", "<space>t2", ":2ToggleTerm<CR>")
vim.keymap.set("n", "<space>t3", ":3ToggleTerm<CR>")
vim.keymap.set("n", "<space>t4", ":4ToggleTerm<CR>")
