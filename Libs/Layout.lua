--[[-----------------------------------------------------------------------------
Layout: sizes for the widgets' rows, in three layers, each overriding the
one before: library defaults, the addon's defaults (SetDefaults, keyed by
AceConfig app name), and the option's `arg.layout`.
-------------------------------------------------------------------------------]]
local lib = LibStub('LibAceOptionsKit-1.0')

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- An AceConfig option whose `arg` the library's widgets read
--- @class LibAceOptionsKit_Option : AceConfig.OptionsTable
--- @field arg? LibAceOptionsKit_Arg

--- Per-option settings passed through AceConfig's `arg`
--- @class LibAceOptionsKit_Arg
--- @field layout? LibAceOptionsKit_Layout
--- @field tooltip? LibAceOptionsKit_TooltipArg

--- Tooltip content, keyed by the part it shows over
--- @class LibAceOptionsKit_TooltipArg
--- @field dropdown? string|fun(tooltip: GameTooltip) @Shown over the dropdown, not its arrows

--- @class LibAceOptionsKit_Size
--- @field width? number  @px
--- @field height? number @px

--- Hover highlight insets from the row's left and right edges
--- @class LibAceOptionsKit_RowHighlight
--- @field left? number  @px
--- @field right? number @px

--- AceGUI sets the row width; the option's `width` sizes it
--- @class LibAceOptionsKit_RowLayout
--- @field height? number @px
--- @field gap? number    @px between label and control
--- @field highlight? LibAceOptionsKit_RowHighlight

--- Width includes the stepper arrows; 'fill' takes the rest of the row
--- @class LibAceOptionsKit_DropdownLayout
--- @field width? number|'fill' @px
--- @field height? number       @px

--- Width excludes the value label; 'fill' takes the rest of the row
--- @class LibAceOptionsKit_SliderLayout
--- @field width? number|'fill' @px
--- @field height? number       @px
--- @field valueWidth? number   @px kept for the value label by 'fill'

--- Tooltip BOTTOMLEFT offset from its context's TOPRIGHT
--- @class LibAceOptionsKit_TooltipLayout
--- @field x? number @px
--- @field y? number @px

--- @class LibAceOptionsKit_Layout
--- @field row? LibAceOptionsKit_RowLayout
--- @field label? LibAceOptionsKit_Size
--- @field dropdown? LibAceOptionsKit_DropdownLayout
--- @field checkbox? LibAceOptionsKit_Size
--- @field slider? LibAceOptionsKit_SliderLayout
--- @field tooltip? LibAceOptionsKit_TooltipLayout

--[[-----------------------------------------------------------------------------
Defaults
-------------------------------------------------------------------------------]]
--- @type LibAceOptionsKit_Layout
local DEFAULT_LAYOUT = {
  row = { height = 30, gap = 0, highlight = { left = -10, right = -5 } },
  label = { width = 150 },
  dropdown = { width = 260, height = 30 },
  checkbox = { width = 30, height = 30 },
  slider = { width = 220, height = 19, valueWidth = 45 },
  tooltip = { x = 20, y = 20 },
}

-- Kept across upgrades: addons set them while loading
--- @type table<string, LibAceOptionsKit_Layout>
lib.appDefaults = lib.appDefaults or {}

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- Deep-copies source's keys into target; tables merge per key
--- @param target table
--- @param source table
--- @return table @target
local function Overlay(target, source)
  for key, value in pairs(source) do
    if type(value) == 'table' then
      local nested = type(target[key]) == 'table' and target[key] or {}
      target[key] = Overlay(nested, value)
    else
      target[key] = value
    end
  end
  return target
end

--- @param widget AceGUIWidget
--- @return LibAceOptionsKit_Arg? @nil unless the option's `arg` is a table
local function ArgFor(widget)
  local option = widget:GetUserData('option') --[[@as LibAceOptionsKit_Option?]]
  local arg = option and option.arg
  return type(arg) == 'table' and arg or nil
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Merges into the app's defaults; doesn't replace them
--- @param appName string       @The AceConfig app name
--- @param layout LibAceOptionsKit_Layout
function lib:SetDefaults(appName, layout)
  self.appDefaults[appName] = Overlay(self.appDefaults[appName] or {}, layout)
end

--- All three layers merged into a new table
--- @param widget AceGUIWidget
--- @return LibAceOptionsKit_Layout
function lib:Layout(widget)
  local appDefaults = self.appDefaults[widget:GetUserData('appName')] or {}
  local arg = ArgFor(widget)
  local layout = Overlay(Overlay({}, DEFAULT_LAYOUT), appDefaults)
  return Overlay(layout, arg and arg.layout or {})
end

--- @param widget AceGUIWidget
--- @return (string|fun(tooltip: GameTooltip))? @nil if the option sets none
function lib:DropdownTooltip(widget)
  local arg = ArgFor(widget)
  local tooltip = arg and arg.tooltip
  return type(tooltip) == 'table' and tooltip.dropdown or nil
end
