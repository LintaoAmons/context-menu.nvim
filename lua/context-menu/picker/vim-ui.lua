local M = {}

---@param item?  ContextMenu.Item
M.select = function(item)
  item = item or require("context-menu.config").root
  local items = {}
  for _, i in ipairs(item.items) do
    table.insert(items, i)
  end

  vim.ui.select(
    items,
    {
      prompt = "Select tabs or spaces:",
      format_item = function(i)
        return i.name
      end,
    },
    ---@param choice ContextMenu.Item
    function(choice)
      if not choice.action then
        M.select(choice)
      else
        choice.action({}) -- TODO: pass in ctx
      end
    end
  )
end

return M
