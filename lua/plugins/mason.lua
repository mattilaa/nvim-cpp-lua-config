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

    -- Use `nvim-lspconfig` to configure LSP servers
    {
        "neovim/nvim-lspconfig",
        dependencies = { "williamboman/mason-lspconfig.nvim" },
        config = function()
            local lspconfig = require("lspconfig")

            -- Setup Clangd (C/C++)
            lspconfig.clangd.setup({})

            -- Setup Rust Analyzer (Rust)
            lspconfig.rust_analyzer.setup({})
        end,
    },
}

