-- zarul.lua
--

return {
  { -- THEMES
    -- 'folke/tokyonight.nvim',
    'rose-pine/neovim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      require('rose-pine').setup {
        styles = { transparency = true },
      }
      vim.cmd 'colorscheme rose-pine'
    end,
  },
  { -- tokyonight theme
    'folke/tokyonight.nvim',
    -- require('tokyonight').setup {
    --   styles = {
    --     comments = { italic = false }, -- Disable italics in comments
    --   },
    -- }
  },
  { -- Comfortable motions
    'yuttie/comfortable-motion.vim',
  },
  { -- Automatic closing quotes/parenthesis/brackets
    'Raimondi/delimitMate',
  },
  { -- NERDTREE
    'preservim/nerdtree',
  },
  {
    'stevearc/oil.nvim',
    ---@module 'oil'
    -- ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  { -- fold python code
    'tmhedberg/SimpylFold',
    dependencies = {
      'Konfekt/FastFold',
    },
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'python',
        callback = function()
          vim.opt.foldlevel = 99
          vim.opt.foldlevelstart = 99
          vim.opt.foldenable = true
        end,
      })
    end,
  },
  { -- treesitter playground
    'nvim-treesitter/playground',
  },
  { -- treesitter playground
    'nvim-treesitter/playground',
  },
  -- { -- pydoc
  --   'girishji/pythondoc.vim',
  --   ft = 'python'
  -- },
  { -- undotree
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<CR>', desc = 'Toggle Undotree' },
    },
  },
  -- {
  --   'davidmh/mdx.nvim',
  --   config = true,
  --   dependencies = { 'nvim-treesitter/nvim-treesitter' },
  -- },
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
