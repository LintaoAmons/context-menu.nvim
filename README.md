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

## Usecases

### Git

![cm-git-blame](https://github.com/user-attachments/assets/185c9ebb-7d94-4864-989b-6a6a0a32867f)

### Json | Jq

![cm-jq](https://github.com/user-attachments/assets/6b4212e1-2122-4ad1-bd66-3e1f72864b1a)

### Copy

![cm-copy](https://github.com/user-attachments/assets/6b59dbbb-594d-41a7-a610-eeb22b332ba1)


## [See more usecases and configuration](https://lintao-index.pages.dev/docs/Vim/plugins/context-menu/)
```


TODO:

- [ ] make configuration sourceable in the runtime
- [ ] beautify menu buffer
- [ ] Example of how to config in multiple file using lazy.vim
