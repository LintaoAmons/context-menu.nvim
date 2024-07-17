local M = {}

---@enum ContextMenu.ActionType
local ActionType ={
  callback = 1,
  sub_cmds = 2
}

---@class ContextMenu.Action
---@field type ContextMenu.ActionType
---@field callback? fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
---@field sub_cmds? ContextMenu.Item[]

---@class ContextMenu.Item
---@field cmd string Unique identifier and display name for the menu item.
---@field action ContextMenu.Action 
---@field ft? string[] Optional list of filetypes that determine menu item visibility.
---@field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
---@field order? number Optional numerical order for menu item sorting.

local default_config = {
  ---@type ContextMenu.Item[]
  menu_items = {}, -- override the default items:: use it when you don't want the plugin provided menu_items
  ---@type ContextMenu.Item[]
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
