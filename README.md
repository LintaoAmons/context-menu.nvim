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

```lua
-- lazy.nvim
return {
  "LintaoAmons/context-menu.nvim",
  config = function(_, opts)
    require("context-menu").setup({
      -- enable predefined modules:
      -- "git"|"http"|"markdown"|"test"|"copy"
      modules = {},
    })
  end,
}
```

### Add new context-menu items

> An simple example to add new add_items
> Share yours in the Discussion

```lua
require("context-menu").add_items({
  {
    order = 1,
    name = "Code Action",
    not_ft = { "markdown", "toggleterm" },
    action = function(_)
      vim.lsp.buf.code_action()
    end,
  },
  {
    order = 2,
    name = "Run Test",
    not_ft = { "markdown" },
    filter_func = function(context)
      local a = context.filename
      if string.find(a, ".test.") or string.find(a, "spec.") then
        return true
      else
        return false
      end
    end,
    action = function(_)
      require("neotest").run.run()
    end,
  },
})
```

## Keymaps

No default keymaps, you need to set the shortcut by yourself, here's a reference

```lua
vim.keymap.set({ "v", "n" }, "<M-l>", function()
  require("context-menu.picker.vim-ui").select()
end, {})

-- or
vim.keymap.set({ "v", "n" }, "<M-l>", "ContextMenuTrigger", {})
```

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

By [telegram](https://t.me/+ssgpiHyY9580ZWFl) or [微信: CateFat](https://lintao-index.pages.dev/assets/images/wechat-437d6c12efa9f89bab63c7fe07ce1927.png)

## Some Other Neovim Stuff

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [context-menu.nvim](https://github.com/LintaoAmons/context-menu.nvim)
