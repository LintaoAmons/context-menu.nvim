> [!WARNING]
>
> This plugin is in its early stages, and the data structures is like to undergo significant changes over time.
>
> Switch to Dev branch to enjoy new features:
>
> - Merge MenuItems when call setup function, multiple places, even at runtime

<p align="center">
  <a href="https://github.com/LintaoAmons/context-menu.nvim">Philosophy</a>
  ·
  <a href="https://github.com/LintaoAmons/context-menu.nvim">Install & Configuration</a>
  ·
  <a href="https://github.com/songquanpeng/one-api/issues">Usecases</a>
</p>

Instead of keymaps, you can put your actions in the context menu

- Menu is a buffer, use hjkl to navigate the items and trigger it or just trigger it by the number
- Build your own menu, (items order) and (display or hide) are easily configurable
- Split you config in multiple places, encapsulating those item in its own place
- Adjust your config at runtime, simply source the setup function again
- Local keymaps of the items

## Philosophy

- Minimise the cognitive overload in the head, but still put every functionality around you hand
- Less keybindings but remian productivity
- Configuration can be put in seperated spec files, and behaviour can be config at runtime and take effect immediately

## Install & Configuration

> For more complex usecases, you can use [my config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-core/context-menu.lua) as a reference

Default config and fields overview

```lua
local default_config = {
  menu_items = {}, -- add menu_items, if you call setup function at multiple place, this field will merge together instead of overwrite
  enable_log = true, -- Optional, enable error log be printed out. Turn it off if you don't want see those lines
  default_action_keymaps = {
    -- hint: if you have keymap set to trigger menu like:
    -- vim.keymap.set({ "v", "n" }, "<M-l>", function() require("context-menu").trigger_context_menu() end, {})
    -- You can put the same key here to close the menu, which results like a toggle menu key:
    -- close_menu = { "q", "<ESC>", "<M-l>" },
    close_menu = { "q", "<ESC>" },
    trigger_action = { "<CR>", "o" }, -- Trigger undercursor item's action
  },
}
```

MenuItems config demo

```lua
-- TYPE REF
--class ContextMenu.Item
--field cmd string **Unique identifier** and display name for the menu item.
--field action ContextMenu.Action
--field ft? string[] Optional list of filetypes that determine menu item visibility.
--field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
--field filter_func? fun(context: ContextMenu.Context): boolean Optional, true will remain, false will be filtered out
--field order? number Optional numerical order for menu item sorting.
--field keymap? string Optional, local keymap in menu

--class ContextMenu.Action
--field type ContextMenu.ActionType
--field callback? fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
--field sub_cmds? ContextMenu.Item[]

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

## Keymaps

No default keymaps, you need to set the shortcut by yourself, here's a reference

```lua
vim.keymap.set({ "v", "n" }, "<M-l>", function()
  require("context-menu").trigger_context_menu()
end, {})
```

## Usecases

### Git

![cm-git-blame](https://github.com/user-attachments/assets/185c9ebb-7d94-4864-989b-6a6a0a32867f)

<details>
<summary>Git Config: Config in two files</summary>

```lua title="gitsign.lua"
local prev_hunk = function()
  require("gitsigns").prev_hunk({ navigation_message = false })
end
vim.keymap.set("n", "gk", prev_hunk)

local next_hunk = function()
  require("gitsigns").next_hunk({ navigation_message = false })
end
vim.keymap.set("n", "gj", next_hunk)

return {
  {
    "LintaoAmons/context-menu.nvim",
    opts = function(_, opts)
      require("context-menu").setup({
        menu_items = {
          {
            cmd = "Git",
            order = 85,
            action = {
              type = "sub_cmds",
              sub_cmds = {
                {
                  cmd = "Commit Log Diagram",
                  order = 86,
                  action = {
                    type = "callback",
                    callback = function(_)
                      vim.cmd([[Flog]])
                    end,
                  },
                },
                {
                  cmd = "Git :: Blame",
                  order = 85,
                  action = {
                    type = "callback",
                    callback = function(_)
                      vim.cmd([[Gitsigns blame]])
                    end,
                  },
                },
                {
                  cmd = "Git :: Peek",
                  order = 80,
                  action = {
                    type = "callback",
                    callback = function(_)
                      vim.cmd([[Gitsigns preview_hunk]])
                    end,
                  },
                },
                {
                  cmd = "Git :: Reset Hunk",
                  order = 81,
                  action = {
                    type = "callback",
                    callback = function(_)
                      vim.cmd([[Gitsigns reset_hunk]])
                    end,
                  },
                },
                {
                  cmd = "Git :: Reset Buffer",
                  order = 82,
                  action = {
                    type = "callback",
                    callback = function(_)
                      vim.cmd([[Gitsigns reset_buffer]])
                    end,
                  },
                },
                {
                  cmd = "Git :: Diff Current Buffer",
                  order = 83,
                  action = {
                    type = "callback",
                    callback = function(_)
                      require("gitsigns").diffthis()
                    end,
                  },
                },
              },
            },
          },
        },
      })
    end,
  },
  -- git signs highlights text that has changed since the list
  -- git commit, and also lets you interactively stage & unstage
  -- hunks in a commit.
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
    },
  },
}
```

```lua title="diffview.lua"

return {
"LintaoAmons/context-menu.nvim",
opts = function()
  require("context-menu").setup({
    menu_items = {
      {
        cmd = "Git",
        action = {
          type = "sub_cmds",
          sub_cmds = {
            {
              cmd = "Git Status",
              action = {
                type = "callback",
                callback = function(_)
                  vim.cmd([[DiffviewOpen]])
                end,
              },
            },
            {
              cmd = "Branch History",
              action = {
                type = "callback",
                callback = function(_)
                  vim.cmd([[DiffviewFileHistory]])
                end,
              },
            },
            {
              cmd = "Current File Commit History",
              action = {
                type = "callback",
                callback = function(_)
                  vim.cmd([[DiffviewFileHistory %]])
                end,
              },
            },
          },
        },
      },
    },
  })
end,
}
```

</details>

### Json | Jq

> [config ref](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/lang/json.lua)

![cm-jq](https://github.com/user-attachments/assets/6b4212e1-2122-4ad1-bd66-3e1f72864b1a)

<details>
<summary>Config</summary>

```lua
return {
  "LintaoAmons/context-menu.nvim",
  opts = function(_, opts)
    require("context-menu").setup({
      menu_items = {
        {
          cmd = "Jq Query",
          ft = { "json" },
          action = {
            type = "callback",
            callback = function(_)
              -- you can find those util function in my config repository
              local sys = require("util.base.sys")
              local editor = require("util.editor")

              vim.ui.input(
                { prompt = 'Query pattern, e.g. `.[] | .["@message"].message` ' },
                function(pattern)
                  local absPath = editor.buf.read.get_buf_abs_path()
                  local stdout, _, stderr = sys.run_sync({ "jq", pattern, absPath }, ".")
                  local result = stdout or stderr
                  editor.split_and_write(result, { vertical = true, ft = "json" })
                end
              )
            end,
          },
        },
      },
    })
  end,
}
```

</details>

### Copy

> [config ref](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/copy.lua)

![cm-copy](https://github.com/user-attachments/assets/6b59dbbb-594d-41a7-a610-eeb22b332ba1)

## [See more usecases and configuration](https://lintao-index.pages.dev/docs/Vim/plugins/context-menu/)

---

TODO:

- [x] make configuration source-able in the runtime
- [x] configurable keymaps
- [ ] fix the reorder function
- [ ] beautify menu buffer
