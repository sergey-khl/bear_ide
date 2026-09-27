--=============================================================================
-- Clipboard
--=============================================================================
-- Copy (yank) always goes out as an OSC 52 escape sequence. OSC 52 is the only
-- method that behaves the same in every environment this setup is used in:
--
--   * local kitty
--   * a docker container (no X11 / Wayland needed)
--   * plain ssh
--   * ssh + tmux
--   * across Ubuntu 20.04 / 22.04 / 24.04 and on x86_64 or arm64
--
-- It also leaves no helper process behind, so nothing "keeps appending" to the
-- clipboard the way xclip / xsel do when their background owners pile up.
--
-- Paste is deliberately NOT wired to OSC 52. Reading the clipboard needs the
-- terminal to answer an OSC 52 *query*, which:
--
--   * kitty only allows when `read-clipboard` is enabled in
--     ~/.config/kitty/kitty.conf, and that lets every host you ssh into read
--     your local clipboard; and
--   * tmux does not reliably forward anyway (the query never reaches kitty).
--
-- Use the terminal's own paste instead (kitty: Ctrl+Shift+V). It arrives in
-- neovim as a bracketed paste and works through ssh, tmux and containers.
--
-- Fallback: `"+p` / `"*p` return the unnamed register, i.e. the last thing you
-- yanked or deleted in this session. Never blocks, never errors.
--
-- Want real `"+p` via OSC 52? See "OPT-IN" at the bottom of this file.
--=============================================================================

local M = {}

-- Best-effort paste: the current unnamed register, as a list of lines.
-- With `clipboard=unnamedplus` this mirrors the last yank / delete.
local function local_register()
  return vim.fn.getreg('"', true, true)
end

function M.setup()
  -- Every yank goes to the "+ register...
  vim.opt.clipboard = "unnamedplus"

  -- ...and "+ is provided by OSC 52. `name` shows up in :checkhealth.
  vim.g.clipboard = {
    name = "OSC52 (write-only)",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = local_register,
      ["*"] = local_register,
    },
  }
end

return M
