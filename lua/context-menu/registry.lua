---The single place where registered menu items live.

local Item = require("context-menu.item")

local M = {}

---@type ContextMenu.Item[]
local items = {}

---Add (or merge, by name) menu items. Safe to call from anywhere, any number
---of times — including at runtime after re-sourcing a config file.
---@param new_items ContextMenu.Item[]
function M.add(new_items)
  local normalized = vim.tbl_map(Item.normalize, new_items)
  items = Item.merge_lists(items, normalized)
end

---@return ContextMenu.Item[]
function M.get()
  return items
end

---Remove every registered item. Mainly useful for tests and live reloading.
function M.clear()
  items = {}
end

return M
