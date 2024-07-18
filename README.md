> [!WARNING]
>
> This plugin is in its early stages, and the data structures is like to undergo significant changes over time.

## Philosophy

- Minimise the cognitive overload in the head, but still put every functionality around you hand
- Less keybindings but remian productivity
- Configuration can be put in seperated spec files, and behaviour can be config at runtime and take effect immediately

## Install & Configuration

> You can use [my config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/context-menu.lua) as a reference

```lua
return {
	"LintaoAmons/context-menu.nvim",
	config = function(_, opts)
		require("context-menu").setup({
			---@type ContextMenu.Items
			menu_items = {}, -- default items
			---@type ContextMenu.Items
			add_menu_items = { -- add more items :: use it when you split your menu_items over other places
				{
					cmd = "do_something",
					action = {
						type = "callback",
						callback = function(context)
							vim.print(context) -- you can take a look of what's in side context
							vim.print("do something")
						end,
					},
				},
			},
            enable_log = true, -- enable error log be printed out. Turn it off if you don't want see those lines
		})
	end,
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


---

TODO:

- [ ] make configuration source-able in the runtime
- [ ] beautify menu buffer
- [ ] Example of how to config in multiple file using lazy.vim
