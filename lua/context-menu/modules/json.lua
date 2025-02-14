--- Create a new horizontal splitted buffer
--- and write the content into the buffer
---@param content string[]
---@param opts? {vertical?: boolean, ft?: string}
local function write_into_new_buf(content, opts)
  opts = opts or {}
  if opts.vertical then
    vim.cmd("vnew")
  else
    vim.cmd("new")
  end

  -- Get the current buffer
  local buf = vim.api.nvim_get_current_buf()

  -- Clear the buffer
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})

  -- Write the content into the buffer
  vim.api.nvim_put(content, "", true, true)

  -- Set the buffer as unmodified
  vim.cmd("setlocal nomodified")
  if opts.ft then
    vim.bo.ft = opts.ft
  end
end

---@type ContextMenu.ItemStruct[]
return {
  {
    name = "Jq Query",
    order = 1,
    ft = { "json" },
    action = function(_)
      vim.ui.input(
        { prompt = 'Query pattern, e.g. `.[] | .["@message"].message` ' },
        function(pattern)
          if pattern == nil then
            return
          end

          local absDir = vim.fn.expand("%:p")
          local cmd = "jq" .. " '" .. pattern .. "' \"" .. absDir .. '"'
          local output = vim.fn.system(cmd)

          if vim.v.shell_error ~= 0 then
            error("Failed to execute jq command: \n" .. cmd .. "\noutput\n" .. output)
          end

          local lines = vim.split(output, "\n", { trimempty = true })
          write_into_new_buf(lines, { vertical = true, ft = "json" })
        end
      )
    end,
  },
}
