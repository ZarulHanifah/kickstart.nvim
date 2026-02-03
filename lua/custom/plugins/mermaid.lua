return {
  {
    'mracos/mermaid.vim',
    ft = { 'mermaid', 'mmd' },
  },

  {
    'nvim-lua/plenary.nvim',
    config = function()
      local state = {} -- buf -> job

      local function escape_html(s)
        return s:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
      end

      local html_template = [[
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Mermaid Preview</title>
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>
  <script>
    mermaid.initialize({ startOnLoad: true, theme: "dark" });
  </script>
  <style>
    body { margin: 0; padding: 1rem; background: #0f111a; }
  </style>
</head>
<body>
<pre class="mermaid">
%s
</pre>
</body>
</html>
]]

      local function start(buf)
        if state[buf] then
          return
        end

        local file = vim.api.nvim_buf_get_name(buf)
        if file == '' then
          return
        end

        local dir = vim.fn.fnamemodify(file, ':h')
        local base = vim.fn.fnamemodify(file, ':t:r')
        local html = dir .. '/' .. base .. '.preview.html'

        local function render()
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local content = escape_html(table.concat(lines, '\n'))
          local f = io.open(html, 'w')
          f:write(html_template:format(content))
          f:close()
        end

        render()

        local job = vim.fn.jobstart({ 'live-server', dir }, { detach = true })
        state[buf] = job

        -- open browser explicitly to the right file
        vim.defer_fn(function()
          vim.fn.jobstart({ 'xdg-open', 'http://127.0.0.1:8080/' .. base .. '.preview.html' }, { detach = true })
        end, 300)

        vim.api.nvim_create_autocmd('BufWritePost', {
          buffer = buf,
          callback = render,
        })
      end

      local function stop(buf)
        local job = state[buf]
        if job then
          vim.fn.jobstop(job)
        end
        state[buf] = nil
      end

      vim.api.nvim_create_user_command('MermaidToggle', function()
        local buf = vim.api.nvim_get_current_buf()
        if state[buf] then
          stop(buf)
          vim.notify 'Mermaid preview stopped'
        else
          start(buf)
          vim.notify 'Mermaid preview started'
        end
      end, {})

      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'mermaid',
        callback = function(args)
          start(args.buf)
        end,
      })

      vim.api.nvim_create_autocmd('BufUnload', {
        callback = function(args)
          stop(args.buf)
        end,
      })
    end,
  },
}
