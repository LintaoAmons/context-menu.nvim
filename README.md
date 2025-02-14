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

Without handruds of keybindings, `trigger ctx-menu then select the first item` is all you need

- Build your own menu, (items order) and (display or hide) are easily configurable
- Split you config in multiple places, encapsulating those item in its own place
- Adjust your config at runtime, simply source the setup function again
- built-in modules, start with ease

- Jq in json ctx
  ![context-menu for json](https://github.com/user-attachments/assets/6854fe18-d6c5-4c1a-848a-af6cb33dab27)

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
      -- Available predefined modules:
      -- "git"|"http"|"markdown"|"test"|"copy"|"json"
      modules = {
        "git",       -- Module implementations can be found in `lua/context-menu/modules`
                     -- To check the dependencies of the module, e.g. git module requires VGit.nvim
        "copy",      -- Remove any predefined modules you don't need
        "markdown",  -- Reference existing modules to learn how to create your own
        "http",      -- http module requires kulala.nvim
        "json",      -- jq
      },
    })

    -- Add custom menu items
    -- This method can be called from any location to modularize your configuration
    -- Items can be modified at runtime to simplify configuration and debugging
    require("context-menu").add_items({
      {
        order = 1, -- Lower numbers indicate higher priority
        name = "Code Action", -- Display name in the menu
        -- Additional filters are defined in `lua/context-menu/types.lua`
        -- Options include ft, not_ft, and filter_func
        not_ft = { "markdown", "toggleterm", "json", "http" }, -- Hide item for specified filetypes
        action = function(_) -- Function executed when item is selected
          vim.lsp.buf.code_action()
        end,
      },
    })
  end,
}
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
