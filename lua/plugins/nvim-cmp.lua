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
