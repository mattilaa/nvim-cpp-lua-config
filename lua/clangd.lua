-- Cpp stuff

local util = require('lspconfig/util')
local lsp = require('lsp-zero').preset({
  name = 'minimal',
  set_lsp_keymaps = true,
  manage_nvim_cmp = true,
  suggest_lsp_servers = false,
})

lsp.configure("clangd", {
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
   root_dir = util.root_pattern("compile_commands.json", ".git"),
   settings = {
       clangd = {
           semanticHighlighting = true,
           completion = {
               filterAndSort = true,
           },
           diagnostics = {
               disabled = { "clang-diagnostic-unused-parameter" },
           },
       },
   },
})

lsp.setup()


