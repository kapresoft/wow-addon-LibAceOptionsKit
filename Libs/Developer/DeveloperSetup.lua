--[[-----------------------------------------------------------------------------
DeveloperSetup: dev-only printer and tracer, replacing the no-ops
in LogTraceKit.lua. Loads before the files that call lib:log.
-------------------------------------------------------------------------------]]
local lib = LibStub('LibAceOptionsKit-1.0')
local LibPrettyPrint = LibStub('LibPrettyPrint-1.0')
local LibTraceKit = LibStub('LibTraceKit-1.0')

local NAMESPACE = 'LibAceOptionsKit'
local TRACE_DELIM = '_'

local printer = LibPrettyPrint:Printer({
  prefix = NAMESPACE,
  prefix_color = '12E600',
  sub_prefix_color = '9CFF9C',
  formatter = LibPrettyPrint:Formatter({ show_all = true, depth_limit = 3 }),
})

--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
--- @param moduleName string
--- @return LibAceOptionsKit_PrintFn
local function printerFn(moduleName)
  return printer:WithSubPrefix(moduleName) --[[@as LibAceOptionsKit_PrintFn]]
end

--- @param moduleName string
--- @return LibAceOptionsKit_TraceFn
local function traceFn(moduleName)
  return LibTraceKit:New(NAMESPACE, moduleName):WithDelimiter(TRACE_DELIM) --[[@as LibAceOptionsKit_TraceFn]]
end

--[[-----------------------------------------------------------------------------
Logger and Tracer
-------------------------------------------------------------------------------]]
do
  local h = lib.logHolder
  h.printer, h.tracer = printerFn, traceFn
end
