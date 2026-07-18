---Built-in picker backed by `vim.ui.select`.

---@type ContextMenu.Picker
return function(entries, opts, on_choice)
  vim.ui.select(entries, {
    prompt = opts.prompt,
    kind = "context-menu",
    format_item = function(item)
      if item.items and not item.action then
        return item.name .. " ▸"
      end
      return item.name
    end,
  }, on_choice)
end
