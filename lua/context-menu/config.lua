---Holds the plugin options. No other module stores configuration.

local M = {}

---@type ContextMenu.Config
M.defaults = {
  modules = {},
  picker = "vim-ui",
  prompt = "Context Menu",
}

---@type ContextMenu.Config
M.options = vim.deepcopy(M.defaults)

---@param opts? ContextMenu.Config
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M
