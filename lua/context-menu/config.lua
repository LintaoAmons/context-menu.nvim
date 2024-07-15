local M = {}

---@class ContextMenu.Item
---@field cmd string Unique identifier and display name for the menu item.
---@field ft? string[] Optional list of filetypes that determine menu item visibility.
---@field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
---@field order? number Optional numerical order for menu item sorting.
---@field callback fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
local menu_items = {
  {
    cmd = "hi",
    callback = function(_)
      vim.print("Hi")
    end,
  },
}

local default_config = {
  menu_items = menu_items, -- override the default items:: use it when you don't want the plugin provided menu_items
  add_menu_items = {},
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

  vim.g.context_menu_config = config
end

return M
