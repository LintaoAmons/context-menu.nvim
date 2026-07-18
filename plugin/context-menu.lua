if vim.g.loaded_context_menu then
  return
end
vim.g.loaded_context_menu = true

vim.api.nvim_create_user_command("ContextMenu", function()
  require("context-menu").open()
end, { desc = "Open the context menu" })

-- Deprecated alias, kept for backwards compatibility.
vim.api.nvim_create_user_command("ContextMenuTrigger", function()
  vim.deprecate(":ContextMenuTrigger", ":ContextMenu", "1.0", "context-menu.nvim")
  require("context-menu").open()
end, { desc = "Open the context menu (deprecated: use :ContextMenu)" })
