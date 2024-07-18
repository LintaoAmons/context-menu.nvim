local Item = require("context-menu.domain.menu-item")
local M = {}

---@alias ContextMenu.Items ContextMenu.Item[]

---prepare items to display in the menu-window
---@param self ContextMenu.Items
---@param opts? {}
---@return string[]
function M.format(self, opts)
  local result = {}
  for index, i in ipairs(self) do
    table.insert(result, Item.format(i, { line_number = index }))
  end
  return result
end

---@return ContextMenu.Items
local function all_items()
  local result = {}

  ---@param items ContextMenu.Items
  local function process_items(items)
    if not items or #items == 0 then
      return
    end

    for _, item in ipairs(items) do
      if not item.action then
        vim.print("action is not found in menu_item [" .. item.cmd .. "]") -- TODO: option to disable this error info print
        goto continue
      end

      table.insert(result, item)
      if item.action.type == "sub_cmds" then
        process_items(item.action.sub_cmds)
      end
      ::continue::
    end
  end

  process_items(vim.g.context_menu_config.menu_items)
  return result
end

---@param cmd string
function M.find_item_by_cmd(cmd)
  for _, item in ipairs(all_items()) do
    if cmd == item.cmd then
      return item
    else
      vim.print("Can't find Menu Item by this cmd [" .. cmd .. "]")
    end
  end
end

return M
