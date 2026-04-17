vim.keymap.set('t', '<C-c><C-c>', '<c-\\><c-n>', { desc = 'Easy exit from terminal mode' })
vim.keymap.set('t', '<C-w><C-w>', [[<C-\><C-n><C-w><C-w>]], { desc = 'Cycle windows from terminal' })

local state = {
  floating = {
    buf = -1,
    win = -1,
  },
}

local function create_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if opts.buf and opts.buf > 0 and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= 'terminal' then
      vim.cmd.terminal()
      vim.cmd 'startinsert'
      vim.b[state.floating.buf].is_floating_terminal = true
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

local get_python_info = function()
  local file_path = vim.api.nvim_buf_get_name(0)
  local filename = vim.fn.fnamemodify(file_path, ':t')
  local dir = vim.fn.fnamemodify(file_path, ':p:h')

  local parts = {}
  if filename ~= '__init__.py' then
    table.insert(parts, 1, vim.fn.fnamemodify(filename, ':r'))
  end

  local current = dir
  while true do
    if vim.fn.filereadable(current .. '/__init__.py') ~= 1 then
      break
    end
    table.insert(parts, 1, vim.fn.fnamemodify(current, ':t'))
    local parent = vim.fn.fnamemodify(current, ':h')
    if parent == current then
      break
    end
    current = parent
  end

  local module_name = table.concat(parts, '.')
  local project_root = current

  return module_name, project_root
end

local run_python_terminal_interactive = function()
  local current_file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype ~= 'python' then
    vim.notify('Not a python file', vim.log.levels.WARN)
    return
  end

  -- Save the file before running
  vim.cmd 'silent! write'

  local module_name, project_root = get_python_info()

  local win_info = create_floating_window()
  -- vim.fn.termopen { 'python', current_file }
  vim.cmd('terminal PYTHONPATH=' .. vim.fn.shellescape(project_root) .. ' python -i -m ' .. module_name)
  vim.cmd 'startinsert'

  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = win_info.buf,
    command = 'startinsert',
  })

  -- Close the window with 'q' when the process is done
  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win_info.win) then
      vim.api.nvim_win_close(win_info.win, true)
    end
  end, { buffer = win_info.buf, silent = true })
end

local run_python_terminal = function()
  local current_file = vim.api.nvim_buf_get_name(0)
  if vim.bo.filetype ~= 'python' then
    vim.notify('Not a python file', vim.log.levels.WARN)
    return
  end

  -- Save the file before running
  vim.cmd 'silent! write'

  local module_name, project_root = get_python_info()

  local win_info = create_floating_window()
  -- vim.fn.termopen { 'python', current_file }
  vim.cmd('terminal PYTHONPATH=' .. vim.fn.shellescape(project_root) .. ' python -m ' .. module_name)
  vim.cmd 'startinsert'

  vim.api.nvim_create_autocmd('BufEnter', {
    buffer = win_info.buf,
    command = 'startinsert',
  })

  -- Close the window with 'q' when the process is done
  vim.keymap.set('n', 'q', function()
    if vim.api.nvim_win_is_valid(win_info.win) then
      vim.api.nvim_win_close(win_info.win, true)
    end
  end, { buffer = win_info.buf, silent = true })
end

vim.api.nvim_create_user_command('Floaterminal', toggle_terminal, {})
vim.keymap.set({ 'n', 't' }, '<space>tt', toggle_terminal, { desc = 'Floating terminal' })
vim.keymap.set('n', '<leader>tpp', run_python_terminal, { desc = 'Run Python in floating terminal' })
vim.keymap.set('n', '<leader>tpi', run_python_terminal_interactive, { desc = 'Run interactive Python in floating terminal' })

return {}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
