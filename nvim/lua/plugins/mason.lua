return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua-language-server",
          "pyright",
          "typescript-language-server",
          "html-lsp",
          "css-lsp",
          "json-lsp",
          "yaml-language-server",
          "bash-language-server",
          "clangd",
          "rust-analyzer",
          "gopls",
          "jdtls",
          "marksman",
          "dockerfile-language-server",
        },
        automatic_installation = true,
      })
    end,
  },

  -- This must come AFTER none-ls.nvim is defined and configured
  {
    "jay-babu/mason-null-ls.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {
          "prettier",
          "black",
          "eslint_d",
          "rustfmt",
          "gofumpt",
          "stylua",
          "clang-format",
          "shfmt",
          "flake8",
          "ruff",
          "shellcheck",
          "yamllint",
          "jsonlint",
        },
        automatic_installation = true,
        handlers = {},
      })
    end,
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "debugpy",
          "node-debug2-adapter",
          "codelldb",
          "delve",
        },
        automatic_installation = true,
      })
    end,
  },
}

