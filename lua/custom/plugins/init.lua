-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--

-- move chunks of code
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Definehighlight groups
-- vim.api.nvim_set_hl(0, 'NormalActive', { bg = 'NONE' }) -- Transparent for active
-- vim.api.nvim_set_hl(0, 'NormalInactive', { bg = '#1e1e2e' }) -- Opaque for inactive
-- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1e1e2e' }) -- Opaque float
-- vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#1e1e2e', fg = '#a6accd' })

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
  local bufnr, winid = orig_util_open_floating_preview(contents, syntax, opts, ...)
  if winid and vim.api.nvim_win_is_valid(winid) then
    vim.w[winid].is_lsp_hover = true
  end
  return bufnr, winid
end

local function set_window_highlight()
  local current_win = vim.api.nvim_get_current_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype

    if config.relative == '' and ft ~= 'help' then
      local hl = (win == current_win) and 'Normal:NormalActive' or 'Normal:NormalInactive'
      vim.api.nvim_set_option_value('winhighlight', hl, { win = win })
    end
  end
end

-- Trigger on window enter
vim.api.nvim_create_autocmd({ 'WinEnter', 'BufWinEnter', 'VimResized' }, {
  callback = function()
    vim.schedule(set_window_highlight)
  end,
})

-- Trigger on window leave
vim.api.nvim_create_autocmd({ 'WinLeave' }, {
  callback = function()
    vim.schedule(set_window_highlight)
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function()
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1e1e2e' })
    vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#1e1e2e', fg = '#a6accd' })
    vim.api.nvim_set_hl(0, 'NormalActive', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'NormalInactive', { bg = '#1e1e2e' })
  end,
})

vim.api.nvim_create_autocmd({ 'WinNew', 'BufWinEnter' }, {
  callback = function()
    vim.defer_fn(function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then
          local buf = vim.api.nvim_win_get_buf(win)

          local is_term = vim.b[buf].is_floating_terminal
          local is_lsp_hover = vim.w[win].is_lsp_hover

          if is_term then
            -- Floating terminal follows active/inactive logic
            local current_win = vim.api.nvim_get_current_win()
            local hl = (win == current_win) and 'Normal:NormalActive' or 'Normal:NormalInactive'
            vim.api.nvim_set_option_value('winhighlight', hl, { win = win })
          elseif is_lsp_hover then
            -- Force LSP hover to opaque
            vim.api.nvim_set_option_value('winhighlight', 'Normal:NormalFloat,FloatBorder:FloatBorder', { win = win })
          else
            -- Leave others (Telescope, cmp, etc.) alone
          end
        end
      end
    end, 10)
  end,
})
-- See the kickstart.nvim README for more information
return {
  { import = 'custom.plugins.remap' },
  { import = 'custom.plugins.terminal' },
  { import = 'custom.plugins.slimelike' },
  { import = 'custom.plugins.lsp' },
  { import = 'custom.plugins.zarul' },
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
