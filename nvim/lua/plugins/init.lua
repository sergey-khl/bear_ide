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
          "typescript-language-server",
          "vue-language-server",
          "eslint-lsp",
          "clang-format",
          "clangd",
          "gersemi",
          "markdownlint",
          "shellcheck",
          "shfmt",
          "tree-sitter-cli",
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
      local to_install = {
        -- Neovim / Lua
        "vim", "lua", "vimdoc", "luadoc", "query",

        -- Web (JS/TS/Vue stack)
        "html", "css",
        "javascript",          -- JS core
        "typescript",          -- TS core
        "jsdoc",               -- JSDoc comment blocks inside JS/TS
        "tsx",                 -- React JSX/TSX (needed by ts_ls for .tsx files)
        "vue",                 -- Vue SFCs (.vue) — treesitter for <template> blocks
        "json", "json5",       -- package.json, tsconfig, etc.
        "graphql",             -- common in Vue/TS projects

        -- Python
        "python",

        -- C# (stable on all Ubuntu versions)
        "c_sharp",

        -- C / C++ / ROS
        "c", "cpp",

        -- Build systems
        "cmake",               -- CMakeLists.txt
        "make",                -- Makefile

        -- Shell / Scripting
        "bash",

        -- Config & Data (ROS params, URDFs, launch files)
        "yaml",                -- ROS .yaml param files
        "xml",                 -- URDF, SDF, package.xml
        "toml",                -- pyproject.toml, Cargo.toml

        -- Documentation
        "markdown",            -- Markdown structure
        "markdown_inline",     -- Bold/italic/code inside markdown
        "rst",                 -- reStructuredText (Sphinx / ROS docs)

        -- Git
        "git_config", "gitcommit", "gitignore", "diff",
      }
      require'nvim-treesitter'.install(to_install)
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
