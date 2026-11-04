--[[-----------------------------------------------------------------------------
LibAceOptionsKit: Blizzard Settings-style AceGUI widgets for AceConfig
options tables, used through an option's dialogControl.
-------------------------------------------------------------------------------]]
local MAJOR, MINOR = 'LibAceOptionsKit-1.0', 1

--- AceGUI type name and version, for an option's dialogControl
--- @class LibAceOptionsKit_WidgetInfo
--- @field Type string
--- @field Version number @The library's minor that registered it

--- @class LibAceOptionsKit-1.0
--- @field SettingsCheckbox LibAceOptionsKit_WidgetInfo
--- @field StepperSlider LibAceOptionsKit_WidgetInfo
--- @field StepperDropdown LibAceOptionsKit_WidgetInfo
local lib = LibStub:NewLibrary(MAJOR, MINOR); if not lib then return end
