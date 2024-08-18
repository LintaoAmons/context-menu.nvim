---@class ContextMenu.Context
---@field buffer number buffer number where triggered the menu
---@field window number window number where triggered the menu
---@field line string content of current line when trigger the menu
---@field ft string filetype
---@field filename string filename of the file where triggered the menu
---@field menu_buffer_stack number[]
---@field menu_window_stack number[]

local M = {}

M.init = function()
  return {
    line = vim.api.nvim_get_current_line(),
    window = vim.api.nvim_get_current_win(),
    buffer = vim.api.nvim_get_current_buf(),
    filename = vim.fn.expand("%:p:t"),
    ft = vim.bo.filetype,
    menu_buffer_stack = {},
    menu_window_stack = {},
  }
end

---@param prev ContextMenu.Context
---@param new_values {menu: {buf: number, win: number}}
function M.update_context(prev, new_values)
  table.insert(prev.menu_window_stack, new_values.menu.win)
  table.insert(prev.menu_buffer_stack, new_values.menu.buf)
end

return M
