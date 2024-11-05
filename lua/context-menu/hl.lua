local M = {}
local Item = require("context-menu.domain.menu-item")
local HILIGHT_GROUP = "CurrentLineContextMenu"

---@param bufnr number
local function highlight_current_line(bufnr)
  vim.api.nvim_buf_clear_namespace(
    bufnr,
    vim.api.nvim_create_namespace("current_line_highlight"),
    0,
    -1
  )

  vim.api.nvim_set_hl(0, HILIGHT_GROUP, vim.g.context_menu_config.ui.selected_item)

  local ns_id = vim.api.nvim_create_namespace("current_line_highlight")

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1

  -- Get the length of the current line
  local line_length = #(vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or "")

  -- Use `nvim_buf_set_extmark` to set an extended mark on the buffer
  vim.api.nvim_buf_set_extmark(bufnr, ns_id, row, 0, {
    end_row = row,
    end_col = line_length,
    hl_group = HILIGHT_GROUP,
    priority = 101,
  })
end

local function hilight_column(bufnr)
  local ns_id = vim.api.nvim_create_namespace("hilight_column")

  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1)

  vim.api.nvim_set_hl(0, "ContextMenuColumn1", { fg = "#656565" }) -- Green
  vim.api.nvim_set_hl(0, "ContextMenuColumn2", { fg = "white" }) -- Green
  vim.api.nvim_set_hl(0, "ContextMenuColumn3", { fg = "#656565" }) -- Green
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- TODO: this is a hack, need to find a better way to do this
  -- use markdown syntax and get highlight by markdown highlight
  local end_col = Item.MAX_LENGTH
  for i = 1, line_count do
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 0, {
      end_row = i - 1,
      end_col = 3,
      hl_group = "ContextMenuColumn1",
      priority = 100,
    })
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, 4, {
      end_row = i - 1,
      end_col = end_col,
      hl_group = "ContextMenuColumn2",
      priority = 100,
    })
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, i - 1, end_col -1, {
      end_row = i - 1,
      end_col = end_col+2,
      hl_group = "ContextMenuColumn3",
      priority = 100,
    })
  end
end

---create highlight for current buffer
---@param bufnr any
function M.create_hight_light(bufnr)
  -- Use an autocmd to trigger the highlight when the cursor moves
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
    callback = function()
      highlight_current_line(bufnr)
      hilight_column(bufnr)
    end,
    buffer = bufnr, -- Ensure the autocommand is tied to the current buffer
  })
end

return M
