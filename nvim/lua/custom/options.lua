vim.opt.showtabline = 4
vim.opt.number = true
vim.opt.scrolloff = 5
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.g.mkdp_auto_close = 0

vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! wa",
})

-- Optional: Also save when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "silent! wa",
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text" },
    callback = function()
        vim.opt_local.spell = true
        vim.opt_local.spelllang = { 'en_us' }
    end,
    group = vim.api.nvim_create_augroup("SpellCheck", { clear = true })
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"json", "lua" },
    callback = function()
        vim.bo.shiftwidth = 2
        vim.bo.tabstop = 2
        vim.bo.expandtab = true
        vim.bo.softtabstop = 2
    end,
    group = vim.api.nvim_create_augroup("2-space-indentation", { clear = true })
})

