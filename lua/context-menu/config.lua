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
---@field callback function(ContextMenu.Context): nil
local menu_items = {
	{
		cmd = "run_file",
		not_ft = { "markdown" },
		callback = function(context)
			menu_item_routine(function()
				require("features.terminal-and-run").run_file()
			end, context)
		end,
	},
	{
		cmd = "code_action",
		not_ft = { "markdown" },
		callback = function(context)
			menu_item_routine(function()
				vim.cmd([[Lspsaga code_action]])
			end, context)
		end,
	},
	{
		cmd = "toggle_view",
		ft = { "markdown" },
		callback = function(context)
			menu_item_routine(function()
				if vim.opt.conceallevel == 2 then
					vim.opt.conceallevel = 0
				else
					vim.opt.conceallevel = 2
				end

				vim.cmd([[Markview]])
			end, context)
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
vim.g.context_menu_config = {
	menu_items = menu_items,
}

M.setup = function(opts)
	opts = opts or {}
	vim.g.context_menu_config = vim.tbl_extend("force", vim.g.context_menu_config, opts)
end

return M
