-- pages/debug.lua
-- Debug page: buttons to trigger every modal type × severity.

return function(ctx)
  local Page    = ctx.Page
  local Section = ctx.Section
  local List    = ctx.List
  local Modal   = ctx.Modal
  local scale   = ctx.scale
  local theme   = ctx.theme

  local Debug = {}
  Debug.__index = Debug

  function Debug.new()
    local self = setmetatable({}, Debug)

    self._page = Page.new({
      hasHeader    = true,
      title        = "BTWifiSerial",
      hasPageTitle = true,
      pageTitle    = "Debug",
      hasFooter    = true,
    })

    local secY = self._page.contentY + scale.sy(8)
    self._section = Section.new({ title = "Modal Tests", y = secY })

    local secHdrH = theme.FH.body + scale.sy(14) + 1 + scale.sy(12)
    local listY   = secY + secHdrH
    local listH   = (self._page.contentY + self._page.contentH) - listY

    -- Each row triggers a different modal when ENTER is pressed
    self._list = List.new({
      y          = listY,
      h          = listH,
      selectable = true,
      showScroll = true,
      cols = {
        { key = "label" },
        { key = "action", xFrac = 0.65 },
      },
      rows = {
        { label = "Alert Success",   action = "Run", _id = "alert_success" },
        { label = "Alert Error",     action = "Run", _id = "alert_error" },
        { label = "Alert Warning",   action = "Run", _id = "alert_warning" },
        { label = "Alert Info",      action = "Run", _id = "alert_info" },
        { label = "Confirm Success", action = "Run", _id = "confirm_success" },
        { label = "Confirm Error",   action = "Run", _id = "confirm_error" },
        { label = "Info Loading",    action = "Run", _id = "info_loading" },
        { label = "Alert No Overlay", action = "Run", _id = "alert_no_overlay" },
      },
    })

    self._page:addChild(self._section)
    self._page:addChild(self._list)

    self._modal = nil  -- active modal (only one at a time)
    self._infoTimer = 0

    return self
  end

  function Debug:_openModal(id)
    local m
    if id == "alert_success" then
      m = Modal.new({
        type = "alert", severity = "success",
        title = "Success!", message = "Operation completed OK.",
      })
    elseif id == "alert_error" then
      m = Modal.new({
        type = "alert", severity = "error",
        title = "Error!", message = "Something went wrong.",
      })
    elseif id == "alert_warning" then
      m = Modal.new({
        type = "alert", severity = "warning",
        title = "Warning", message = "Proceed with caution.",
      })
    elseif id == "alert_info" then
      m = Modal.new({
        type = "alert", severity = "info",
        title = "Information", message = "Here is some info text.",
      })
    elseif id == "confirm_success" then
      m = Modal.new({
        type = "confirm", severity = "success",
        title = "Apply changes?",
        onResult = function(ok)
          -- result received, modal closed automatically
        end,
      })
    elseif id == "confirm_error" then
      m = Modal.new({
        type = "confirm", severity = "error",
        title = "Delete all data?",
        onResult = function(ok)
          -- result received
        end,
      })
    elseif id == "info_loading" then
      m = Modal.new({
        type = "info", severity = "info",
        title = "Loading...", message = "Please wait",
        onClose = function() end,
      })
      self._infoTimer = 150  -- auto-close after ~150 render cycles (~5s)
    elseif id == "alert_no_overlay" then
      m = Modal.new({
        type = "alert", severity = "warning",
        title = "No Overlay", message = "Content visible behind.",
        overlay = false,
      })
    end

    if m then
      m:show()
      self._modal = m
    end
  end

  function Debug:handleEvent(event)
    -- If a modal is open, it consumes all events
    if self._modal and self._modal:isOpen() then
      self._modal:handleEvent(event)
      return
    end

    -- List navigation
    if self._list:handleEvent(event) then
      -- Check if enter was pressed but list didn't start edit (no _options)
      -- We use enter directly to open modals
      return
    end

    -- ENTER on a row → open the corresponding modal
    local evEnter = (EVT_VIRTUAL_ENTER ~= nil and event == EVT_VIRTUAL_ENTER)
    if evEnter then
      local row = self._list:getSel()
      if row and row._id then
        self:_openModal(row._id)
      end
    end
  end

  function Debug:setPagination(n, total)
    self._page:setPagination(n, total)
  end

  function Debug:render()
    -- Auto-close info modal after timer expires
    if self._modal and self._modal:isOpen() and self._infoTimer > 0 then
      self._infoTimer = self._infoTimer - 1
      if self._infoTimer <= 0 then
        self._modal:close()
        self._modal = nil
      end
    end

    self._page:render()

    -- Render modal on top of everything
    if self._modal and self._modal:isOpen() then
      self._modal:render()
    end
  end

  return Debug
end
