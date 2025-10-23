-- lua/config/clangd.lua
local lspconfig = require("lspconfig")

local clangd_config = {
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
        return lspconfig.util.root_pattern("compile_commands.json", "compile_flags.txt", ".git")(fname)
        or lspconfig.util.path.dirname(fname)
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
        },
    },
}

-- Optional: Setup clangd directly here if you want standalone functionality
lspconfig.clangd.setup(clangd_config)

-- Export the config
return clangd_config
