-- Color scheme
vim.cmd.colorscheme "catppuccin-mocha"

-- Trim trailing whitespaces on save
vim.cmd([[autocmd BufWritePre * :%s/\s\+$//e]])

