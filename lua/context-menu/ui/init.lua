---Presentation layer: picker registry and menu traversal.
---
---A picker is just a function `(entries, opts, on_choice)` that shows one
---flat list and reports the chosen item (or nil on cancel). Descending into
---sub menus is handled here, so every picker supports nesting for free.

local Item = require("context-menu.item")

local M = {}

---@type table<string, ContextMenu.Picker>
local pickers = {
  ["vim-ui"] = function(...)
    return require("context-menu.ui.vim_ui")(...)
  end,
  ["menu"] = function(...)
    return require("context-menu.ui.menu")(...)
  end,
}

---Register a picker under a name so it can be referenced from `setup()`.
---@param name string
---@param picker ContextMenu.Picker
function M.register(name, picker)
  pickers[name] = picker
end

---@param picker string|ContextMenu.Picker
---@return ContextMenu.Picker
local function resolve_picker(picker)
  if type(picker) == "function" then
    return picker
  end
  local found = pickers[picker]
  if not found then
    error(("context-menu: unknown picker %q"):format(picker))
  end
  return found
end

---Open a menu level, descending into sub items until an action runs.
---@param items ContextMenu.Item[]
---@param ctx ContextMenu.Context
---@param opts { picker: string|ContextMenu.Picker, prompt: string }
function M.open(items, ctx, opts)
  local entries = Item.resolve(items, ctx)
  if #entries == 0 then
    vim.notify("context-menu: no menu items for this context", vim.log.levels.INFO)
    return
  end

  local picker = resolve_picker(opts.picker)

  picker(entries, { prompt = opts.prompt, ctx = ctx }, function(choice)
    if not choice then
      return
    end

    if choice.action then
      local ok, missing = Item.check_deps(choice)
      if not ok then
        vim.notify(("context-menu: %q: %s"):format(choice.name, missing), vim.log.levels.WARN)
        return
      end
      local action_ok, err = pcall(choice.action, ctx)
      if not action_ok then
        vim.notify(
          ("context-menu: %q failed:\n%s"):format(choice.name, err),
          vim.log.levels.ERROR
        )
      end
    elseif choice.items then
      M.open(choice.items, ctx, { picker = opts.picker, prompt = choice.name })
    end
  end)
end

return M
