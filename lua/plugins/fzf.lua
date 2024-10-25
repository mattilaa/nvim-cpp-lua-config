-- FZF Lua plugin
return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("fzf-lua").setup({})
    end,
}
