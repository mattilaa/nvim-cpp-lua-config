-- Generic LSP keybindings
local opts = { buffer = buffer }
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<leader>h", "<cmd>ClangdSwitchSourceHeader<cr>", opts)
vim.keymap.set("n", "<leader>e", "<cmd>lua vim.diagnostic.open_float()<cr>", opts)
vim.keymap.set("n", "<leader>x", "<cmd>Explore<cr>", opts)
vim.keymap.set('v', '<leader>f', vim.lsp.buf.format, { remap = false })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

-- FZF and RG
vim.keymap.set("n", "<c-p>",
    "<cmd>lua require('fzf-lua').files()<cr>", { silent = true })
vim.keymap.set("n", "<c-s>",
    "<cmd>lua require('fzf-lua').live_grep()<cr>", { silent = true })
vim.keymap.set("n", "<c-a>",
  "<cmd>lua require('fzf-lua').buffers()<cr>", { silent = true })

-- Copy/paste from system clipboard
vim.keymap.set('x', '<leader>p', '"_dP', opts)
vim.keymap.set('v', '<leader>y', '"+y', opts)

-- Browse buffers
vim.keymap.set('n', '<c-j>', ':bp<cr>', opts)
vim.keymap.set('n', '<c-k>', ':bn<cr>', opts)
vim.keymap.set('n', '<leader>bd', ':bd<cr>', opts)

-- Escape from everything
vim.keymap.set('n', '<esc><esc>', ':noh<cr>')

