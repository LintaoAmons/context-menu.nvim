local M = {}

---Capture the current editor state. Fields can be overridden, which keeps
---the rest of the plugin testable without a real buffer.
---@param overrides? table partial ContextMenu.Context, missing fields are captured live
---@return ContextMenu.Context
function M.capture(overrides)
  overrides = overrides or {}

  ---@type ContextMenu.Context
  local ctx = {
    buffer = overrides.buffer or vim.api.nvim_get_current_buf(),
    window = overrides.window or vim.api.nvim_get_current_win(),
    line = overrides.line or vim.api.nvim_get_current_line(),
    ft = overrides.ft or vim.bo.filetype,
    filename = overrides.filename or vim.api.nvim_buf_get_name(0),
    mode = overrides.mode or vim.fn.mode(),
    cursor = overrides.cursor or vim.api.nvim_win_get_cursor(0),
  }

  return ctx
end

return M
