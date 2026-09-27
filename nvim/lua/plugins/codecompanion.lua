return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat" },
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions", mode = { "n", "v" } },
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = { adapter = "deepseek" },
          inline = { adapter = "deepseek" },
        },
        adapters = {
          -- anthropic = function()
          --   return require("codecompanion.adapters").extend("anthropic", {
          --     env = { api_key = "ANTHROPIC_API_KEY" },
          --   })
          -- end,
          -- openai = function()
          --   return require("codecompanion.adapters").extend("openai", {
          --     env = { api_key = "OPENAI_API_KEY" },
          --   })
          -- end,
          deepseek = function()
            return require("codecompanion.adapters").extend("deepseek", {
              env = { api_key = "DEEPSEEK_API_KEY" },
              schema = {
                model = {
                  default = "deepseek-chat",
                },
              },
            })
          end,
        },
      })
    end,
  },
}
