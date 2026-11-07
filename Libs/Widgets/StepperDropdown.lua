--[[-----------------------------------------------------------------------------
StepperDropdown Widget
AceGUI select control using Blizzard's Settings dropdown with stepper arrows.
Use via `dialogControl = AOK.StepperDropdown.Type` on a 'select' option.
Layout: [Label] [icon] < [dropdown] > [button]; the icon and button show only
when the option sets `arg.icon` / `arg.button`.

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

local ATLAS_ON = 'auctionhouse-icon-favorite'
local ATLAS_OFF = 'auctionhouse-icon-favorite-off'
local MENU_MARK_SIZE = 14
local MENU_ENTRY_HEIGHT = 20
local MENU_MAX_VISIBLE_ENTRIES = 20

--- Fields and methods a wrapper widget may use
--- @class LibAceOptionsKit_StepperDropdownWidget : AceGUIWidget
--- @field frame Frame                              @Parent for a wrapper's extra regions
--- @field label FontString
--- @field control Frame                            @Re-anchored on OnWidthSet; re-anchor after it
--- @field dropdown DropdownButton
--- @field icon Button                              @Shown when the option sets arg.icon
--- @field button Button                            @Shown when the option sets arg.button
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

--- @param frame Frame
--- @return Button
local function CreateIcon(frame)
  local icon = CreateFrame('Button', nil, frame)
  icon.texture = icon:CreateTexture(nil, 'ARTWORK')
  icon.texture:SetAllPoints()
  icon:Hide()
  return icon
end

--- @param frame Frame
--- @return Button
local function CreateButton(frame)
  local template = 'RefreshButtonTemplate' --[[@as Template ]]
  local button = CreateFrame('Button', nil, frame, template)
  button:Hide()
  return button
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
--- @param self table
--- @return LibAceOptionsKit_IconArg? @nil unless the option sets arg.icon
local function IconArg(self)
  local arg = lib:ArgFor(self)
  return arg and arg.icon
end

--- @param self table
--- @return LibAceOptionsKit_ButtonArg? @nil unless the option sets arg.button
local function ButtonArg(self)
  local arg = lib:ArgFor(self)
  return arg and arg.button
end

--- @param icon LibAceOptionsKit_IconArg
--- @return string, string @The on and off atlases
local function Atlases(icon) return icon.atlasOn or ATLAS_ON, icon.atlasOff or ATLAS_OFF end

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

--- Shows the icon's state for the selected value
--- @param self table
local function RefreshIcon(self)
  local icon = IconArg(self)
  if not icon then return end
  local atlasOn, atlasOff = Atlases(icon)
  self.icon.texture:SetAtlas(icon.get() and atlasOn or atlasOff)
  self.icon:SetHighlightAtlas(atlasOff, 'ADD')
end

--- @param self table
local function Refresh(self)
  if self.dropdown:IsShown() then self.dropdown:GenerateMenu() end
end

--- @param self table
local function SetupMenu(self)
  local function IsSelected(key) return key == self.value end
  local function SetSelected(key)
    if self.disabled or key == self.value then return end
    self.value = key
    self:Fire('OnValueChanged', key)
    RefreshIcon(self)
  end
  self.dropdown:SetupMenu(function(_, root)
    root:SetScrollMode(MENU_ENTRY_HEIGHT * MENU_MAX_VISIBLE_ENTRIES)
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
--- @param context ScriptRegion                       @The part the tooltip shows beside
--- @param tooltip (string|fun(tooltip: GameTooltip))? @Nothing shows if nil
local function ShowTooltip(self, context, tooltip)
  if not tooltip then return end
  GameTooltip:SetOwner(context, 'ANCHOR_NONE')
  lib:AnchorTooltip(self, GameTooltip, context)
  if type(tooltip) == 'function' then
    tooltip(GameTooltip)
  else
    GameTooltip:SetText(tooltip)
  end
  GameTooltip:Show()
end

--- Undo line fonts a tooltip set; the lines are shared
local function HideTooltip()
  for i = 1, GameTooltip:NumLines() do
    local line = _G['GameTooltipTextLeft' .. i]
    line:SetFontObject(i == 1 and GameTooltipHeaderText or GameTooltipText)
  end
  GameTooltip:Hide()
end

--- @param self table
local function Dropdown_OnEnter(self) ShowTooltip(self, self.dropdown, lib:DropdownTooltip(self)) end

--- @param self table
local function Icon_OnClick(self)
  local icon = IconArg(self)
  if self.disabled or not icon then return end
  icon.set(not icon.get())
  RefreshIcon(self)
  Refresh(self)
end

--- @param self table
local function Icon_OnEnter(self)
  local icon = IconArg(self)
  ShowTooltip(self, self.icon, icon and icon.tooltip)
end

--- @param self table
local function Button_OnClick(self)
  local button = ButtonArg(self)
  if button then button.onClick() end
end

--- @param self table
local function Button_OnEnter(self)
  local button = ButtonArg(self)
  ShowTooltip(self, self.button, button and button.tooltip)
end

--[[-----------------------------------------------------------------------------
Layout
-------------------------------------------------------------------------------]]
--- Room the icon and button take from a 'fill' dropdown
--- @param self table
--- @param layout LibAceOptionsKit_Layout
--- @return number @px
local function ReservedWidth(self, layout)
  local reserved = 0
  if IconArg(self) then reserved = reserved + layout.icon.width + layout.icon.gap end
  if ButtonArg(self) then reserved = reserved + self.button:GetWidth() + layout.button.gap end
  return reserved
end

--- @param self table
--- @param layout LibAceOptionsKit_Layout
local function PlaceIcon(self, layout)
  local shown = IconArg(self) ~= nil
  self.icon:SetShown(shown)
  if not shown then return end
  self.icon:ClearAllPoints()
  self.icon:SetPoint('LEFT', self.label, 'RIGHT', layout.row.gap, 0)
  self.icon:SetSize(layout.icon.width, layout.icon.height)
  RefreshIcon(self)
end

--- After the icon if shown, else after the label
--- @param self table
--- @param layout LibAceOptionsKit_Layout
local function PlaceControl(self, layout)
  self.control:ClearAllPoints()
  if self.icon:IsShown() then
    self.control:SetPoint('LEFT', self.icon, 'RIGHT', layout.icon.gap, 0)
  else
    self.control:SetPoint('LEFT', self.label, 'RIGHT', layout.row.gap, 0)
  end
end

--- @param self table
--- @param layout LibAceOptionsKit_Layout
local function PlaceButton(self, layout)
  local shown = ButtonArg(self) ~= nil
  self.button:SetShown(shown)
  if not shown then return end
  self.button:ClearAllPoints()
  self.button:SetPoint('LEFT', self.control, 'RIGHT', layout.button.gap, 0)
end

--- Runs on each SetWidth; the option is only known by then. Pooled
--- widgets are reused, so the icon and button are shown or hidden here.
--- @param self table
--- @param width number @px
local function ApplyLayout(self, width)
  local layout = lib:Layout(self)
  local reserved = ReservedWidth(self, layout)
  local controlWidth = Util:ControlWidth(width, layout, layout.dropdown.width, reserved)
  self.label:SetWidth(layout.label.width)
  PlaceIcon(self, layout)
  PlaceControl(self, layout)
  self.control:SetSize(controlWidth, layout.dropdown.height)
  self.dropdown:SetWidth(controlWidth - self.steppersWidth)
  PlaceButton(self, layout)
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
    self.icon:SetEnabled(not disabled)
    self.button:SetEnabled(not disabled)
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
    RefreshIcon(self)
    Refresh(self)
  end,

  GetValue = function(self) return self.value end,

  --- Entries that `arg.icon.marks` picks get the icon's on-atlas
  GetEntryText = function(self, key)
    local text = self.list[key]
    local icon = IconArg(self)
    if not (icon and icon.marks and icon.marks(key)) then return text end
    local atlasOn = Atlases(icon)
    return text .. ' ' .. CreateAtlasMarkup(atlasOn, MENU_MARK_SIZE, MENU_MARK_SIZE)
  end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
--- @param widget table
local function HookExtras(widget)
  widget.icon:SetScript('OnClick', function() Icon_OnClick(widget) end)
  widget.icon:SetScript('OnEnter', function() Icon_OnEnter(widget) end)
  widget.icon:SetScript('OnLeave', HideTooltip)
  widget.button:SetScript('OnClick', function() Button_OnClick(widget) end)
  widget.button:HookScript('OnEnter', function() Button_OnEnter(widget) end)
  widget.button:HookScript('OnLeave', HideTooltip)
end

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
    icon = CreateIcon(frame),
    button = CreateButton(frame),
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
  HookExtras(widget)
  Util:HookRowHover(widget, control)
  control.Dropdown:HookScript('OnEnter', function() Dropdown_OnEnter(widget) end)
  control.Dropdown:HookScript('OnLeave', HideTooltip)

  return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(o.Type, Constructor, o.Version)
