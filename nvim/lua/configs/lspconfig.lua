local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = {
  "html",
  "cssls",
  "ts_ls",
  "jsonls",
  "lua_ls",
  "pyright",
  "omnisharp",
  "clangd",
  "cmake",
  "yamlls",
  "bashls",
  "lemminx",
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
