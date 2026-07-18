---Pure functions over menu items: validation, merging, filtering and sorting.
---No state lives here, which keeps every function independently testable.

local M = {}

local DEFAULT_ORDER = 99

---Validate a raw item table and return a normalized copy (sub items included).
---@param raw ContextMenu.Item
---@return ContextMenu.Item
function M.normalize(raw)
  if type(raw) ~= "table" then
    error("context-menu: item must be a table, got " .. type(raw))
  end
  if type(raw.name) ~= "string" or raw.name == "" then
    error("context-menu: item must have a non-empty string `name`")
  end
  if raw.action ~= nil and type(raw.action) ~= "function" then
    error(("context-menu: item %q: `action` must be a function"):format(raw.name))
  end
  if raw.items ~= nil and type(raw.items) ~= "table" then
    error(("context-menu: item %q: `items` must be a list"):format(raw.name))
  end

  ---@type ContextMenu.Item
  local item = {
    name = raw.name,
    action = raw.action,
    desc = raw.desc,
    ft = raw.ft,
    not_ft = raw.not_ft,
    filter_func = raw.filter_func,
    order = raw.order,
    deps = raw.deps,
  }

  if raw.items then
    item.items = vim.tbl_map(M.normalize, raw.items)
  end

  return item
end

---Merge `incoming` into `base`: scalar fields of `incoming` win, sub items
---are merged recursively by name.
---@param base ContextMenu.Item
---@param incoming ContextMenu.Item
---@return ContextMenu.Item
function M.merge(base, incoming)
  local merged = vim.tbl_extend("force", {}, base)

  for k, v in pairs(incoming) do
    if k ~= "items" then
      merged[k] = v
    end
  end

  if incoming.items then
    merged.items = M.merge_lists(base.items or {}, incoming.items)
  end

  return merged
end

---Merge two item lists by name, preserving the position of existing items.
---@param base ContextMenu.Item[]
---@param incoming ContextMenu.Item[]
---@return ContextMenu.Item[]
function M.merge_lists(base, incoming)
  local result = {}
  local index_by_name = {}

  for _, item in ipairs(base) do
    table.insert(result, item)
    index_by_name[item.name] = #result
  end

  for _, item in ipairs(incoming) do
    local idx = index_by_name[item.name]
    if idx then
      result[idx] = M.merge(result[idx], item)
    else
      table.insert(result, item)
      index_by_name[item.name] = #result
    end
  end

  return result
end

---Keep only the items visible in the given context.
---@param items ContextMenu.Item[]
---@param ctx ContextMenu.Context
---@return ContextMenu.Item[]
function M.filter(items, ctx)
  return vim.tbl_filter(function(item)
    if item.ft and #item.ft > 0 and not vim.tbl_contains(item.ft, ctx.ft) then
      return false
    end
    if item.not_ft and vim.tbl_contains(item.not_ft, ctx.ft) then
      return false
    end
    if item.filter_func and not item.filter_func(ctx) then
      return false
    end
    return true
  end, items)
end

---Stable sort: by `order` (lower first), then filetype-matching items first,
---then original insertion order.
---@param items ContextMenu.Item[]
---@param ctx ContextMenu.Context
---@return ContextMenu.Item[]
function M.sort(items, ctx)
  local decorated = {}
  for i, item in ipairs(items) do
    decorated[i] = { item = item, index = i }
  end

  table.sort(decorated, function(a, b)
    local a_order = a.item.order or DEFAULT_ORDER
    local b_order = b.item.order or DEFAULT_ORDER
    if a_order ~= b_order then
      return a_order < b_order
    end

    local a_matches = a.item.ft ~= nil and vim.tbl_contains(a.item.ft, ctx.ft)
    local b_matches = b.item.ft ~= nil and vim.tbl_contains(b.item.ft, ctx.ft)
    if a_matches ~= b_matches then
      return a_matches
    end

    return a.index < b.index
  end)

  return vim.tbl_map(function(d)
    return d.item
  end, decorated)
end

---Check an item's declared dependencies.
---@param item ContextMenu.Item
---@return boolean ok
---@return string? missing friendly message describing the missing dependency
function M.check_deps(item)
  for _, dep in ipairs(item.deps or {}) do
    local spec, msg
    if type(dep) == "table" then
      spec, msg = dep[1], dep.msg
    else
      spec = dep
    end

    local kind, name = spec:match("^(%w+):(.+)$")
    if not kind then
      kind, name = "lua", spec
    end

    local ok, default
    if kind == "exe" then
      ok = vim.fn.executable(name) == 1
      default = ("the `%s` executable is not installed (not found in $PATH)"):format(name)
    elseif kind == "cmd" then
      ok = vim.fn.exists(":" .. name) == 2
      default = ("the `:%s` command is not available (is the plugin installed?)"):format(name)
    else
      ok = pcall(require, name)
      default = ("the `%s` lua module is not installed"):format(name)
    end

    if not ok then
      return false, msg or default
    end
  end
  return true
end

---Filter then sort: the list a picker should display for this context.
---@param items ContextMenu.Item[]
---@param ctx ContextMenu.Context
---@return ContextMenu.Item[]
function M.resolve(items, ctx)
  return M.sort(M.filter(items, ctx), ctx)
end

return M
