> [!WARNING]
>
> This plugin is in its early stages, and the data structures is like to undergo significant changes over time.

Instead of keymaps, you can put your actions in the context menu

- Menu is a buffer, use hjkl to navigate the items and trigger it or just trigger it by the number
- Build your own menu, (items order) and (display or hide) are easily configurable
- Split you config in multiple places, encapsulating those item in its own place

## Philosophy

- Minimise the cognitive overload in the head, but still put every functionality around you hand
- Less keybindings but remian productivity
- Configuration can be put in seperated spec files, and behaviour can be config at runtime and take effect immediately

## Install & Configuration

> For more complex usecases, you can use [my config](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/context-menu.lua) as a reference

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

This is the type definition of the MenuItem, you can config your items according to this definition

```lua
---@class ContextMenu.Item
---@field cmd string **Unique identifier** and display name for the menu item.
---@field action ContextMenu.Action
---@field ft? string[] Optional list of filetypes that determine menu item visibility.
---@field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
---@field filter_func? fun(context: ContextMenu.Context): boolean Optional, true will remain, false will be filtered out
---@field order? number Optional numerical order for menu item sorting.

---@class ContextMenu.Action
---@field type ContextMenu.ActionType
---@field callback? fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
---@field sub_cmds? ContextMenu.Item[]
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
<summary>Config</summary>

```lua
return {
  "LintaoAmons/context-menu.nvim",
  opts = function(_, opts)
    local new_items = {
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
    }
    opts.add_menu_items = opts.add_menu_items or {}
    for _, i in ipairs(new_items) do
      table.insert(opts.add_menu_items, i)
    end
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
local jq_query = function()
  local sys = require("util.base.sys")
  local editor = require("util.editor")

  vim.ui.input({ prompt = 'Query pattern, e.g. `.[] | .["@message"].message` ' }, function(pattern)
    local absPath = editor.buf.read.get_buf_abs_path()
    local stdout, _, stderr = sys.run_sync({ "jq", pattern, absPath }, ".")
    local result = stdout or stderr
    editor.split_and_write(result, { vertical = true, ft = "json" })
  end)
end
vim.keymap.set({ "n", "v" }, "rq", jq_query)

return {
  {
    "LintaoAmons/context-menu.nvim",
    opts = function(_, opts)
      local new_item = {
        cmd = "Jq Query",
        ft = { "json" },
        action = {
          type = "callback",
          callback = function(_)
            jq_query()
          end,
        },
      }
      opts.add_menu_items = opts.add_menu_items or {}
      table.insert(opts.add_menu_items, new_item)
    end,
  },

  -- treesitter syntax hightlight
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "json", "jsonc" })
      end
    end,
  },

  -- format
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "jq" },
      },
    },
  },
}
```

</details>

### Copy

> [config ref](https://github.com/LintaoAmons/CoolStuffes/blob/main/nvim/.config/nvim/lua/plugins/editor-enhance/copy.lua)

![cm-copy](https://github.com/user-attachments/assets/6b59dbbb-594d-41a7-a610-eeb22b332ba1)

<details>
<summary>Title</summary>

```lua
--- Returns the absolute path of the current file relative to the project root, and the current line and column.
--- @return string|nil
local function copy_line_ref()
  local current_file_dir = vim.fn.expand("%:p:h") -- '%:p:h' expands to the directory of the current file

  -- Find the .git directory starting from the current file's directory and moving upwards
  local git_dir = vim.fn.finddir(".git", current_file_dir .. ";")

  -- If a .git directory is found, get the project root
  if git_dir ~= "" then
    local project_root = vim.fn.fnamemodify(git_dir, ":p:h:h") -- Get the project root directory
    -- Get the absolute path of the current file
    local current_file_absolute = vim.fn.expand("%:p")

    -- Calculate the relative path from the project root to the current file
    local relative_path = string.sub(current_file_absolute, string.len(project_root) + 2)

    -- Get the current line and column in the same line by unpacking the cursor position
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    local line_ref = relative_path .. ":" .. line .. ":" .. col

    vim.fn.setreg("+", line_ref)
    -- Return the reference path, line, and column
    return line_ref
  else
    return nil -- Return nil if no .git directory is found
  end
end
vim.api.nvim_create_user_command("CopyLineRef", copy_line_ref, {})

local function copy_buf_name()
  local buf_name = vim.fn.expand("%:p:t")
  vim.print(buf_name)
  vim.fn.setreg("+", buf_name)
  return buf_name
end
vim.api.nvim_create_user_command("CopyBufName", copy_buf_name, {})

local function copy_buf_abs_path()
  local abs_path = require("util.editor").buf.read.get_buf_abs_path()
  vim.print(abs_path)
  vim.fn.setreg("+", abs_path)
  return abs_path
end
vim.api.nvim_create_user_command("CopyBufAbsPath", copy_buf_abs_path, {})

local function copy_buf_abs_dir_path()
  local result = require("util.editor").buf.read.get_buf_abs_dir_path()
  vim.print(result)
  vim.fn.setreg("+", result)
  return result
end
vim.api.nvim_create_user_command("CopyBufAbsDirPath", copy_buf_abs_dir_path, {})

local function copy_buf_relative_dir_path()
  local result = require("util.editor").buf.read.get_buf_relative_dir_path()
  vim.print(result)
  vim.fn.setreg("+", result)
  return result
end
vim.api.nvim_create_user_command("CopyBufRelativeDirPath", copy_buf_relative_dir_path, {})

return {
  {
    "LintaoAmons/context-menu.nvim",
    opts = function(_, opts)
      local new_item = {
        cmd = "Copy",
        action = {
          type = "sub_cmds",
          sub_cmds = {
            {
              cmd = "Copy Line Ref",
              order = 91,
              action = {
                type = "callback",
                callback = function(_)
                  copy_line_ref()
                end,
              },
            },
            {
              cmd = "Copy Buf Name",
              order = 92,
              action = {
                type = "callback",
                callback = function(_)
                  copy_buf_name()
                end,
              },
            },
            {
              cmd = "Copy Buf Abs Path",
              order = 92,
              action = {
                type = "callback",
                callback = function(_)
                  copy_buf_abs_path()
                end,
              },
            },
            {
              cmd = "Copy Buf Abs Dir Path",
              order = 92,
              action = {
                type = "callback",
                callback = function(_)
                  copy_buf_abs_dir_path()
                end,
              },
            },
            {
              cmd = "Copy Buf Relative Dir Path",
              order = 92,
              action = {
                type = "callback",
                callback = function(_)
                  copy_buf_relative_dir_path()
                end,
              },
            },
          },
        },
      }

      opts.add_menu_items = opts.add_menu_items or {}
      table.insert(opts.add_menu_items, new_item)
    end,
  },
}
```

</details>

## [See more usecases and configuration](https://lintao-index.pages.dev/docs/Vim/plugins/context-menu/)

---

TODO:

- [ ] make configuration source-able in the runtime
- [ ] beautify menu buffer
- [ ] Example of how to config in multiple file using lazy.vim
