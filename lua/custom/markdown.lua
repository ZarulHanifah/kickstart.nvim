local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node

return {
  s('table', {
    t {
      '| Column 1 | Column 2 | Column 3 |',
      '|----------|----------|----------|',
      '| Row 1    | Data     | Data     |',
      '| Row 2    | Data     | Data     |',
    },
  }),
}
