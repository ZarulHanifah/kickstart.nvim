on_attach = function(client, bufnr)
  -- Other on_attach logic...

  -- Patch hover window
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(function(err, result, ctx, config)
    local bufnr, winnr = vim.lsp.handlers.hover(err, result, ctx, config)
    if winnr then
      vim.api.nvim_set_option_value('winhighlight', 'Normal:NormalFloat,FloatBorder:FloatBorder', { win = winnr })
    end
    return bufnr, winnr
  end, { border = 'rounded' })
end

return {}
