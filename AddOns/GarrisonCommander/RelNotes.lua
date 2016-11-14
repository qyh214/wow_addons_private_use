local me,ns=...
local hlp=LibStub("LibInit"):GetAddon(me)
local L=hlp:GetLocale()
function hlp:loadHelp()
self:HF_Title(me,"RELNOTES")
self:HF_Paragraph("Description")
self:Wiki([[
= GarrisonCommander helps you when choosing the right follower for the right mission =
== General enhancements ==
* Mission panel is movable (position not saved, it's jus to see things, panel is so huge...)
* Success chance extimation shown in mission list (optionally considering only available followers)
* Proposed party button
* each follower can be ignored individually for each mission
* you can ignore maxed followers
* you can ignore busy followers
* you can sort missions
== Tooltip Enhancements ==
* list of additional follower than have useful features for the mission
* both traits (silver lines) and abilities(blue lines) are shown
* every follower line has now the icon for countered trait/ability
* final success chance (optionally considering only available followers)
== Silent mode ==
typing /gac silent in chat will eliminate every chat message from GarrisonCommander
]])
self:RelNotes(2,15,2,[[
Fix: Quick mission button was disappearing if not clicked before moving mouse out of it
]])
self:RelNotes(2,15,1,[[
Fix: Now works with 7.1.0
]])
self:RelNotes(2,15,0,[[
Feature: Right clicking minimap Icon opens Garrison Report
Feature: Switch to bigscreen can now be canceled
Fix: Troops should now be used more wisely in Class Hall Missions
Fix: Should not raise errors when clicking on followers
Fix: No longer showing "Install an auction addon" even with auction addon installed
]])
end

