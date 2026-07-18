-- Dependency-free test suite. Run with:  nvim --headless -l tests/run.lua
vim.opt.runtimepath:prepend(".")

local Item = require("context-menu.item")
local registry = require("context-menu.registry")
local ui = require("context-menu.ui")

local failed = 0
local passed = 0

local function test(name, fn)
  local ok, err = pcall(fn)
  if ok then
    passed = passed + 1
    print("ok   " .. name)
  else
    failed = failed + 1
    print("FAIL " .. name .. "\n     " .. tostring(err))
  end
end

local function eq(expected, actual, msg)
  if not vim.deep_equal(expected, actual) then
    error(
      ("%s\n     expected: %s\n     actual:   %s"):format(
        msg or "values differ",
        vim.inspect(expected),
        vim.inspect(actual)
      ),
      2
    )
  end
end

local function names(items)
  return vim.tbl_map(function(i)
    return i.name
  end, items)
end

local ctx = { ft = "lua", buffer = 0, window = 0, line = "", filename = "", mode = "n", cursor = { 1, 0 } }

-- item.normalize -------------------------------------------------------------

test("normalize rejects items without a name", function()
  assert(not pcall(Item.normalize, {}), "expected error for missing name")
  assert(not pcall(Item.normalize, { name = "" }), "expected error for empty name")
end)

test("normalize rejects non-function actions", function()
  assert(not pcall(Item.normalize, { name = "x", action = "not a function" }))
end)

test("normalize recurses into sub items", function()
  assert(not pcall(Item.normalize, { name = "x", items = { { action = function() end } } }))
end)

-- item.merge_lists -----------------------------------------------------------

test("merge_lists appends new items and keeps base order", function()
  local merged = Item.merge_lists({ { name = "a" }, { name = "b" } }, { { name = "c" } })
  eq({ "a", "b", "c" }, names(merged))
end)

test("merge_lists merges items with the same name", function()
  local action = function() end
  local merged = Item.merge_lists(
    { { name = "a", order = 1 } },
    { { name = "a", action = action }, { name = "b" } }
  )
  eq({ "a", "b" }, names(merged))
  eq(1, merged[1].order, "base field kept")
  assert(merged[1].action == action, "incoming field applied")
end)

test("merge_lists merges sub items recursively by name", function()
  local merged = Item.merge_lists(
    { { name = "menu", items = { { name = "one" } } } },
    { { name = "menu", items = { { name = "one", order = 5 }, { name = "two" } } } }
  )
  eq({ "one", "two" }, names(merged[1].items))
  eq(5, merged[1].items[1].order)
end)

-- item.filter ----------------------------------------------------------------

test("filter honors ft, not_ft and filter_func", function()
  local items = {
    { name = "lua-only", ft = { "lua" } },
    { name = "json-only", ft = { "json" } },
    { name = "not-lua", not_ft = { "lua" } },
    { name = "func-hidden", filter_func = function() return false end },
    { name = "func-shown", filter_func = function(c) return c.ft == "lua" end },
    { name = "always" },
  }
  eq({ "lua-only", "func-shown", "always" }, names(Item.filter(items, ctx)))
end)

-- item.sort ------------------------------------------------------------------

test("sort orders by `order`, ft match, then insertion order", function()
  local items = {
    { name = "no-order-1" },
    { name = "third", order = 3 },
    { name = "first", order = 1 },
    { name = "ft-match", ft = { "lua" } }, -- default order, but matches ft
    { name = "no-order-2" },
  }
  eq({ "first", "third", "ft-match", "no-order-1", "no-order-2" }, names(Item.sort(items, ctx)))
end)

test("sort is stable for equal keys", function()
  local items = {}
  for i = 1, 20 do
    items[i] = { name = "item-" .. i }
  end
  eq(names(items), names(Item.sort(items, ctx)))
end)

-- registry -------------------------------------------------------------------

test("registry merges repeated add calls by name", function()
  registry.clear()
  registry.add({ { name = "a", order = 1 } })
  registry.add({ { name = "a", order = 2 }, { name = "b" } })
  local items = registry.get()
  eq({ "a", "b" }, names(items))
  eq(2, items[1].order, "later add wins")
end)

test("registry validates items on add", function()
  registry.clear()
  assert(not pcall(registry.add, { { order = 1 } }), "expected error for missing name")
end)

-- item.check_deps ------------------------------------------------------------

