> [!WARNING]
>
> This plugin is in its early stages, and the data structures is like to undergo significant changes over time.

<p align="center">
  <a href="https://github.com/LintaoAmons/context-menu.nvim?tab=readme-ov-file#philosophy">Philosophy</a>
  ·
  <a href="https://github.com/LintaoAmons/context-menu.nvim?tab=readme-ov-file#install--configuration">Install & Configuration</a>
  ·
  <a href="https://github.com/LintaoAmons/context-menu.nvim?tab=readme-ov-file#usecases">Usecases</a>
</p>

Instead of keymaps, you can put your actions in the context menu

- Menu is a buffer, use hjkl to navigate the items and trigger it or just trigger it by the number
- Build your own menu, (items order) and (display or hide) are easily configurable
- Split you config in multiple places, encapsulating those item in its own place
- Adjust your config at runtime, simply source the setup function again
- Local keymaps of the items

  
![show](https://github.com/user-attachments/assets/48cc708a-f989-4d66-9b0a-16e36ac8620d)


## Philosophy

- Minimise the cognitive overload in the head, but still put every functionality around you hand
- Less keybindings but remian productivity
- Configuration can be put in seperated spec files, and behaviour can be config at runtime and take effect immediately

## Install & Configuration

> For more complex usecases, you can use [my config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-core/context-menu.lua) as a reference

```lua
local default_config = {
  -- add menu_items, if you call setup function at multiple place, this field will merge together instead of overwrite
  menu_items = {
    {
      cmd = "Run File",
      order = 1,
      not_ft = { "markdown" },
      action = {
        type = "callback",
        callback = function(context)
          if context.ft == "lua" then
            return vim.cmd([[source %]])
          elseif context.ft == "javascript" then
            return vim.print("run javascript:: haven't impl yet")
          end
        end,
      },
    }
  },
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

```

<details>
<summary>Click here to check the items config demo</summary>

```lua
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


return {
  "LintaoAmons/context-menu.nvim",
  config = function(_, opts)
    -- setup function can be called multiple time at multiple places
    -- MenuItems will be merged instead of overwrite
    -- You can also source the setup function at runtime to test your configuration
    -- run `:lua = vim.g.context_menu_config` to check your current configuration
    require("context-menu").setup({
      menu_items = {
        {
          order = 1,
          cmd = "Code Action",
          not_ft = { "markdown" },
          action = {
            type = "callback",
            callback = function(_)
              vim.cmd([[Lspsaga code_action]])
            end,
          },
        },
        {
          cmd = "ChatGPT :: New",
          keymap = "a", -- keymap `a` will trigger this action when it show in the menu
          action = {
            type = "callback",
            callback = function(_)
              vim.cmd([[GpChatNew vsplit]])
            end,
          },
        },
        {
          order = 2,
          cmd = "Run Test",
          filter_func = function(context)
            local a = context.filename
            if string.find(a, ".test.") or string.find(a, "spec.") then
              return true
            else
              return false
            end
          end,
          action = {
            type = "callback",
            callback = function(_)
              require("neotest").run.run()
            end,
          },
        },
      },
    })
  end,
}
```

</details>

## Keymaps

No default keymaps, you need to set the shortcut by yourself, here's a reference

```lua
vim.keymap.set({ "v", "n" }, "<M-l>", function()
  require("context-menu").trigger_context_menu()
end, {})
```

## Usecases

> Copy paste the module into your config.
>
> Please share your usecases by provided a PR.

- [git](./modules/git.lua)
- [http request](./modules/http.lua)
- [markdown](./modules/markdown.lua)
- [test](./modules/test.lua)

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

By [telegram](https://t.me/+ssgpiHyY9580ZWFl) or [微信: CateFat](https://lintao-index.pages.dev/assets/images/wechat-437d6c12efa9f89bab63c7fe07ce1927.png)

## Some Other Neovim Stuff

- [my neovim config](https://github.com/LintaoAmons/CoolStuffes/tree/main/nvim/.config/nvim)
- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [context-menu.nvim](https://github.com/LintaoAmons/context-menu.nvim)

---

TODO:

- [x] make configuration source-able in the runtime
- [x] configurable keymaps
- [ ] Show shortcut in the menu
- [x] fix the reorder function
- [x] fix_order field in MenuItem
- [ ] enhance j/k: k jump from the first item to the last time, j jump from the last item to the first item
- [ ] navi back/forward
- [ ] beautify menu buffer
  - [x] highlight item under cursor
  - [ ] sub menu position
  - [ ] render shortcuts at the end of the line
