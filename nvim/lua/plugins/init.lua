return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    config = function()
      local opts = {
        default_file_explorer = true,
        view_options = {
          show_hidden = true,
        },
      }
      require("oil").setup(opts)
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
    end,
  },
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
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
