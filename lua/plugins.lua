require("packer").startup(function(use)
  -- Packer can manage itself
  use("wbthomason/packer.nvim")
  -- Collection of common configurations for the Nvim LSP client
  use("neovim/nvim-lspconfig")
  -- Mason
  -- use 'williamboman/mason.nvim'
  -- use 'williamboman/mason-lspconfig.nvim'
  -- Visualize lsp progress
  use({
    "j-hui/fidget.nvim",
    config = function()
      require("fidget").setup()
    end
  })

  -- Autocompletion framework
  use("hrsh7th/nvim-cmp")
  use({
    -- cmp LSP completion
    "hrsh7th/cmp-nvim-lsp",
    -- cmp Snippet completion
    "hrsh7th/cmp-vsnip",
    -- cmp Path completion
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    after = { "hrsh7th/nvim-cmp" },
    requires = { "hrsh7th/nvim-cmp" },
  })
  -- See hrsh7th other plugins for more great completion sources!
  -- Snippet engine
  use('hrsh7th/vim-vsnip')
  -- Adds extra functionality over rust analyzer
  use("simrat39/rust-tools.nvim")

  -- Optional
  use("nvim-lua/popup.nvim")
  use("nvim-lua/plenary.nvim")
  use("nvim-telescope/telescope.nvim")

  use('VonHeikemen/lsp-zero.nvim')
  use('mhartington/formatter.nvim')

  use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}

  use { "catppuccin/nvim", as = "catppuccin" }

  use { "ibhagwan/fzf-lua",
  -- optional for icon support
      requires = { "nvim-tree/nvim-web-devicons" }
  }

end)

-- the first run will install packer and our plugins
if packer_bootstrap then
  require("packer").sync()
  return
end

