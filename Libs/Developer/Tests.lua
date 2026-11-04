--[[-----------------------------------------------------------------------------
Tests: the test dialog's options, every widget beside Ace's own.
Dev only, like Developer.lua; laok_dev:OpenTests() opens it.
-------------------------------------------------------------------------------]]
local AOK = LibStub('LibAceOptionsKit-1.0')
local AceConfig = LibStub('AceConfig-3.0')

--- @class LibAceOptionsKit_Tests
local o = {}; laok_tests = o

--[[-----------------------------------------------------------------------------
Options
-------------------------------------------------------------------------------]]
local values = {
  checked = true, unchecked = false, disabled = true, wide = false, ace = true,
  slider = 50, percent = 0.25, sliderDisabled = 20, sliderFill = 30, aceRange = 50,
  dropdown = 12, ordered = 'high', dropdownDisabled = 12, dropdownFill = 14, aceSelect = 12,
}
local sizes = { [10] = 'Small', [12] = 'Medium', [14] = 'Large', [16] = 'Huge' }
local levels = { low = 'Low', medium = 'Medium', high = 'High' }

--- @param order number
--- @return table<string, LibAceOptionsKit_Option>
local function CheckboxArgs(order)
  return {
    checkboxHeader = { type = 'header', order = order, name = 'SettingsCheckbox' },
    checked = {
      type = 'toggle', order = order + 1, width = 'full',
      name = 'Checkbox', desc = 'Tooltip beside the label or the box',
      dialogControl = AOK.SettingsCheckbox.Type,
    },
    unchecked = {
      type = 'toggle', order = order + 2, width = 'full',
      name = 'Checkbox, unchecked',
      dialogControl = AOK.SettingsCheckbox.Type,
    },
    disabled = {
      type = 'toggle', order = order + 3, width = 'full', disabled = true,
      name = 'Checkbox, disabled',
      dialogControl = AOK.SettingsCheckbox.Type,
    },
    wide = {
      type = 'toggle', order = order + 4, width = 'full',
      name = 'Checkbox, arg.layout label 300, gap 20',
      dialogControl = AOK.SettingsCheckbox.Type,
      arg = { layout = { label = { width = 300 }, row = { gap = 20 } } },
    },
    ace = {
      type = 'toggle', order = order + 5, width = 'full',
      name = 'Ace toggle, for comparison',
    },
  }
end

--- @param order number
--- @return table<string, LibAceOptionsKit_Option>
local function SliderArgs(order)
  return {
    sliderHeader = { type = 'header', order = order, name = 'StepperSlider' },
    slider = {
      type = 'range', order = order + 1, width = 'full', min = 0, max = 100, step = 5,
      name = 'Slider, step 5', desc = 'Tooltip beside the label or the slider',
      dialogControl = AOK.StepperSlider.Type,
    },
    percent = {
      type = 'range', order = order + 2, width = 'full', min = 0, max = 1, step = 0.05,
      isPercent = true,
      name = 'Slider, percent',
      dialogControl = AOK.StepperSlider.Type,
    },
    sliderDisabled = {
      type = 'range', order = order + 3, width = 'full', min = 0, max = 100, step = 1,
      disabled = true,
      name = 'Slider, disabled',
      dialogControl = AOK.StepperSlider.Type,
    },
    sliderFill = {
      type = 'range', order = order + 4, width = 'full', min = 0, max = 100, step = 1,
      name = "Slider, arg.layout width 'fill'",
      dialogControl = AOK.StepperSlider.Type,
      arg = { layout = { slider = { width = 'fill' } } },
    },
    aceRange = {
      type = 'range', order = order + 5, width = 'full', min = 0, max = 100, step = 1,
      name = 'Ace range, for comparison',
    },
  }
end

--- @param tooltip GameTooltip
local function TwoLineTooltip(tooltip)
  tooltip:SetText('Function tooltip')
  tooltip:AddLine('Second line', 1, 1, 1)
end

--- @param order number
--- @return table<string, LibAceOptionsKit_Option>
local function DropdownArgs(order)
  return {
    dropdownHeader = { type = 'header', order = order, name = 'StepperDropdown' },
    dropdown = {
      type = 'select', order = order + 1, width = 'full', values = sizes,
      name = 'Dropdown, sorted by text', desc = 'Row tooltip',
      dialogControl = AOK.StepperDropdown.Type,
      arg = { tooltip = { dropdown = 'Dropdown tooltip, not over the arrows' } },
    },
    ordered = {
      type = 'select', order = order + 2, width = 'full', values = levels,
      sorting = { 'low', 'medium', 'high' },
      name = 'Dropdown, sorting low to high',
      dialogControl = AOK.StepperDropdown.Type,
      arg = { tooltip = { dropdown = TwoLineTooltip } },
    },
    dropdownDisabled = {
      type = 'select', order = order + 3, width = 'full', values = sizes, disabled = true,
      name = 'Dropdown, disabled',
      dialogControl = AOK.StepperDropdown.Type,
    },
    dropdownFill = {
      type = 'select', order = order + 4, width = 'full', values = sizes,
      name = "Dropdown, arg.layout width 'fill'",
      dialogControl = AOK.StepperDropdown.Type,
      arg = { layout = { dropdown = { width = 'fill' } } },
    },
    aceSelect = {
      type = 'select', order = order + 5, width = 'full', values = sizes,
      name = 'Ace select, for comparison',
    },
  }
end

--- @return AceConfig.OptionsTable
local function Options()
  local args = {}
  for _, group in ipairs({ CheckboxArgs(10), SliderArgs(20), DropdownArgs(30) }) do
    for key, option in pairs(group) do
      args[key] = option
    end
  end
  return {
    type = 'group',
    name = 'LibAceOptionsKit Dev',
    get = function(info) return values[info[#info]] end,
    set = function(info, value)
      values[info[#info]] = value
      print('LAOK set:', info[#info], '=', value)
    end,
    args = args,
  }
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- Called on open only, so a plain /reload registers nothing
--- @param appName string @The AceConfig app name to register
function o:Register(appName)
  -- App default; the 'wide' row's arg.layout overrides it
  AOK:SetDefaults(appName, { label = { width = 200 } })
  AceConfig:RegisterOptionsTable(appName, Options())
end