test("check_deps validates exe, cmd and lua dependencies", function()
  local ok = Item.check_deps({ name = "x", deps = { "exe:ls", "lua:vim.fs" } })
  assert(ok, "existing deps should pass")

  local ok2, missing = Item.check_deps({ name = "x", deps = { "exe:definitely-missing-bin" } })
  assert(not ok2 and missing:match("definitely%-missing%-bin"), "missing exe should fail")

  local ok3, missing3 = Item.check_deps({ name = "x", deps = { "cmd:NoSuchCommand" } })
  assert(not ok3 and missing3:match("NoSuchCommand"), "missing command should fail")

  local ok4, missing4 = Item.check_deps({ name = "x", deps = { "no_such_lua_module" } })
  assert(not ok4 and missing4:match("no_such_lua_module"), "missing lua module should fail")
end)

test("check_deps table form: custom msg is shown when missing", function()
  local ok, msg = Item.check_deps({
    name = "x",
    deps = { { "cmd:VGit", msg = "VGit.nvim is required — install tanvirtin/vgit.nvim" } },
  })
  assert(not ok)
  eq("VGit.nvim is required — install tanvirtin/vgit.nvim", msg)

  local ok2 = Item.check_deps({
    name = "x",
    deps = { { "exe:ls", msg = "never shown, dependency exists" } },
  })
  assert(ok2, "satisfied table-form dep should pass")
end)

test("ui.open notifies instead of running an action with missing deps", function()
  local ran, notified = false, nil
  local orig_notify = vim.notify
  vim.notify = function(msg, level)
    notified = { msg = msg, level = level }
  end

  local picker = function(entries, _, on_choice)
    on_choice(entries[1])
  end
  ui.open({
    {
      name = "Needs Stuff",
      deps = { "exe:definitely-missing-bin" },
      action = function()
        ran = true
      end,
    },
  }, ctx, { picker = picker, prompt = "Root" })

  vim.notify = orig_notify
  assert(not ran, "action must not run when deps are missing")
  assert(notified and notified.level == vim.log.levels.WARN, "expected a warning notification")
  assert(notified.msg:match("Needs Stuff"), "notification should name the item")
end)

test("ui.open reports action errors as friendly notifications", function()
  local notified
  local orig_notify = vim.notify
  vim.notify = function(msg, level)
    notified = { msg = msg, level = level }
  end

  local picker = function(entries, _, on_choice)
    on_choice(entries[1])
  end
  ui.open({
    {
      name = "Explodes",
      action = function()
        error("boom")
      end,
    },
  }, ctx, { picker = picker, prompt = "Root" })

  vim.notify = orig_notify
  assert(notified and notified.level == vim.log.levels.ERROR, "expected an error notification")
  assert(notified.msg:match("boom"), "notification should include the error")
end)

-- setup: user modules --------------------------------------------------------

test("setup loads user modules by require path", function()
  registry.clear()
  package.loaded["my_custom_module"] = {
    { name = "My Tool", action = function() end },
  }
  require("context-menu").setup({ modules = { "copy", "my_custom_module" } })
  local top = names(registry.get())
  assert(vim.tbl_contains(top, "My Tool"), "user module item missing")
  assert(vim.tbl_contains(top, "Copy"), "built-in module item missing")
  package.loaded["my_custom_module"] = nil
  registry.clear()
end)

-- ui traversal ---------------------------------------------------------------

test("ui.open descends into sub menus and runs the action with ctx", function()
  local shown_prompts = {}
  local ran_with
  local fake_picker = function(entries, opts, on_choice)
    table.insert(shown_prompts, opts.prompt)
    on_choice(entries[1]) -- always pick the first entry
  end

  local items = {
    {
      name = "Sub",
      items = { { name = "Leaf", action = function(c) ran_with = c end } },
    },
  }

  ui.open(items, ctx, { picker = fake_picker, prompt = "Root" })
  eq({ "Root", "Sub" }, shown_prompts, "root menu then sub menu")
  assert(ran_with == ctx, "action received the trigger-time context")
end)

test("ui.open filters sub menus by context too", function()
  local seen
  local fake_picker = function(entries, _, on_choice)
    seen = names(entries)
    on_choice(nil)
  end

  ui.open({
    { name = "visible" },
    { name = "hidden", ft = { "json" } },
  }, ctx, { picker = fake_picker, prompt = "Root" })
  eq({ "visible" }, seen)
end)

test("ui.open errors on unknown picker name", function()
  assert(not pcall(ui.open, { { name = "a" } }, ctx, { picker = "nope", prompt = "Root" }))
end)

-- ui/menu picker ---------------------------------------------------------------

local menu = require("context-menu.ui.menu")

