# context-menu.nvim

Without hundreds of keybindings, `trigger the menu, then pick an item` is all you need.

- One keybinding opens a menu whose items are filtered by the current context (filetype, or any custom predicate)
- Build your own menu: item order and visibility are easily configurable
- Split your config across multiple files — call `add_items()` from anywhere, any number of times
- Adjust the menu at runtime: re-source your config and it takes effect immediately
- Built-in modules to start with ease; a pluggable picker interface to extend the UI

## Usecases

- Run jq query in a json buffer
  ![context-menu for json](https://github.com/user-attachments/assets/6854fe18-d6c5-4c1a-848a-af6cb33dab27)

- Send HTTP request in an http buffer
  ![context-menu for http](https://github.com/user-attachments/assets/6d6d60e4-fc6f-4366-bbad-5aacdcc02a91)

## Philosophy

- Minimise cognitive overload, but keep every functionality within reach
- Fewer keybindings, same productivity
- Configuration can live in separate spec files and be changed at runtime with immediate effect

## Install & configuration

```lua
-- lazy.nvim
return {
  "LintaoAmons/context-menu.nvim",
  config = function()
    require("context-menu").setup({
      -- Built-in modules (see lua/context-menu/modules/):
      -- "git" | "http" | "markdown" | "test" | "copy" | "json"
      -- Check each module's dependencies before enabling it,
      -- e.g. the http module requires kulala.nvim, json requires jq.
      modules = { "git", "copy", "markdown", "http", "json" },

      -- picker = "vim-ui",        -- default; see "Custom pickers" below
      -- prompt = "Context Menu",  -- title of the root menu
    })

    -- Add custom menu items. This can be called from any file, any number of
    -- times — before or after setup — so your menu config stays modular.
    require("context-menu").add_items({
      {
        order = 1,            -- lower numbers appear first
        name = "Code Action", -- unique identifier and display name
        -- Visibility filters: ft, not_ft, filter_func (see lua/context-menu/types.lua)
        not_ft = { "markdown", "toggleterm", "json", "http" },
        action = function(ctx) -- receives the context captured at trigger time
          vim.lsp.buf.code_action()
        end,
      },
      {
        name = "My Tools",    -- an item without an action opens a sub menu
        items = {
          { name = "Do X", action = function() --[[ ... ]] end },
          { name = "Do Y", action = function() --[[ ... ]] end },
        },
      },
    })
  end,
}
```

Adding an item whose `name` already exists merges into it (fields override,
sub items merge recursively), so separate config files can safely contribute
entries to the same sub menu.

## Adding your own commands and modules

**A single command** is one call to `add_items()` — from any file, at any time:

```lua
require("context-menu").add_items({
  {
    name = "Format Buffer",
    ft = { "lua", "go", "python" },
    action = function(ctx)
      vim.lsp.buf.format({ bufnr = ctx.buffer })
    end,
  },
})
```

**A sub menu entry**: because items merge by name, any file can contribute to
an existing sub menu — this adds one entry into the built-in `Copy` menu:

```lua
require("context-menu").add_items({
  { name = "Copy", items = { { name = "File URL", action = function() ... end } } },
})
```

**Your own module** is just a Lua file that returns a list of items, exactly
like the built-in ones in `lua/context-menu/modules/`:

```lua
-- ~/.config/nvim/lua/my/menus/docker.lua
---@type ContextMenu.Item[]
return {
  {
    name = "Docker",
    filter_func = function(ctx)
      return ctx.filename:match("Dockerfile") ~= nil or ctx.ft == "yaml"
    end,
    items = {
      { name = "Build", action = function() vim.cmd("!docker build .") end },
      { name = "Compose Up", action = function() vim.cmd("!docker compose up -d") end },
    },
  },
}
```

Then load it by require path next to the built-ins:

```lua
require("context-menu").setup({
  modules = { "git", "copy", "my.menus.docker" },
})
```

(or equivalently: `require("context-menu").add_items(require("my.menus.docker"))`)

### Declaring dependencies

If an action needs a plugin or an external tool, declare it with `deps`.
When the user picks the item and a dependency is missing, they get a friendly
notification instead of a stack trace (and any error thrown by an action is
reported the same way):

```lua
{
  name = "Buffer Blame",
  -- table form: spec + custom message shown when the dependency is missing
  deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
  action = function() vim.cmd("VGit buffer_blame_preview") end,
},
{
  name = "Jq Query",
  deps = { "exe:jq" },          -- string form: a default message is generated
  action = function() ... end,
},
```

Three spec forms are supported, as plain strings or as `{ spec, msg = ... }`:

| Spec | Check |
| --- | --- |
| `"lua:kulala"` (or just `"kulala"`) | lua module is require-able |
| `"cmd:VGit"` | `:VGit` user command exists |
| `"exe:jq"` | `jq` executable is on `$PATH` |

All built-in modules declare their dependencies this way, so enabling a module
whose backing plugin isn't installed is safe — its items simply tell you
what's missing when selected. `:checkhealth context-menu` lists the same
dependencies up front.

## Keymaps

No default keymaps; bind the trigger yourself:

```lua
vim.keymap.set({ "v", "n" }, "<M-l>", function()
  require("context-menu").open()
end, { desc = "Open context menu" })

-- or use the command
vim.keymap.set({ "v", "n" }, "<M-l>", "<Cmd>ContextMenu<CR>")
```

## API

| Function | Description |
| --- | --- |
| `setup(opts?)` | Configure the plugin and load built-in modules. Optional. |
| `add_items(items)` | Register menu items (merged by `name`). Callable from anywhere. |
| `open(opts?)` | Open the menu for the current buffer. `opts` can override `picker`/`prompt`. |
| `register_picker(name, fn)` | Register a custom picker usable via `setup({ picker = name })`. |

The context passed to `action` and `filter_func`:

```lua
---@field buffer   integer  buffer number where the menu was triggered
---@field window   integer  window id
---@field line     string   content of the cursor line
---@field ft       string   filetype
---@field filename string   absolute path of the file
---@field mode     string   vim.fn.mode() at trigger time
---@field cursor   {[1]: integer, [2]: integer}  (row, col)
```

## Pickers

Two pickers are built in, selected via `setup({ picker = ... })`:

- `"vim-ui"` (default) — plain `vim.ui.select`; integrates with dressing.nvim, snacks picker, etc.
- `"menu"` — a right-click style floating menu at the cursor: sub menus expand
  inline in the same view, and `/` fuzzy-searches across all nested items.

`"menu"` keys:

| Key | Action |
| --- | --- |
| `j` / `k` | move |
| `<CR>` / `o` | run item / toggle sub menu |
| `l` / `<Right>` | expand sub menu (or run leaf) |
| `h` / `<Left>` | collapse / jump to parent |
| `<Tab>` | toggle sub menu |
| `/` | fuzzy search all nested items (breadcrumb results) |
| `<Esc>` / `q` | clear search / close |

While searching: type to filter, `<C-n>`/`<C-p>` or arrows to move, `<CR>`
runs the highlighted result straight away (one `<CR>` for the whole
search-and-pick), and `<Esc>` discards the search and returns to the tree.

For a true right-click experience:

```lua
vim.keymap.set({ "n", "v" }, "<RightMouse>", "<LeftMouse><Cmd>ContextMenu<CR>")
```

## Architecture & custom pickers

The core (item registry, filtering, sorting, context capture) is fully
decoupled from the presentation layer:

```
lua/context-menu/
├── init.lua      public API
├── config.lua    options
├── context.lua   context capture
├── item.lua      pure functions: normalize / merge / filter / sort
├── registry.lua  the item store
├── ui/
│   ├── init.lua  picker registry + menu traversal
│   ├── vim_ui.lua  built-in vim.ui.select picker
│   └── menu.lua  built-in right-click style floating picker
└── modules/      built-in item packs
```

A picker is just a function that shows one flat list and reports the choice —
sub menu traversal is handled by the core, so any picker supports nested menus
for free:

```lua
---@param entries ContextMenu.Item[]
---@param opts { prompt: string, ctx: ContextMenu.Context }
---@param on_choice fun(item: ContextMenu.Item?)
require("context-menu").register_picker("my-picker", function(entries, opts, on_choice)
  -- render entries however you like, then call on_choice(chosen_entry)
  -- (call on_choice(nil) on cancel)
end)

require("context-menu").setup({ picker = "my-picker" })
```

## Development

```sh
make test   # run the dependency-free test suite (nvim --headless)
make fmt    # format with stylua
```

`:checkhealth context-menu` reports registered items and missing module
dependencies.

## Migrating from v0.x

- `require("context-menu.picker.vim-ui").select()` → `require("context-menu").open()` (old call still works, with a deprecation notice)
- `:ContextMenuTrigger` → `:ContextMenu` (old command still works, with a deprecation notice)
- The item `keymap` field was removed (it was never implemented)

## CONTRIBUTING

Don't hesitate to ask me anything about the codebase if you want to contribute.

By [telegram](https://t.me/+ssgpiHyY9580ZWFl) or [微信: CateFat](https://lintao-index.pages.dev/assets/images/wechat-437d6c12efa9f89bab63c7fe07ce1927.png)

## Some Other Neovim Stuff

- [scratch.nvim](https://github.com/LintaoAmons/scratch.nvim)
- [cd-project.nvim](https://github.com/LintaoAmons/cd-project.nvim)
- [bookmarks.nvim](https://github.com/LintaoAmons/bookmarks.nvim)
- [context-menu.nvim](https://github.com/LintaoAmons/context-menu.nvim)
