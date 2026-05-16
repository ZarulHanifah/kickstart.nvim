vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript' },
  callback = function()
    vim.opt_local.expandtab = true -- Convert tabs to spaces
    vim.opt_local.shiftwidth = 2 -- Size of an indent
    vim.opt_local.tabstop = 2 -- Number of spaces tabs count for
  end,
})
