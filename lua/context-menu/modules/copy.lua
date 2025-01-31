return {
  {
    order = 1,
    name = "Copy Line Reference",
    action = function()
      local current_file_dir = vim.fn.expand("%:p:h")
      local git_dir = vim.fn.finddir(".git", current_file_dir .. ";")

      if git_dir ~= "" then
        local project_root = vim.fn.fnamemodify(git_dir, ":p:h:h")
        local current_file_absolute = vim.fn.expand("%:p")
        local relative_path = string.sub(current_file_absolute, string.len(project_root) + 2)
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line_ref = relative_path .. ":" .. line .. ":" .. col
        vim.fn.setreg("+", line_ref)
        vim.notify("Copied line reference: " .. line_ref, vim.log.levels.INFO)
        return line_ref
      end
      vim.notify("No git repository found", vim.log.levels.WARN)
      return nil
    end,
  },
  {
    name = "Copy",
    items = {
      {
        name = "Buffer Name",
        action = function()
          local buf_name = vim.fn.expand("%:p:t")
          vim.fn.setreg("+", buf_name)
          vim.notify("Copied buffer name: " .. buf_name, vim.log.levels.INFO)
          return buf_name
        end,
      },
      {
        name = "Absolute Path",
        action = function()
          local abs_path = vim.fn.expand("%:p")
          vim.fn.setreg("+", abs_path)
          vim.notify("Copied absolute path: " .. abs_path, vim.log.levels.INFO)
          return abs_path
        end,
      },
      {
        name = "Absolute Directory Path",
        action = function()
          local abs_dir_path = vim.fn.expand("%:p:h")
          vim.fn.setreg("+", abs_dir_path)
          vim.notify("Copied absolute directory path: " .. abs_dir_path, vim.log.levels.INFO)
          return abs_dir_path
        end,
      },
      {
        name = "Relative Directory Path",
        action = function()
          local current_file_dir = vim.fn.expand("%:p:h")
          local git_dir = vim.fn.finddir(".git", current_file_dir .. ";")

          local project_root = vim.fn.fnamemodify(git_dir, ":p:h:h")
          local current_file_absolute = vim.fn.expand("%:p")
          local relative_path = string.sub(current_file_absolute, string.len(project_root) + 2)
          vim.fn.setreg("+", relative_path)
          vim.notify("Copied relative directory path: " .. relative_path, vim.log.levels.INFO)
          return relative_path
        end,
      },
      {
        name = "Project Path",
        action = function()
          local current_file_dir = vim.fn.expand("%:p:h")
          local git_dir = vim.fn.finddir(".git", current_file_dir .. ";")
          local project_root = vim.fn.fnamemodify(git_dir, ":p:h:h")
          vim.fn.setreg("+", project_root)
          vim.notify("Copied relative directory path: " .. project_root, vim.log.levels.INFO)
          return project_root
        end,
      },
    },
  },
}
