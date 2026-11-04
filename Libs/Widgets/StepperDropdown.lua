--[[-----------------------------------------------------------------------------
StepperDropdown Widget
AceGUI select control using Blizzard's Settings dropdown with stepper arrows.
Use via `dialogControl = AOK.StepperDropdown.Type` on a 'select' option.

The stepper control is built in Lua, not from an XML template, so a newer
embedded copy can replace it.
-------------------------------------------------------------------------------]]
local lib = LibAceOptionsKit
local AceGUI = LibStub('AceGUI-3.0')
local Util = lib.O.WidgetUtil
local p, t = lib:log('StepperDropdown')

--- @type LibAceOptionsKit_WidgetInfo
local o = { Type = 'LibAceOptionsKit_StepperDropdown', Version = lib.MINOR }; lib.O.StepperDropdown = o
-- Public alias: AOK.StepperDropdown.Type in dialogControl
lib.StepperDropdown = o

--- Fields and methods a wrapper widget may use
--- @class LibAceOptionsKit_StepperDropdownWidget : AceGUIWidget
--- @field frame Frame                              @Parent for a wrapper's extra regions
--- @field label FontString
--- @field control Frame                            @Re-anchored on OnWidthSet; re-anchor after it
--- @field dropdown DropdownButton
--- @field GetEntryText fun(self, key: any): string @Override to decorate menu entries

--[[-----------------------------------------------------------------------------
Stepper Control
-------------------------------------------------------------------------------]]
--- The template's OnLoad ran without atlases; apply them now
--- @param parent Frame
--- @param atlas string
--- @return Button
local function CreateStepperArrow(parent, atlas)
  local template = 'WowStyle2IconButtonTemplate' --[[@as Template ]]
  local button = CreateFrame('Button', nil, parent, template)
  button.normalAtlas, button.disabledAtlas = atlas, atlas .. '-disabled'
  button:OnButtonStateChanged()
  return button
end

--- Mixin OnLoad anchors the arrows to Dropdown, so it runs last
--- @param parent Frame
--- @return Frame
local function CreateStepperControl(parent)
  local control = CreateFrame('Frame', nil, parent)
  control:SetSize(200, 26)
  local template = 'WowStyle2DropdownTemplate' --[[@as Template ]]
  control.Dropdown = CreateFrame('DropdownButton', nil, control, template)
  control.Dropdown:SetPoint('CENTER')
  control.IncrementButton = CreateStepperArrow(control, 'common-dropdown-icon-next')
  control.DecrementButton = CreateStepperArrow(control, 'common-dropdown-icon-back')
  Mixin(control, DropdownWithSteppersMixin)
  -- Closes the gap between the arrows and the dropdown
  control.decrementOffsetX, control.incrementOffsetX = -2, 2
  control:OnLoad()
  return control
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
--- @param list table<any, string>
--- @return any[] @Keys sorted by their display text
local function SortedKeys(list)
  local keys = {}
  for k in pairs(list) do
    table.insert(keys, k)
  end
  table.sort(keys, function(a, b) return tostring(list[a]) < tostring(list[b]) end)
  return keys
end

--- @param self table
local function SetupMenu(self)
  local function IsSelected(key) return key == self.value end
  local function SetSelected(key)
    if self.disabled or key == self.value then return end
    self.value = key
    self:Fire('OnValueChanged', key)
  end
  self.dropdown:SetupMenu(function(_, root)
    for _, key in ipairs(self.order) do
      root:CreateRadio(self:GetEntryText(key), IsSelected, SetSelected, key)
    end
  end)
  -- The closed dropdown shows the plain value, not menu decorations
  self.dropdown:SetSelectionTranslator(function(selection) return self.list[selection.data] end)
end

--- Blizzard uses TOOLTIP strata only if the owner has it
--- @param dropdown DropdownButton
local function OpenMenuAboveDialogs(dropdown)
  local openMenu = dropdown.OpenMenu
  function dropdown:OpenMenu()
    local strata = self:GetFrameStrata()
    self:SetFrameStrata('TOOLTIP')
    openMenu(self)
    self:SetFrameStrata(strata)
  end
