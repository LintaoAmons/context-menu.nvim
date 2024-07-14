local M = {}

local function menu_item_routine(func, context)
	vim.api.nvim_set_current_buf(context.buffer)
	vim.api.nvim_set_current_win(context.window)
	vim.api.nvim_win_close(context.menu_window, true)
	vim.api.nvim_buf_delete(context.menu_buffer, {})
	func()
end

---@class ContextMenu.Item
---@field cmd string
---@field ft? string[]
---@field not_ft? string[]
---@field order? number
---@field callback function(ContextMenu.Context): nil
local menu_items = {
	{
		order = 1,
		cmd = "code_action",
		not_ft = { "markdown" },
		callback = function(_)
			vim.cmd([[Lspsaga code_action]])
		end,
	},
	{
		cmd = "toggle_view",
		ft = { "markdown" },
		callback = function(_)
			if vim.opt.conceallevel == 2 then
				vim.opt.conceallevel = 0
			else
				vim.opt.conceallevel = 2
			end

			vim.cmd([[Markview]])
		end,
	},
	{
		cmd = "run_test",
		ft = { "js" },
		callback = function(context)
			menu_item_routine(require("neotest").run.run, context)
		end,
	},
	{
		cmd = "run_as_cmd",
		ft = { "sh" },
		callback = function(context)
			menu_item_routine(function()
				local stdout = vim.fn.system(context.line)
				local lines = require("util.base.strings").split_into_lines(stdout)
				vim.api.nvim_set_current_buf(context.buffer)
				vim.api.nvim_put(lines, "l", true, true)
			end, context)
		end,
	},
}

local default_config = {
	menu_items = menu_items, -- override the default items:: use it when you don't want the plugin provided menu_items
	add_menu_items = {},
}

M.setup = function(opts)
	opts = opts or {}
	-- 确保 config 是 default_config 的独立副本
	local config = vim.deepcopy(default_config)
	config = vim.tbl_extend("force", config, opts)

	if opts.add_menu_items and #opts.add_menu_items > 0 then
		for _, item in ipairs(opts.add_menu_items) do
			table.insert(config.menu_items, item)
		end
	end

	vim.g.context_menu_config = config
end

return M
