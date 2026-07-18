---Public API of context-menu.nvim. Everything else is an implementation detail.

local M = {}

---Configure the plugin and load built-in modules. Optional: the plugin works
---without calling setup, and calling it again at runtime takes effect
---immediately.
---@param opts? ContextMenu.Config
function M.setup(opts)
  local config = require("context-menu.config")
  config.setup(opts)

  for _, module in ipairs(config.options.modules) do
    -- built-in module first, then any user module by require path
    local ok, items = pcall(require, "context-menu.modules." .. module)
    if not ok then
      ok, items = pcall(require, module)
    end
    if ok then
      M.add_items(items)
    else
      vim.notify(
        ("context-menu: failed to load module %q (tried %q and %q):\n%s"):format(
          module,
          "context-menu.modules." .. module,
          module,
          items
        ),
        vim.log.levels.ERROR
      )
    end
  end
end

---Add (or merge, by name) menu items. Can be called from any file, any number
---of times, before or after setup — this is how config stays modular.
---@param items ContextMenu.Item[]
function M.add_items(items)
  require("context-menu.registry").add(items)
end

---Open the context menu for the current buffer.
---@param opts? ContextMenu.OpenOpts
function M.open(opts)
  opts = opts or {}
  local config = require("context-menu.config")
  local ctx = require("context-menu.context").capture()

  require("context-menu.ui").open(require("context-menu.registry").get(), ctx, {
    picker = opts.picker or config.options.picker,
    prompt = opts.prompt or config.options.prompt,
  })
end

---Register a custom picker by name, so `setup({ picker = name })` can use it.
---@param name string
---@param picker ContextMenu.Picker
function M.register_picker(name, picker)
  require("context-menu.ui").register(name, picker)
end

return M
