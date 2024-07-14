local M = {}

---@class ContextMenu.Context
---@field buffer number
---@field window number
---@field line string
---@field ft string
---@field menu_buffer number?
---@field menu_window number?

---@param items ContextMenu.Item[]
---@return string[]
local function add_line_number(items)
	local line_number_added = {}
	for index, item in ipairs(items) do
		table.insert(line_number_added, index .. " " .. item.cmd)
	end
	return line_number_added
end

---@param cmd string
---@return {line_number: number, cmd: string}
local function parse_cmd(cmd)
	return {
		line_number = tonumber(cmd:match("^(%d+)")),
		cmd = cmd:gsub("^%d+%s+", ""), -- 从字符串开头匹配一个或多个数字和空格
	}
end

---@param items ContextMenu.Item[]
local function get_width(items)
	local cmds = {}
	for _, item in ipairs(items) do
		table.insert(cmds, item.cmd)
	end
	return vim.fn.strdisplaywidth(table.concat(cmds, "\n")) + 3
end

---@param menu_options ContextMenu.Item[]
---@return {buf: integer, win: integer}
local function menu_popup_window(menu_options)
	local popup_buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, add_line_number(menu_options))
	local width = get_width(menu_options)
	local height = #menu_options

	local opts = {
		relative = "cursor",
		row = 0,
		col = 0,
		width = width + 1,
		height = height,
		style = "minimal",
		border = "single",
		title = "ContextMenu.",
	}

	local win = vim.api.nvim_open_win(popup_buf, true, opts)
	return {
		buf = popup_buf,
		win = win,
	}
end

---@param context ContextMenu.Context
local function trigger_action(context)
	vim.api.nvim_set_current_buf(context.menu_buffer)
	local line = vim.api.nvim_get_current_line()
	local result = parse_cmd(line)

	local callback
	for _, item in ipairs(vim.g.context_menu_config.menu_items) do
		if result.cmd == item.cmd then
			callback = item.callback
		end
	end
	if callback then
		callback(context)
	else
		vim.print("haven't implemented yet")
	end
end

---@param items ContextMenu.Item[]
---@param context ContextMenu.Context
local function create_local_keymap(items, context)
	local function map(lhs, rhs)
		vim.keymap.set({ "v", "n" }, lhs, rhs, {
			noremap = true,
			silent = true,
			nowait = true,
			buffer = context.menu_buffer,
		})
	end

	map("q", function()
		vim.api.nvim_win_close(context.menu_window, true)
		vim.api.nvim_buf_delete(context.menu_buffer, {})
	end)

	for index, item in ipairs(items) do
		map(tostring(index), function()
			item.callback(context)
		end)
	end

	map("<CR>", function()
		trigger_action(context)
	end)

	map("g?", function()
		vim.print("<q> quit; <CR> trigger action under cursor")
	end)
end

local function table_contains(table, value)
	if not table then
		return false
	end
	for _, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

---@param items ContextMenu.Item[]
---@param context ContextMenu.Context
---@return ContextMenu.Item[]
local function filter_items(items, context)
	local filter_by_ft = {}
	for _, item in ipairs(items) do
		if table_contains(item.ft, context.ft) or item.ft == nil then
			table.insert(filter_by_ft, item)
		end
	end

	local filter_by_not_ft = {}
	for _, i in ipairs(filter_by_ft) do
		if not i.not_ft then
			table.insert(filter_by_not_ft, i)
			break
		end

		if not table_contains(i.not_ft, context.ft) then
			table.insert(filter_by_not_ft, i)
		end
	end

	return filter_by_not_ft
end

---order menu_items by the their order field value
---@param menu_items ContextMenu.Item[]
local function reorder_items(menu_items)
	table.sort(menu_items, function(a, b)
		if a.order and b.order then
			return a.order < b.order
		elseif b.order then
			return false
		else
			return true
		end
	end)
end

function M.trigger_context_menu()
	---@type ContextMenu.Context
	local context = {
		line = vim.api.nvim_get_current_line(),
		window = vim.api.nvim_get_current_win(),
		buffer = vim.api.nvim_get_current_buf(),
		ft = vim.bo.filetype,
	}

	local filtered_items = filter_items(vim.g.context_menu_config.menu_items, context)
	reorder_items(filtered_items)
	-- TODO: reorder the items by the order fields
	local created = menu_popup_window(filtered_items)
	context.menu_buffer = created.buf
	context.menu_window = created.win

	create_local_keymap(filtered_items, context)
end

return M
