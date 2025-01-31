local M = {}

---@param item?  ContextMenu.Item
M.select = function(item)
  item = item or require("context-menu.config").root

  vim.ui.select(
    item:get_items(), -- TODO: filter by ctx
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
