return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      direction = "float",
      float_opts = { border = "curved" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      local Terminal = require("toggleterm.terminal").Terminal

      -- swap the cmd string to whatever agent you're using that week
      local agent = Terminal:new({
        cmd = "deepcode",
        direction = "float",
        hidden = true,
      })

      function _AGENT_TOGGLE()
        agent:toggle()
      end

      vim.keymap.set({ "n", "t" }, "<leader>ai", "<cmd>lua _AGENT_TOGGLE()<CR>", { desc = "Toggle AI agent" })

      vim.keymap.set("v", "<leader>as", function()
        require("toggleterm").send_lines_to_terminal("visual_lines", false, { args = agent.id })
      end, { desc = "Send selection to agent" })
    end,
  },
}
