---@type ContextMenu.Item[]
return {
  {
    order = 10,
    name = "Git: Status",
    deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
    action = function()
      vim.cmd([[VGit project_diff_preview]])
    end,
  },
  {
    order = 11,
    name = "Git: Add .",
    deps = { "exe:git" },
    action = function()
      vim.cmd([[!git add .]])
    end,
  },
  {
    name = "Git",
    order = 19,
    items = {
      {
        name = "Project Diff",
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit project_diff_preview]])
        end,
      },
      {
        order = 1,
        name = "Project Histories :: VGit",
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit project_logs_preview]])
        end,
      },
      {
        order = 1,
        name = "Project Histories :: Diffview",
        -- Checked by command name, not repo: `:DiffviewFileHistory` is identical in
        -- sindrets/diffview.nvim and its maintained fork dlyongemallo/diffview-plus.nvim,
        -- so name both here rather than making either one the prerequisite.
        deps = {
          {
            "cmd:DiffviewFileHistory",
            msg = "diffview is required — install sindrets/diffview.nvim or dlyongemallo/diffview-plus.nvim",
          },
        },
        action = function()
          vim.cmd([[DiffviewFileHistory]])
        end,
      },
      {
        name = "Project Stash",
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit project_stash_preview]])
        end,
      },
      {
        name = "Buffer Diff",
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit buffer_diff_preview]])
        end,
      },
      {
        name = "Buffer Histories",
        order = 2,
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit buffer_history_preview]])
        end,
      },
      {
        name = "Buffer Blame",
        deps = { { "lua:gitsigns", msg = "gitsigns.nvim is required — install lewis6991/gitsigns.nvim" } },
        action = function()
          require("gitsigns").blame()
        end,
      },
      {
        name = "Blame Line",
        deps = { { "lua:gitsigns", msg = "gitsigns.nvim is required — install lewis6991/gitsigns.nvim" } },
        action = function()
          require("gitsigns").blame_line({ full = true })
        end,
      },
      {
        name = "Open in github",
        deps = { { "lua:snacks", msg = "snacks.nvim is required — install folke/snacks.nvim" } },
        action = function()
          require("snacks").gitbrowse()
        end,
      },
      {
        name = "Reset Hunk",
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit buffer_hunk_reset]])
        end,
      },
      {
        name = "Reset Buffer",
        deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
        action = function()
          vim.cmd([[VGit buffer_reset]])
        end,
      },
    },
  },
}
