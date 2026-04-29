local function doi_to_cursor()
  vim.ui.input({ prompt = 'Enter DOI: ' }, function(doi)
    if not doi or doi == '' then
      return
    end

    vim.notify '⏳ Fetching BibTeX...'

    local url = 'https://api.crossref.org/works/' .. doi .. '/transform/application/x-bibtex'

    vim.fn.jobstart({ 'curl', '-s', '-L', url }, {
      stdout_buffered = true,
      on_stdout = function(_, data)
        if not data or #data == 0 then
          return
        end

        local lines = {}
        for _, line in ipairs(data) do
          -- Strip carriage returns and trim whitespace
          local cleaned = line:gsub('\r', ''):gsub('^%s*(.-)%s*$', '%1')
          if cleaned ~= '' then
            table.insert(lines, cleaned)
          end
        end

        if #lines > 0 then
          local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
          -- We insert at 'row-1' for 0-indexed positioning,
          -- or 'row' to put it exactly where the cursor is.
          vim.api.nvim_buf_set_lines(0, row, row, false, lines)
          vim.notify('✅ BibTeX inserted!', vim.log.levels.INFO)
        end
      end,
      on_stderr = function(_, data)
        -- Only notify if there's an actual error message that isn't empty
        if data and data[1] ~= '' then
          vim.notify('❌ Connection Issue', vim.log.levels.ERROR)
        end
      end,
    })
  end)
end

vim.keymap.set('n', '<leader>d2b', doi_to_cursor, { desc = 'Fetch DOI and insert at cursor' })

return {
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_compiler_method = 'latexmk'

      vim.g.vimtex_compiler_latexmk = {
        out_dir = 'build',
        callback = 1,
        continuous = 1,
        options = {
          '-pdf',
          '-shell-escape',
          '-verbose',
          '-file-line-error',
          '-synctex=1',
          '-interaction=nonstopmode',
        },
      }
      vim.g.vimtex_quickfix_open_on_warning = 0
      vim.o.foldmethod = 'expr'
      vim.o.foldexpr = 'vimtex#fold#level(v:lnum)'
      vim.o.foldtext = 'vimtex#fold#text()'
      vim.o.foldlevel = 2
    end,
    -- config = function()
    --   vim.api.nvim_create_autocmd('FileType', {
    --     pattern = 'tex',
    --     callback = function()
    --       if vim.b.vimtex then
    --         local function compile_latex_with_bib()
    --           -- vim.cmd 'VimtexClean'
    --           local main = vim.b.vimtex.tex
    --           local base = vim.fn.fnamemodify(main, ':r')
    --           local proj_root = vim.fn.fnamemodify(main, ':h')
    --           local cwd = vim.fn.getcwd()
    --
    --           vim.cmd('lcd' .. vim.fn.fnameescape(proj_root))
    --
    --           vim.fn.system('pdflatex -interaction=nonstopmode -file-line-error ' .. vim.fn.shellescape(main))
    --           vim.fn.system('bibtex ' .. vim.fn.shellescape(base))
    --           vim.fn.system('pdflatex -interaction=nonstopmode -file-line-error ' .. vim.fn.shellescape(main))
    --           vim.fn.system('pdflatex -interaction=nonstopmode -file-line-error ' .. vim.fn.shellescape(main))
    --           vim.cmd('lcd' .. vim.fn.fnameescape(proj_root))
    --         end
    --         vim.keymap.set('n', '<leader>lA', compile_latex_with_bib, { buffer = true })
    --       end
    --     end,
    --   })
    -- end,
  },
  {
    'nvim-telescope/telescope-bibtex.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function()
      local telescope = require 'telescope'
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      local function extract_url_from_content(content_lines)
        local url, doi
        for _, line in ipairs(content_lines) do
          local u = line:match 'url%s*=%s*{([^}]+)}'
          if u then
            url = u:match '^%s*(.-)%s*$'
          end

          local d = line:match '[Dd][Oo][Ii]%s*=%s*{([^}]+)}'
          if d then
            doi = d:match '^%s*(.-)%s*$'
          end
        end

        if url then
          return url
        elseif doi then
          local clean_doi = doi:gsub('^https?://doi%.org/', '')
          return 'https://doi.org/' .. clean_doi -- 🔧 removed extra spaces!
        end
        return nil
      end

      local function safe_inspect(obj, seen, depth)
        depth = depth or 0
        if depth > 5 then
          return '{...}'
        end
        seen = seen or {}
        if type(obj) ~= 'table' then
          return vim.inspect(obj)
        end
        if seen[obj] then
          return '[circular]'
        end
        seen[obj] = true
        local parts = {}
        for k, v in pairs(obj) do
          local key_str = vim.inspect(k)
          local val_str = safe_inspect(v, seen, depth + 1)
          table.insert(parts, key_str .. ' = ' .. val_str)
        end
        return '{\n  ' .. table.concat(parts, ',\n  ') .. '\n}'
      end

      local open_url_action = function(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if not selection or not selection.id or not selection.id.content then
          actions.close(prompt_bufnr)
          vim.notify('❌ No BibTeX content found.', vim.log.levels.ERROR)
          return
        end

        local content_lines = selection.id.content -- ✅ This is the correct path
        local url, doi

        for _, line in ipairs(content_lines) do
          if type(line) == 'string' then
            -- Extract url = {...}
            local u = line:match 'url%s*=%s*{([^}]+)}'
            if u then
              url = u:match '^%s*(.-)%s*$' -- trim
            end

            -- Extract DOI = {...} (case-insensitive)
            local d = line:match '[Dd][Oo][Ii]%s*=%s*{([^}]+)}'
            if d then
              doi = d:match '^%s*(.-)%s*$'
            end
          end
        end

        actions.close(prompt_bufnr)

        if url and url ~= '' then
          vim.fn.jobstart { 'xdg-open', url }
        elseif doi and doi ~= '' then
          local clean_doi = doi:gsub('^https?://doi%.org/', '')
          vim.fn.jobstart { 'xdg-open', 'https://doi.org/' .. clean_doi }
        else
          vim.notify("⚠️ No 'url' or 'DOI' found in BibTeX entry.", vim.log.levels.WARN)
        end
      end

      telescope.setup {
        extensions = {
          bibtex = {
            search_fields = { 'title', 'author', 'year', 'journal', 'url', 'doi', 'note' },
            mappings = {
              i = { ['<C-o>'] = open_url_action },
              n = { ['<C-o>'] = open_url_action },
            },
          },
        },
      }

      telescope.load_extension 'bibtex'
    end,
    keys = {
      {
        '<leader>sb',
        function()
          require('telescope').extensions.bibtex.bibtex()
        end,
        desc = 'Search BibTeX entries',
      },
      {
        '<C-b>',
        function()
          require('telescope').extensions.bibtex.bibtex()
        end,
        mode = 'i',
        desc = 'Insert \\cite{BibTeX key}',
      },
    },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
