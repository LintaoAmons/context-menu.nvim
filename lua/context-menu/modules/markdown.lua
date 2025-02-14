---@type ContextMenu.ItemStruct[]
return {
  {
    name = "Markdown Preview",
    order = 1,
    ft = { "markdown" },
    action = function(_)
      vim.cmd([[MarkdownPreview]])
    end,
  },
  {
    name = "Markdown",
    order = 2,
    ft = { "markdown" },
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
