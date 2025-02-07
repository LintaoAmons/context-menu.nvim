return { {
  name = "Test",
  items = {
    {
      name = "Run Current File",
      action = function(_)
        require("neotest").run.run(vim.fn.expand("%"))
      end,
    },
    {
      name = "Run Nearest",
      action = function(_)
        require("neotest").run.run()
      end,
    },
    {
      name = "Run Last",
      action = function(_)
        require("neotest").run.run_last()
      end,
    },
    {
      name = "Run Suite",
      action = function(_)
        require("neotest").run.run(vim.fn.getcwd())
      end,
    },
  },
} }
