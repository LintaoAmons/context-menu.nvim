local Ctx = require("context-menu.ctx")
local root = require("context-menu.config").root

local M = {}

---@param item?  ContextMenu.Item
M.select = function(item)
  item = item or root
  local ctx = Ctx.new()

  -- Snacks.debug.inspect(ctx)
  vim.ui.select(
    item:get_items(ctx),
    {
      prompt = "Select tabs or spaces:",
      format_item = function(i)
        return i.name
      end,
    },
    ---@param choice ContextMenu.Item
    function(choice)
      if not choice then
        return
      end

      if not choice.action then
        M.select(choice)
      else
        choice.action(ctx)
      end
    end
  )
end

return M
