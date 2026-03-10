-- pages/settings.lua
-- Settings page.

return function(ctx)
  local Page    = ctx.Page
  local Section = ctx.Section
  local List    = ctx.List
  local scale   = ctx.scale

  local Settings = {}
  Settings.__index = Settings

  -- Settings rows: each row has _options for the editable value column.
  local function defaultRows()
    return {
      { label = "AP Mode",      value = "On",         _options = { "On", "Off" } },
      { label = "Device Mode",  value = "Trainer IN",  _options = { "Trainer IN", "Trainer OUT", "Telemetry" } },
      { label = "Telem Output", value = "WiFi",        _options = { "WiFi", "BLE", "Off" } },
      { label = "Mirror Baud",  value = "57600",       _options = { "57600", "115200" } },
      { label = "Trainer Map",  value = "GV",          _options = { "GV", "TR" } },
    }
  end

  function Settings.new()
    local self = setmetatable({}, Settings)

    self._page = Page.new({
      hasHeader    = true,
      title        = "BTWifiSerial",
      hasPageTitle = true,
      pageTitle    = "Settings",
      hasFooter    = true,
    })

    local secY  = self._page.contentY + scale.sy(8)
    self._section = Section.new({ title = "Configuration", y = secY })

    -- List fills all remaining height down to the footer
    local listY = self._section.contentY
    local listH = (self._page.contentY + self._page.contentH) - listY

    self._list = List.new({
      y          = listY,
      h          = listH,
      selectable = true,
      editCol    = 2,          -- value column is editable
      onEdit     = function(row, key, oldVal, newVal)
        -- TODO: send command to ESP32 when serial is wired
      end,
      cols = {
        { key = "label" },
        { key = "value", xFrac = 0.54 },
      },
      rows = defaultRows(),
    })

    self._page:addChild(self._section)
    self._page:addChild(self._list)

    return self
  end

  function Settings:handleEvent(event)
    -- List handles selection, edit mode enter/exit, option cycling
    if self._list:handleEvent(event) then return true end
    return false
  end

  function Settings:setPagination(n, total)
    self._page:setPagination(n, total)
  end

  function Settings:render()
    self._page:render()
  end

  function Settings:contentY()
    return self._page.contentY
  end

  return Settings
end
