---@type ContextMenu.Item
return {
  name = "Send HTTP Request",
  fix = 1,
  ft = { "http" },
  action = function(_)
    require("kulala").run()
  end,
}
