-- Load additional Lua modules
require('settings')
require('clangd')
require('cmpsettings')

-- Initialize packer
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Mason for managing LSP servers, linters, and formatters
  use {
    'williamboman/mason.nvim',
    config = function()
      require("mason").setup()
    end
  }

  -- Mason LSPConfig bridge
  use {
    'williamboman/mason-lspconfig.nvim',
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "lua_ls", "pyright", "tsserver", "clangd" }, -- example LSP servers
      }
    end
  }

  -- Collection of configurations for built-in LSP client
  use {
    'neovim/nvim-lspconfig',
    config = function()
      local lspconfig = require('lspconfig')
      require('mason-lspconfig').setup_handlers({
        function(server_name)
          lspconfig[server_name].setup {}
        end,
      })
    end
  }

  -- Autocompletion framework
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer', -- Buffer completions
      'hrsh7th/cmp-path', -- Path completions
      'hrsh7th/cmp-cmdline', -- Cmdline completions
      'saadparwaiz1/cmp_luasnip', -- Snippet completions
      'L3MON4D3/LuaSnip' -- Snippets plugin
    },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = {
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'buffer' },
          { name = 'path' },
          { name = 'cmdline' },
        }
      })
    end
  }

  -- Catppuccin theme
  use {
    'catppuccin/nvim',
    as = 'catppuccin',
    config = function()
      require('catppuccin').setup({
        flavour = 'macchiato', -- or 'frappe', 'macchiato', 'mocha'
      })
      vim.cmd [[colorscheme catppuccin]]
    end
  }

  -- FZF-Lua for fuzzy finding
  use {
    'ibhagwan/fzf-lua',
    requires = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('fzf-lua').setup({})
    end
  }

  -- Web devicons for file icons
  use 'nvim-tree/nvim-web-devicons'
  -- Bufferline for buffer tabs
  use {
    'akinsho/bufferline.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
    config = function()
      require('bufferline').setup {
          options = {
            diagnostics = "nvim_lsp",
            show_buffer_icons = true,
            show_buffer_close_icons = true,
            show_close_icon = false,
            separator_style = "slant",
            offsets = {
              {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "left"
              }
            }
          }
        }
    end
  }
end)

