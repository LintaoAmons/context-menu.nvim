local M = {}

---@class ContextMenu.Config
---@field menu_items ContextMenu.Items
---@field add_menu_items ContextMenu.Items
local default_config = {
  menu_items = {}, -- override the default items:: use it when you don't want the plugin provided menu_items
  add_menu_items = {},
  enable_log = true, -- enable error log be printed out. Turn it off if you don't want see those lines
}

M.setup = function(opts)
  opts = opts or {}
  local config = vim.deepcopy(default_config)
  config = vim.tbl_extend("force", config, opts)

  if opts.add_menu_items and #opts.add_menu_items > 0 then
    for _, item in ipairs(opts.add_menu_items) do
      table.insert(config.menu_items, item)
    end
  end

  ---@type ContextMenu.Config
  vim.g.context_menu_config = config
end

return M
