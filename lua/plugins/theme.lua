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

