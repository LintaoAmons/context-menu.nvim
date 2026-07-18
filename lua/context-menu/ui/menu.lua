---Right-click style picker: a floating menu at the cursor with inline
---expandable sub menus and fuzzy search.
---
---Keys:
---  j/k          move
---  <CR> / o     run item / toggle sub menu
---  l / <Right>  expand sub menu (or run leaf)
---  h / <Left>   collapse / jump to parent
---  <Tab>        toggle sub menu
---  /            fuzzy search all (nested) items
---  <Esc> / q    clear search / close
---While searching: type to filter, <C-n>/<C-p> or arrows to move, <CR>
---confirms the filter — focus returns to the list so j/k/o/<CR> can pick —
---and <Esc> discards the search and goes back to the tree.

local Item = require("context-menu.item")

local M = {}

local ns = vim.api.nvim_create_namespace("context-menu.menu")
local MAX_HEIGHT = 20

-- Pure helpers (exposed for tests) -------------------------------------------

---@class ContextMenu.MenuNode
---@field item ContextMenu.Item
---@field depth integer
---@field path string unique path of names, used as key for the expanded set
---@field children ContextMenu.MenuNode[]

---Build the node tree, filtering and sorting every level against the context.
---@param items ContextMenu.Item[]
---@param ctx ContextMenu.Context
---@return ContextMenu.MenuNode[]
function M.build_tree(items, ctx)
  local function build(list, depth, prefix)
    local nodes = {}
    for _, item in ipairs(Item.resolve(list, ctx)) do
      local path = prefix .. "/" .. item.name
      local node = { item = item, depth = depth, path = path, children = {} }
      if item.items and not item.action then
        node.children = build(item.items, depth + 1, path)
      end
      table.insert(nodes, node)
    end
    return nodes
  end
  return build(items, 0, "")
end

---Nodes currently visible in tree view, given the expanded set (DFS order).
---@param tree ContextMenu.MenuNode[]
---@param expanded table<string, boolean>
---@return ContextMenu.MenuNode[]
function M.visible_nodes(tree, expanded)
  local out = {}
  local function walk(nodes)
    for _, node in ipairs(nodes) do
      table.insert(out, node)
      if #node.children > 0 and expanded[node.path] then
        walk(node.children)
      end
    end
  end
  walk(tree)
  return out
end

---Every actionable leaf with a breadcrumb label, fuzzy-filtered by query.
---@param tree ContextMenu.MenuNode[]
---@param query string
---@return { node: ContextMenu.MenuNode, label: string }[]
function M.search_nodes(tree, query)
  local leaves = {}
  local function walk(nodes, crumbs)
    for _, node in ipairs(nodes) do
      if #node.children > 0 then
        walk(node.children, crumbs .. node.item.name .. " ▸ ")
      elseif node.item.action then
        table.insert(leaves, { node = node, label = crumbs .. node.item.name })
      end
    end
  end
  walk(tree, "")
  if query == "" then
    return leaves
  end
  -- Only hand plain data to matchfuzzy: nodes contain functions and
  -- mixed-key tables (e.g. deps) that cannot cross into Vimscript.
  local candidates = {}
  for i, leaf in ipairs(leaves) do
    candidates[i] = { label = leaf.label, idx = i }
  end
  return vim.tbl_map(function(m)
    return leaves[m.idx]
  end, vim.fn.matchfuzzy(candidates, query, { key = "label" }))
end

-- The picker ------------------------------------------------------------------

