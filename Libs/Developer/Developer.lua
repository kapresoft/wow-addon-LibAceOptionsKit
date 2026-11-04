--[[-----------------------------------------------------------------------------
Developer: dev-only hooks for testing the library in game.
Loaded by the TOC inside @do-not-package@; never packaged or embedded.

Run in LuaDevKit:
  laok_dev:OpenTests() -- opens the test dialog (Tests.lua)
  laok_dev:Load()      -- prints the active copy's minor
-------------------------------------------------------------------------------]]
local MAJOR = 'LibAceOptionsKit-1.0'
local Tests = laok_tests
local AceConfigDialog = LibStub('AceConfigDialog-3.0')

--- @class LibAceOptionsKit_Developer
local o = { APP = 'LibAceOptionsKit_Dev' }; laok_dev = o

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- The library is registered with LibStub, and at which minor
--- ### Example:
--- ```lua
--- laok_dev:Load()
--- ```
--- @return number @Minor of the copy LibStub serves
function o:Load()
  local _, minor = LibStub(MAJOR)
  print('LAOK load:', MAJOR, 'minor =', minor)
  return minor
end

--- Opens a dialog with every widget beside Ace's own
--- ### Example:
--- ```lua
--- laok_dev:OpenTests()
--- ```
function o:OpenTests()
  Tests:Register(self.APP)
  AceConfigDialog:Open(self.APP)
end
