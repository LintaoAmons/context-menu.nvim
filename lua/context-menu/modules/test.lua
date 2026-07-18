return { {
  name = "Test",
  items = {
    {
      name = "Run Current File",
      deps = { { "lua:neotest", msg = "neotest is required — install nvim-neotest/neotest" } },
      action = function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
    },
    {
      name = "Run Nearest",
      deps = { { "lua:neotest", msg = "neotest is required — install nvim-neotest/neotest" } },
      action = function()
        require("neotest").run.run()
      end,
    },
    {
      name = "Run Last",
      deps = { { "lua:neotest", msg = "neotest is required — install nvim-neotest/neotest" } },
      action = function()
        require("neotest").run.run_last()
      end,
    },
    {
      name = "Run Suite",
      deps = { { "lua:neotest", msg = "neotest is required — install nvim-neotest/neotest" } },
      action = function()
        require("neotest").run.run(vim.fn.getcwd())
      end,
    },
  },
} }
