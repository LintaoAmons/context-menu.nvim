---@type ContextMenu.ItemStruct[]
return {
  {
    name = "Send HTTP Request",
    order = 1,
    ft = { "http" },
    action = function(_)
      require("kulala").run()
    end,
  },
  {
    name = "HTTP",
    ft = { "http" },
    items = {
      {
        name = "Send HTTP Request",
        ft = { "http" },
        action = function(_)
          require("kulala").run()
        end,
      },
      {
        name = "Re Run HTTP Request",
        ft = { "http" },
        action = function(_)
          require("kulala").replay()
        end,
      },
      {
        name = "Copy as Curl",
        ft = { "http" },
        action = function(_)
          require("kulala").copy()
        end,
      },
      {
        name = "Import from Curl",
        ft = { "http" },
        action = function(_)
          require("kulala").from_curl()
        end,
      },
      {
        name = "Select Environment Variables",
        ft = { "http" },
        action = function(_)
          require("kulala").set_selected_env()
        end,
      },
    },
  },
}
