-- Resize splits with arrow keys
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>', { silent = true })
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { silent = true })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { silent = true })

-- pasting over highlighted text, without overwriting copied register
vim.keymap.set('x', '<leader>p', '"_dP')

-- Ctrl-C is same as Esc
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Global search replace
vim.keymap.set('n', '<leader>S', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = 'Substitute word under cursor (global, case-insensitive)',
})

vim.keymap.set('n', '<leader>cc', function()
  local line = vim.api.nvim_get_current_line()
  local prefix, open, inner, close = line:match '^(.-)([%[{%(])%s*(.-)%s*([%]}%)])$'
  if not prefix then
    vim.notify('No iterable structure found on line', vim.log.levels.WARN)
    return
  end

  local items = vim.split(inner, ',%s*', { trimempty = true })
  if #items == 0 then
    return
  end

  -- Add a trailing comma to the last item if missing
  if not items[#items]:match ',$' then
    items[#items] = items[#items] .. ','
  end

  local indent = string.rep(' ', vim.fn.indent '.')
  local new_lines = { prefix .. open }
  for _, item in ipairs(items) do
    table.insert(new_lines, indent .. '  ' .. item .. ',')
  end
  -- Replace last comma with nothing (optional)
  -- new_lines[#new_lines] = new_lines[#new_lines]:gsub(",$", "")
  table.insert(new_lines, indent .. close)

  -- Replace current line with the formatted block
  vim.api.nvim_buf_set_lines(0, vim.fn.line '.' - 1, vim.fn.line '.', false, new_lines)
end, { desc = 'Format dict/list/tuple inline to multi-line', noremap = true, silent = true })

return {}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
