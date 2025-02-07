---@class ContextMenu.Ctx : ContextMenu.CtxStruct
---@field __index ContextMenu.Ctx
---@field items ContextMenu.Ctx[]
local Ctx = {}

---Create a new context object
---@param init_value? ContextMenu.CtxStruct
---@return ContextMenu.Ctx
function Ctx.new(init_value)
  init_value = init_value or {}

  local self = {
    buffer = init_value.buffer or vim.api.nvim_get_current_buf(),
    window = init_value.window or vim.api.nvim_get_current_win(),
    line = init_value.line or vim.api.nvim_get_current_line(),
    ft = init_value.ft or vim.bo.filetype,
    filename = init_value.filename or vim.fn.expand("%:p"),
    menu_buffer_stack = init_value.menu_buffer_stack or {},
    menu_window_stack = init_value.menu_window_stack or {},
  }

  setmetatable(self, { __index = Ctx })
  return self
end

return Ctx
