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


local function get_clipboard()
  if vim.env.SSH_TTY ~= nil
    or vim.env.SSH_CLIENT ~= nil
    or vim.env.KITTY_IS_REMOTE ~= nil
  then
    return {
      name = 'OSC52',
      copy  = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  end

  if vim.env.WAYLAND_DISPLAY ~= nil and vim.fn.executable('wl-copy') == 1 then
    return {
      name = 'wl-clipboard',
      copy  = {
        ['+'] = { 'wl-copy', '--type', 'text/plain' },
        ['*'] = { 'wl-copy', '--primary', '--type', 'text/plain' },
      },
      paste = {
        ['+'] = { 'wl-paste', '--no-newline' },
        ['*'] = { 'wl-paste', '--no-newline', '--primary' },
      },
    }
  end

  -- X11 — use xsel, NOT xclip (xclip backgrounds itself and accumulates content)
  if vim.env.DISPLAY ~= nil and vim.fn.executable('xsel') == 1 then
    return {
      name = 'xsel',
      copy  = {
        ['+'] = { 'xsel', '--clipboard', '--input' },
        ['*'] = { 'xsel', '--primary',   '--input' },
      },
      paste = {
        ['+'] = { 'xsel', '--clipboard', '--output' },
        ['*'] = { 'xsel', '--primary',   '--output' },
      },
    }
  end

  return {
    name = 'OSC52-fallback',
    copy  = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end

vim.g.clipboard = get_clipboard()

vim.opt.clipboard = "unnamedplus"
