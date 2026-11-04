--[[-----------------------------------------------------------------------------
WidgetUtil: row hover and tooltip helpers shared by the library's widgets.
-------------------------------------------------------------------------------]]
local lib = LibAceOptionsKit
local ACD = LibStub('AceConfigDialog-3.0')

--- Internal to the library's widgets; not a public API
--- @class LibAceOptionsKit_WidgetUtil
local o = {}; lib.O.WidgetUtil = o

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Same look as the hover highlight on Blizzard's Settings rows
--- @param frame Frame
--- @return Texture @Placed by PlaceRowHighlight
function o:CreateRowHighlight(frame)
  local hover = frame:CreateTexture(nil, 'BACKGROUND')
  hover:SetColorTexture(1, 1, 1, 0.1)
  hover:Hide()
  return hover
end

--- @param widget table
--- @param layout LibAceOptionsKit_Layout
function o:PlaceRowHighlight(widget, layout)
  local inset = layout.row.highlight
  widget.hover:ClearAllPoints()
  widget.hover:SetPoint('TOPLEFT', inset.left, 0)
  widget.hover:SetPoint('BOTTOMRIGHT', inset.right, 0)
end

--- Only the row frame shows the highlight; all fire tooltips
--- @param widget table
--- @param control Frame   @Tooltip context for the extra regions
--- @param ... ScriptRegion @Parts of the control that also show the tooltip
function o:HookRowHover(widget, control, ...)
  local frame = widget.frame
  frame:HookScript('OnEnter', function() widget.hover:Show() end)
  frame:HookScript('OnLeave', function() widget.hover:Hide() end)
  for _, region in ipairs({ frame, ... }) do
    local context = region == frame and widget.label or control
    region:HookScript('OnEnter', function() self:FireEnter(widget, context) end)
    region:HookScript('OnLeave', function() widget:Fire('OnLeave') end)
  end
end

--- A 'fill' width takes what the row has left after the label
--- @param rowWidth number     @px
--- @param layout LibAceOptionsKit_Layout
--- @param width number|'fill' @The control's layout width
--- @param reserved? number    @px kept free at the row's right end
--- @return number             @px
function o:ControlWidth(rowWidth, layout, width, reserved)
  if width ~= 'fill' then return width end
  local used = layout.label.width + layout.row.gap + (reserved or 0)
  return math.max(0, rowWidth - used)
end

--- Label column only; the control handles its own hover
--- @param widget table
--- @param labelWidth number @px
function o:LimitHoverToLabel(widget, labelWidth)
  local rightInset = math.max(0, widget.frame:GetWidth() - labelWidth)
  widget.frame:SetHitRectInsets(0, rightInset, 0, 0)
end

--- Also moves AceConfigDialog's tooltip beside the context
--- @param widget AceGUIWidget
--- @param context ScriptRegion
function o:FireEnter(widget, context)
  widget:Fire('OnEnter')
  local tooltip = ACD.tooltip
  if not (tooltip:IsShown() and tooltip:GetOwner() == widget.frame) then return end
  lib:AnchorTooltip(widget, tooltip, context)
end
