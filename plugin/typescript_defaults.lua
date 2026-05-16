-- ~/.config/nvim/plugin/javascript_defaults.lua
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'typescript',
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.keymap.set('i', '<C-j>', '`${}`<Left><Left>', {
      desc = 'Insert template literal',
      buffer = true,
    })
  end,
})
