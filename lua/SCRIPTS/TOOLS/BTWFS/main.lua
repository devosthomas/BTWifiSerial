-- main.lua  –  EdgeTX Tools script
-- BTWifiSerial – BTWFS tool entry point

-- ── Module base path (folder where this file lives) ────────────────
-- loadScript() requires absolute paths on the radio SD card.
-- BTWFS scripts live at /SCRIPTS/TOOLS/BTWFS/
local BASE = "/SCRIPTS/TOOLS/BTWFS"

-- ── Load shared libs ───────────────────────────────────────────────
local scale = loadScript(BASE .. "/lib/scale.lua")()
local theme = loadScript(BASE .. "/lib/theme.lua")()

-- ── Build component context (injected into every component) ────────
local ctx = { scale = scale, theme = theme }

-- ── Load component classes ─────────────────────────────────────────
-- loadScript(path)  → chunk function
-- ()                → executes chunk, returns the factory function(ctx)
-- (ctx)             → executes factory, returns the class table
local Label     = loadScript(BASE .. "/components/label.lua")()(ctx)
ctx.Label       = Label

local Header    = loadScript(BASE .. "/components/header.lua")()(ctx)
ctx.Header      = Header

local PageTitle = loadScript(BASE .. "/components/page_title.lua")()(ctx)
ctx.PageTitle   = PageTitle

local Footer    = loadScript(BASE .. "/components/footer.lua")()(ctx)
ctx.Footer      = Footer

local Section   = loadScript(BASE .. "/components/section.lua")()(ctx)
ctx.Section     = Section

local List      = loadScript(BASE .. "/components/list.lua")()(ctx)
ctx.List        = List

local ChannelBar = loadScript(BASE .. "/components/channel_bar.lua")()(ctx)
ctx.ChannelBar   = ChannelBar

local Grid       = loadScript(BASE .. "/components/grid.lua")()(ctx)
ctx.Grid         = Grid

local Page      = loadScript(BASE .. "/components/page.lua")()(ctx)
ctx.Page        = Page

local Button    = loadScript(BASE .. "/components/button.lua")()(ctx)
ctx.Button      = Button

local Loading   = loadScript(BASE .. "/components/loading.lua")()(ctx)
ctx.Loading     = Loading

local Modal     = loadScript(BASE .. "/components/modal.lua")()(ctx)
ctx.Modal       = Modal

-- ── Load pages ─────────────────────────────────────────────────────
local Dashboard = loadScript(BASE .. "/pages/dashboard.lua")()(ctx)
local Settings  = loadScript(BASE .. "/pages/settings.lua")()(ctx)
local DebugPage = loadScript(BASE .. "/pages/debug.lua")()(ctx)

-- ── Navigator ──────────────────────────────────────────────────────
-- pages: ordered array of page instances. Add/remove at will.
-- The footer pagination updates automatically.
local pages    = {}
local pageIdx  = 1

local function currentPage()
  return pages[pageIdx]
end

local function navigateTo(idx)
  pageIdx = ((idx - 1) % #pages) + 1   -- wrap around
  currentPage():setPagination(pageIdx, #pages)
end

local function init()
  pages[1] = Dashboard.new()
  pages[2] = Settings.new()
  pages[3] = DebugPage.new()
  navigateTo(1)
end

local function run(event, touchState)
  -- Page-button navigation (consume event before passing to page)
  if EVT_VIRTUAL_NEXT_PAGE ~= nil and event == EVT_VIRTUAL_NEXT_PAGE then
    navigateTo(pageIdx + 1)
    event = 0
  elseif EVT_VIRTUAL_PREV_PAGE ~= nil and event == EVT_VIRTUAL_PREV_PAGE then
    navigateTo(pageIdx - 1)
    event = 0
  end

  -- Delegate remaining events to the current page (if it handles them)
  local pg = currentPage()
  if event ~= 0 and pg.handleEvent then
    pg:handleEvent(event)
  end

  pg:render()
  return 0
end

local function background()
end

return { init = init, run = run, background = background }
