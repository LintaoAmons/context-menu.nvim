local M = {}

---@param lines string[]
---@return number
function M.get_width(lines)
  local length = 0
  for _, line in ipairs(lines) do
    if #line > length then
      length = #line
    end
  end
  return length + 3
end

function M.log(msg)
  if vim.g.context_menu_config.enable_log then
    vim.print(msg)
  end
end

return M
