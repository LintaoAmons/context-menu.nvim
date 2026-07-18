---@meta
---Type definitions for context-menu.nvim. This file contains no runtime code.

---The context captured at the moment the menu is triggered.
---It is passed to every `filter_func` and `action`.
---@class ContextMenu.Context
---@field buffer integer buffer number where the menu was triggered
---@field window integer window id where the menu was triggered
---@field line string content of the cursor line when the menu was triggered
---@field ft string filetype of the buffer
---@field filename string absolute path of the file
---@field mode string result of `vim.fn.mode()` at trigger time (e.g. "n", "v")
---@field cursor { [1]: integer, [2]: integer } (row, col) cursor position

---A single menu item. `name` is the unique identifier: adding an item with an
---existing name merges into it instead of duplicating it.
---@class ContextMenu.Item
---@field name string unique identifier and display name
---@field action? fun(ctx: ContextMenu.Context) executed when the item is selected
---@field items? ContextMenu.Item[] sub items; opens a nested menu when the item has no action
---@field desc? string optional longer description (pickers may display it)
---@field ft? string[] only show the item for these filetypes
---@field not_ft? string[] hide the item for these filetypes
---@field filter_func? fun(ctx: ContextMenu.Context): boolean return false to hide the item
---@field order? number lower numbers appear first (default 99)
---@field deps? ContextMenu.Dep[] dependencies checked before running the action,
---with a friendly notification when one is missing

---A dependency: either a spec string, or a table of the spec plus a custom
---message shown when the dependency is missing.
---Spec forms:
---  "lua:mod"  — lua module must be require-able (plain "mod" means the same)
---  "cmd:Name" — user command :Name must exist
---  "exe:bin"  — executable must be on $PATH
---@alias ContextMenu.Dep string | { [1]: string, msg?: string }

---A picker renders a flat list of entries and reports the user's choice.
---Menu traversal (descending into sub items) is handled by the core, so a
---picker only ever deals with one level at a time.
---@alias ContextMenu.Picker fun(entries: ContextMenu.Item[], opts: ContextMenu.PickerOpts, on_choice: fun(item: ContextMenu.Item?))

---@class ContextMenu.PickerOpts
---@field prompt string title for the current menu level
---@field ctx ContextMenu.Context

---@alias ContextMenu.Module "git"|"http"|"markdown"|"test"|"copy"|"json"

---@class ContextMenu.Config
---@field modules? ContextMenu.Module[] built-in modules to load
---@field picker? string|ContextMenu.Picker picker name or picker function (default "vim-ui")
---@field prompt? string root menu prompt (default "Context Menu")

---@class ContextMenu.OpenOpts
---@field picker? string|ContextMenu.Picker override the configured picker for this call
---@field prompt? string override the root prompt for this call
