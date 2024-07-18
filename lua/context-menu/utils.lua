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

return M
