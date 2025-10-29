local ls = require 'luasnip'

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local rep = require('luasnip.extras').rep
local fmta = require('luasnip.extras.fmt').fmta
local postfix = require('luasnip.extras.postfix').postfix
local l = require('luasnip.extras').lambda
local f = ls.function_node
local c = ls.choice_node
local sn = ls.snippet_node
local d = ls.dynamic_node
local r = ls.restore_node

local function math()
  return vim.api.nvim_eval 'vimtex#syntax#in_mathzone()' == 1
end

local visualSelectOrInsert = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, t(parent.snippet.env.LS_SELECT_RAW))
  else
    return sn(nil, i(1))
  end
end

local generate_matrix = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { '\\\\', '' })
  end
  -- fix last node.
  nodes[#nodes] = t '\\\\'
  return sn(nil, nodes)
end

return {
  s({ trig = ';a', snippetType = 'autosnippet', desc = 'alpha', wordTrig = false }, { t '\\alpha' }),
  s({ trig = '"', snippetType = 'autosnippet', desc = 'quotation marks' }, fmta([[``<>'']], { i(1, 'text') })),
  s( -- begin snippet
    { trig = 'env', snippetType = 'snippet', desc = 'Begin and end an arbitrary environment' },
    fmta(
      [[
      \begin{<>}
        <>
      \end{<>}
      ]],
      { i(1, 'broski'), i(2), rep(1) }
    )
  ),
  postfix( -- x hat postfix
    { trig = 'hat', match_pattern = [[[\\%w%.%_%-%"%']+$]], snippetType = 'autosnippet', desc = 'postfix hat when in math mode' },
    { l('\\hat{' .. l.POSTFIX_MATCH .. '}') },
    { condition = math }
  ),
  s( -- dynamic textbf
    'textbf',
    f(function(args, snip)
      local res, env = {}, snip.env
      for _, ele in ipairs(env.LS_SELECT_RAW) do
        table.insert(res, '\\textbf{' .. ele .. '}')
      end
      return res
    end, {})
  ),
  s(
    { trig = ';I', snippetType = 'autosnippet', desc = 'integral with infinite or inserted limits', wordTrig = false },
    fmta(
      [[
      <>
      ]],
      { c(1, {
        t '\\int_{-\\infty}^\\infty',
        sn(nil, fmta([[ \int_{<>}^{<>}]], { i(1), i(2) })),
      }) }
    )
  ),
  s({ trig = 'emph', desc = 'the emph command, either in insert mode or wrapping a visual selection' }, fmta('\\emph{<>}', { d(1, visualSelectOrInsert) })),
  s( -- dynamic matrix!!
    { trig = '([%sbBpvV])Mat(%d+)x(%d+)', snippetType = 'autosnippet', regTrig = true, wordTrig = false, desc = '[bBpvV]matrix of A x B size' },
    fmta(
      [[
    \begin{<>}
    <>
    \end{<>}]],
      {
        f(function(_, snip)
          if snip.captures[1] == ' ' then
            return 'matrix'
          else
            return snip.captures[1] .. 'matrix'
          end
        end),
        d(1, generate_matrix),
        f(function(_, snip)
          return snip.captures[1] .. 'matrix'
        end),
      }
    ),
    { show_condition = math }
  ),
}
