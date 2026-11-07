--[[-----------------------------------------------------------------------------
LibAceOptionsKit: Blizzard Settings-style AceGUI widgets for AceConfig
options tables, used through an option's dialogControl.
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibAceOptionsKit-1.0', 3

--- AceGUI type name and version, for an option's dialogControl
--- @class LibAceOptionsKit_WidgetInfo
--- @field Type string
--- @field Version number @The library's minor that registered it

--- Library objects, by module name
--- @class LibAceOptionsKit_Objects
--- @field SettingsCheckbox LibAceOptionsKit_WidgetInfo
--- @field StepperDropdown LibAceOptionsKit_WidgetInfo
--- @field StepperSlider LibAceOptionsKit_WidgetInfo
--- @field WidgetUtil LibAceOptionsKit_WidgetUtil

--- @class LibAceOptionsKit-1.0
--- @field MINOR number @The newest loaded copy's minor
--- @field O LibAceOptionsKit_Objects
--- @field SettingsCheckbox LibAceOptionsKit_WidgetInfo
--- @field StepperSlider LibAceOptionsKit_WidgetInfo
--- @field StepperDropdown LibAceOptionsKit_WidgetInfo
local lib = LibStub:NewLibrary(MAJOR, MINOR); if not lib then return end
lib.MINOR = MINOR
lib.O = lib.O or {}

--- @type LibAceOptionsKit-1.0
LibAceOptionsKit = lib

--[[-----------------------------------------------------------------------------
Logger and Tracer: no-ops in releases; Libs/Developer/DeveloperSetup.lua
overrides them with LibPrettyPrint and LibTraceKit ones.
-------------------------------------------------------------------------------]]
--- @alias LibAceOptionsKit_PrintFn fun(...: any) @Prints like print()
--- @alias LibAceOptionsKit_TraceFn fun(...: any) @Traces to /etrace

--- @class LibAceOptionsKit_LogHolder
--- @field printer fun(moduleName: string): LibAceOptionsKit_PrintFn
--- @field tracer fun(moduleName: string): LibAceOptionsKit_TraceFn

local function noop() return function() end end

-- Kept across upgrades: Libs/Developer overrides it
--- @type LibAceOptionsKit_LogHolder
lib.logHolder = lib.logHolder or { printer = noop, tracer = noop }

--- Returns the print and trace functions
--- ### Example:
--- ```lua
--- local p, t = lib:log('StepperSlider')
--- ```
--- @param moduleName string @The module name or any general prefix
--- @return LibAceOptionsKit_PrintFn
--- @return LibAceOptionsKit_TraceFn
function lib:log(moduleName)
  local h = self.logHolder
  return h.printer(moduleName), h.tracer(moduleName)
end

--[[-----------------------------------------------------------------------------
Layout Defaults: sizes for the widgets' rows, in three layers, each
overriding the one before: library defaults, the addon's defaults
(SetDefaults, keyed by AceConfig app name), and the option's `arg.layout`.
-------------------------------------------------------------------------------]]
--- @type LibAceOptionsKit_Layout
local DEFAULT_LAYOUT = {
  row = { height = 30, gap = 0, highlight = { left = -10, right = -5 } },
  label = { width = 150 },
  dropdown = { width = 260, height = 30 },
  checkbox = { width = 30, height = 30 },
  slider = { width = 220, height = 19, valueWidth = 45 },
  icon = { width = 18, height = 18, gap = 4 },
  button = { gap = 4 },
  tooltip = { x = 20, y = 20 },
}

-- Kept across upgrades: addons set them while loading
--- @type table<string, LibAceOptionsKit_Layout>
lib.appDefaults = lib.appDefaults or {}

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Places the tooltip the way the library's widgets do
--- @param widget AceGUIWidget
--- @param tooltip GameTooltip
--- @param context ScriptRegion @The part the tooltip shows beside
function lib:AnchorTooltip(widget, tooltip, context)
  local offset = self:Layout(widget).tooltip
  tooltip:SetAnchorType('ANCHOR_NONE')
  tooltip:ClearAllPoints()
  tooltip:SetPoint('BOTTOMLEFT', context, 'TOPRIGHT', offset.x, offset.y)
end

--- @param widget AceGUIWidget
--- @return (string|fun(tooltip: GameTooltip))? @nil if the option sets none
function lib:DropdownTooltip(widget)
  local arg = self:ArgFor(widget)
  local tooltip = arg and arg.tooltip
  return type(tooltip) == 'table' and tooltip.dropdown or nil
end

--- Merges into the app's defaults; doesn't replace them
--- @param appName string       @The AceConfig app name
--- @param layout LibAceOptionsKit_Layout
function lib:SetDefaults(appName, layout)
  self.appDefaults[appName] = self:_Overlay(self.appDefaults[appName] or {}, layout)
end

--- All three layers merged into a new table
--- @param widget AceGUIWidget
--- @return LibAceOptionsKit_Layout
function lib:Layout(widget)
  local appDefaults = self.appDefaults[widget:GetUserData('appName')] or {}
  local arg = self:ArgFor(widget)
  local layout = self:_Overlay(self:_Overlay({}, DEFAULT_LAYOUT), appDefaults)
  return self:_Overlay(layout, arg and arg.layout or {})
end

--- The option's `arg`, as AceConfigDialog passed it to the widget
--- @param widget AceGUIWidget
--- @return LibAceOptionsKit_Arg? @nil unless the option's `arg` is a table
function lib:ArgFor(widget)
  local option = widget:GetUserData('option') --[[@as LibAceOptionsKit_Option?]]
  local arg = option and option.arg
  return type(arg) == 'table' and arg or nil
end

--- @private
--- @deprecated Use lib:ArgFor; kept for callers of 2026.11.2
--- @param widget AceGUIWidget
--- @return LibAceOptionsKit_Arg?
function lib:_ArgFor(widget) return self:ArgFor(widget) end

--- @private
--- Deep-copies source's keys into target; tables merge per key
--- @param target table
--- @param source table
--- @return table @target
function lib:_Overlay(target, source)
  for key, value in pairs(source) do
    if type(value) == 'table' then
      local nested = type(target[key]) == 'table' and target[key] or {}
      target[key] = self:_Overlay(nested, value)
    else
      target[key] = value
    end
  end
  return target
end
