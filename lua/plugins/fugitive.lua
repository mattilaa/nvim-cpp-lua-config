-- In your lazy.nvim setup file (usually init.lua or plugins.lua)
return {
  {
    "tpope/vim-fugitive",
    lazy = false, -- Load at startup
    cmd = {
      "G",
      "Git",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
    },
    -- Optional: Add keymaps
    config = function()
      -- Add your keymaps here
      vim.keymap.set("n", "<leader>gs", ":Git<CR>", { desc = "Git status" })
      vim.keymap.set("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
      vim.keymap.set("n", "<leader>gp", ":Git push<CR>", { desc = "Git push" })
      vim.keymap.set("n", "<leader>gl", ":Git pull<CR>", { desc = "Git pull" })
      vim.keymap.set("n", "<leader>gb", ":Git blame<CR>", { desc = "Git blame" })
    end,
  }
}
