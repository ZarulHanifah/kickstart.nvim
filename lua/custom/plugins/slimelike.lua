local function find_terminal_buf_and_send(lines, opts)
  opts = opts or {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].buftype == 'terminal' then
      local job_id = vim.b[buf].terminal_job_id
      if job_id then
        for _, line in ipairs(lines) do
          vim.api.nvim_chan_send(job_id, line .. '\n')
        end

        if opts.jump then
          vim.api.nvim_set_current_win(win)
        end

        if opts.scroll then
          vim.api.nvim_win_call(win, function()
            vim.cmd 'normal! G'
          end)
        end

        return
      end
    end
  end
  vim.notify('No terminal buffer with a job found', vim.log.levels.WARN)
end

vim.keymap.set('v', '<leader>xx', function()
  local start_row = vim.fn.line 'v'
  local end_row = vim.fn.line '.'
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  find_terminal_buf_and_send(lines, { scroll = true })
end, { desc = 'Send visual selection to terminal' })

vim.keymap.set('n', '<leader>xx', function()
  local line = vim.api.nvim_get_current_line()
  find_terminal_buf_and_send({ line }, { scroll = true })
end, { desc = 'Send current line to terminal' })

vim.keymap.set('v', '<leader>xj', function()
  local start_row = vim.fn.line 'v'
  local end_row = vim.fn.line '.'
  if start_row > end_row then
    start_row, end_row = end_row, start_row
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  find_terminal_buf_and_send(lines, { jump = true, scroll = true })
end, { desc = 'Send selection and jump to terminal' })

vim.keymap.set('n', '<leader>xj', function()
  local line = vim.api.nvim_get_current_line()
  find_terminal_buf_and_send({ line }, { jump = true, scroll = true })
end, { desc = 'Send line and jump to terminal' })

return {}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
