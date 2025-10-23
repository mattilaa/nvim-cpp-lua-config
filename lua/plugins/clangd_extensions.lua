-- lua/plugins/clangd_extensions.lua
return {
    {
        "p00f/clangd_extensions.nvim",
        ft = { "c", "cpp", "objc", "objcpp" },
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            -- Import clangd_config from config/clangd.lua
            local clangd_config = require("config.clangd")

            -- Setup clangd_extensions
            require("clangd_extensions").setup({
                server = clangd_config,
                extensions = {
                    inlay_hints = {
                        inline = vim.fn.has("nvim-0.10") == 1,
                        only_current_line = false,
                        show_parameter_hints = true,
                        parameter_hints_prefix = "<- ",
                        other_hints_prefix = "=> ",
                        max_len_align = false,
                        highlight = "Comment",
                    },
                    ast = {
                        role_icons = {
                            type = "T",
                            declaration = "D",
                            expression = "E",
                            specifier = "S",
                            statement = ";",
                            template = "T",
                        },
                        kind_icons = {
                            Compound = "C",
                            Recovery = "R",
                            TranslationUnit = "U",
                            PackExpansion = "P",
                            TemplateTypeParm = "TP",
                            TemplateTemplateParm = "TTP",
                            TemplateParamObject = "TPO",
                        },
                        highlight = true,
                    },
                    memory_usage = {
                        border = "rounded",
                    },
                    symbol_info = {
                        border = "rounded",
                    },
                },
            })

            -- Keymaps
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    local buf = ev.buf
                    local client = vim.lsp.get_client_by_id(ev.data.client_id)
                    if client and client.name == "clangd" then
                        vim.keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", { buffer = buf, desc = "Switch source/header" })
                        vim.keymap.set("n", "<leader>cm", "<cmd>ClangdMemoryUsage<CR>", { buffer = buf, desc = "Show memory usage" })
                        vim.keymap.set("n", "<leader>cs", "<cmd>ClangdSymbolInfo<CR>", { buffer = buf, desc = "Show symbol info" })
                        vim.keymap.set("n", "<leader>ca", "<cmd>ClangdAST<CR>", { buffer = buf, desc = "Show AST" })
                    end
                end,
            })
        end,
    },
}
