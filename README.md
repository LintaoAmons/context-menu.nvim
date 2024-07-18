> [!WARNING]
> This plugin is under rapid development, data structure may have big change over time
> 
> Currently mostly for my personal usecases


## Install & Configuration
> You can use [my config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/context-menu.lua) as a reference

```lua
return {
  "LintaoAmons/context-menu.nvim",
  config = function(_, opts)
    require("context-menu").setup({
      ---@type ContextMenu.Item[]
      menu_items = {}, -- default items
      ---@type ContextMenu.Item[]
      add_menu_items = { -- add more items :: use it when you split your menu_items over other places
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

<details>
<summary>Split the config in multiple places</summary>

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

- `gitsign` specific config for `context-menu.nvim`

```lua
return {
  {
    "LintaoAmons/context-menu.nvim",
    opts = function(_, opts)
      local new_items = {
        {
          cmd = "Git :: Blame",
          order = 85,
          callback = function(_)
            vim.cmd([[Gitsigns blame]])
          end,
        },
        {
          cmd = "Git :: Blame Line",
          order = 84,
          callback = function(_)
            vim.cmd([[Gitsigns blame_line]])
          end,
        },
        {
          cmd = "Git :: Peek",
          order = 80,
          callback = function(_)
            vim.cmd([[Gitsigns preview_hunk]])
          end,
        },
        {
          cmd = "Git :: Reset Hunk",
          order = 81,
          callback = function(_)
            vim.cmd([[Gitsigns reset_hunk]])
          end,
        },
        {
          cmd = "Git :: Reset Buffer",
          order = 82,
          callback = function(_)
            vim.cmd([[Gitsigns reset_buffer]])
          end,
        },
        {
          cmd = "Git :: Diff Current Buffer",
          order = 83,
          callback = function(_)
            require("gitsigns").diffthis()
          end,
        },
      }
      opts.add_menu_items = opts.add_menu_items or {}
      for _, i in ipairs(new_items) do
        table.insert(opts.add_menu_items, i)
      end
    end,
  },
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

</details>

TODO:

- [ ] make configuration sourceable in the runtime
- [ ] beautify menu buffer
- [ ] Example of how to config in multiple file using lazy.vim