---@param entries ContextMenu.Item[]
---@param opts ContextMenu.PickerOpts
---@param on_choice fun(item: ContextMenu.Item?)
local function menu_picker(entries, opts, on_choice)
  local tree = M.build_tree(entries, opts.ctx)
  local expanded = {} ---@type table<string, boolean>
  local query = ""
  local searching = false -- true while the / prompt is capturing keys
  local sel = 1
  local rows = {} ---@type { text: string, node: ContextMenu.MenuNode?, hls: table }[]
  local done = false
  local flip = nil ---@type boolean? open downwards or upwards; decided once

  -- Anchor to the trigger position in absolute screen coordinates: once the
  -- float has focus, "cursor"-relative would mean the float's own cursor and
  -- the menu would drift on every re-render.
  local screen_row = vim.fn.screenrow()
  local screen_col = vim.fn.screencol()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "context-menu"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = screen_row,
    col = screen_col - 1,
    width = 1,
    height = 1,
    style = "minimal",
    border = "rounded",
    title = " " .. opts.prompt .. " ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].winhighlight = "Normal:NormalFloat,CursorLine:PmenuSel"
  vim.wo[win].wrap = false

  local function compute_rows()
    rows = {}
    if query ~= "" then
      for _, r in ipairs(M.search_nodes(tree, query)) do
        local crumb_len = #r.label - #r.node.item.name
        table.insert(rows, {
          text = r.label,
          node = r.node,
          hls = crumb_len > 0 and { { 0, crumb_len, "Comment" } } or {},
        })
      end
      if #rows == 0 then
        table.insert(rows, { text = "(no matches)", node = nil, hls = { { 0, 12, "Comment" } } })
      end
    else
      for _, node in ipairs(M.visible_nodes(tree, expanded)) do
        local has_children = #node.children > 0
        local icon = has_children and (expanded[node.path] and "▾ " or "▸ ") or "  "
        local indent = string.rep("  ", node.depth)
        table.insert(rows, {
          text = indent .. icon .. node.item.name,
          node = node,
          hls = has_children and { { #indent, #indent + #icon, "Special" } } or {},
        })
      end
    end
  end

  local function render()
    compute_rows()
    sel = math.max(1, math.min(sel, #rows))

    local lines = {}
    local width = vim.fn.strdisplaywidth(opts.prompt) + 4
    for _, r in ipairs(rows) do
      table.insert(lines, " " .. r.text .. " ")
      width = math.max(width, vim.fn.strdisplaywidth(r.text) + 2)
    end

    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, r in ipairs(rows) do
      for _, hl in ipairs(r.hls) do
        -- +1 byte for the leading padding space
        vim.api.nvim_buf_set_extmark(buf, ns, i - 1, hl[1] + 1, {
          end_col = hl[2] + 1,
          hl_group = hl[3],
        })
      end
    end

    -- Direction is decided once, on the first render; afterwards the height
    -- is clamped to the available space so the menu never moves.
    local space_below = vim.o.lines - screen_row - 3
    local space_above = screen_row - 3
    if flip == nil then
      flip = #lines + 2 > space_below and space_above > space_below
    end
    local height =
      math.max(1, math.min(#lines, MAX_HEIGHT, flip and space_above or space_below))
    local footer
    if searching then
      footer = { { " /" .. query .. "█ ", "Title" } }
    elseif query ~= "" then
      footer = { { " /" .. query .. " ", "Title" } }
    else
      footer = { { " / to search ", "Comment" } }
    end

    width = math.min(width, vim.o.columns - 4)
    vim.api.nvim_win_set_config(win, {
      relative = "editor",
      anchor = flip and "SW" or "NW",
      -- below the trigger line, or bottom edge just above it when flipped
      row = flip and screen_row - 1 or screen_row,
      col = math.max(0, math.min(screen_col - 1, vim.o.columns - width - 2)),
      width = width,
      height = height,
      footer = footer,
      footer_pos = "left",
    })
    vim.api.nvim_win_set_cursor(win, { sel, 0 })
  end

  local function close(choice)
    if done then
      return
    end
    done = true
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    vim.schedule(function()
      on_choice(choice)
    end)
  end

  local function current()
    -- The cursor is the source of truth: j/k/gg move it natively.
    if not done and vim.api.nvim_get_current_win() == win then
      sel = vim.api.nvim_win_get_cursor(win)[1]
    end
    return rows[sel] and rows[sel].node
  end

  ---Run the selected leaf, or toggle the selected sub menu.
  local function activate()
    local node = current()
    if not node then
      return
    end
    if node.item.action then
      close(node.item)
    elseif query == "" and #node.children > 0 then
      expanded[node.path] = not expanded[node.path] or nil
      render()
    end
  end

  local function expand()
    local node = current()
    if node and query == "" and #node.children > 0 then
      if expanded[node.path] then
        sel = math.min(sel + 1, #rows + 1) -- step into the first child
      else
        expanded[node.path] = true
      end
      render()
    else
      activate()
    end
  end

  local function collapse()
    local node = current()
    if not node or query ~= "" then
      return
    end
    local target = node.path
    if expanded[node.path] then
      expanded[node.path] = nil
    else
      target = node.path:match("^(.+)/[^/]+$")
      if not target then
        return
      end
      expanded[target] = nil
    end
    render()
    for i, r in ipairs(rows) do
      if r.node and r.node.path == target then
        sel = i
        vim.api.nvim_win_set_cursor(win, { sel, 0 })
        break
      end
    end
  end

  local function toggle()
    local node = current()
    if node and query == "" and #node.children > 0 then
      expanded[node.path] = not expanded[node.path] or nil
      render()
    end
  end

  local BS = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
  local UP = vim.api.nvim_replace_termcodes("<Up>", true, false, true)
  local DOWN = vim.api.nvim_replace_termcodes("<Down>", true, false, true)

  ---Live fuzzy search: consumes keys until <CR> (run) or <Esc> (back).
  local function search()
    searching = true
    while not done do
      render()
      vim.cmd("redraw")
      local ok, ch = pcall(vim.fn.getcharstr)
      if not ok or ch == "\27" then -- <Esc>: back to tree view
        query = ""
        sel = 1
        break
      elseif ch == "\r" or ch == "\n" then
        -- confirm the filter: back to normal navigation over the results
        break
      elseif ch == BS or ch == "\8" or ch == "\127" then
        query = vim.fn.strcharpart(query, 0, vim.fn.strchars(query) - 1)
        sel = 1
      elseif ch == "\21" then -- <C-u>: clear
        query = ""
        sel = 1
      elseif ch == "\14" or ch == DOWN then -- <C-n>
        sel = sel + 1
      elseif ch == "\16" or ch == UP then -- <C-p>
        sel = sel - 1
      elseif ch:byte(1) >= 32 and ch:byte(1) ~= 127 and ch:byte(1) ~= 128 then
        query = query .. ch
        sel = 1
      end
    end
    searching = false
    if not done then
      render()
    end
  end

  local function map(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true })
  end

  map("q", function()
    close(nil)
  end)
  map("<Esc>", function()
    if query ~= "" then
      query = ""
      sel = 1
      render()
    else
      close(nil)
    end
  end)
  map("<CR>", activate)
  map("o", activate)
  map("<LeftRelease>", activate)
  map("l", expand)
  map("<Right>", expand)
  map("h", collapse)
  map("<Left>", collapse)
  map("<Tab>", toggle)
  map("/", search)

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    callback = function()
      close(nil)
    end,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    pattern = tostring(win),
    once = true,
    callback = function()
      close(nil)
    end,
  })

  render()
end

return setmetatable(M, {
  __call = function(_, ...)
    return menu_picker(...)
  end,
})
