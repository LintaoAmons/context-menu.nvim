---@type ContextMenu.Item[]
return {
  {
    name = "Send HTTP Request",
    ft = { "http" },
    deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
    action = function()
      require("kulala").run()
    end,
  },
  {
    name = "Re Run Last HTTP Request",
    deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
    action = function()
      require("kulala").replay()
    end,
  },
  {
    name = "HTTP",
    ft = { "http" },
    items = {
      {
        name = "Send HTTP Request",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").run()
        end,
      },
      {
        name = "Re Run HTTP Request",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").replay()
        end,
      },
      {
        name = "Copy as Curl",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").copy()
        end,
      },
      {
        name = "Import from Curl",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").from_curl()
        end,
      },
      {
        name = "Select Environment Variables",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").set_selected_env()
        end,
      },
      {
        name = "Show Statistics of the Last Request",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").show_stats()
        end,
      },
      {
        name = "Search named request in current buffer",
        ft = { "http" },
        deps = { { "lua:kulala", msg = "kulala.nvim is required — install mistweaverco/kulala.nvim" } },
        action = function()
          require("kulala").search()
        end,
      },
    },
  },
}
