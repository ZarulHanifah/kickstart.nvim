return {
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_imaps_enabled = 0 -- disable VimTex insert mode mappings
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'latexmk'
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_quickfix_open_on_warning = 0 -- dont open quickfix if only warnings
      vim.g.vimtex_compiler_latexmk = {
        backend = 'nvim',
        build_dir = '',
        callback = 1,
        continuous = 1,
        executable = 'latexmk',
        options = {
          '-pdf',
          '-pdflatex=pdflatex',
          -- '-bibtex=biber',
          '-interaction=nonstopmode',
          '-shell-escape',
          '-verbose',
        },
      }
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'vimtex#fold#level(v:lnum)'
      vim.o.foldtext = 'vimtex#fold#text()'
      vim.o.foldlevel = 2
    end,
    config = function()
      require('nvim-treesitter.configs').setup {
        highlight = { enable = true, disable = { 'latex' } },
      }
    end,
  },
  {
    'nvim-telescope/telescope-bibtex.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
    },
    config = function()
      require('telescope').load_extension 'bibtex'
    end,
  },
}
