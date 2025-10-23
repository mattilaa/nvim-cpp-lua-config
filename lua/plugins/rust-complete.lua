return {
    -- Mason for installing LSP servers
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "rust_analyzer",  -- Rust LSP
                    "taplo",         -- TOML LSP for Cargo.toml
                },
            })
        end,
    },

    -- Completion plugins
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",     -- LSP completion source
            "hrsh7th/cmp-buffer",        -- Buffer completion source
            "hrsh7th/cmp-path",          -- Path completion source
            "hrsh7th/cmp-cmdline",       -- Command line completion
            "L3MON4D3/LuaSnip",          -- Snippet engine
            "saadparwaiz1/cmp_luasnip",  -- Snippet completion
            "hrsh7th/cmp-nvim-lsp-signature-help", -- Function signatures
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            -- Helper function for better tab completion
            local has_words_before = function()
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
            end

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = {
                        border = "rounded",
                        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                    },
                    documentation = {
                        border = "rounded",
                        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                        max_width = 80,
                    },
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        -- Kind icons for different completion types
                        local kind_icons = {
                            Text = "󰉿",
                            Method = "󰆧",
                            Function = "󰊕",
                            Constructor = "",
                            Field = "󰜢",
                            Variable = "󰀫",
                            Class = "󰠱",
                            Interface = "",
                            Module = "",
                            Property = "󰜢",
                            Unit = "󰑭",
                            Value = "󰎠",
                            Enum = "",
                            Keyword = "󰌋",
                            Snippet = "",
                            Color = "󰏘",
                            File = "󰈙",
                            Reference = "󰈇",
                            Folder = "󰉋",
                            EnumMember = "",
                            Constant = "󰏿",
                            Struct = "󰙅",
                            Event = "",
                            Operator = "󰆕",
                            TypeParameter = "",
                        }
                        vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind)

                        -- Show source of completion
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip = "[Snippet]",
                            buffer = "[Buffer]",
                            path = "[Path]",
                            nvim_lsp_signature_help = "[Signature]",
                        })[entry.source.name]

                        -- Truncate long completions
                        local max_width = 50
                        if string.len(vim_item.abbr) > max_width then
                            vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 3) .. "..."
                        end

                        return vim_item
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-p>"] = cmp.mapping.select_prev_item(),
                    ["<C-n>"] = cmp.mapping.select_next_item(),
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        elseif has_words_before() then
                            cmp.complete()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "nvim_lsp_signature_help", priority = 900 },
                    { name = "luasnip", priority = 750 },
                    { name = "path", priority = 500 },
                }, {
                    { name = "buffer", priority = 250 },
                }),
                experimental = {
                    ghost_text = true,  -- Show ghost text for the top completion
                },
            })

            -- Setup completion for specific filetypes
            cmp.setup.filetype('rust', {
                sources = cmp.config.sources({
                    { name = 'nvim_lsp', priority = 1000 },
                    { name = 'nvim_lsp_signature_help', priority = 900 },
                    { name = 'luasnip', priority = 750 },
                    { name = 'crates', priority = 650 },  -- Crate version completions
                    { name = 'path', priority = 500 },
                }, {
                    { name = 'buffer', priority = 250 },
                })
            })

            -- Command line completion
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },

    -- LSP Configuration
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            local lspconfig = require("lspconfig")

            -- Enhanced capabilities for nvim-cmp
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            capabilities.textDocument.completion.completionItem = {
                documentationFormat = { "markdown", "plaintext" },
                snippetSupport = true,
                preselectSupport = true,
                insertReplaceSupport = true,
                labelDetailsSupport = true,
                deprecatedSupport = true,
                commitCharactersSupport = true,
                tagSupport = { valueSet = { 1 } },
                resolveSupport = {
                    properties = {
                        "documentation",
                        "detail",
                        "additionalTextEdits",
                    },
                },
            }

            -- Rust Analyzer setup with enhanced completion
            lspconfig.rust_analyzer.setup({
                capabilities = capabilities,
                settings = {
                    ["rust-analyzer"] = {
                        -- Cargo configuration
                        cargo = {
                            allFeatures = true,
                            loadOutDirsFromCheck = true,
                            runBuildScripts = true,
                            -- Enhanced completion features
                            autoreload = true,
                        },
                        -- Enhanced completion settings
                        completion = {
                            addCallArgumentSnippets = true,
                            addCallParenthesis = true,
                            postfix = {
                                enable = true,
                            },
                            autoimport = {
                                enable = true,
                            },
                            autoself = {
                                enable = true,
                            },
                            snippets = {
                                custom = {
                                    ["Arc::new"] = {
                                        postfix = "arc",
                                        body = "Arc::new(${receiver})",
                                        requires = "std::sync::Arc",
                                        description = "Wrap in Arc",
                                        scope = "expr",
                                    },
                                    ["Rc::new"] = {
                                        postfix = "rc",
                                        body = "Rc::new(${receiver})",
                                        requires = "std::rc::Rc",
                                        description = "Wrap in Rc",
                                        scope = "expr",
                                    },
                                    ["Box::new"] = {
                                        postfix = "box",
                                        body = "Box::new(${receiver})",
                                        description = "Wrap in Box",
                                        scope = "expr",
                                    },
                                    ["Some"] = {
                                        postfix = "some",
                                        body = "Some(${receiver})",
                                        description = "Wrap in Some",
                                        scope = "expr",
                                    },
                                    ["Ok"] = {
                                        postfix = "ok",
                                        body = "Ok(${receiver})",
                                        description = "Wrap in Ok",
                                        scope = "expr",
                                    },
                                    ["Err"] = {
                                        postfix = "err",
                                        body = "Err(${receiver})",
                                        description = "Wrap in Err",
                                        scope = "expr",
                                    },
                                },
                            },
                        },
                        -- Check on save configuration
                        checkOnSave = true,
                        check = {
                            command = "clippy",
                            extraArgs = { "--no-deps" },
                        },
                        -- Proc macro support
                        procMacro = {
                            enable = true,
                            attributes = {
                                enable = true,
                            },
                        },
                        -- Enhanced diagnostics
                        diagnostics = {
                            enable = true,
                            experimental = {
                                enable = true,
                            },
                            disabled = {
                                -- Add any diagnostics you want to disable
                            },
                        },
                        -- Inlay hints for better code understanding
                        inlayHints = {
                            bindingModeHints = {
                                enable = false,
                            },
                            chainingHints = {
                                enable = true,
                            },
                            closingBraceHints = {
                                enable = true,
                                minLines = 25,
                            },
                            closureReturnTypeHints = {
                                enable = "never",
                            },
                            lifetimeElisionHints = {
                                enable = "never",
                                useParameterNames = false,
                            },
                            maxLength = 25,
                            parameterHints = {
                                enable = true,
                            },
                            reborrowHints = {
                                enable = "never",
                            },
                            renderColons = true,
                            typeHints = {
                                enable = true,
                                hideClosureInitialization = false,
                                hideNamedConstructor = false,
                            },
                        },
                        -- Code lens
                        lens = {
                            enable = true,
                            implementations = {
                                enable = true,
                            },
                            references = {
                                enable = true,
                                trait = {
                                    enable = true,
                                },
                                enumVariant = {
                                    enable = true,
                                },
                                adt = {
                                    enable = true,
                                },
                                method = {
                                    enable = true,
                                },
                            },
                            run = {
                                enable = true,
                            },
                            debug = {
                                enable = true,
                            },
                        },
                        -- Rustfmt
                        rustfmt = {
                            enableRangeFormatting = true,
                            extraArgs = {},
                        },
                        -- Workspace configuration
                        workspace = {
                            symbol = {
                                search = {
                                    scope = "workspace",
                                },
                            },
                        },
                    },
                },
                on_attach = function(client, bufnr)
                    -- Enable completion triggered by <c-x><c-o>
                    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                    -- Enable inlay hints
                    if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                    end

                    -- Rust-specific keymaps
                    local opts = { buffer = bufnr, noremap = true, silent = true }

                    -- Go to definition/declaration
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
                    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)

                    -- Documentation and hover
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

                    -- Workspace management
                    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)

                    -- Code actions and refactoring
                    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

                    -- Formatting
                    vim.keymap.set('n', '<leader>f', function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)

                    -- Diagnostics
                    vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
                    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
                    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
                    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

                    -- Rust-specific commands
                    vim.keymap.set("n", "<leader>rh", function()
                        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                    end, vim.tbl_extend("force", opts, { desc = "Toggle inlay hints" }))

                    -- Auto-format on save
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format({ async = false })
                        end,
                    })
                end,
            })

            -- TOML LSP for Cargo.toml files
            lspconfig.taplo.setup({
                capabilities = capabilities,
            })
        end,
    },

    -- Rust-specific plugins
    {
        "rust-lang/rust.vim",
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
            vim.g.rustfmt_emit_files = 1
            vim.g.rustfmt_fail_silently = 0
        end,
    },

    -- Crates.nvim for Cargo.toml dependency management
    {
        "saecki/crates.nvim",
        ft = { "rust", "toml" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local crates = require("crates")
            crates.setup({
                smart_insert = true,
                insert_closing_quote = true,
                autoload = true,
                autoupdate = true,
                loading_indicator = true,
                date_format = "%Y-%m-%d",
                thousands_separator = ".",
                notification_title = "Crates",
                text = {
                    loading = "   Loading",
                    version = "   %s",
                    prerelease = "   %s",
                    yanked = "   %s",
                    nomatch = "   No match",
                    upgrade = "   %s",
                    error = "   Error fetching crates",
                },
                highlight = {
                    loading = "CratesNvimLoading",
                    version = "CratesNvimVersion",
                    prerelease = "CratesNvimPreRelease",
                    yanked = "CratesNvimYanked",
                    nomatch = "CratesNvimNoMatch",
                    upgrade = "CratesNvimUpgrade",
                    error = "CratesNvimError",
                },
                popup = {
                    autofocus = false,
                    hide_on_select = false,
                    copy_register = '"',
                    style = "minimal",
                    border = "rounded",
                    show_version_date = true,
                    show_dependency_version = true,
                    max_height = 30,
                    min_width = 20,
                    padding = 1,
                },
                -- No need for completion.cmp anymore, it integrates automatically
            })

            -- Crates.nvim keymaps
            vim.api.nvim_create_autocmd("BufRead", {
                group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
                pattern = "Cargo.toml",
                callback = function()
                    local opts = { noremap = true, silent = true, buffer = true }
                    vim.keymap.set("n", "<leader>ct", crates.toggle, opts)
                    vim.keymap.set("n", "<leader>cr", crates.reload, opts)
                    vim.keymap.set("n", "<leader>cv", crates.show_versions_popup, opts)
                    vim.keymap.set("n", "<leader>cf", crates.show_features_popup, opts)
                    vim.keymap.set("n", "<leader>cd", crates.show_dependencies_popup, opts)
                    vim.keymap.set("n", "<leader>cu", crates.update_crate, opts)
                    vim.keymap.set("v", "<leader>cu", crates.update_crates, opts)
                    vim.keymap.set("n", "<leader>ca", crates.update_all_crates, opts)
                    vim.keymap.set("n", "<leader>cU", crates.upgrade_crate, opts)
                    vim.keymap.set("v", "<leader>cU", crates.upgrade_crates, opts)
                    vim.keymap.set("n", "<leader>cA", crates.upgrade_all_crates, opts)

                    -- Setup completion for Cargo.toml
                    require("cmp").setup.buffer({
                        sources = {
                            { name = "crates" },
                            { name = "nvim_lsp" },
                            { name = "path" },
                            { name = "buffer" },
                        },
                    })
                end,
            })
        end,
    },
}
