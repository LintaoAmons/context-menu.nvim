local M = {}

---@type ContextMenu.Item
M.root = {
  name = "root",
  items = {},
}

---merge Items
---@param config1 ContextMenu.Item
---@param config2 ContextMenu.Item
---@return ContextMenu.Item
local function merge(config1, config2)
  -- create new table for result
  local result = vim.deepcopy(config1)

  -- merge or override properties
  for k, v in pairs(config2) do
    if k == "items" then
      -- handle subs array specially
      local items = {}
      local item_map = {}

      -- add all sub items from config1 first
      for _, item in ipairs(config1.items or {}) do
        table.insert(items, item)
        item_map[item.name] = #items
      end

      -- merge or add subs from config2
      for _, item2 in ipairs(config2.items) do
        local idx = item_map[item2.name]
        if idx then
          -- merge existing sub
          items[idx] = merge(items[idx], item2)
        else
          -- add new sub
          table.insert(items, vim.deepcopy(item2))
        end
      end

      result.items = items
    else
      -- for non-subs properties, just override
      result[k] = vim.deepcopy(v)
    end
  end

  return result
end

---add a menu item
---@param items ContextMenu.Item[]
M.add_items = function(items)
  vim.print("before_merge")
  vim.print(M.root)
  local b  = merge(M.root, {
    name = "root",
    items = items,
  })
  vim.print("after_merge")
  vim.print(b)
  M.root = b
end

---@param opts ContextMenu.Config
M.setup = function(opts)
  opts = opts or {}
  ---@type ContextMenu.Config
  local config = vim.tbl_extend("force", vim.g.context_menu_config, opts)

  for _, module in ipairs(config.modules) do
    local ok, m = pcall(require, "context-menu.modules." .. module)
    if ok then
      table.insert(M.root.items, m)
    end
  end
  vim.print(M.root)
  vim.g.context_menu_config = config
end

return M
