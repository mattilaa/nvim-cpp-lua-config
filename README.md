# Step by step guide: NeoVim Lua config for C/C++ and Rust development
In this guide we'll make a NeoVim Lua-configuration from scratch for C/C++ and Rust development using lazy.nvim plugin manager.
## First steps
### Directory structure

Create a directory structure under ~/.config/nvim
```bash
.
└── lua
    ├── config
    └── plugins
```

### Create init.lua into root with content
```lua
require("config.lazy")
```

### Let's create lazy.lua into lua/config directory. This content will create a bootsrtap for Lazy plugin and loads it if it doesn's found (likely not..)
```lua
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

Your ~/.config/nvim file structure should look like this now
```bash
.
├── init.lua
└── lua
    ├── config
    │   └── lazy.lua
    └── plugins
```

Now you have a basic setup with Lazy installed. Next we continue to add plugins needed for the development. Your .config/nvim structure should looks like this

## Plugins
