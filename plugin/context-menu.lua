local default_config = {
  menu_items = {}, -- add menu_items, if you call setup function at multiple place, this field will merge together instead of overwrite
  enable_log = true, -- Optional, enable error log be printed out. Turn it off if you don't want see those lines
  default_action_keymaps = {
    -- hint: if you have keymap set to trigger menu like:
    -- vim.keymap.set({ "v", "n" }, "<M-l>", function() require("context-menu").trigger_context_menu() end, {})
    -- You can put the same key here to close the menu, which results like a toggle menu key:
    -- close_menu = { "q", "<ESC>", "<M-l>" },

    close_menu = { "q", "<ESC>" },
    trigger_action = { "<CR>", "o" },
  },
  ui = {
    selected_item = { bg = "#244C55", fg = "white" },
  },
}

vim.g.context_menu_config = default_config
