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
* each follower can bew ignored individually for each mission
* you can ignore maxed followers
* you can ignore busy followers
* you can sort missions
== Tooltip Enhancements ==
* list of additional follower than have useful features for the mission
* both traits (silver lines) and abilities(blue lines) are shown
* every follower line has now the icon for countered trait/ability
* final success chance (optionally considering only available followers)
== Silent mode ==
typing /gac silent in chat will eliminate every chat messag from GarrisonCommander
]])
self:RelNotes(2,0,1)[[
Fixed: RU,KR,CH (both traditional and simplified) locales where broken
Fixed: error when upgrading a follower for the first time
]]
self:RelNotes(2,0,0,[[
Gui totally redesigned, tons of feature added
Check curse site for complete changelog
]])
self:RelNotes(1,1,7,[[
Fix: Followers cache was not initialized
FIx: When filling a party using followers with no counters, was taking busy followers in all cases
]])
self:RelNotes(1,1,6,[[
Fix: GarrisonCommander was unwilling triggering a mission reordering.
Fix: First mission list button was opening the wrong mission
Feature: Reduced memory footprint
Feature: You can switch between considering busy follower or not via a checkbox in main mission panel
Feature: Follower are now assigned to mission giving priority to highest level
Feature: GarrisonCommander is now load on demand when opening Garrison interface
]])
self:RelNotes(1,1,5,[[
Fix: Possible clash with another addon
Fix: Improved follower data refresh. Hopefully no more "You dont have enough followers.." on every button
]])
self:RelNotes(1,1,4,[[
Fixed: Was lagging when zoning inside Garrison
Fixed: Sometimes clicking on a mission button opened the wrong mission page
]])
self:RelNotes(1,1,3,[[
Fixed: When used for a long session of mission management, GarrisonCommander could starve with memory. Now it never go over 1M
Feature: Preview of 1.2.0: Chance of success is now permanently displayed on every mission. In this version it get updated ONLY when you hover on it
Feature: Preview of 1.2.0: Number of requested followers is now permanently displayed on every mission.
Feature: Even if you enabled use of busy followers in calculation, you are warned if you miss enough followers for the mission
]])
self:RelNotes(1,1,2,[[
Fixed: Solves a rare case of library incompatibility causing error ...rfaceGarrisonCommander\GarrisonCommander-1.1.1.lua:47: attempt to call method 'capitalize' (a nil value)
Feature: Removed signature in tooltip... it was annoying me too.. :)
]])
self:RelNotes(1,1,1,[[
Fixed: Added workaround to avoid that MasterPlan steals tooltip de facto
disabling GarrisonCommander
]])
self:RelNotes(1,1,0,[[
Feature: Level added to follower line
Feature: All counterd traits listed on the same line
Feature: For "In mission" follower time letf is shown instead of "In mission"
Feature: Trait related lines are now silver, while abilities related are Blue
Feature: Mission panel can now optionally be relocked
Feature: You can select to ignore "busy" followers
Feature: possible party and success chance with that party
]])
self:RelNotes(1,0,1,[[
Fixed: Follower info refresh should be now more reliable
Feature: Mission panel is now movable
Feature: Shows also countered traits( i.e. environmente/racial bonuses)
Feature: Shows icon for trait or ability countered. Abilities are blue lines, traits orange lines
]])
self:RelNotes(1,0,0,[[
Initial release
]])
end

