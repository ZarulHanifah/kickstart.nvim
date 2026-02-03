return {
  {
    'richardhapb/pytest.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = { '-q', '--disable-warnings', '--maxfail=1' }, -- Define the options here
    config = function(_, opts)
      require('nvim-treesitter.configs').setup {
        ensure_installed = { 'python', 'xml' },
      }

      require('pytest').setup(opts)
    end,
  },
}
