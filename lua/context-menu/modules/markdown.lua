---@type ContextMenu.Item[]
return {
  {
    name = "Markdown Preview",
    order = 1,
    ft = { "markdown" },
    deps = { { "cmd:MarkdownPreview", msg = "markdown-preview.nvim is required — install iamcco/markdown-preview.nvim" } },
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
        deps = { { "cmd:MarkdownPreview", msg = "markdown-preview.nvim is required — install iamcco/markdown-preview.nvim" } },
        action = function(_)
          vim.cmd([[MarkdownPreview]])
        end,
      },
      {
        name = "Generate TOC",
        ft = { "markdown" },
        deps = { { "cmd:Mtoc", msg = "markdown-toc.nvim is required — install hedyhli/markdown-toc.nvim" } },
        action = function(_)
          vim.cmd([[Mtoc]])
        end,
      },
    },
  },
}
