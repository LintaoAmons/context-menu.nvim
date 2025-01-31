return {
  {
    name = "Markdown Preview",
    ft = { "markdown" },
    action = function(_)
      vim.cmd([[MarkdownPreview]])
    end,
  },
  {
    name = "Markdown",
    items = {
      {
        name = "Preview",
        ft = { "markdown" },
        action = function(_)
          vim.cmd([[MarkdownPreview]])
        end,
      },
      {
        name = "Generate TOC",
        ft = { "markdown" },
        action = function(_)
          vim.cmd([[Mtoc]])
        end,
      },
    },
  },
}
