return {
  'L3MON4D3/LuaSnip',
  version = '2.*',
  build = (function()
    -- Build Step is needed for regex support in snippets.
    -- This step is not supported in many windows environments.
    -- Remove the below condition to re-enable on windows.
    if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
      return
    end
    return 'make install_jsregexp'
  end)(),
  dependencies = {
    {
      'rafamadriz/friendly-snippets',
      config = function()
        require('luasnip.loaders.from_vscode').lazy_load()
      end,
    },
  },
  opts = {},

  config = function()
    require('luasnip.loaders.from_lua').lazy_load { paths = '/home/ahbui/.config/nvim/lua/custom/plugins/luasnip/' }
    local ls = require 'luasnip'
    ls.setup {
      update_events = { 'TextChanged', 'TextChangedI' },
      enable_autosnippets = true,
      store_selection_keys = '<Tab>',
    }
    vim.keymap.set({ 'i' }, '<C-k>', function()
      ls.expand()
    end, { silent = true, desc = 'expand autocomplete' })
    vim.keymap.set({ 'i', 's' }, '<C-j>', function()
      ls.jump(1)
    end, { silent = true, desc = 'next autocomplete' })
    vim.keymap.set({ 'i', 's' }, '<C-L>', function()
      ls.jump(-1)
    end, { silent = true, desc = 'previous autocomplete' })
    vim.keymap.set({ 'i', 's' }, '<C-E>', function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end, { silent = true, desc = 'select autocomplete' })
  end,
}
