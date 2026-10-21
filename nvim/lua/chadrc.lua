-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "neofusion",
  hl_override = {
    Comment = { fg = "#aac8f2", italic = true },
    LineNr = { fg = "#777777" },
    CursorLineNr = { fg = "#ffffff" },
    ["@comment"] = { fg = "#aac8f2", italic = true },
  },
}

M.nvdash = { load_on_startup = true }
M.term = {
  float = {
    relative = "editor",
    row = 0,
    col = 0,
    width = vim.o.columns,
    height = vim.o.lines,
  },
  sizes = {
    vsp = 0.5,
  },
}
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
--}

return M
