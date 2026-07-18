local M = {}

---Optional dependencies per built-in module.
local module_deps = {
  git = { plugins = { "vgit" }, note = "git module uses VGit.nvim (and Snacks/Diffview for some items)" },
  http = { plugins = { "kulala" }, note = "http module requires kulala.nvim" },
  test = { plugins = { "neotest" }, note = "test module requires neotest" },
  json = { executables = { "jq" }, note = "json module requires the jq executable" },
  markdown = { note = "markdown module uses :MarkdownPreview and :Mtoc if installed" },
  copy = {},
}

function M.check()
  local health = vim.health

  health.start("context-menu.nvim")

  if vim.fn.has("nvim-0.10") == 1 then
    health.ok("Neovim >= 0.10")
  else
    health.warn("Neovim >= 0.10 is recommended")
  end

  local count = #require("context-menu.registry").get()
  if count > 0 then
    health.ok(("%d top-level menu item(s) registered"):format(count))
  else
    health.warn("no menu items registered", {
      "call require('context-menu').setup({ modules = { ... } })",
      "or add your own items via require('context-menu').add_items({ ... })",
    })
  end

  for _, module in ipairs(require("context-menu.config").options.modules or {}) do
    local deps = module_deps[module]
    if not deps then
      if pcall(require, module) then
        health.ok(("custom module %q loaded"):format(module))
      else
        health.error(("module %q is neither built-in nor a loadable lua module"):format(module))
      end
    else
      for _, plugin in ipairs(deps.plugins or {}) do
        if pcall(require, plugin) then
          health.ok(("module %q: dependency %q found"):format(module, plugin))
        else
          health.warn(("module %q: dependency %q not found"):format(module, plugin), { deps.note })
        end
      end
      for _, exe in ipairs(deps.executables or {}) do
        if vim.fn.executable(exe) == 1 then
          health.ok(("module %q: executable %q found"):format(module, exe))
        else
          health.warn(("module %q: executable %q not found"):format(module, exe), { deps.note })
        end
      end
    end
  end
end

return M
