---@class ContextMenu.Context
---@field buffer number buffer number where triggered the menu
---@field window number window number where triggered the menu
---@field line string content of current line when trigger the menu
---@field ft string filetype
---@field filename string filename of the file where triggered the menu
---@field menu_buffer_stack number[]
---@field menu_window_stack number[]

---@alias ContextMenu.Modules "git"|"http"|"markdown"|"test"|"copy"

---@class ContextMenu.Config
---@field modules ContextMenu.Modules[]

---@class ContextMenu.ItemStruct
---@field name string **Unique identifier** and display name for the menu item.
---@field action? fun(context: ContextMenu.Context): nil Function executed upon menu item selection, with context provided.
---@field items? ContextMenu.ItemStruct[] sub items
---@field keymap? string Optional, local keymap in menu
---filter
---@field ft? string[] Optional list of filetypes that determine menu item visibility.
---@field not_ft? string[] Optional list of filetypes that exclude the menu item's display.
---@field filter_func? fun(context: ContextMenu.Context): boolean Optional, true will remain, false will be filtered out
---@field order? number Optional, order of the menu item.
