local Utils = require("context-menu.utils")

local M = {}

M.MAX_LENGTH = 20

---@enum ContextMenu.ActionType
M.ActionType = {
  callback = "callback",
  sub_cmds = "sub_cmds",
}

---@class ContextMenu.Item
---@field cmd string **Unique identifier** and display name for the menu item.
---@field action ContextMenu.Action
---
--- filter
---@field ft? string[] Optional list of filetypes that determine menu item visibility.
---@field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
---@field filter_func? fun(context: ContextMenu.Context): boolean Optional, true will remain, false will be filtered out
---
--- order
---@field fix? number Optional, fix the order of the menu item.
---@field order? number Optional, order of the menu item.
---
---@field keymap? string Optional, local keymap in menu

---@class ContextMenu.Action
---@field type ContextMenu.ActionType
---@field callback? fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
---@field sub_cmds? ContextMenu.Item[]

---play callback with correct buffer
---@param func function
---@param local_buf_win ContextMenu.LevelInfo
---@param context ContextMenu.Context
---@return function
local function enhance_callback(func, local_buf_win, context)
  return function()
    vim.api.nvim_set_current_buf(context.buffer)
    vim.api.nvim_set_current_win(context.window)
    --TODO: menu_item should not depend on context-menu
    require("context-menu.api").close_menu(context)
    func(context)
  end
end

---trigger the action of this item
---@param self ContextMenu.Item
---@param local_buf_win ContextMenu.LevelInfo
---@param context ContextMenu.Context
function M.trigger_action(self, local_buf_win, context)
  if not self.action or not self.action.type then
    return Utils.log("missing ActionType in the item config [" .. self.cmd .. "]")
  end

  if self.action.type == M.ActionType.callback then
    enhance_callback(self.action.callback, local_buf_win, context)()
  elseif self.action.type == M.ActionType.sub_cmds then
    --TODO: how to structure this call?
    require("context-menu.api").menu_popup_window(
      self.action.sub_cmds,
      context,
      { level = local_buf_win.level + 1 }
    )
  else
    Utils.log("haven't implemented yet")
  end
end

---prepare item to display in the menu_window
---@param self ContextMenu.Item
---@param opts {line_number: number, max_length?: number}
function M.format(self, opts)
  local max_length = opts.max_length or M.MAX_LENGTH
  local content_length = max_length - 3 - 2
  local content = self.cmd
  vim.print(#content)
  if #content > content_length then
    vim.print(content_length)
    content = string.sub(content, 1, content_length)
  end
  vim.print(content)
  return string.format(
    "%-3s %-" .. content_length .. "s %2s",
    opts.line_number,
    content,
    self.keymap or ""
  )
end

---@param cmd string the display string in the menu_window
---@return {line_number?: number , cmd?: string }
function M.parse(cmd)
  local line_number_str = cmd:match("^(%d+)")

  if not line_number_str then
    error("Line number not found in command: " .. cmd)
  end

  local line_number = tonumber(line_number_str)

  local command_text = cmd:gsub("^%d+%s+(%w+)%s*(.-)$", "%1")

  return {
    line_number = line_number,
    cmd = command_text,
  }
end

return M
