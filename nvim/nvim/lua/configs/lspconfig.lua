--=============================================================================
-- LSP
--=============================================================================
-- Uses the neovim 0.11+ vim.lsp.config / vim.lsp.enable API.
--
-- Every server named here must also be listed in mason's `ensure_installed`
-- (see lua/plugins/init.lua) -- mason package names differ from server names:
--
--   html   -> html-lsp                  yamlls  -> yaml-language-server
--   cssls  -> css-lsp                   bashls  -> bash-language-server
--   ts_ls  -> typescript-language-server cmake  -> cmake-language-server
--   jsonls -> json-lsp                  lemminx -> lemminx
--   lua_ls -> lua-language-server       marksman-> marksman
--   pyright-> pyright                   texlab  -> texlab
--   clangd -> clangd                    omnisharp -> omnisharp

local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = {
  -- web
  "html",
  "cssls",
  "ts_ls",
  "jsonls",
  -- lua
  "lua_ls",
  -- python
  "pyright",
  -- c# / c / c++ / cmake
  "omnisharp",
  "clangd",
  "cmake",
  -- config / data / shell
  "yamlls",
  "bashls",
  "lemminx",
  -- docs
  "marksman",
  "texlab",
}

for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    settings = lsp == "yamlls" and {
      yaml = {
        schemas = {
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
        },
      },
    } or nil,
  })
end

vim.lsp.enable(servers)
