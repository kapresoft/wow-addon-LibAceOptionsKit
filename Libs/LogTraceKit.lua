--[[-----------------------------------------------------------------------------
LogTraceKit: the printer and tracer; no-ops in releases. Libs/Developer
overrides them with LibPrettyPrint and LibTraceKit ones.
-------------------------------------------------------------------------------]]
local lib = LibStub('LibAceOptionsKit-1.0')

--[[-----------------------------------------------------------------------------
Types
-------------------------------------------------------------------------------]]
--- @alias LibAceOptionsKit_PrintFn fun(...: any) @Prints like print()
--- @alias LibAceOptionsKit_TraceFn fun(...: any) @Traces to /etrace

--- @class LibAceOptionsKit_LogHolder
--- @field printer fun(moduleName: string): LibAceOptionsKit_PrintFn
--- @field tracer fun(moduleName: string): LibAceOptionsKit_TraceFn

--[[-----------------------------------------------------------------------------
Logger and Tracer
-------------------------------------------------------------------------------]]
local function noop() return function() end end

-- Kept across upgrades: Libs/Developer overrides it
--- @type LibAceOptionsKit_LogHolder
lib.logHolder = lib.logHolder or { printer = noop, tracer = noop }

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
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
