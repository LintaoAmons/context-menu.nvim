vim.g.context_menu_config = require("context-menu.default_config")

vim.api.nvim_create_user_command("ContextMenuTrigger", function()
  require("context-menu.picker.vim-ui").select()
end, {desc = "trigger context menu"})
