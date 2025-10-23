return {
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()  -- Initialize
        end,
    },

    -- Use `mason-lspconfig.nvim` to bridge `mason.nvim` with `nvim-lspconfig`
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "rust_analyzer" },  -- Ensure servers are installed
            })
        end,
    },
}

