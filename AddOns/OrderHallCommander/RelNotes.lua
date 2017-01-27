local me,ns=...
local hlp=LibStub("LibInit"):GetAddon(me)
local L=hlp:GetLocale()
function hlp:loadHelp()
self:HF_Title(me,"RELNOTES")
self:HF_Paragraph("Description")
self:Wiki([[
= OrderHallCommander helps you when choosing the right follower for the right mission =
== General enhancements ==
* Mission panel is movable (position not saved, it's jus to see things, panel is so huge...)
* Success chance extimation shown in mission list (optionally considering only available followers)
* Proposed party buttons and mission autofill
* "What if" switches to change party composition based on criteria
== Silent mode ==
typing /ohc silent in chat will eliminate every chat message from GarrisonCommander
]])
self:RelNotes(0,2,4,[[
Fix: lua errors in matchmaker.lua
]])
self:RelNotes(0,2,0,[[
Fix: sometimes cache was not refresh after completing missions,leaving al missions unpopulated
]])
self:RelNotes(0,1,1,[[
Fix: Checks we actually cached a follower before removing it from cache
Fix: one follower missions where not supported
Fix: Countered spells are now always marked
Feature: new options for party selection
]])
self:RelNotes(0,1,0,[[
Feature: First release
]])
end

