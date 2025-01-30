return {
  "LintaoAmons/context-menu.nvim",
  opts = function()
    require("context-menu").setup({
      menu_items = {
        {
          fix = 1,
          cmd = "Markdown Preview",
          ft = { "markdown" },
          action = {
            type = "callback",
            callback = function(_)
              vim.cmd([[MarkdownPreview]])
            end,
          },
        },
        {
          fix = 1,
          cmd = "Markdown TOC generation",
          ft = { "markdown" },
          action = {
            type = "callback",
            callback = function(_)
              vim.cmd([[Mtoc]])
            end,
          },
        },
      },
    })
  end,
}
