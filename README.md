## Install & Configuration

> [My config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/context-menu.lua)

### Simple version

```lua
return {
  "LintaoAmons/context-menu.nvim",
  opts = {}
}
```

### Explain the options

```lua
return {
  "LintaoAmons/context-menu.nvim",
  config = function(_, opts)
    require("context-menu").setup({
      ---@class ContextMenu.Item
      ---@field cmd string Unique identifier and display name for the menu item.
      ---@field ft? string[] Optional list of filetypes that determine menu item visibility.
      ---@field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
      ---@field order? number Optional numerical order for menu item sorting.
      ---@field callback fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
      menu_items = {}, -- override the default items:: use it when you don't want the plugin provided menu_items
      add_menu_items = {
        {
          cmd = "do_something",
          callback = function(context)
            vim.print(context)
            vim.print("do something")
          end,
        },
      },
    end,
  })
}
```

### Split the config in multiple places

- The main Configuration of context-menu
  - use lazy.vim's `config` to call the `setup` function

```lua title="context-menu.lua"
return {
  "LintaoAmons/context-menu.nvim",
  config = function(_, opts)
    local addition_items = {
      {
        cmd = "do_something",
        callback = function(context)
          vim.print(context)
          do_something()
        end,
      },
    }
    opts.add_menu_items = opts.add_menu_items or {}
    for _, i in pairs(addition_items) do
      table.insert(opts.add_menu_items, i)
    end

    require("context-menu").setup(opts)
  end,
}
```

- `json` specific config for context-menu.nvim

```lua title="markdown.lua"
return {
  "LintaoAmons/context-menu.nvim",
  opts = function(_, opts)
    local new_item = {
      cmd = "toggle_view",
      ft = { "markdown" },
      callback = function(_)
        if vim.opt.conceallevel == 2 then
          vim.opt.conceallevel = 0
        else
          vim.opt.conceallevel = 2
        end

        vim.cmd([[Markview]])
      end,
    }
    opts.add_menu_items = opts.add_menu_items or {}
    table.insert(opts.add_menu_items, new_item)
  end
}
```

TODO:

- [ ] beautify menu buffer
- [ ] Example of how to config in multiple file using lazy.vim
