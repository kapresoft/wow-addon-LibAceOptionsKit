local MAJOR = 'LibAceOptionsKit-1.0'

--- The library is registered with LibStub, and at which minor.
local function TestLoad()
  local lib, minor = LibStub(MAJOR)
  _G.LAOK_TEST = lib
  print('LAOK load:', MAJOR, 'minor =', minor)
end

TestLoad()
