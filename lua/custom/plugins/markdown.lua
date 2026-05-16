local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node

ls.add_snippets('markdown', {
  s('table', {
    t {
      '| Column 1 | Column 2 | Column 3 |',
      '|----------|----------|----------|',
      '| Row 1    | Data     | Data     |',
      '| Row 2    | Data     | Data     |',
    },
  }),
})

return {
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && npm install',
    keys = {
      { '<leader>mps', '<cmd>MarkdownPreview<cr>', desc = 'Markdown Preview Start' },
    },
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  {
    'tadmccorkle/markdown.nvim',
    ft = 'markdown',
    config = function()
      require('markdown').setup {
        on_attach = function(bufnr)
          -- Use the plugin's own <Plug> mappings.
          -- This is significantly more reliable than calling internal Lua functions.

          -- Visual Mode mappings
          vim.keymap.set('x', '<C-b>', '<Plug>(markdown_toggle_emphasis_visual)b', { buffer = bufnr, desc = 'Toggle Bold' })
          vim.keymap.set('x', '<C-i>', '<Plug>(markdown_toggle_emphasis_visual)i', { buffer = bufnr, desc = 'Toggle Italics' })

          -- Normal Mode mappings
          vim.keymap.set('n', '<C-b>', '<Plug>(markdown_toggle_emphasis)b', { buffer = bufnr, desc = 'Toggle Bold' })
          vim.keymap.set('n', '<C-i>', '<Plug>(markdown_toggle_emphasis)i', { buffer = bufnr, desc = 'Toggle Italics' })
        end,
      }
    end,
  },
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
