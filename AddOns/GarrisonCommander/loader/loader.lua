local __FILE__=tostring(debugstack(1,2,0):match("(.*):1:")) -- Always check line number in regexp and file
local me,ns=...
local pp=function(...) print(me,...) end
pp(me,"loaded")
local GarrisonEnabled
local zoneId
LibStub("AceEvent-3.0"):Embed(ns)
LibStub("AceHook-3.0"):Embed(ns)
function ns:ZONE_CHANGED_NEW_AREA(...)
  pp(...)
end
--[[
function ns:ADDON_LOADED(event,addon)
  if addon=="Blizzard_GarrisonUI" then
    GarrisonEnabled=true
    pp(C_Garrison.IsOnGarrisonMap())
  end
end
ns:RegisterEvent("ADDON_LOADED",pp)
--]]
if C_Garrison.IsOnGarrisonMap() then
  LoadAddOn("GarrisonCommander")
end
ns:RegisterEvent("ZONE_CHANGED_NEW_AREA")
ns:RegisterEvent("ZONE_CHANGED","ZONE_CHANGED_NEW_AREA")


--LibStub("AceHook-3.0"):Embed(ns)
--ns:RawHookScript(frame,"OnShow","load")
