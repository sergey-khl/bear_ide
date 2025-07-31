return {
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup {}
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "williamboman/mason.nvim", "jay-babu/mason-null-ls.nvim" },
    config = function()
      local null_ls = require "null-ls"
      null_ls.setup {
        sources = {
          null_ls.builtins.formatting.black,
          null_ls.builtins.diagnostics.ruff,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint_d,
          null_ls.builtins.formatting.eslint_d,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.gofumpt,
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.shfmt,
        },
      }
      null_ls.setup {
        sources = sources,

        -- ths is buns, fix later
        on_attach = function(client, bufnr) end,
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup {
        max_length = 0, -- No limit
        silent = false, -- Show message on copy
        trim = false,
      }

      -- Automatically copy on yank
      local function copy()
        if vim.v.event.operator == "y" and vim.v.event.regname == "d" then
          require("osc52").copy_register ""
        end
      end

      vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
    end,
  },
}
