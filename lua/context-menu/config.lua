local Item = require("context-menu.item")
local M = {}

---@type ContextMenu.Item
M.root = Item.new({
  name = "root",
  items = {},
})

---add a menu item
---@param items ContextMenu.ItemStruct[]
M.add_items = function(items)
  local new_root = Item.new({
    name = "root",
    items = items,
  })
  M.root = M.root:merge(new_root)
end

---@param opts ContextMenu.Config
M.setup = function(opts)
  opts = opts or {}
  ---@type ContextMenu.Config
  local config = vim.tbl_extend("force", vim.g.context_menu_config, opts)

  for _, module in ipairs(config.modules) do
    local ok, m = pcall(require, "context-menu.modules." .. module)
    if ok then
      Snacks.debug.inspect(m)
      M.add_items(m)
    end
  end
  vim.g.context_menu_config = config
end

return M
