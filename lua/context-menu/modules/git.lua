---@type ContextMenu.Item
return {
  name = "Git",
  items = {
    {
      name = "Project Diff",
      action = function()
        vim.cmd([[VGit project_diff_preview]])
      end,
    },
    {
      name = "Project Stash",
      action = function()
        vim.cmd([[VGit project_stash_preview]])
      end,
    },
  },
}
