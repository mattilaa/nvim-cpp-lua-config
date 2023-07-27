-- Generic LSP keybindings
local opts = { buffer = buffer }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<leader>h", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
vim.keymap.set("n", "<space>e", "<cmd>Explore<cr>", opts)
vim.keymap.set('v', '<leader>f', vim.lsp.buf.format, { remap = false })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

-- FZF and RG
vim.keymap.set("n", "<c-p>",
    "<cmd>lua require('fzf-lua').files()<cr>", { silent = true })
vim.keymap.set("n", "<c-s>",
    "<cmd>lua require('fzf-lua').live_grep()<cr>", { silent = true })
vim.keymap.set("n", "<c-a>",
  "<cmd>lua require('fzf-lua').buffers()<cr>", { silent = true })

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

-- Copy/paste from system clipboard
vim.opt.clipboard = 'unnamedplus'
vim.keymap.set('x', '<leader>p', '"_dP', opts)
vim.keymap.set('v', '<leader>y', '"+y', opts)

-- Browse buffers
vim.keymap.set('n', '<c-j>', ':bp<cr>', opts)
vim.keymap.set('n', '<c-k>', ':bn<cr>', opts)
vim.keymap.set('n', '<leader>bd', ':bd<cr>', opts)

-- Escape from everything
vim.keymap.set('n', '<esc><esc>', ':noh<cr>')

-- Ignore case in search
vim.opt.ignorecase = true

-- Color scheme
vim.cmd.colorscheme "catppuccin-mocha"

-- Trim trailing whitespaces on save
vim.cmd([[autocmd BufWritePre * :%s/\s\+$//e]])
