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
        order = 1,
        name = "Project Histories :: VGit",
        action = function()
          vim.cmd([[VGit project_logs_preview]])
        end,
      },
      {
        order = 1,
        name = "Project Histories :: Diffview",
        action = function()
          vim.cmd([[DiffviewFileHistory]])
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
        order = 2,
        action = function()
          vim.cmd([[VGit buffer_history_preview]])
        end,
      },
      {
        name = "Buffer Blame",
        action = function()
          vim.cmd([[VGit buffer_blame_preview]])
        end,
      },
      {
        name = "Open in github",
        action = function()
          Snacks.gitbrowse()
        end,
      },
      {
        name = "Reset Hunk",
        action = function(_)
          vim.cmd([[VGit buffer_hunk_reset]])
        end,
      },
      {
        name = "Reset Buffer",
        action = function(_)
          vim.cmd([[VGit buffer_reset]])
        end,
      },
    },
  },
}
