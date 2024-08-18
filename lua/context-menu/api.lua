local Context = require("context-menu.domain.context")
local MenuItem = require("context-menu.domain.menu-item")
local MenuItems = require("context-menu.domain.menu-items")
local Utils = require("context-menu.utils")

local M = {}

---@param table table
---@param value any
---@return boolean
local function table_contains(table, value)
  if not table then
    return false
  end
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

---@param items ContextMenu.Item[]
---@param context ContextMenu.Context
---@return ContextMenu.Item[]
local function filter_items(items, context)
  ---@type ContextMenu.Items
  local filter_by_ft = {}
  for _, item in ipairs(items) do
    if table_contains(item.ft, context.ft) or item.ft == nil then
      table.insert(filter_by_ft, item)
    end
  end

  ---@type ContextMenu.Items
  local filter_by_not_ft = {}
  for _, i in ipairs(filter_by_ft) do
    if not table_contains(i.not_ft, context.ft) then
      table.insert(filter_by_not_ft, i)
    end
  end

  local filter_by_func = {}
  for _, i in ipairs(filter_by_not_ft) do
    if not i.filter_func or i.filter_func(context) then
      table.insert(filter_by_func, i)
    end
  end

  return filter_by_func
end

---order menu_items by the their order field value
---@param menu_items ContextMenu.Item[]
---@param context ContextMenu.Context
local function reorder_items(menu_items, context)
  table.sort(menu_items, function(a, b)
    if not a.order and not b.order then
      return false -- Both are equal; stay in their current order.
    elseif not a.order then
      return false -- a should come after b since it does not have an order.
    elseif not b.order then
      return true -- b should come after a since it does not have an order.
    end

    return a.order < b.order -- Compare numerically if both have valid orders.
  end)

  local items = {}
  local fix_items = {}
  for _, item in ipairs(menu_items) do
    if item.fix then
      if not fix_items[item.fix] then
        fix_items[item.fix] = { item }
      else
        table.insert(fix_items[item.fix], item)
      end
    else
      table.insert(items, item)
    end
  end

  for i, group in pairs(fix_items) do
    for j = #group, 1, -1 do
      local e = group[j]
      table.insert(items, i, e)
    end
  end

  return items
end

---@class ContextMenu.LevelInfo
---@field level number

---@param context ContextMenu.Context
---@param local_buf_win ContextMenu.LevelInfo
local function trigger_action(context, local_buf_win)
  local current_buf = context.menu_buffer_stack[local_buf_win.level]
  vim.api.nvim_set_current_buf(current_buf)

  vim.print(context)
  vim.print(current_buf)
  vim.print(vim.api.nvim_get_current_line())
  local line = vim.api.nvim_get_current_line()

  local selected_cmd = MenuItem.parse(line)
  vim.print(selected_cmd)

  local item = MenuItems.find_item_by_cmd(selected_cmd.cmd)
  MenuItem.trigger_action(item, local_buf_win, context)
end

---@param context ContextMenu.Context
local function prepare_items(context)
  local filtered_items = filter_items(vim.g.context_menu_config.menu_items, context)
  local ordered_items = reorder_items(filtered_items, context)
  return ordered_items
end

---close all menu buffer and window
---@param context ContextMenu.Context
local function close_menu(context)
  for _, w in ipairs(context.menu_window_stack) do
    pcall(vim.api.nvim_win_close, w, true)
  end
  for _, b in ipairs(context.menu_buffer_stack) do
    pcall(vim.api.nvim_win_close, b, true)
  end
end

M.close_menu = close_menu

---@param items ContextMenu.Item[]
---@param local_level ContextMenu.LevelInfo
---@param context ContextMenu.Context
local function create_local_keymap(items, local_level, context)
  local function map(lhs, rhs)
    local current_buf = context.menu_buffer_stack[local_level.level]
    vim.keymap.set({ "v", "n" }, lhs, rhs, {
      noremap = true,
      silent = true,
      nowait = true,
      buffer = current_buf,
    })
  end

  for index, item in ipairs(items) do
    local action = function()
      MenuItem.trigger_action(item, local_level, context)
    end
    if index < 10 then
      map(tostring(index), action)
    end

    if item.keymap then
      map(item.keymap, action)
    end
  end

  for _, k in ipairs(vim.g.context_menu_config.default_action_keymaps.close_menu) do
    map(k, function()
      close_menu(context)
    end)
  end

  for _, k in ipairs(vim.g.context_menu_config.default_action_keymaps.trigger_action) do
    map(k, function()
      trigger_action(context, local_level)
    end)
  end
end

---@param menu_items ContextMenu.Item[]
---@param context ContextMenu.Context
---@param local_level ContextMenu.LevelInfo
function M.menu_popup_window(menu_items, context, local_level)
  local popup_buf = vim.api.nvim_create_buf(false, true)
  local lines = MenuItems.format(menu_items)
  vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(popup_buf, "modifiable", false)
  local width = Utils.get_width(lines)
  local height = #menu_items

  local win_opts = {}
  if not context.menu_window then
    win_opts = {
      relative = "cursor",
      row = 0, -- Subtract one from row if you want to appear on the same line, or keep as is to go to the next line.
      col = 0, -- Position the window slightly to the right
      width = width,
      height = height,
      style = "minimal",
      border = "single",
      title = "ContextMenu.",
    }
  else
    win_opts = {
      relative = "win",
      win = context.menu_window,
      row = 0, -- Subtract one from row if you want to appear on the same line, or keep as is to go to the next line.
      col = 15, -- Position the window slightly to the right
      width = width + 1,
      height = height,
      style = "minimal",
      border = "single",
      title = "ContextMenu.",
    }
  end

  local win = vim.api.nvim_open_win(popup_buf, true, win_opts)
  Context.update_context(context, { menu = { buf = popup_buf, win = win } })

  create_local_keymap(menu_items, {
    buf = popup_buf,
    win = win,
    level = local_level.level,
  }, context)

  require("context-menu.hl").create_hight_light(popup_buf)
end

function M.trigger_context_menu()
  ---@type ContextMenu.Context
  local context = Context.init()

  local items = prepare_items(context)

  M.menu_popup_window(items, context, { level = 1 })
end

return M
