-- pages/dashboard.lua
-- Dashboard page: System info + Channel bars.

return function(ctx)
  local Page       = ctx.Page
  local Section    = ctx.Section
  local List       = ctx.List
  local Grid       = ctx.Grid
  local ChannelBar = ctx.ChannelBar
  local scale      = ctx.scale

  local Dashboard = {}
  Dashboard.__index = Dashboard

  function Dashboard.new()
    local self = setmetatable({}, Dashboard)
    local theme = ctx.theme

    self._page = Page.new({
      hasHeader    = true,
      title        = "BTWifiSerial",
      hasPageTitle = true,
      pageTitle    = "Dashboard",
      hasFooter    = true,
    })

    -- ── Proportional layout ───────────────────────────────────────
    local contentY = self._page.contentY
    local contentH = self._page.contentH
    local gap      = scale.sy(8)                                       -- top & inter-section gap
    local bottomGap = scale.sy(10)                                     -- keep space above footer
    local secHdrH  = theme.FH.body + scale.sy(14) + 1 + scale.sy(12)   -- matches Section defaults
    local PAD      = scale.sx(17)                                      -- section title x

    -- Channels grid has a fixed required height (4 rows)
    local chCellH    = scale.sy(25)
    local chGapY     = scale.sy(1)
    local chContentH = 4 * chCellH + 3 * chGapY

    -- System list gets the remaining vertical space
    local sysContentH = contentH - gap - secHdrH - gap - secHdrH - chContentH - bottomGap

    -- ── System section ────────────────────────────────────────────
    local sysSecY  = contentY + gap
    self._sysSection = Section.new({ title = "System", y = sysSecY })

    local sysListY = sysSecY + secHdrH
    self._list = List.new({
      y          = sysListY,
      h          = sysContentH,
      selectable = true,
      showScroll = true,
      cols = {
        { key = "label" },
        { key = "value", xFrac = 0.54 },
      },
      rows = {
        { label = "Device Mode",  value = "--" },
        { label = "BT Name",      value = "--" },
        { label = "AP Mode",      value = "--" },
        { label = "Telem Output", value = "--" },
        { label = "Firmware",     value = "--" },
      },
    })

    -- ── Channels section ──────────────────────────────────────────
    local chSecY   = sysListY + sysContentH + gap
    self._chSection = Section.new({ title = "Channels", y = chSecY })

    local chGridY  = chSecY + secHdrH

    self._grid = Grid.new({
      x     = PAD,
      y     = chGridY,
      w     = LCD_W - 2 * PAD,
      cols  = 2,
      cellH = chCellH,
      gapX  = scale.sx(16),
      gapY  = chGapY,
    })

    -- Create 8 channel bars in row-major order:
    --   col 0: CH1-CH4    col 1: CH5-CH8
    self._bars = {}
    for i = 1, 8 do
      local col = (i <= 4) and 0 or 1
      local row = (i <= 4) and (i - 1) or (i - 5)
      local cx, cy, cw = self._grid:cellPos(col, row)
      self._bars[i] = ChannelBar.new({
        x     = cx,
        y     = cy,
        w     = cw,
        h     = chCellH,
        label = "CH" .. i,
      })
    end
    self._grid:setChildren(self._bars)

    self._page:addChild(self._sysSection)
    self._page:addChild(self._list)
    self._page:addChild(self._chSection)
    self._page:addChild(self._grid)

    return self
  end

  -- Call this each frame with live state data (5-row table)
  function Dashboard:updateInfo(data)
    self._list:setRows(data)
  end

  -- Call with array of 8 channel values (-1024..+1024)
  function Dashboard:updateChannels(vals)
    for i = 1, 8 do
      if vals[i] and self._bars[i] then
        self._bars[i]:setValue(vals[i])
      end
    end
  end

  function Dashboard:handleEvent(event)
    self._list:handleEvent(event)
  end

  function Dashboard:setPagination(n, total)
    self._page:setPagination(n, total)
  end

  function Dashboard:render()
    self._page:render()
  end

  function Dashboard:contentY()
    return self._page.contentY
  end

  return Dashboard
end
