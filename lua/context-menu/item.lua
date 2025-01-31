---@class ContextMenu.Item : ContextMenu.ItemStruct
---@field __index ContextMenu.Item
---@field items ContextMenu.Item[]
local Item = {}

---@param init_value ContextMenu.ItemStruct
---@return ContextMenu.Item
function Item.new(init_value)
  local self = {
    name = init_value.name,
    action = init_value.action,
    items = vim.tbl_map(function(item)
      return Item.new(item)
    end, init_value.items or {}),
    keymap = init_value.keymap,
    ft = init_value.ft,
    not_ft = init_value.not_ft,
    filter_func = init_value.filter_func,
    fix = init_value.fix,
    order = init_value.order,
  }

  if not self.name then
    error("Item must have a name")
  end

  setmetatable(self, { __index = Item })
  return self
end

---Get the direct sub items of this item
---@param ctx? ContextMenu.CtxStruct
---@param order? "desc"|"asc"
---@return ContextMenu.Item[]
function Item:get_items(ctx, order)
  ctx = ctx or {}
  -- Snacks.debug.inspect(ctx)
  order = order or "asc"
  local filtered_items = {}

  -- Filter items
  for _, item in ipairs(self.items) do
    -- Snacks.debug.inspect("===============================start===============================")
    -- Snacks.debug.inspect(item)
    local should_include = true

    -- Check filetype inclusion
    if item.ft and #item.ft > 0 then
      should_include = vim.tbl_contains(item.ft, ctx.ft or "")
    end
    -- Snacks.debug.inspect("after inclusion check", should_include)

    -- Check filetype exclusion
    if should_include and item.not_ft and #item.not_ft > 0 then
      should_include = not vim.tbl_contains(item.not_ft, ctx.ft or "")
    end
    -- Snacks.debug.inspect("after exclusion check", should_include)

    -- Apply custom filter function
    if should_include and item.filter_func then
      should_include = item.filter_func(ctx)
    end
    -- Snacks.debug.inspect("after filter_func", should_include)

    if should_include then
      table.insert(filtered_items, item)
    end
    -- Snacks.debug.inspect("single round", filtered_items)
  end

  -- Snacks.debug.inspect("after filter", filtered_items)
  -- Sort items
  table.sort(filtered_items, function(a, b)
    local a_order = a.order or 99
    local b_order = b.order or 99
    if order == "desc" then
      return a_order > b_order
    else
      return a_order < b_order
    end
  end)
  -- -- Snacks.debug.log("after ", filtered_items)

  return filtered_items
end

---Merge two items together
---@param other ContextMenu.Item
---@return ContextMenu.Item
function Item:merge(other)
  local result = Item.new(self)

  -- merge or override properties
  for k, v in pairs(other) do
    if k == "items" then
      -- handle items array specially
      local items = {}
      local item_map = {}

      -- add all items from self first
      for _, item in ipairs(self.items or {}) do
        table.insert(items, item)
        item_map[item.name] = #items
      end

      -- merge or add items from other
      for _, item2 in ipairs(other.items) do
        local idx = item_map[item2.name]
        if idx then
          -- merge existing item
          items[idx] = Item.new(items[idx]):merge(item2)
        else
          -- add new item
          table.insert(items, Item.new(item2))
        end
      end

      result.items = items
    else
      -- for non-items properties, just override
      result[k] = vim.deepcopy(v)
    end
  end

  return result
end

return Item
