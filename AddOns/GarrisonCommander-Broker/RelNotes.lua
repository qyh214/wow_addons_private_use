local me,ns=...
local hlp=LibStub("LibInit"):GetAddon(me)
local L=hlp:GetLocale()
function hlp:loadHelp()
self:HF_Title(me,"RELNOTES")
self:HF_Paragraph("Description")
self:HF_Pre([[
Data broker for Garrison stuff.
]])
self:RelNotes(3,2,1,[[
Fix: No longer gives error when clicking on minimap report icon while in combat
]])
self:RelNotes(3,1,1,[[
Fix: Harvesting node should now be detected again
]])
self:RelNotes(3,0,0,[[
Fix: Harvesting detection works again, thanks to twitchdefresa
]])
self:RelNotes(2,18,8,[[
Fix: Removed lua error GetAbsoluteMonth
]])
self:RelNotes(2,15,3,[[
Fix: Ticket 158  attempt to call method 'loadHelp' (a nil value)
]])
self:RelNotes(2,15,2,[[
Feature: Order hall mission are now purple
Feature: Extended profile management enabled
]])
end