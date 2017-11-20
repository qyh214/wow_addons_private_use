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
self:RelNotes(2,18,5,[[
Fix: OrderHallCommander advertising removed. I still stronlgy suggest to install it because Order Hall support in GC is totally outdated  
]])
self:RelNotes(2,18,4,[[
Fix: Error when playing sounds 
]])
self:RelNotes(2,18,2,[[
Fix: Message: Interface\AddOns\GarrisonCommander\FollowerCache.lua:25: attempt to perform arithmetic on local 'GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY' (a table value)
]])
self:RelNotes(2,18,1,[[
Toc bump
]])
self:RelNotes(2,18,0,[[
Feature: Improved autologout management. Now you are logged out on timeout ONLY if you started mission control via ctrl-click on table.
Popup message should be informative
Feature: Added help button to Shipyard and revamped help to show release notes and addon description
]])
self:RelNotes(2,17,0,[[
Feature: Fast mode: if you keep the CTRL key pressed while opening the mission table, GC automagically completes pending mission and schedule new ones
Feature: Fast mode works for both Garrison and Shipyard mission
Feature: On auto logout informs you if you have items to salvage
Feature: No longer includes OrderHallCommander: be sure you added it to Curse Client or manually update it 
Fix: Lua error when trying to close header in Order Hall if OrderHallCommander was not installed 
]])
self:RelNotes(2,16,1,[[
Fix: Mission control was reusing followers
Feature: Option to always fill Oil Rig mission when available
Feature: Blockade Missions are always enabled when needed 
Feature: OrderHallCommander 1.0.0 
]])
self:RelNotes(2,16,0,[[
Feature: Mission control added to Shipyard. Send your naval mission with one click!
Feature: Adds reward icons to shipyard missions
Feature: Includes OrderHallCommander
]])
self:RelNotes(2,15,9,[[
Fix: Non latin languages localization should now work
]])
self:RelNotes(2,15,8,[[
Fix: Lua error: FollowerPage.lua line 329:    attempt to call global 'kpairs' (a nil value)
]])
self:RelNotes(2,15,7,[[
Fix: 2.15.6 zip was corrupted, repackaged
Fix: Pushed a new version hoping to trigger Curse packager
Fix: Shipyard equipment buitton were appearing out of follower panel frame and not disappearing with follower panel
Fix: Whem mission were filled, followers were not marked "In party"
Feature: Added equipment button in OrderHall as a workaround for "ACTION BLOCKED". You no longer need drag and drop
Fix: In broker, OrderHall mission are now purple
]])
self:RelNotes(2,15,3,[[
Fix: Lua error on startup
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

