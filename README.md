# Install
If you want to use this repository directly in your NeoVim, just clone it
```bash
Mac/Linux:
git clone https://github.com/mattilaa/nvim-lua-config ~/.config/nvim

Windows:
git clone https://github.com/mattilaa/nvim-lua-config ~\AppData\Local\nvim
```

Note: It should work out of the box on first launch, if all depedencies (such as FZF) are installed to the system. Confirmed to work on MacOS, Linux and Windows 11 (some additional Mason plugins might not install directly).

# Step by step guide: NeoVim Lua config for C/C++ and Rust development
In this guide we'll make a NeoVim Lua-configuration from scratch for C/C++ and Rust development using [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager. Version of NeoVim used: v0.10.1

![alt text](https://github.com/mattilaa/nvim-lua-config/blob/main/config.png?raw=true)
## First steps
### Directory structure

Create a directory structure under ~/.config/nvim (Windows: ~\AppData\Local\nvim)
```bash
.
└── lua
    ├── config
    └── plugins
```

### Take Lazy is use
Create init.lua into root with content
```lua
require("config.lazy")
```

Let's create lazy.lua into lua/config directory. This content will create a bootsrtap for Lazy plugin and loads it if it doesn's found (likely not..)
```lua
-- Set leader key to space. This needs to be done before Lazy
vim.g.mapleader = " "

-- Bootstrap: Install lazy.nvim (if not already installed)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- use always latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we don't error out on first use
local ok, lazy = pcall(require, "lazy")
if not ok then
    return
end

-- Load plugins
lazy.setup("plugins")
```

Your ~/.config/nvim file structure should look like this now.
```bash
.
├── init.lua
└── lua
    ├── config
    │   └── lazy.lua
    └── plugins
```

Now you have a basic setup with Lazy installed. Next we continue to add plugins needed for the development.

## Plugins
Let's add plugins. In this section you'll see how Lazy plugin management works. Structuring files is recommended because of easy plugin management, like adding or removing plugins, and for better maintenance of the config files.

### First plugin
Let's add [bufferline](https://github.com/akinsho/bufferline.nvim) first, since it's simple to configure. Create a file under lua/plugins/bufferline.lua with contents
```lua
return {
    {
        "akinsho/bufferline.nvim",
        version = "v4.*", -- Update major version manually if you want to upgrade in the future
        dependencies = "nvim-tree/nvim-web-devicons",
        opts = {},
    },
}
```
First plugin added. Easy? Restart NeoVim and type
```
:Lazy install
```
Lazy install will install missing plugins.

### Add LSP support with Mason
Languare Server Protocol (LSP) is very handly for autocompleting code and navigating through the code base. Let's add [Mason](https://github.com/williamboman/mason.nvim) plugin. It's an inner plugin manager inside NeoVim that enables different LSP servers, like clangd and rust-analyzer in this example. Create a file lua/plugins/mason.lua with contents
```lua
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
```
Next you have to install the plugin. Restart NeoVim and type :Lazy install

#### Install Mason plugins
Now let's install needed plugins inside Mason package manager. In NeoVim, type
```vim
:MasonInstall clangd clang-format rust-analyzer tree-sitter-cli 
```
That's basically all plugins you need in C/C++/Rust development. I also use Python. If you want to add LSP support for Python as well, type
```vim
:MasonInstall pyright ruff
```
### Clangd config
Let's create config for Clangd LSP. Create a file lua/config/clangd.lua with contents
```lua
-- Cpp stuff
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {
  cmd = {
       "clangd",
       "--clang-tidy",
       "--background-index",
       "--all-scopes-completion",
       "--header-insertion=never",
       "--completion-style=detailed",
       "--cross-file-rename",
  },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  root_dir = function(fname)
    return lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname) or lspconfig.util.path.dirname(fname)
  end,
  settings = {
    clangd = {
      completeUnimported = true,
      usePlaceholders = true,
      clangdFileStatus = true,
      semanticHighlighting = true,
      completion = {
	      filterAndSort = true,
      },
      diagnostics = {
	      disabled = { "clang-diagnostic-unused-parameter" },
      },
    }
  }
}
```

### Add autocomplete framework
Now we need an autocompleting framework plugin to work with LSPs. Create a file lua/plugins/nvim-cmp.lua with contents
```lua
local complete = {
	"hrsh7th/nvim-cmp",
	dependencies = {
        "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
        "hrsh7th/cmp-buffer", -- Buffer completions
        "hrsh7th/cmp-path", -- Path completions
        "hrsh7th/cmp-cmdline", -- Cmdline completions
        'saadparwaiz1/cmp_luasnip', -- Snippet completions
        'L3MON4D3/LuaSnip' -- Snippets plugin
	},
}

complete.config = function()
    local cmp = require("cmp")

    -- Helper function for tab completion
    local has_words_before = function()
        if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line-1, 0, line-1, col, {})[1]:match("^%s*$") == nil
    end

    -- Helper function for vsnip
    local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end

    cmp.setup({
        snippet = {
            expand = function(args)
                require('luasnip').lsp_expand(args.body)
            end,
        },
        formatting = {
            fields = { "abbr", "kind", "menu" },
            format = function(entry, vim_item)
                local item = entry:get_completion_item()
                if item.detail then
                    vim_item.abbr = vim_item.abbr .. " : " .. item.detail
                end
                return vim_item
            end,
        },
        mapping = {
            ['<C-d>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<C-e>'] = cmp.mapping.close(),
            ['<CR>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    local entry = cmp.get_selected_entry()
                    if entry and (entry.completion_item.kind == 3 or entry.completion_item.kind == 2) then
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
                        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('()<Left>', true, true, true), 'n', true)
                    else
                        cmp.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true })
                    end
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif vim.fn["vsnip#available"](1) == 1 then
                    feedkey("<Plug>(vsnip-expand-or-jump)", "")
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif vim.fn["vsnip#jumpable"](-1) == 1 then
                    feedkey("<Plug>(vsnip-jump-prev)", "")
                else
                    fallback()
                end
            end, { "i", "s" }),
        },
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer' },
            { name = 'path' },
            { name = 'cmdline' },
        }
    })
end

return complete
```

## Settings
Let's make NeoVim more confortable to use. We'll start with keymapping. Add a file lua/config/keymap.lua with contents
```lua
-- Generic LSP keybindings
local opts = { buffer = buffer }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<leader>h", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
vim.keymap.set("n", "<space>e", "<cmd>Explore<cr>", opts)
vim.keymap.set('v', '<leader>f', vim.lsp.buf.format, { remap = false })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

-- Copy/paste from system clipboard
vim.keymap.set('x', '<leader>p', '"_dP', opts)
vim.keymap.set('v', '<leader>y', '"+y', opts)

-- Browse buffers
vim.keymap.set('n', '<c-j>', ':bp<cr>', opts)
vim.keymap.set('n', '<c-k>', ':bn<cr>', opts)
vim.keymap.set('n', '<leader>bd', ':bd<cr>', opts)

-- Escape from everything
vim.keymap.set('n', '<esc><esc>', ':noh<cr>')
```
Also some visual settings make life better. Create a file lua/config/options.lua with contents
```lua
-- Visual settings
vim.opt.relativenumber = true
vim.opt.ruler = true
vim.opt.cc = "80" -- Right margin
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.softtabstop = 4
vim.opt.cursorline = true
vim.opt.number = true

-- Enable copy/paste from system clipboard
vim.opt.clipboard = 'unnamedplus'
```

You have to update your init.lua also looking like this
```lua
-- Load Lazy and configure plugins
require("config.lazy")

-- Enable key mapping
require("config.keymap")

-- Options
require("config.options")

-- Commands
require("config.commands")

-- Clangd config
require("config.clangd")
```

### Color theme
I use [Catppuccin](https://github.com/catppuccin/nvim) as a theme. Here's how to configure it. Create a file lua/plugins/theme.lua with contents
```lua
-- Catppuccin theme
return {
    'catppuccin/nvim',
    name = 'catppuccin',
    config = function()
        require('catppuccin').setup({
            flavour = 'macchiato', -- or 'frappe', 'macchiato', 'mocha'
        })
        vim.cmd [[colorscheme catppuccin]]
    end
}
```
We use theme.lua as a general theme file name, since no need to change file name if some other theme will be used in the future. Catppuccin integrates with [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) installed with Mason earlier. You have also good looking syntax highlighting now.

You have to enable it also. Let's make a new file lua/config/commands.lua with contents
```lua
-- Color scheme
vim.cmd.colorscheme "catppuccin-mocha"

-- Trim trailing whitespaces on save
vim.cmd([[autocmd BufWritePre * :%s/\s\+$//e]])
```
Other commands should be placed into the same file as well. There is whitespace trim on save also added to the same file.

### Fuzzy search
Fuzzy search is really good feature to find files and text in the project very fast. Let's install FZF. It must be installed into the operating system first. Follow [these instructions](https://github.com/junegunn/fzf.vim?tab=readme-ov-file#dependencies). Create a file lua/plugins/fzf.lua with contents
```lua
-- FZF Lua plugin
return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        require("fzf-lua").setup({})
    end,
}
```
Now add these lines into lua/config/keymap.lua
```lua
-- FZF and RG
vim.keymap.set("n", "<c-p>",
    "<cmd>lua require('fzf-lua').files()<cr>", { silent = true })
vim.keymap.set("n", "<c-s>",
    "<cmd>lua require('fzf-lua').live_grep()<cr>", { silent = true })
vim.keymap.set("n", "<c-a>",
  "<cmd>lua require('fzf-lua').buffers()<cr>", { silent = true })
```
Ctrl-P will activate fuzzy file search and Ctrl-S activates search text in files.

Finally, your .config/nvim (Windows: ~\AppData\Local\nvim) file strucure should look like this
```bash
.
├── init.lua
└── lua
    ├── config
    │   ├── clangd.lua
    │   ├── commands.lua
    │   ├── keymap.lua
    │   ├── lazy.lua
    │   ├── nvim-cmp.lua
    │   └── options.lua
    └── plugins
        ├── bufferline.lua
        ├── fzf.lua
        ├── mason.lua
        ├── nvim-cmp.lua
        └── theme.lua

```
# Enjoy your NeoVim!
