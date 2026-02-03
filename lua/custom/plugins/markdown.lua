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
}
