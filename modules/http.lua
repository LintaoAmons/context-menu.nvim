return {
    "LintaoAmons/context-menu.nvim",
    dependencies = {
      "mistweaverco/kulala.nvim",
    },
    opts = function()
      require("context-menu").setup({
        menu_items = {
          {
            cmd = "Send HTTP Request",
            fix = 1,
            ft = { "http" },
            action = {
              type = "callback",
              callback = function(_)
                require("kulala").run()
              end,
            },
          },
          {
            cmd = "HTTP",
            fix = 2,
            ft = { "http" },
            action = {
              type = "sub_cmds",
              sub_cmds = {
                {
                  cmd = "Re Run",
                  fix = 1,
                  action = {
                    type = "callback",
                    callback = function(_)
                      require("kulala").replay()
                    end,
                  },
                },
                {
                  cmd = "Copy Curl",
                  fix = 1,
                  action = {
                    type = "callback",
                    callback = function(_)
                      require("kulala").copy()
                    end,
                  },
                },
                {
                  cmd = "From Curl",
                  fix = 1,
                  action = {
                    type = "callback",
                    callback = function(_)
                      require("kulala").from_curl()
                    end,
                  },
                },
              },
            },
          },
        },
      })
    end,
  }