end

--- @param self table
local function Refresh(self)
  if self.dropdown:IsShown() then self.dropdown:GenerateMenu() end
end

--- Arrow widths plus the gaps from Blizzard's OnLoad
--- @param control Frame
--- @return number @px
local function SteppersWidth(control)
  local back, forward = control.DecrementButton, control.IncrementButton
  local _, _, _, backX = back:GetPoint()
  local _, _, _, forwardX = forward:GetPoint()
  return back:GetWidth() - backX + forward:GetWidth() + forwardX
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
--- @param self table
local function Dropdown_OnEnter(self)
  local tooltip = lib:DropdownTooltip(self)
  if not tooltip then return end
  GameTooltip:SetOwner(self.dropdown, 'ANCHOR_NONE')
  lib:AnchorTooltip(self, GameTooltip, self.dropdown)
  if type(tooltip) == 'function' then
    tooltip(GameTooltip)
  else
    GameTooltip:SetText(tooltip)
  end
  GameTooltip:Show()
end

--- Undo line fonts a tooltip set; the lines are shared
local function Dropdown_OnLeave()
  for i = 1, GameTooltip:NumLines() do
    local line = _G['GameTooltipTextLeft' .. i]
    line:SetFontObject(i == 1 and GameTooltipHeaderText or GameTooltipText)
  end
  GameTooltip:Hide()
end

--- Runs on each SetWidth; the option is only known by then
--- @param self table
--- @param width number @px
local function ApplyLayout(self, width)
  local layout = lib:Layout(self)
  local controlWidth = Util:ControlWidth(width, layout, layout.dropdown.width)
  self.label:SetWidth(layout.label.width)
  self.control:ClearAllPoints()
  self.control:SetPoint('LEFT', self.label, 'RIGHT', layout.row.gap, 0)
  self.control:SetSize(controlWidth, layout.dropdown.height)
  self.dropdown:SetWidth(controlWidth - self.steppersWidth)
  self:SetHeight(layout.row.height)
  Util:PlaceRowHighlight(self, layout)
  Util:LimitHoverToLabel(self, layout.label.width)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
  OnAcquire = function(self)
    self.hover:Hide()
    self.list, self.order, self.value = {}, {}, nil
    self:SetWidth(200)
    self:SetDisabled(false)
  end,

  OnRelease = function(self)
    self.dropdown:CloseMenu()
    self.list, self.order, self.value = {}, {}, nil
  end,

  OnWidthSet = ApplyLayout,

  SetLabel = function(self, text) self.label:SetText(text) end,

  SetDisabled = function(self, disabled)
    self.disabled = disabled
    self.control:SetEnabled(not disabled)
    local color = disabled and GRAY_FONT_COLOR or NORMAL_FONT_COLOR
    self.label:SetTextColor(color:GetRGB())
  end,

  SetList = function(self, list, order)
    self.list = list or {}
    self.order = order or SortedKeys(self.list)
    Refresh(self)
  end,

  SetValue = function(self, value)
    self.value = value
    Refresh(self)
  end,

  GetValue = function(self) return self.value end,

  GetEntryText = function(self, key) return self.list[key] end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
  local frame = CreateFrame('Frame', nil, UIParent)
  frame:EnableMouse(true)

  local label = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  label:SetPoint('LEFT')
  label:SetJustifyH('LEFT')

  local control = CreateStepperControl(frame)

  local widget = {
    label = label,
    hover = Util:CreateRowHighlight(frame),
    control = control,
    dropdown = control.Dropdown,
    steppersWidth = SteppersWidth(control),
    list = {},
    order = {},
    alignoffset = 30,
    frame = frame,
    type = o.Type,
  }
  for method, func in pairs(methods) do
    widget[method] = func
  end
  OpenMenuAboveDialogs(widget.dropdown)
  SetupMenu(widget)
  Util:HookRowHover(widget, control)
  control.Dropdown:HookScript('OnEnter', function() Dropdown_OnEnter(widget) end)
  control.Dropdown:HookScript('OnLeave', Dropdown_OnLeave)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(o.Type, Constructor, o.Version)
