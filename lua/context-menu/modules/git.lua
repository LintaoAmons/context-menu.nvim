---@type ContextMenu.ItemStruct[]
return {
  {
    order = 5,
    name = "Git: Project Diff",
    action = function()
      vim.cmd([[VGit project_diff_preview]])
    end,
  },
  {
    name = "Git",
    items = {
      {
        name = "Project Diff",
        action = function()
          vim.cmd([[VGit project_diff_preview]])
        end,
      },
      {
        name = "Project Histories",
        action = function()
          vim.cmd([[VGit project_logs_preview]])
        end,
      },
      {
        name = "Project Stash",
        action = function()
          vim.cmd([[VGit project_stash_preview]])
        end,
      },
      {
        name = "Buffer Diff",
        action = function()
          vim.cmd([[VGit buffer_diff_preview]])
        end,
      },
      {
        name = "Buffer Histories",
        action = function()
          vim.cmd([[VGit buffer_diff_preview]])
        end,
      },
      {
        name = "Buffer Blame",
        action = function()
          vim.cmd([[VGit buffer_blame_preview]])
        end,
      },
    },
  },
}