test("menu: build_tree filters every level against the context", function()
  local tree = menu.build_tree({
    {
      name = "Sub",
      items = {
        { name = "lua-only", ft = { "lua" }, action = function() end },
        { name = "json-only", ft = { "json" }, action = function() end },
      },
    },
    { name = "hidden", ft = { "json" } },
  }, ctx)
  eq(1, #tree)
  eq("/Sub", tree[1].path)
  eq({ "lua-only" }, names(vim.tbl_map(function(n)
    return n.item
  end, tree[1].children)))
end)

test("menu: visible_nodes respects the expanded set", function()
  local tree = menu.build_tree({
    { name = "Sub", items = { { name = "Leaf", action = function() end } } },
    { name = "Plain", action = function() end },
  }, ctx)

  local collapsed = vim.tbl_map(function(n)
    return n.item.name
  end, menu.visible_nodes(tree, {}))
  eq({ "Sub", "Plain" }, collapsed)

  local open = vim.tbl_map(function(n)
    return n.item.name
  end, menu.visible_nodes(tree, { ["/Sub"] = true }))
  eq({ "Sub", "Leaf", "Plain" }, open)
end)

test("menu: search_nodes returns breadcrumb leaves, fuzzy filtered", function()
  local tree = menu.build_tree({
    { name = "Git", items = { { name = "Buffer Blame", action = function() end } } },
    { name = "Code Action", action = function() end },
  }, ctx)

  local all = menu.search_nodes(tree, "")
  eq({ "Git ▸ Buffer Blame", "Code Action" }, vim.tbl_map(function(r)
    return r.label
  end, all))

  local hits = menu.search_nodes(tree, "blame")
  eq(1, #hits)
  eq("Buffer Blame", hits[1].node.item.name)
end)

test("menu: search works on items with table-form deps (mixed-key tables)", function()
  local tree = menu.build_tree({
    {
      name = "Git",
      items = {
        {
          name = "Buffer Blame",
          deps = { { "lua:gitsigns", msg = "gitsigns.nvim is required" } },
          action = function() end,
        },
      },
    },
  }, ctx)
  local hits = menu.search_nodes(tree, "blame")
  eq(1, #hits)
  eq("Buffer Blame", hits[1].node.item.name)
end)

test("menu picker: expand sub menu and select leaf with keyboard", function()
  local chosen
  menu({
    { name = "Top", items = { { name = "Leaf", action = function() end } } },
  }, { prompt = "Root", ctx = ctx }, function(c)
    chosen = c
  end)

  -- l expands "Top", j moves to "Leaf", <CR> selects it
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("lj<CR>", true, false, true), "x", false)
  vim.wait(500, function()
    return chosen ~= nil
  end)
  eq("Leaf", chosen and chosen.name)
end)

test("menu picker: float position stays fixed across re-renders", function()
  menu({
    { name = "Top", items = { { name = "Leaf", action = function() end } } },
    { name = "Other", action = function() end },
  }, { prompt = "Root", ctx = ctx }, function() end)

  local win = vim.api.nvim_get_current_win()
  local before = vim.api.nvim_win_get_config(win)
  -- moving + expanding re-renders the float; it must not move
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("jkl<Tab>l", true, false, true), "x", false)
  local after = vim.api.nvim_win_get_config(win)
  eq({ before.relative, before.row, before.col }, { after.relative, after.row, after.col })
  vim.api.nvim_feedkeys("q", "x", false)
  vim.wait(100, function()
    return false
  end)
end)

test("menu picker: search confirms with <CR>, then j/o picks from results", function()
  local chosen
  menu({
    { name = "Alpha", action = function() end },
    { name = "Git", items = {
      { name = "Buffer Blame", action = function() end },
      { name = "Buffer Diff", action = function() end },
    } },
  }, { prompt = "Root", ctx = ctx }, function(c)
    chosen = c
  end)

  -- /buffer<CR> confirms the filter, j moves to the second match, o picks it
  -- (fuzzy ranking puts the shorter "Buffer Diff" first, "Buffer Blame" second)
  vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes("/buffer<CR>jo", true, false, true),
    "x",
    false
  )
  vim.wait(500, function()
    return chosen ~= nil
  end)
  eq("Buffer Blame", chosen and chosen.name)
end)

test("menu picker: q cancels with nil", function()
  local called, chosen = false, "sentinel"
  menu({ { name = "A", action = function() end } }, { prompt = "Root", ctx = ctx }, function(c)
    called, chosen = true, c
  end)
  vim.api.nvim_feedkeys("q", "x", false)
  vim.wait(500, function()
    return called
  end)
  assert(called, "on_choice was not called")
  eq(nil, chosen)
end)

-- ----------------------------------------------------------------------------

print(("\n%d passed, %d failed"):format(passed, failed))
if failed > 0 then
  os.exit(1)
end
