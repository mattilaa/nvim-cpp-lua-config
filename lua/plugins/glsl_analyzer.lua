return {
  -- Mason setup
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "glsl_analyzer",
      },
    },
  },

  -- Mason-LSPConfig bridge
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "glsl_analyzer", -- or "glslls"
      },
      handlers = {
        -- Default handler for glsl_analyzer
        ["glsl_analyzer"] = function()
          require("lspconfig").glsl_analyzer.setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
            on_attach = function(client, bufnr)
            end,
          })
        end,
      },
    },
    dependencies = {
      "mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- You can also configure directly here if not using mason-lspconfig handlers
      -- require("lspconfig").glsl_analyzer.setup({})
    end,
  },
}

-- Manual setup (if not using lazy.nvim):
-- require("mason").setup()
-- require("mason-lspconfig").setup({
--   ensure_installed = { "glsl_analyzer" }
-- })
-- require("lspconfig").glsl_analyzer.setup({
--   capabilities = require("cmp_nvim_lsp").default_capabilities(),
-- })
