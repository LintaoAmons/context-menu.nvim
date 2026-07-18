---Deprecated compatibility shim. Use `require("context-menu").open()` instead.

local M = {}

function M.select()
  vim.deprecate(
    'require("context-menu.picker.vim-ui").select()',
    'require("context-menu").open()',
    "1.0",
    "context-menu.nvim"
  )
  require("context-menu").open()
end

return M
