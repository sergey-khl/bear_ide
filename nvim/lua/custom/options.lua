--=============================================================================
-- Editor options
--=============================================================================
-- Neovim-wide settings only. Keymaps live in custom/keymaps.lua and the
-- clipboard provider in custom/clipboard.lua.

-- Indentation / whitespace --------------------------------------------------
vim.opt.number = true
vim.opt.scrolloff = 5
vim.opt.showtabline = 4 -- nvchad's tabufline; >0 means "always show"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smartindent = true

-- Markdown ------------------------------------------------------------------
vim.g.mkdp_auto_close = 0

-- Autosave ------------------------------------------------------------------
-- Save on focus loss and when leaving insert mode.
vim.api.nvim_create_autocmd({ "FocusLost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("Autosave", { clear = true }),
  pattern = "*",
  command = "silent! wa",
})

-- File-type tweaks ----------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("SpellCheck", { clear = true }),
  pattern = { "markdown", "text" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = { "en_us" }
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("TwoSpaceIndent", { clear = true }),
  pattern = { "json", "lua" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})
