
## Install & Configuration
> [My config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/context-menu.lua)


```lua
return {
  "LintaoAmons/context-menu.nvim",
  config = function(_, opts)
      local addition_items = {
        cmd = "jq_query",
        ft = { "json" },
        callback = function(context)
          menu_item_routine(jq_query, context)
        end,
      }
      opts.add_menu_items = opts.add_menu_items or {}
      table.insert(opts.add_menu_items, addition_items)
    require("context-menu").setup(opts)
  end,
}
```


TODO:

- [ ] beautify menu buffer
- [ ] Example of how to config in multiple file using lazy.vim
