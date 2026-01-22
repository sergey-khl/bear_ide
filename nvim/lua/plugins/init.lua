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
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",

    config = function()
      require("gitsigns").setup {
        signs = {
          add = { hl = "GitSignsAdd", text = "+", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
          change = {
            hl = "GitSignsChange",
            text = "│",
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn",
          },
          delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          topdelete = {
            hl = "GitSignsDelete",
            text = "‾",
            numhl = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn",
          },
          changedelete = {
            hl = "GitSignsChange",
            text = "~",
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn",
          },
          untracked = { hl = "GitSignsAdd", text = "┆", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
        },
      }
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  {
    "williamboman/mason.nvim",
    dependencies = {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      local mason = require("mason")
      local mason_tool_installer = require("mason-tool-installer")

      mason.setup()

      mason_tool_installer.setup({
        ensure_installed = {
          "lua-language-server",
          "stylua",
          "html-lsp",
          "css-lsp",
          "prettier",
          "pyright",
          "clang-format",
          "gersemi",
          "markdownlint",
          "shellcheck",
          "shfmt",
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    priority = 1000,
    build = ":TSUpdate",
    dependencies = { "OXY2DEV/markview.nvim" },
    config = function(_)
      to_install = {
        "vim", "lua", "vimdoc", "luadoc", "query",
        "html", "css", "javascript", "typescript", "json",
        "python",
        "c_sharp",
        -- 4. ROS & Systems (Crucial for C++ nodes & build)
        "c", "cpp",
        "cmake",
        "make",
        "bash",
        -- 5. Config & Data (ROS params, URDFs, Launch files)
        "yaml",             -- Critical for ROS .yaml param files
        "xml",              -- Critical for URDF, SDF, and package.xml
        "toml",             -- For Rust or Python tool configs (pyproject.toml)
        -- 6. Documentation
        "markdown",         -- Structure of markdown files
        "markdown_inline",  -- **Bold**, *Italic*, and code blocks inside markdown
        "rst",              -- reStructuredText (Standard for Python Sphinx docs)
        "latex",            -- Academic papers / Complex math
        -- 7. Git (Helpful for diffs and commit messages)
        "git_config", "gitcommit", "gitignore", "diff",
      }
      require'nvim-treesitter'.install(to_install)
    end,
  },
  {
    "ojroques/vim-oscyank",
    lazy = false,
    config = function()
      -- Should be accompanied by a setting clipboard in tmux.conf, also see
      -- https://github.com/ojroques/vim-oscyank#the-plugin-does-not-work-with-tmux
      vim.g.oscyank_term = "default"
      vim.g.oscyank_max_length = 0 -- unlimited
      -- Below autocmd is for copying to OSC52 for any yank operation,
      -- see https://github.com/ojroques/vim-oscyank#copying-from-a-register
      vim.api.nvim_create_autocmd("TextYankPost", {
        pattern = "*",
        callback = function()
          if vim.v.event.operator == "y" and vim.v.event.regname == "" then
            vim.cmd 'OSCYankRegister "'
          end
        end,
      })
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
        { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    lazy = false,
    config = function()
      local diffview = require("diffview")

      diffview.setup({
        enhanced_diff_hl = true, -- better syntax-aware highlighting
        view = {
          merge_tool = {
            layout = "diff3_mixed",
          },
        },
      })

      -- Keymaps for quick access
      local map = vim.keymap.set
      map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
      map("n", "<leader>gD", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
      map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File History" })
      map("n", "<leader>gH", "<cmd>DiffviewFileHistory<cr>", { desc = "Repo History" })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    config = function()
        require("ibl").setup() 
    end,
  }
}
