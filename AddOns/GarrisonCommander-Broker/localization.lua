local me,ns=...
local lang=GetLocale()
local l=LibStub("AceLocale-3.0")
local L=l:NewLocale(me,"enUS",true,true)
L["%1$d%% lower than %2$d%%. Lower %s"] = true
L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = true
L["%s |4follower:followers; with %s"] = true
L["%s for a wowhead link popup"] = true
L["%s no longer blacklist missions"] = true
L["%s start the mission without even opening the mission page. No question asked"] = true
L["%s to actually start mission"] = true
L["%s to blacklist"] = true
L["%s to remove from blacklist"] = true
L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = true
L["(Ignores low bias ones)"] = true
L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = true
L["Add %1$d levels to %2$s"] = true
L["Adds a list of other useful followers to tooltip"] = true
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = true
L["Allowed Rewards"] = true
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = true
L["Always counter increased resource cost"] = true
L["Always counter increased time"] = true
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = true
L["Always counter no bonus loot threat"] = true
L["Analyze parties"] = true
L["and then by:"] = true
L["Applied when 'maximize result' is enabled. Default is 80%"] = true
L["Applies the best armor set"] = true
L["Applies the best armor upgrade"] = true
L["Applies the best weapon set"] = true
L["Applies the best weapon upgrade"] = true
L["Archaelogy"] = true
L["Artifact shown value is the base value without considering knowledge multiplier"] = true
L["Attempting %s"] = true
L["Base Chance"] = true
L["Better parties available in next future"] = true
L["Big screen"] = true
L["Blacklisted"] = true
L["Blacklisted missions are ignored in Mission Control"] = true
L["Bonus Chance"] = true
L["Building Final report"] = true
L["but using troops with just one durability left"] = true
L["Capped"] = true
L["Capped %1$s. Spend at least %2$d of them"] = true
L["Changes the second sort order of missions in Mission panel"] = true
L["Changes the sort order of missions in Mission panel"] = true
L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = true
L["Combat ally is proposed for missions so you can consider unassigning him"] = true
L["Complete all missions without confirmation"] = true
L["Configuration for mission party builder"] = true
L["Consider again"] = true
L["Cost reduced"] = true
L["Could not fulfill mission, aborting"] = true
L["Counter kill Troops"] = true
L["Customization options (non mission related)"] = true
L["Disable blacklisting"] = true
L["Disable if you dont want the full Garrison Commander Header."] = true
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = true
L["Disables warning: "] = true
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = true
L["Do not show follower icon on plots"] = true
L["Dont use this slot"] = true
L["Don't use troops"] = true
L["Duration reduced"] = true
L["Duration Time"] = true
L["Elite: Prefer overcap"] = true
L["Elites mission mode"] = true
L["Empty missions sorted as last"] = true
L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = true
L["Enhance tooltip"] = true
L["Environment Preference"] = true
L["Epic followers are NOT sent alone on xp only missions"] = true
L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = true
L["Equipped by following champions:"] = true
L["Expiration Time"] = true
L["Favours leveling follower for xp missions"] = true
L["Follower"] = true
L["Follower equipment set or upgrade"] = true
L["Follower experience"] = true
L["Follower set minimum upgrade"] = true
L["Follower Training"] = true
L["Followers status "] = true
L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = true
L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = true
L["Garrison Appearance"] = true
L["Garrison Comander Quick Mission Completion"] = true
L["Garrison Commander Mission Control"] = true
L["General"] = true
L["Global approx. xp reward"] = true
L["Global approx. xp reward per hour"] = true
L["Global success chance"] = true
L["Gold incremented!"] = true
L["HallComander Quick Mission Completion"] = true
L["Hide followers"] = true
L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = true
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = true
L["IF checked, shows armors on the left and weapons on the right "] = true
L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = true
L["If not checked, inactive followers are used as last chance"] = true
L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = true
L["If you continue, you will lose them"] = true
L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = true
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = true
L["Ignore \"maxed\""] = true
L["Ignore busy followers"] = true
L["Ignore epic for xp missions."] = true
L["Ignore for all missions"] = true
L["Ignore for this mission"] = true
L["Ignore inactive followers"] = true
L["Ignore rare missions"] = true
L["Increased Rewards"] = true
L["Item minimum level"] = true
L["Item Tokens"] = true
L["Keep cost low"] = true
L["Keep extra bonus"] = true
L["Keep time short"] = true
L["Keep time VERY short"] = true
L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = true
L["Left Click to see available missions"] = true
L["Legendary Items"] = true
L["Level"] = true
L["Level 100 epic followers are not used for xp only missions."] = true
L["Lock all"] = true
L["Lock this follower"] = true
L["Locked follower are only used in this mission"] = true
L["Make Order Hall Mission Panel movable"] = true
L["Makes main mission panel movable"] = true
L["Makes shipyard panel movable"] = true
L["Makes sure that no troops will be killed"] = true
L["Max champions"] = true
L["Maximize result"] = true
L["Maximize xp gain"] = true
L["Maximum mission duration."] = true
L["Minimum chance"] = true
L["Minimum mission duration."] = true
L["Minimum needed chance"] = true
L["Minimum requested level for equipment rewards"] = true
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = true
L["Minimun chance success under which ignore missions"] = true
L["Minumum needed chance"] = true
L["Mission Control"] = true
L["Mission Duration"] = true
L["Mission duration reduced"] = true
L["Mission shown"] = true
L["Mission shown for follower"] = true
L["Mission Success"] = true
L["Mission time reduced!"] = true
L["Mission was capped due to total chance less than"] = true
L["Mission with lower success chance will be ignored"] = true
L["Missionlist"] = true
L["Missions"] = true
L["Must reload interface to apply"] = true
L["Never kill Troops"] = true
L["No confirmation"] = true
L["No follower gained xp"] = true
L["No mission prefill"] = true
L["No suitable missions. Have you reserved at least one follower?"] = true
L["Not blacklisted"] = true
L["Not Selected"] = true
L["Nothing to report"] = true
L["Notifies you when you have troops ready to be collected"] = true
L["Number of followers"] = true
L["Only accept missions with time improved"] = true
L["Only consider elite missions"] = true
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = true
L["Only meaningful upgrades are shown"] = true
L["Only need %s instead of %s to start a mission from mission list"] = true
L["Only ready"] = true
L["Only use champions even if troops are available"] = true
L["Original concept and interface by %s"] = true
L["Original method"] = true
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = true
L["Other"] = true
L["Other rewards"] = true
L["Other settings"] = true
L["Other useful followers"] = true
L["Position is not saved on logout"] = true
L["Prefer high durability"] = true
L["Processing mission %d of %d"] = true
L["Profession"] = true
L["Quick start first mission"] = true
L["Racial Preference"] = true
L["Rare missions will not be considered"] = true
L["Reagents"] = true
L["Remove no champions warning"] = true
L["Reputation Items"] = true
L["Restart the tutorial"] = true
L["Restart tutorial from beginning"] = true
L["Resume tutorial"] = true
L["Resurrect troops effect"] = true
L["Reward type"] = true
L["Right-Click to blacklist"] = true
L["Right-Click to remove from blacklist"] = true
L["Rush orders"] = true
L["See all possible parties for this mission"] = true
L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = true
L["Shipyard Appearance"] = true
L["Show Garrison Commander menu"] = true
L["Show itemlevel"] = true
L["Show upgrades"] = true
L["Show xp"] = true
L["Show/hide OrderHallCommander mission menu"] = true
L["Shows only parties with available followers"] = true
L["Slayer"] = true
L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = true
L["Some follower"] = true
L["Sort missions by:"] = true
L["Started with "] = true
L["Submit all your mission at once. No question asked."] = true
L["Success Chance"] = true
L["Swap upgrades positions"] = true
L["Switch between Garrison Commander and Master Plan interface for missions"] = true
L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = true
L["Thank you for reading this, enjoy %s"] = true
L["There are %d tutorial step you didnt read"] = true
L["Threat Counter"] = true
L["To go: %d"] = true
L["Toggles Garrison Commander Menu Header on/off"] = true
L["Toys and Mounts"] = true
L["Troop ready alert"] = true
L["Unable to fill missions, raise \"%s\""] = true
L["Unable to fill missions. Check your switches"] = true
L["Unable to start mission, aborting"] = true
L["Uncapped"] = true
L["Unchecking this will allow you to set specific success chance for each reward type"] = true
L["Unlock all"] = true
L["Unlock Panel"] = true
L["Unlock this follower"] = true
L["Unlocks all follower and slots at once"] = true
L["Unsafe mission start"] = true
L["Upgrade %1$s to  %2$d itemlevel"] = true
L["Upgrading to |cff00ff00%d|r"] = true
L["URL Copy"] = true
L["Use at most this many champions"] = true
L["Use big screen"] = true
L["Use combat ally"] = true
L["Use GC Interface"] = true
L["Use this slot"] = true
L["Uses armor token"] = true
L["Uses troops with the highest durability instead of the ones with the lowest"] = true
L["Uses weapon token"] = true
L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = true
L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = true
L["When checked, show on each follower button missing xp to next level"] = true
L["When checked, show on each follower button weapon and armor level for maxed followers"] = true
L["When no free followers are available shows empty follower"] = true
L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = true
L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = true
L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = true
L["Would start with "] = true
L["XP"] = true
L["Xp incremented!"] = true
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = true
L["You can also send mission one by one clicking on each button."] = true
L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = true
L["You can choose not to use a troop type clicking its icon"] = true
L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = true
L["You can open the menu clicking on the icon in top right corner"] = true
L["You have ignored followers"] = true
L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = true
L["You never performed this mission"] = true
L["You now need to press both %s and %s to start mission"] = true
L["You performed this mission %d times with a win ratio of"] = true

L=l:NewLocale(me,"ptBR")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["%s |4follower:followers; with %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["(Ignores low bias ones)"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Add %1$d levels to %2$s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Adds a list of other useful followers to tooltip"] = ""--]] 
--[[Translation missing --]]
--[[ L["Affects only little screen mode, hiding the per follower mission list if not checked"] = ""--]] 
--[[Translation missing --]]
--[[ L["Allowed Rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applied when 'maximize result' is enabled. Default is 80%"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best armor set"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best armor upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best weapon set"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best weapon upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Archaelogy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
--[[Translation missing --]]
--[[ L["Big screen"] = ""--]] 
--[[Translation missing --]]
--[[ L["Blacklisted"] = ""--]] 
--[[Translation missing --]]
--[[ L["Blacklisted missions are ignored in Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Building Final report"] = ""--]] 
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped %1$s. Spend at least %2$d of them"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
--[[Translation missing --]]
--[[ L["Complete all missions without confirmation"] = ""--]] 
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consider again"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable if you dont want the full Garrison Commander Header."] = ""--]] 
--[[Translation missing --]]
--[[ L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
--[[Translation missing --]]
--[[ L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""--]] 
--[[Translation missing --]]
--[[ L["Do not show follower icon on plots"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration Time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enhance tooltip"] = ""--]] 
--[[Translation missing --]]
--[[ L["Environment Preference"] = ""--]] 
--[[Translation missing --]]
--[[ L["Epic followers are NOT sent alone on xp only missions"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Expiration Time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower equipment set or upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower experience"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower set minimum upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower Training"] = ""--]] 
--[[Translation missing --]]
--[[ L["Followers status "] = ""--]] 
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Appearance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Comander Quick Mission Completion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Commander Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global approx. xp reward"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global success chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gold incremented!"] = ""--]] 
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Hide followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = ""--]] 
--[[Translation missing --]]
--[[ L["IF checked, shows armors on the left and weapons on the right "] = ""--]] 
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["If you continue, you will lose them"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["IF you have a Salvage Yard you probably dont want to have this one checked"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore \"maxed\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore epic for xp missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore for all missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore rare missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Increased Rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item minimum level"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Left Click to see available missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Legendary Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
--[[Translation missing --]]
--[[ L["Level 100 epic followers are not used for xp only missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes main mission panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes shipyard panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximize result"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximum mission duration."] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum mission duration."] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum needed chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum requested level for equipment rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum requested upgrade for followers set (Enhancements are always included)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimun chance success under which ignore missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minumum needed chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Duration"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission shown for follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Success"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission time reduced!"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission with lower success chance will be ignored"] = ""--]] 
--[[Translation missing --]]
--[[ L["Missionlist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Must reload interface to apply"] = ""--]] 
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["No confirmation"] = ""--]] 
--[[Translation missing --]]
--[[ L["No follower gained xp"] = ""--]] 
--[[Translation missing --]]
--[[ L["No mission prefill"] = ""--]] 
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Not blacklisted"] = ""--]] 
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
--[[Translation missing --]]
--[[ L["Nothing to report"] = ""--]] 
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
--[[Translation missing --]]
--[[ L["Number of followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only meaningful upgrades are shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original concept and interface by %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original method"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other settings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other useful followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
--[[Translation missing --]]
--[[ L["Processing mission %d of %d"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Racial Preference"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rare missions will not be considered"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reward type"] = ""--]] 
--[[Translation missing --]]
--[[ L["Right-Click to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Right-Click to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rush orders"] = ""--]] 
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shipyard Appearance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show Garrison Commander menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show xp"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Slayer"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Some follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sort missions by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
--[[Translation missing --]]
--[[ L["Submit all your mission at once. No question asked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Success Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Swap upgrades positions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Switch between Garrison Commander and Master Plan interface for missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
--[[Translation missing --]]
--[[ L["Threat Counter"] = ""--]] 
--[[Translation missing --]]
--[[ L["To go: %d"] = ""--]] 
--[[Translation missing --]]
--[[ L["Toggles Garrison Commander Menu Header on/off"] = ""--]] 
--[[Translation missing --]]
--[[ L["Toys and Mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unchecking this will allow you to set specific success chance for each reward type"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock Panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
--[[Translation missing --]]
--[[ L["Upgrade %1$s to  %2$d itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Upgrading to |cff00ff00%d|r"] = ""--]] 
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use big screen"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use GC Interface"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses armor token"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses weapon token"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["When checked, show on each follower button missing xp to next level"] = ""--]] 
--[[Translation missing --]]
--[[ L["When checked, show on each follower button weapon and armor level for maxed followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
--[[Translation missing --]]
--[[ L["Xp incremented!"] = ""--]] 
--[[Translation missing --]]
--[[ L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = ""--]] 
--[[Translation missing --]]
--[[ L["You can also send mission one by one clicking on each button."] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can open the menu clicking on the icon in top right corner"] = ""--]] 
--[[Translation missing --]]
--[[ L["You have ignored followers"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You never performed this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["You performed this mission %d times with a win ratio of"] = ""--]] 

return
end
L=l:NewLocale(me,"frFR")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4sujet:sujets; avec %s"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "(Ignorer celles \195\160 basse priorit\195\169)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "Ajoute %1$d niveaux \195\160 %2$s"
L["Adds a list of other useful followers to tooltip"] = "Ajoute une liste d'autres sujets utiles dans l'infobulle"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "N'affecte que le mode petit \195\169cran, masquant la liste par mission de sujet si d\195\169coch\195\169"
L["Allowed Rewards"] = "R\195\169compenses re\195\167ues"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Permet un pourcentage de r\195\169ussite inf\195\169rieur pour des missions de ressources. Utiliser /gac gui pour le changer. Il est par d\195\169faut \195\160 80 %."
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Affecter quand \194\171 maximiser le r\195\169sultat \194\187 est actif. Il est par d\195\169faut de 80 %"
L["Applies the best armor set"] = "Applique le meilleur ensemble d'armure"
L["Applies the best armor upgrade"] = "Applique la meilleure am\195\169lioration d'armure"
L["Applies the best weapon set"] = "Applique le meilleur ensemble d'arme"
L["Applies the best weapon upgrade"] = "Applique la meilleure am\195\169lioration d'arme"
L["Archaelogy"] = "Arch\195\169ologie"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "Grand \195\169cran"
L["Blacklisted"] = "Liste noire"
L["Blacklisted missions are ignored in Mission Control"] = "Les missions en liste noire sont ignor\195\169es dans Contr\195\180le de mission"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "Cr\195\169ation du rapport final"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "Maxi pour %1$s. En d\195\169pensera au moins %2$d"
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "Terminer toutes les missions sans confirmation"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "Reconsid\195\169rer"
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
L["Disable if you dont want the full Garrison Commander Header."] = "\195\128 d\195\169sactiver si vous ne voulez pas de l'intitul\195\169 naval complet"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "D\195\169sactive le remplissage automatique des sujets sur la page de mission, ou maintenir CTRL tout en cliquant sur une mission."
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "D\195\169sactiver ceci vous donnera l'interface de version 1.1.8. Rechargera l'interface maintenant."
L["Do not show follower icon on plots"] = "Ne pas afficher l'ic\195\180ne des sujets dans leurs emplacements"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "Dur\195\169e"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "Infobulle am\195\169lior\195\169e"
L["Environment Preference"] = "Pr\195\169f\195\169rence d'environnement"
L["Epic followers are NOT sent alone on xp only missions"] = "Les sujets \195\169piques ne sont PAS envoy\195\169s seuls dans des missions d'XP uniquement"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "D\195\169lai avant expiration"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "Sujet"
L["Follower equipment set or upgrade"] = "\195\137quipement du sujet d\195\169fini ou am\195\169lior\195\169"
L["Follower experience"] = "Exp\195\169rience du sujet"
L["Follower set minimum upgrade"] = "Am\195\169lioration minimale du sujet d\195\169finie"
L["Follower Training"] = "Formation de sujet"
L["Followers status "] = "Statuts des sujets"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "Arriv\195\169e de fief"
L["Garrison Comander Quick Mission Completion"] = "Terminer rapidement toutes les missions navales"
L["Garrison Commander Mission Control"] = "Contr\195\180le des missions navales"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "\195\137valuation totale du gain en XP"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "Chance totale de succ\195\168s"
L["Gold incremented!"] = "Or augment\195\169 !"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "Masquer les sujets"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[Si activ\195\169, cliquer sur une ic\195\180ne d'am\195\169lioration fera dispara\195\174tre l'objet et am\195\169liorera le sujet
|cFFFF0000AUCUNE CONFIRMATION !|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "SI coch\195\169, affiche les armures \195\160 gauche et les armes \195\160 droite"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "Si vous continuez, vous le(s) perdrez"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "SI vous avez un centre de tri, vous ne voulez probablement pas avoir \195\167a une fois v\195\169rifi\195\169"
L["Ignore \"maxed\""] = "Ignorer \"maximis\195\169\""
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "Ignorer sujet \195\169pique pour les missions \195\160 XP."
L["Ignore for all missions"] = "Ignorer pour toutes les missions"
L["Ignore for this mission"] = "Ignorer pour cette mission"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "Ignorer les missions rares"
L["Increased Rewards"] = "Augmentation des r\195\169compenses"
L["Item minimum level"] = "Niveau minimum de l'objet"
L["Item Tokens"] = "Objets-jeton"
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "Cliquer gauche pour voir les missions disponibles"
L["Legendary Items"] = "Objet l\195\169gendaire"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "Les sujets \195\169piques de niveau 100 ne sont pas utilis\195\169s pour les missions d'XP uniquement."
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "Faire que le panneau principal de missions soit mobile"
L["Makes shipyard panel movable"] = "Faire que le panneau du port naval soit mobile"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "Maximiser le r\195\169sultat"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "Dur\195\169e maximale de mission."
L["Minimum chance"] = "Chance minimale"
L["Minimum mission duration."] = "Dur\195\169e minimale de mission."
L["Minimum needed chance"] = "Chance minimale n\195\169cessaire"
L["Minimum requested level for equipment rewards"] = "Niveau requis minimum pour les r\195\169compenses d'\195\169quipement"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Am\195\169lioration minimale requise pour l'\195\169quipement des sujets (les am\195\169liorations sont toujours inclus)"
L["Minimun chance success under which ignore missions"] = "R\195\169ussite minimale en dessous de laquelle les missions seront ignor\195\169es"
L["Minumum needed chance"] = "Chance minimale n\195\169cessaire"
L["Mission Control"] = "Contr\195\180le de missions"
L["Mission Duration"] = "Dur\195\169e de missions"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "Affichage de missions"
L["Mission shown for follower"] = "Mission affich\195\169e pour les sujets"
L["Mission Success"] = "Succ\195\168s de missions"
L["Mission time reduced!"] = "Dur\195\169e de mission r\195\169duite !"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "Les missions avec des chances faibles seront ignor\195\169es"
L["Missionlist"] = "Liste des missions"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "Devra recharger l'interface pour activer"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "Ne pas confirmer"
L["No follower gained xp"] = "Aucune sujet n'a eu d'XP"
L["No mission prefill"] = "Pas de constitution auto. de missions"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "Ne pas mettre en liste noire"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "Rien \195\160 signaler"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "Nombre de sujets"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Seuls les %1$d premi\195\168res missions avec plus de %2$d%% de chances de succ\195\168s sont affich\195\169es"
L["Only meaningful upgrades are shown"] = "N'afficher que les am\195\169liorations utiles"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "Conception et interface originels de %s"
L["Original method"] = "M\195\169thode originale"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Trie original restaure la m\195\169thode de trie par d\195\169faut, quelle qu'elle f\195\187t (si vous avez un autre addon pour trier les missions, il devrait fonctionner \195\160 nouveau)"
L["Other"] = "Autre"
L["Other rewards"] = "Autres r\195\169compenses"
L["Other settings"] = "Autres param\195\168tres"
L["Other useful followers"] = "Autres sujets utiles"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "Traitement de la mission %d sur %d"
L["Profession"] = "M\195\169tier"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "Pr\195\169f\195\169rence de race"
L["Rare missions will not be considered"] = "Les missions rares ne sont pas examin\195\169es"
L["Reagents"] = "R\195\169actifs"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "Objets de r\195\169putations"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "Type de r\195\169compense"
L["Right-Click to blacklist"] = "Clic-droit pour mettre en liste noire"
L["Right-Click to remove from blacklist"] = "Clic-droit pour retirer de la liste noire"
L["Rush orders"] = "Commandes urgentes"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "Aspect du port naval"
L["Show Garrison Commander menu"] = "Afficher le menu de Garrison Commander"
L["Show itemlevel"] = "Afficher l'ilvl"
L["Show upgrades"] = "Affiche les am\195\169liorations"
L["Show xp"] = "Afficher l'XP"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "Pourfendeur"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "Un sujet"
L["Sort missions by:"] = "Trier les missions par :"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "Soumettre toutes vos missions en une fois. Aucune confirmation demand\195\169e."
L["Success Chance"] = "Chance de succ\195\168s"
L["Swap upgrades positions"] = "Mettre \195\160 jour les positions permut\195\169es"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "Permuter l'interface entre Garrison Commander et Master Plan pour les missions"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "Niveau de menace"
L["To go: %d"] = "Aller \195\160 : %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Activer/d\195\169sactiver le menu d'intitul\195\169 de Garrison Commander"
L["Toys and Mounts"] = "Jouets et montures"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "D\195\169cocher pour d\195\169finir les chances de r\195\169ussite pour chaque type de r\195\169compense"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "D\195\169verrouille le panneau"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "Am\195\169lioration du ilvl de %1$s \195\160 %2$d"
L["Upgrading to |cff00ff00%d|r"] = "Am\195\169lioration \195\160 |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "Utilise la gd taille"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "Utiliser l'interface de GC"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "Utiliser le jeton d'armure"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "Utiliser le jeton d'arme"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "Quand coch\195\169, affiche l'XP n\195\169cessaire, pour le prochain niveau, sur chaque bouton de sujets"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Quand coch\195\169, affiche le niveau d'arme et d'armure sur chaque bouton des sujets maximis\195\169s"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
L["Xp incremented!"] = "XP augment\195\169e !"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Vous gaspillez |cffff0000%d|cffffd200 point(s) !!!"
L["You can also send mission one by one clicking on each button."] = "Vous pouvez aussi d\195\169buter les missions une par une en cliquant sur chaque bouton."
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "Vous pouvez ouvrir le menu en cliquant sur l'ic\195\180ne dans le coin sup\195\169rieur droit"
L["You have ignored followers"] = "Vous avez ignor\195\169 des sujets"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "Vous n'avez jamais effectu\195\169 cette mission"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "Vous avez effectu\195\169 cette mission %d fois avec un rapport de"

return
end
L=l:NewLocale(me,"deDE")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4Anh\195\164nger:Anh\195\164nger; mit %s"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "(Niedrigstufige werden ignoriert)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "Erh\195\182he die %2$s um %1$d Stufen"
L["Adds a list of other useful followers to tooltip"] = "F\195\188ge dem Tooltip eine Liste anderer n\195\188tzlicher Anh\195\164nger hinzu"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "Nur f\195\188r den Kleinfenstermodus; Versteckt die Pro-Anh\195\164nger-Missionsliste, wenn hier das H\195\164kchen fehlt."
L["Allowed Rewards"] = "Erlaubte Belohnungen"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Erlaubt eine geringere Erfolgschance f\195\188r Ressourcenmissionen. Mit \"/gac gui\" kannst du diesen Prozentwert \195\164ndern. Standard ist 80%."
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Nur wirksam, wenn 'Ergebnis maximieren' aktiv ist. Standard ist 80%"
L["Applies the best armor set"] = "Wendet das beste R\195\188stungsset an."
L["Applies the best armor upgrade"] = "Wendet die beste R\195\188stungsverbesserung an."
L["Applies the best weapon set"] = "Wendet das beste Waffenset an."
L["Applies the best weapon upgrade"] = "Wendet die beste Waffenverbesserung an."
L["Archaelogy"] = "Arch\195\164ologie"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "Gro\195\159es Fenster"
L["Blacklisted"] = "Ignoriert"
L["Blacklisted missions are ignored in Mission Control"] = "Ignorierte Missionen werden in der Missionssteuerung ignoriert"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "Erstelle Abschlussbericht"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "Maximalwert von %1$s erreicht. Gib mindestens %2$d davon aus"
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "Beende alle Missionen ohne Best\195\164tigung"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "Wieder ber\195\188cksichtigen"
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
L["Disable if you dont want the full Garrison Commander Header."] = "Deaktiviere diese Option, wenn du den Header vom Garrison Commander nicht haben willst."
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Deaktiviert das automatische Bef\195\188llen von Missionen auf der Missionsseite. Du kannst auch STRG+MAUSKLICK dr\195\188cken, um einzelne Missionen zu bef\195\188llen."
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Durch Deaktivieren dieser Option erh\195\164ltst du das Interface von 1.1.8. Das Interface muss dabei neu geladen werden."
L["Do not show follower icon on plots"] = "Anh\195\164ngersymbole auf den Fl\195\164chen nicht anzeigen"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "Zeitdauer"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "Tooltip verbessern"
L["Environment Preference"] = "Bevorzugte Umgebung"
L["Epic followers are NOT sent alone on xp only missions"] = "Epische Anh\195\164nger werden NICHT allein auf EP-Missionen geschickt"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "Ablaufzeit"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "Anh\195\164nger"
L["Follower equipment set or upgrade"] = "Anh\195\164ngerausr\195\188stungsset oder -verbesserung"
L["Follower experience"] = "Anh\195\164ngererfahrung"
L["Follower set minimum upgrade"] = "Minimale Aufwertung f\195\188r Anh\195\164ngersets"
L["Follower Training"] = "Anh\195\164ngerausbildung"
L["Followers status "] = "Anh\195\164ngerstatus"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "Garnisonsdarstellung"
L["Garrison Comander Quick Mission Completion"] = "GC-Schnellmissionsabschluss"
L["Garrison Commander Mission Control"] = "GC-Missionssteuerung"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "Globale ungef\195\164hre EP-Belohnung"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "Gesamte Erfolgschance"
L["Gold incremented!"] = "Gold erh\195\182ht!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "Anh\195\164nger verstecken"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[Wenn aktiviert, wird beim Anklicken eines Aufwertungssymbols der Gegenstand verbraucht und der Anh\195\164nger verbessert
|cFFFF0000OHNE BEST\195\132TIGUNGSABFRAGE|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "Wenn markiert, werden R\195\188stungen auf der linken Seite und Waffen auf der rechten Seite angezeigt"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "Wenn du weitermachst, wirst du sie verlieren"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "Wenn du ein Wiederverwertungsgeb\195\164ude hast, sollte diese Option deaktiviert bleiben"
L["Ignore \"maxed\""] = "\"Maximierte\" ignorieren"
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "Epische Anh. bei Erfahrungsmissionen ignorieren"
L["Ignore for all missions"] = "Bei allen Missionen ignorieren"
L["Ignore for this mission"] = "Bei dieser Mission ignorieren"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "Seltene Missionen ignorieren"
L["Increased Rewards"] = "Belohnungsbonus"
L["Item minimum level"] = "Minimale Gegenstandsstufe"
L["Item Tokens"] = "Gegenstandsmarken"
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "Linksklicke hier, um alle verf\195\188gbaren Missionen zu sehen"
L["Legendary Items"] = "Legend\195\164re Gegenst\195\164nde"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "Epische Stufe-100-Anh\195\164nger werden nicht bei Nur-EP-Missionen benutzt."
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "Macht das Hauptmissionsfenster verschiebbar"
L["Makes shipyard panel movable"] = "Macht das Werftfenster verschiebbar"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "Ergebnis maximieren"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "Maximale Missionsdauer"
L["Minimum chance"] = "Minimalchance"
L["Minimum mission duration."] = "Minimale Missionsdauer"
L["Minimum needed chance"] = "Kleinstm\195\182gliche Chance"
L["Minimum requested level for equipment rewards"] = "Kleinstm\195\182gliche Stufe f\195\188r Ausr\195\188stungsbelohnungen"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Kleinstm\195\182gliche Aufwertung f\195\188r Anh\195\164ngersets (Verbesserungen sind immer enthalten)"
L["Minimun chance success under which ignore missions"] = "Minimale Erfolgschance \226\128\147 alle Missionen, die darunter liegen, werden ignoriert"
L["Minumum needed chance"] = "Kleinstm\195\182gliche Chance"
L["Mission Control"] = "Missionssteuerung"
L["Mission Duration"] = "Missionsdauer"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "Anzahl gezeigter Missionen"
L["Mission shown for follower"] = "Angezeigte Missionen f\195\188r einen Anh\195\164nger"
L["Mission Success"] = "Missionserfolg"
L["Mission time reduced!"] = "Missionszeit reduziert!"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "Missionen mit geringerer Erfolgschance werden ignoriert"
L["Missionlist"] = "Missionsliste"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "Das Interface muss neu geladen werden"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "Ohne Nachfragen"
L["No follower gained xp"] = "Kein Anh\195\164nger bekam Erfahrung"
L["No mission prefill"] = "Kein Vorab-Auff\195\188llen bei Missionen"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "Nicht ignoriert"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "Es gibt nichts zu berichten"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "Anzahl der Anh\195\164nger"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Nur die ersten %1$d Missionen mit einer Erfolgschance von \195\188ber %2$d%% werden angezeigt"
L["Only meaningful upgrades are shown"] = "Nur sinnvolle Aufwertungen werden angezeigt"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "Originales Konzept und Interface von %s"
L["Original method"] = "Originale Methode"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Originale Sortierung stellt die originale Sortiermethode wieder her, was auch immer sie war (wenn du ein anderes Addon zum Sortieren der Missionen hast, sollte dieses wieder wirksam werden)"
L["Other"] = "Andere"
L["Other rewards"] = "Sonstige Belohnungen"
L["Other settings"] = "Sonstige Einstellungen"
L["Other useful followers"] = "Andere n\195\188tzliche Anh\195\164nger"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "Bearbeite Mission %d von %d"
L["Profession"] = "Beruf"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "Volksvorliebe"
L["Rare missions will not be considered"] = "Seltene Missionen werden ignoriert"
L["Reagents"] = "Reagenzien"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "Rufgegenst\195\164nde"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "Belohnungstyp"
L["Right-Click to blacklist"] = "Rechtsklicken, um sie auf die Ignorierliste zu setzen"
L["Right-Click to remove from blacklist"] = "Rechtsklicken, um sie aus der Ignorierliste zu entfernen"
L["Rush orders"] = "Eilauftr\195\164ge"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "Werftdarstellung"
L["Show Garrison Commander menu"] = "Das Men\195\188 von Garrison Commander zeigen"
L["Show itemlevel"] = "Gegenstandsstufe zeigen"
L["Show upgrades"] = "Aufwertungen zeigen"
L["Show xp"] = "EP zeigen"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "Schl\195\164chter"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "Manche Anh\195\164nger"
L["Sort missions by:"] = "Sortiere Missionen nach:"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "Beginne alle Missionen mit einem Klick. Es werden keine Fragen gestellt."
L["Success Chance"] = "Erfolgschance"
L["Swap upgrades positions"] = "Positionen der Aufwertungen tauschen"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "Schalte bei Missionen zwischen Garrison-Commander- und Master-Plan-Interface um."
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "Bedrohungskonter"
L["To go: %d"] = "Noch zu machen: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Schalte Men\195\188-Header vom Garrison Commander an/aus"
L["Toys and Mounts"] = "Spielzeuge und Reittiere"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "Entferne hier das H\195\164kchen, wenn du f\195\188r jeden Belohnungstyp eine spezifische Erfolgschance angeben willst."
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "Fenster freigeben"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "Werte %1$s um %2$d Gegenstandsstufe(n) auf"
L["Upgrading to |cff00ff00%d|r"] = "Verbessere auf |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "Benutze das gro\195\159e Fenster"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "GC-Interface benutzen"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "Benutzt R\195\188stungsverbesserung"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "Benutzt Waffenverbesserung"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "Wenn aktiviert, wird auf jedem Anh\195\164nger-Button die fehlende EP bis zur n\195\164chsten Stufe angezeigt"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Wenn aktiviert, wird auf jedem Anh\195\164nger-Button die Waffen- und R\195\188stungsstufe bei maximierten Anh\195\164ngern angezeigt"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
L["Xp incremented!"] = "EP erh\195\182ht!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Du verschwendest |cffff0000%d|cffffd200 Punkt(e)!!!"
L["You can also send mission one by one clicking on each button."] = "Du kannst eine Mission auch einzeln beginnen, indem du sie jeweils anklickst."
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "Du kannst das Men\195\188 \195\182ffnen, indem du auf das Symbol in der oberen rechten Ecke klickst."
L["You have ignored followers"] = "Du hast ignorierte Anh\195\164nger"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "Du hast diese Mission noch nie durchgef\195\188hrt."
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "Du hast diese Mission %d-mal durchgef\195\188hrt, mit einem Gewinnverh\195\164ltnis von"

return
end
L=l:NewLocale(me,"itIT")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4seguace:seguaci; con %s"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "(Ignorati i seguaci di livello basso)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "Aggiunge %1$d livelli a %2$s"
L["Adds a list of other useful followers to tooltip"] = "Aggiunge altri seguaci utili al tooltip"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "Si applica solo alla modalit\195\160 dimensioni native, nascode la lista missioni per seguace se inattivo"
L["Allowed Rewards"] = "Ricompense ammesse"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Accetta una minor percentuale di successo per le missioni che danno risorse. Con /gac gui puoi cambiare la percentuale (deault 80%)"
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Si applica quando 'massimizza risultato' \195\168 abilitato. Default 80%"
L["Applies the best armor set"] = "Applica il miglior set di armatura"
L["Applies the best armor upgrade"] = "Applica il miglior incremento di armatura"
L["Applies the best weapon set"] = "Applica il miglior set di armi"
L["Applies the best weapon upgrade"] = "Applica il milgior incremento di armi"
L["Archaelogy"] = "Archeologia"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "Pannello grande"
L["Blacklisted"] = "Blacklistato"
L["Blacklisted missions are ignored in Mission Control"] = "Le missioni blacklistate vengono ignorate in Controllo Missione"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "Preparo il report finale"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "Limitato a %1$s. Spendine almeno %2$d"
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "Completa tutte le mission senza conferme"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "Prendi in considerazione di nuovo"
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
L["Disable if you dont want the full Garrison Commander Header."] = "Disabilita se vuoi la testata completa di Garrison Commander"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Disabilita la popolazione automatica della pagina di missione. Puoi anche tenere premuto ctrl mentre clicchi il pulsante missione per non popolare quella specifica missione"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Disabilitando questo avrete la vecchia interfaccia (1.1.8). Verr\195\160 effettuato un reload dell' interfaccia"
L["Do not show follower icon on plots"] = "Nascondi le icone dei seguaci dalle piazzole"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "Durata"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "Migliora il tooltip"
L["Environment Preference"] = "Preferenze Ambientali"
L["Epic followers are NOT sent alone on xp only missions"] = "I seguaci epici NON vengono mandati da soli nelle missioni \"solo pe\""
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "Ora di scadenza"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "Seguace"
L["Follower equipment set or upgrade"] = "Milgioramento armi seguace"
L["Follower experience"] = "Esperienza del seguace"
L["Follower set minimum upgrade"] = "Incremento miniimo del seguace"
L["Follower Training"] = "Istruzione seguace"
L["Followers status "] = "Stato del seguace"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "Aspetto della Garrison"
L["Garrison Comander Quick Mission Completion"] = "Completamento veloce missioni di Garrison Commander"
L["Garrison Commander Mission Control"] = "Controllo missione di Garrison Commander"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "Pe globali approssimativi"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "Chance globale di successo"
L["Gold incremented!"] = "Oro incrementato!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "Nascondi seguaci"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "Se marcato, cliccando un upgrade l'oggetto verr\195\160 consumato e il seguace aggiornato |cFFFF0000SENZA CONFERME|r"
L["IF checked, shows armors on the left and weapons on the right "] = "Inverte la posizione di armi e armature"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "Se continui, le perderai"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "Se avete il Salvage Yard probabilmente questo non lo volete attivo"
L["Ignore \"maxed\""] = "Ignora \"maxati\""
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "Ignora gli epici per le missioni solo pe"
L["Ignore for all missions"] = "Ignora per tutte le missioni"
L["Ignore for this mission"] = "Ignore per questa missione"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "Ignora le missioni rare"
L["Increased Rewards"] = "Ricompensa Migliorata"
L["Item minimum level"] = "Livello minimo oggetto"
L["Item Tokens"] = "Gettone per oggetti"
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "Clicca col sinistro per vedere le missioni disponibili"
L["Legendary Items"] = "Oggetti Leggendari"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "I seguaci di livello 100 e qualit\195\160 epica non sono usati per le missioni di soli pe"
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "Rende movibile il pannello principale"
L["Makes shipyard panel movable"] = "Rende movibile il pannello dela Baia"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "Massimizza risultato"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "Durata massima"
L["Minimum chance"] = "Chance minima"
L["Minimum mission duration."] = "Durata minima"
L["Minimum needed chance"] = "Percentuale minima di successo"
L["Minimum requested level for equipment rewards"] = "Livello minimo richiesto per le ricompense di tipo equipaggiamento"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Livello minimo richiesto per gli upgrade dei followers (I token di miglioramenteo sono sempre inclusi)"
L["Minimun chance success under which ignore missions"] = "Chance di successo minima sotto cui ignorare le missioni"
L["Minumum needed chance"] = "Chance minima richiesta"
L["Mission Control"] = "Controllo Missione"
L["Mission Duration"] = "Durata della Missione"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "Missione mostrata"
L["Mission shown for follower"] = "Numero di missioni mostrato per seguace"
L["Mission Success"] = "Missione Completata"
L["Mission time reduced!"] = "Durata ridotta!"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "Missioni con percentuale di successo inferiore verranno ignorate"
L["Missionlist"] = "Lista Missioni"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "E' necessario ricaricare l'interfaccia per applicarlo"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "Nessuna conferma"
L["No follower gained xp"] = "Nessun seguage ha ottenuto punti esperienza"
L["No mission prefill"] = "Non assegnare alle missioni"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "Non blacklistata"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "Niente da riportare"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "Numero di seguaci"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Vengono mostrare solo le prime %1$d missions con una speranza di successo supseriore al %2$d%%"
L["Only meaningful upgrades are shown"] = "Vengono mostrati solo gli upgrade che hanno senso per il seguace corrente"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "Concetto originale e interfaccia di %s"
L["Original method"] = "Ordinamento originale"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Ripristina il metodo di ordinamento originale, Se avete un altro addon che oridna le missioni, sara\195\160 questo addon a agestirlo."
L["Other"] = "Altro"
L["Other rewards"] = "Atre ricompense"
L["Other settings"] = "Altre impostazioni"
L["Other useful followers"] = "Altri seguagi che possono aiutare"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "Elaboro la missione %d di %d"
L["Profession"] = "Professione"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "Intesa Razziale"
L["Rare missions will not be considered"] = "Le missioni rare non vengono considerate"
L["Reagents"] = "Reagenti"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "Item di reputazione"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "Tipo ricompensa"
L["Right-Click to blacklist"] = "Clicca col destro per blacklistare"
L["Right-Click to remove from blacklist"] = "Clicca col destro per rimuovere dalla blacklist"
L["Rush orders"] = "Commissione"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "Aspetto della Baia"
L["Show Garrison Commander menu"] = "Mostra il menu di Garrison Commander"
L["Show itemlevel"] = "Mostra il livello degli item"
L["Show upgrades"] = "Mostra miglioramenti"
L["Show xp"] = "Mostrape"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "Sterminio"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "Un seguace"
L["Sort missions by:"] = "Ordina le missioni per:"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "Lancia tutte le missioni con un click. Non chiede conferma"
L["Success Chance"] = "Probabilit\195\160 di successo"
L["Swap upgrades positions"] = "Inverti la posizione degli upgrades"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "Alterna fra l'interfaccia di Garrison Commander e quella di Master Plan"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "Contrasto Minaccia"
L["To go: %d"] = "Mancano: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Attiva/disattiva il menu di Garrison Commander"
L["Toys and Mounts"] = "Giocattoli e Cavalcature"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "Disabilita per impostare una percentuale specifica di successo per ogni ricompensa"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "Sblocca il pannello"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "Aggiorna %1$s a %2$d itemlevel"
L["Upgrading to |cff00ff00%d|r"] = "Aggiorno a |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "Utilizza il pannello ingrandito"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "Usa l'interfaccia di GC"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "Usa il token per l'armatura"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "Usa il token per le armi"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "Se attivo, su ogni seguace vengono mostrati i pe mancanti al prossimo livello"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Se attivo, su ogni seguace viene mostrato l'itemlevel di armi e armatura"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
L["XP"] = "PX"
L["Xp incremented!"] = "Pe aumentati!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Stai sprecando |cffff0000%d|cffffd200 punti!!!"
L["You can also send mission one by one clicking on each button."] = "Puoi anche inviare le missioni una per una cliccando sui pulsanti"
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "Puoi aprire il menu cliccando l'icona in alto a destra"
L["You have ignored followers"] = "Hai seguaci ignorati"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "Non hai mai fatto questa missione"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "Hai fatto questa missione %d volde, con una percentuale di successo del"

return
end
L=l:NewLocale(me,"koKR")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%2$s|1\236\157\180;\234\176\128; \236\158\136\235\138\148 %1$s \236\182\148\236\162\133\236\158\144"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "(\237\149\152\235\130\152\236\157\152 \235\130\174\236\157\128 \236\132\177\237\150\165 \235\172\180\236\139\156)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "%2$s\236\151\144 %1$d \235\160\136\235\178\168 \236\182\148\234\176\128"
L["Adds a list of other useful followers to tooltip"] = "\235\139\164\235\165\184 \236\156\160\236\154\169\237\149\156 \236\182\148\236\162\133\236\158\144\236\157\152 \235\170\169\235\161\157\236\157\132 \237\136\180\237\140\129\236\151\144 \236\182\148\234\176\128"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "\236\158\145\236\157\128 \237\153\148\235\169\180 \235\170\168\235\147\156\236\151\144\235\167\140 \236\152\129\237\150\165\236\157\132 \236\164\141\235\139\136\235\139\164, \236\132\160\237\131\157\237\149\152\236\167\128 \236\149\138\236\156\188\235\169\180 \236\182\148\236\162\133\236\158\144 \235\179\132\235\161\156 \236\158\132\235\172\180 \235\170\169\235\161\157\236\157\132 \236\136\168\234\185\129\235\139\136\235\139\164"
L["Allowed Rewards"] = "\236\160\129\236\154\169\235\144\156 \235\179\180\236\131\129"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "\236\158\144\236\155\144 \236\158\132\235\172\180\236\151\144 \235\130\174\236\157\128 \236\132\177\234\179\181 \237\153\149\235\165\160\236\157\132 \237\151\136\236\154\169\237\149\169\235\139\136\235\139\164. \235\176\177\235\182\132\236\156\168\236\157\132 \235\179\128\234\178\189\237\149\152\235\160\164\235\169\180 /gac gui\235\165\188 \236\130\172\236\154\169\237\149\152\236\132\184\236\154\148. \234\184\176\235\179\184\234\176\146\236\157\128 80%\236\158\133\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
L["Applied when 'maximize result' is enabled. Default is 80%"] = "'\234\178\176\234\179\188 \236\181\156\235\140\128\237\153\148'\234\176\128 \237\153\156\236\132\177\237\153\148\235\144\152\236\150\180 \236\158\136\236\157\132 \235\149\140 \236\160\129\236\154\169\235\144\169\235\139\136\235\139\164. \234\184\176\235\179\184\234\176\146\236\157\128 80%\236\158\133\235\139\136\235\139\164"
L["Applies the best armor set"] = "\236\181\156\234\179\160 \235\176\169\236\150\180\234\181\172 \236\132\184\237\138\184 \236\160\129\236\154\169"
L["Applies the best armor upgrade"] = "\236\181\156\234\179\160 \235\176\169\236\150\180\234\181\172 \234\176\149\237\153\148 \236\160\129\236\154\169"
L["Applies the best weapon set"] = "\236\181\156\234\179\160 \235\172\180\234\184\176 \236\132\184\237\138\184 \236\160\129\236\154\169"
L["Applies the best weapon upgrade"] = "\236\181\156\234\179\160 \235\172\180\234\184\176 \234\176\149\237\153\148 \236\160\129\236\154\169"
L["Archaelogy"] = "\234\179\160\234\179\160\237\149\153"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "\237\129\176 \237\153\148\235\169\180"
L["Blacklisted"] = "\236\176\168\235\139\168\235\144\168"
L["Blacklisted missions are ignored in Mission Control"] = "\236\176\168\235\139\168\235\144\156 \236\158\132\235\172\180\235\138\148 \236\158\132\235\172\180 \236\160\156\236\150\180\236\151\144\236\132\156 \235\172\180\236\139\156\235\144\169\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "\236\181\156\236\162\133 \235\179\180\234\179\160\236\132\156 \236\158\145\236\132\177"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s\236\151\144 \235\143\132\235\139\172\237\150\136\236\138\181\235\139\136\235\139\164. \236\181\156\236\134\140 %2$d\236\157\152 \236\158\144\236\155\144\236\157\132 \236\130\172\236\154\169\237\149\152\236\132\184\236\154\148"
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "\237\153\149\236\157\184\236\151\134\236\157\180 \235\170\168\235\147\160 \236\158\132\235\172\180 \236\153\132\235\163\140"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "\235\139\164\236\139\156 \234\179\160\235\160\164\237\149\152\234\184\176"
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
L["Disable if you dont want the full Garrison Commander Header."] = "\236\160\132\236\178\180 Garrison Commander \237\151\164\235\141\148\235\165\188 \236\155\144\237\149\152\236\167\128 \236\149\138\236\156\188\235\169\180 \235\185\132\237\153\156\236\132\177\237\149\152\236\132\184\236\154\148."
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "\236\158\132\235\172\180 \237\142\152\236\157\180\236\167\128 \237\153\148\235\169\180\236\157\152 \236\158\144\235\143\153 \236\177\132\236\154\176\234\184\176\235\165\188 \235\185\132\237\153\156\236\132\177\237\149\169\235\139\136\235\139\164. \235\152\144\237\149\156 Ctrl \237\130\164\235\165\188 \235\136\132\235\165\180\234\179\160 \237\129\180\235\166\173\237\149\152\235\169\180 \235\139\168\236\157\188 \236\158\132\235\172\180\236\151\144\236\132\156 \235\185\132\237\153\156\236\132\177\237\149\169\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "\236\157\180\234\178\131\236\157\132 \235\185\132\237\153\156\236\132\177\237\149\152\235\169\180 1.1.8\236\157\152 \236\157\184\237\132\176\237\142\152\236\157\180\236\138\164\235\165\188 \236\160\156\234\179\181\237\149\169\235\139\136\235\139\164, \236\157\184\237\132\176\237\142\152\236\157\180\236\138\164 \236\158\172\236\139\156\236\158\145\236\157\180 \237\149\132\236\154\148\237\149\169\235\139\136\235\139\164"
L["Do not show follower icon on plots"] = "\234\181\172\236\132\177\236\151\144 \236\182\148\236\162\133\236\158\144 \236\149\132\236\157\180\236\189\152 \237\145\156\236\139\156\237\149\152\236\167\128 \236\149\138\234\184\176"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "\236\158\132\235\172\180 \236\136\152\237\150\137 \236\139\156\234\176\132"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "\237\136\180\237\140\129 \234\176\149\237\153\148"
L["Environment Preference"] = "\236\132\160\237\152\184 \237\153\152\234\178\189"
L["Epic followers are NOT sent alone on xp only missions"] = "\236\152\129\236\155\133 \235\147\177\234\184\137 \236\182\148\236\162\133\236\158\144\235\138\148 \234\178\189\237\151\152\236\185\152 \236\158\132\235\172\180\236\151\144 \237\152\188\236\158\144 \235\179\180\235\130\180\236\167\128\236\167\128 \236\149\138\236\138\181\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "\235\167\140\235\163\140 \236\139\156\234\176\132"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "\236\182\148\236\162\133\236\158\144"
L["Follower equipment set or upgrade"] = "\236\182\148\236\162\133\236\158\144 \236\158\165\235\185\132 \236\132\184\237\138\184 \235\152\144\235\138\148 \234\176\149\237\153\148"
L["Follower experience"] = "\236\182\148\236\162\133\236\158\144 \234\178\189\237\151\152\236\185\152"
L["Follower set minimum upgrade"] = "\236\182\148\236\162\133\236\158\144 \236\132\184\237\138\184 \236\181\156\236\134\140 \234\176\149\237\153\148"
L["Follower Training"] = "\236\182\148\236\162\133\236\158\144 \237\155\136\235\160\168"
L["Followers status "] = "\236\182\148\236\162\133\236\158\144 \236\131\129\237\131\156"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "\236\163\188\235\145\148\236\167\128 \235\170\168\236\150\145"
L["Garrison Comander Quick Mission Completion"] = "Garrison Comander \235\185\160\235\165\184 \236\158\132\235\172\180 \236\153\132\235\163\140"
L["Garrison Commander Mission Control"] = "Garrison Commander \236\158\132\235\172\180 \236\160\156\236\150\180"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "\236\160\132\236\151\173 \236\152\136\236\131\129 \234\178\189\237\151\152\236\185\152 \235\179\180\236\131\129"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "\234\179\181\237\134\181 \236\132\177\234\179\181 \237\153\149\235\165\160"
L["Gold incremented!"] = "\234\179\168\235\147\156 \236\166\157\234\176\128\235\144\168!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "\236\182\148\236\162\133\236\158\144 \236\136\168\234\184\176\234\184\176"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "\236\132\160\237\131\157\237\149\152\234\179\160 \234\176\149\237\153\148 \236\149\132\236\157\180\236\189\152\236\157\132 \237\129\180\235\166\173\237\149\152\235\169\180 \236\149\132\236\157\180\237\133\156\236\157\132 \236\134\140\235\185\132\237\149\152\234\179\160 \236\182\148\236\162\133\236\158\144\235\165\188 \234\176\149\237\153\148\237\149\169\235\139\136\235\139\164, |cFFFF0000\236\149\132\235\172\180\234\178\131\235\143\132 \235\172\187\236\167\128 \236\149\138\236\138\181\235\139\136\235\139\164|r"
L["IF checked, shows armors on the left and weapons on the right "] = "\236\132\160\237\131\157\237\149\152\235\169\180 \235\176\169\236\150\180\234\181\172\235\165\188 \236\153\188\236\170\189\236\151\144 \235\172\180\234\184\176\235\165\188 \236\152\164\235\165\184\236\170\189\236\151\144 \237\145\156\236\139\156\237\149\169\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "\234\179\132\236\134\141\237\149\152\235\169\180 \234\183\184\234\178\131\235\147\164\236\157\132 \236\158\131\236\138\181\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "\236\158\172\237\153\156\236\154\169 \236\178\152\235\166\172\236\158\165\236\157\180 \236\158\136\235\139\164\235\169\180 \236\157\180\234\178\131\236\157\132 \236\132\160\237\131\157\237\149\152\234\179\160 \236\139\182\236\167\128 \236\149\138\236\157\132 \234\178\131\236\158\133\235\139\136\235\139\164"
L["Ignore \"maxed\""] = "\"\236\181\156\235\140\128 \235\160\136\235\178\168\" \235\172\180\236\139\156"
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "\234\178\189\237\151\152\236\185\152 \236\158\132\235\172\180\236\151\144 \236\152\129\236\155\133 \235\147\177\234\184\137 \235\172\180\236\139\156."
L["Ignore for all missions"] = "\235\170\168\235\147\160 \236\158\132\235\172\180 \235\172\180\236\139\156"
L["Ignore for this mission"] = "\236\157\180 \236\158\132\235\172\180 \235\172\180\236\139\156"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "\237\157\172\234\183\128 \236\158\132\235\172\180 \235\172\180\236\139\156"
L["Increased Rewards"] = "\236\166\157\234\176\128\235\144\156 \235\179\180\236\131\129"
L["Item minimum level"] = "\236\149\132\236\157\180\237\133\156 \236\181\156\236\134\140 \235\160\136\235\178\168"
L["Item Tokens"] = "\236\149\132\236\157\180\237\133\156 \237\134\160\237\129\176"
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "\236\153\188\236\170\189 \237\129\180\235\166\173\237\149\152\236\151\172 \236\136\152\237\150\137 \234\176\128\235\138\165\237\149\156 \236\158\132\235\172\180 \237\153\149\236\157\184"
L["Legendary Items"] = "\236\160\132\236\132\164 \236\149\132\236\157\180\237\133\156"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "\235\160\136\235\178\168 100 \236\152\129\236\155\133 \235\147\177\234\184\137 \236\182\148\236\162\133\236\158\144\235\138\148 \234\178\189\237\151\152\236\185\152 \236\158\132\235\172\180\236\151\144 \236\130\172\236\154\169\237\149\152\236\167\128 \236\149\138\236\138\181\235\139\136\235\139\164."
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "\236\163\188 \236\158\132\235\172\180 \236\176\189 \236\157\180\235\143\153 \234\176\128\235\138\165\237\149\152\234\178\140 \235\167\140\235\147\164\234\184\176"
L["Makes shipyard panel movable"] = "\237\149\180\236\131\129 \236\158\132\235\172\180 \236\176\189 \236\157\180\235\143\153 \234\176\128\235\138\165\237\149\152\234\178\140 \235\167\140\235\147\164\234\184\176"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "\234\178\176\234\179\188 \236\181\156\235\140\128\237\153\148"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "\236\181\156\235\140\128 \236\158\132\235\172\180 \236\167\128\236\134\141\236\139\156\234\176\132."
L["Minimum chance"] = "\236\181\156\236\134\140 \237\153\149\235\165\160"
L["Minimum mission duration."] = "\236\181\156\236\134\140 \236\158\132\235\172\180 \236\167\128\236\134\141\236\139\156\234\176\132."
L["Minimum needed chance"] = "\236\181\156\236\134\140 \236\154\148\234\181\172 \237\153\149\235\165\160"
L["Minimum requested level for equipment rewards"] = "\236\158\165\235\185\132 \235\179\180\236\131\129\236\151\144 \235\140\128\237\149\156 \236\181\156\236\134\140 \236\154\148\234\181\172 \235\160\136\235\178\168"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "\236\182\148\236\162\133\236\158\144 \236\132\184\237\138\184\236\151\144 \235\140\128\237\149\156 \236\181\156\236\134\140 \236\154\148\234\181\172 \234\176\149\237\153\148 (\237\150\165\236\131\129\236\157\128 \236\150\184\236\160\156\235\130\152 \237\143\172\237\149\168)"
L["Minimun chance success under which ignore missions"] = "\236\158\132\235\172\180\235\165\188 \235\172\180\236\139\156\237\149\160 \236\181\156\236\134\140 \236\132\177\234\179\181 \237\153\149\235\165\160"
L["Minumum needed chance"] = "\236\181\156\236\134\140 \236\154\148\234\181\172 \237\153\149\235\165\160"
L["Mission Control"] = "\236\158\132\235\172\180 \236\160\156\236\150\180"
L["Mission Duration"] = "\236\158\132\235\172\180 \236\167\128\236\134\141\236\139\156\234\176\132"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "\237\145\156\236\139\156\235\144\156 \236\158\132\235\172\180"
L["Mission shown for follower"] = "\236\182\148\236\162\133\236\158\144\236\151\144 \237\145\156\236\139\156\235\144\156 \236\158\132\235\172\180"
L["Mission Success"] = "\236\158\132\235\172\180 \236\132\177\234\179\181"
L["Mission time reduced!"] = "\236\158\132\235\172\180 \236\139\156\234\176\132 \234\176\144\236\134\140\235\144\168!"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "\235\130\174\236\157\128 \236\132\177\234\179\181 \237\153\149\235\165\160\236\157\152 \236\158\132\235\172\180\235\138\148 \235\172\180\236\139\156\237\149\169\235\139\136\235\139\164"
L["Missionlist"] = "\236\158\132\235\172\180 \235\170\169\235\161\157"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "\236\160\129\236\154\169\237\149\152\235\160\164\235\169\180 \236\157\184\237\132\176\237\142\152\236\157\180\236\138\164\235\165\188 \235\176\152\235\147\156\236\139\156 \236\158\172\236\139\156\236\158\145\237\149\180\236\149\188 \237\149\169\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "\237\153\149\236\157\184 \236\151\134\236\157\140"
L["No follower gained xp"] = "\234\178\189\237\151\152\236\185\152\235\165\188 \237\154\141\235\147\157\237\149\156 \236\182\148\236\162\133\236\158\144 \236\151\134\236\157\140"
L["No mission prefill"] = "\236\158\132\235\172\180 \235\175\184\235\166\172 \236\177\132\236\154\176\236\167\128 \236\149\138\234\184\176"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "\236\176\168\235\139\168 \235\170\169\235\161\157 \236\151\134\236\157\140"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "\235\179\180\234\179\160\237\149\160 \235\130\180\236\154\169 \236\151\134\236\157\140"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "\236\182\148\236\162\133\236\158\144\236\157\152 \236\136\152"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "\236\132\177\234\179\181 \237\153\149\235\165\160 %2$d%% \236\157\180\236\131\129\236\157\152 \236\178\171 %1$d\234\176\156 \236\158\132\235\172\180\235\167\140 \237\145\156\236\139\156\237\149\169\235\139\136\235\139\164"
L["Only meaningful upgrades are shown"] = "\236\157\152\235\175\184\236\158\136\235\138\148 \234\176\149\237\153\148\235\167\140 \237\145\156\236\139\156\237\149\169\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "%s\236\151\144 \236\157\152\237\149\156 \236\155\144\235\158\152\236\157\152 \234\176\156\235\133\144\234\179\188 \236\157\184\237\132\176\237\142\152\236\157\180\236\138\164"
L["Original method"] = "\236\155\144\235\158\152\236\157\152 \235\176\169\235\178\149"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "\236\155\144\235\158\152\236\157\152 \236\160\149\235\160\172\236\157\128 \236\155\144\235\158\152\236\157\152 \236\160\149\235\160\172 \235\176\169\235\178\149\236\157\132 \235\179\181\236\155\144\237\149\169\235\139\136\235\139\164 (\236\158\132\235\172\180\235\165\188 \236\160\149\235\160\172\237\149\152\235\138\148 \235\139\164\235\165\184 \236\149\160\235\147\156\236\152\168\236\157\180 \236\158\136\235\139\164\235\169\180 \235\139\164\236\139\156 \236\139\156\236\158\145\237\149\180\236\149\188 \237\149\169\235\139\136\235\139\164)"
L["Other"] = "\234\184\176\237\131\128"
L["Other rewards"] = "\234\184\176\237\131\128 \235\179\180\236\131\129"
L["Other settings"] = "\234\184\176\237\131\128 \236\132\164\236\160\149"
L["Other useful followers"] = "\235\139\164\235\165\184 \236\156\160\236\154\169\237\149\156 \236\182\148\236\162\133\236\158\144"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "%d / %d \236\158\132\235\172\180 \236\178\152\235\166\172 \236\164\145"
L["Profession"] = "\236\160\132\235\172\184 \234\184\176\236\136\160"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "\236\132\160\237\152\184 \236\162\133\236\161\177"
L["Rare missions will not be considered"] = "\237\157\172\234\183\128 \236\158\132\235\172\180\235\138\148 \234\179\160\235\160\164\237\149\152\236\167\128 \236\149\138\236\138\181\235\139\136\235\139\164"
L["Reagents"] = "\236\158\172\235\163\140"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "\237\143\137\237\140\144 \236\149\132\236\157\180\237\133\156"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "\235\179\180\236\131\129 \236\156\160\237\152\149"
L["Right-Click to blacklist"] = "\236\152\164\235\165\184\236\170\189 \237\129\180\235\166\173\237\149\152\236\151\172 \236\176\168\235\139\168"
L["Right-Click to remove from blacklist"] = "\236\152\164\235\165\184\236\170\189 \237\129\180\235\166\173\237\149\152\236\151\172 \236\176\168\235\139\168 \235\170\169\235\161\157\236\151\144\236\132\156 \236\160\156\234\177\176"
L["Rush orders"] = "\234\184\180\234\184\137 \236\163\188\235\172\184"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "\237\149\180\236\131\129 \237\149\168\235\140\128 \235\170\168\236\150\145"
L["Show Garrison Commander menu"] = "Garrison Commander \235\169\148\235\137\180 \237\145\156\236\139\156"
L["Show itemlevel"] = "\236\149\132\236\157\180\237\133\156 \235\160\136\235\178\168 \237\145\156\236\139\156"
L["Show upgrades"] = "\234\176\149\237\153\148 \237\145\156\236\139\156"
L["Show xp"] = "\234\178\189\237\151\152\236\185\152 \237\145\156\236\139\156"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "\237\149\153\236\130\180\236\158\144"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "\235\170\135\235\170\135 \236\182\148\236\162\133\236\158\144"
L["Sort missions by:"] = "\236\158\132\235\172\180 \236\160\149\235\160\172 \235\176\169\235\178\149:"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "\235\139\185\236\139\160\236\157\152 \236\158\132\235\172\180\235\165\188 \237\149\156\235\178\136\236\151\144 \236\160\156\236\182\156\237\149\169\235\139\136\235\139\164. \236\149\132\235\172\180 \234\178\131\235\143\132 \235\172\187\236\167\128 \236\149\138\236\138\181\235\139\136\235\139\164."
L["Success Chance"] = "\236\132\177\234\179\181 \237\153\149\235\165\160"
L["Swap upgrades positions"] = "\234\176\149\237\153\148 \236\156\132\236\185\152 \236\160\132\237\153\152"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "\236\158\132\235\172\180\236\151\144 Garrison Commander\236\153\128 Master Plan \236\157\184\237\132\176\237\142\152\236\157\180\236\138\164 \234\176\132\236\151\144 \236\160\132\237\153\152\237\149\152\234\184\176"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "\236\156\132\237\152\145 \236\154\148\236\134\140 \235\140\128\236\157\145"
L["To go: %d"] = "\235\160\136\235\178\168 \236\131\129\236\138\185: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Garrison Commander \235\169\148\235\137\180 \237\151\164\235\141\148 \236\188\156\234\184\176/\235\129\132\234\184\176 \236\160\132\237\153\152"
L["Toys and Mounts"] = "\236\158\165\235\130\156\234\176\144\234\179\188 \237\131\136\234\178\131"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "\236\132\160\237\131\157\237\149\180\236\160\156\237\149\152\235\169\180 \234\176\129 \235\179\180\236\131\129 \236\156\160\237\152\149\236\151\144 \237\138\185\236\160\149 \236\132\177\234\179\181 \237\153\149\235\165\160\236\157\132 \236\132\164\236\160\149\237\149\160 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "\236\176\189 \236\158\160\234\184\136\237\149\180\236\160\156"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "%1$s\236\151\144\236\132\156 %2$d \236\149\132\236\157\180\237\133\156 \235\160\136\235\178\168\235\161\156 \234\176\149\237\153\148"
L["Upgrading to |cff00ff00%d|r"] = "|cff00ff00%d|r|1\236\156\188\235\161\156;\235\161\156; \236\151\133\234\183\184\235\160\136\236\157\180\235\147\156 \236\164\145"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "\237\129\176 \237\153\148\235\169\180 \236\130\172\236\154\169"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "GC \236\157\184\237\132\176\237\142\152\236\157\180\236\138\164 \236\130\172\236\154\169"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "\235\176\169\236\150\180\234\181\172 \237\134\160\237\129\176 \236\130\172\236\154\169"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "\235\172\180\234\184\176 \237\134\160\237\129\176 \236\130\172\236\154\169"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "\236\132\160\237\131\157\237\149\152\235\169\180 \234\176\129 \236\182\148\236\162\133\236\158\144 \235\178\132\237\138\188\236\151\144 \235\139\164\236\157\140 \235\160\136\235\178\168\234\185\140\236\167\128 \235\182\128\236\161\177\237\149\156 \234\178\189\237\151\152\236\185\152\234\176\128 \237\145\156\236\139\156\235\144\169\235\139\136\235\139\164"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "\236\132\160\237\131\157\237\149\152\235\169\180 \236\181\156\234\179\160 \235\160\136\235\178\168 \236\182\148\236\162\133\236\158\144\236\157\152 \235\172\180\234\184\176\236\153\128 \235\176\169\236\150\180\234\181\172 \235\160\136\235\178\168\236\157\180 \234\176\129 \236\182\148\236\162\133\236\158\144 \235\178\132\237\138\188\236\151\144 \237\145\156\236\139\156\235\144\169\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
L["Xp incremented!"] = "\234\178\189\237\151\152\236\185\152 \236\166\157\234\176\128\235\144\168!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "|cffff0000%d|cffffd200 \237\143\172\236\157\184\237\138\184\235\165\188 \235\130\173\235\185\132 \236\164\145\236\158\133\235\139\136\235\139\164!!!"
L["You can also send mission one by one clicking on each button."] = "\234\176\129 \235\178\132\237\138\188\236\157\132 \237\149\156\235\178\136 \237\129\180\235\166\173\237\149\152\236\151\172 \236\158\132\235\172\180\235\165\188 \237\149\152\235\130\152\236\148\169 \235\179\180\235\130\188 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164."
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "\236\154\176\236\184\161 \236\131\129\235\139\168 \235\170\168\236\132\156\235\166\172\236\151\144 \236\158\136\235\138\148 \236\149\132\236\157\180\236\189\152\236\157\132 \237\129\180\235\166\173\237\149\152\235\169\180 \235\169\148\235\137\180\235\165\188 \236\151\180 \236\136\152 \236\158\136\236\138\181\235\139\136\235\139\164"
L["You have ignored followers"] = "\235\172\180\236\139\156\235\144\156 \236\182\148\236\162\133\236\158\144\234\176\128 \236\158\136\236\138\181\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "\236\157\180 \236\158\132\235\172\180\235\165\188 \236\136\152\237\150\137\237\149\156 \236\160\129\236\157\180 \236\151\134\236\138\181\235\139\136\235\139\164"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "\236\157\180 \236\158\132\235\172\180\235\165\188 \235\139\164\236\157\140\236\157\152 \236\132\177\234\179\181 \237\153\149\235\165\160\235\161\156 %d\235\178\136 \236\136\152\237\150\137\237\150\136\236\138\181\235\139\136\235\139\164:"

return
end
L=l:NewLocale(me,"esMX")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["%s |4follower:followers; with %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["(Ignores low bias ones)"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Add %1$d levels to %2$s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Adds a list of other useful followers to tooltip"] = ""--]] 
--[[Translation missing --]]
--[[ L["Affects only little screen mode, hiding the per follower mission list if not checked"] = ""--]] 
--[[Translation missing --]]
--[[ L["Allowed Rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applied when 'maximize result' is enabled. Default is 80%"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best armor set"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best armor upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best weapon set"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best weapon upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Archaelogy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
--[[Translation missing --]]
--[[ L["Big screen"] = ""--]] 
--[[Translation missing --]]
--[[ L["Blacklisted"] = ""--]] 
--[[Translation missing --]]
--[[ L["Blacklisted missions are ignored in Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Building Final report"] = ""--]] 
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped %1$s. Spend at least %2$d of them"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
--[[Translation missing --]]
--[[ L["Complete all missions without confirmation"] = ""--]] 
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consider again"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable if you dont want the full Garrison Commander Header."] = ""--]] 
--[[Translation missing --]]
--[[ L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
--[[Translation missing --]]
--[[ L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""--]] 
--[[Translation missing --]]
--[[ L["Do not show follower icon on plots"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration Time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enhance tooltip"] = ""--]] 
--[[Translation missing --]]
--[[ L["Environment Preference"] = ""--]] 
--[[Translation missing --]]
--[[ L["Epic followers are NOT sent alone on xp only missions"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Expiration Time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower equipment set or upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower experience"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower set minimum upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower Training"] = ""--]] 
--[[Translation missing --]]
--[[ L["Followers status "] = ""--]] 
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Appearance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Comander Quick Mission Completion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Commander Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global approx. xp reward"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global success chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gold incremented!"] = ""--]] 
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Hide followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = ""--]] 
--[[Translation missing --]]
--[[ L["IF checked, shows armors on the left and weapons on the right "] = ""--]] 
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["If you continue, you will lose them"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["IF you have a Salvage Yard you probably dont want to have this one checked"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore \"maxed\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore epic for xp missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore for all missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore rare missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Increased Rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item minimum level"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Left Click to see available missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Legendary Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
--[[Translation missing --]]
--[[ L["Level 100 epic followers are not used for xp only missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes main mission panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes shipyard panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximize result"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximum mission duration."] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum mission duration."] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum needed chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum requested level for equipment rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum requested upgrade for followers set (Enhancements are always included)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimun chance success under which ignore missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minumum needed chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Duration"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission shown for follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Success"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission time reduced!"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission with lower success chance will be ignored"] = ""--]] 
--[[Translation missing --]]
--[[ L["Missionlist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Must reload interface to apply"] = ""--]] 
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["No confirmation"] = ""--]] 
--[[Translation missing --]]
--[[ L["No follower gained xp"] = ""--]] 
--[[Translation missing --]]
--[[ L["No mission prefill"] = ""--]] 
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Not blacklisted"] = ""--]] 
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
--[[Translation missing --]]
--[[ L["Nothing to report"] = ""--]] 
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
--[[Translation missing --]]
--[[ L["Number of followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only meaningful upgrades are shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original concept and interface by %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original method"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other settings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other useful followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
--[[Translation missing --]]
--[[ L["Processing mission %d of %d"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Racial Preference"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rare missions will not be considered"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reward type"] = ""--]] 
--[[Translation missing --]]
--[[ L["Right-Click to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Right-Click to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rush orders"] = ""--]] 
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shipyard Appearance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show Garrison Commander menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show xp"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Slayer"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Some follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sort missions by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
--[[Translation missing --]]
--[[ L["Submit all your mission at once. No question asked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Success Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Swap upgrades positions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Switch between Garrison Commander and Master Plan interface for missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
--[[Translation missing --]]
--[[ L["Threat Counter"] = ""--]] 
--[[Translation missing --]]
--[[ L["To go: %d"] = ""--]] 
--[[Translation missing --]]
--[[ L["Toggles Garrison Commander Menu Header on/off"] = ""--]] 
--[[Translation missing --]]
--[[ L["Toys and Mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unchecking this will allow you to set specific success chance for each reward type"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock Panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
--[[Translation missing --]]
--[[ L["Upgrade %1$s to  %2$d itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Upgrading to |cff00ff00%d|r"] = ""--]] 
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use big screen"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use GC Interface"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses armor token"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses weapon token"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["When checked, show on each follower button missing xp to next level"] = ""--]] 
--[[Translation missing --]]
--[[ L["When checked, show on each follower button weapon and armor level for maxed followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
--[[Translation missing --]]
--[[ L["Xp incremented!"] = ""--]] 
--[[Translation missing --]]
--[[ L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = ""--]] 
--[[Translation missing --]]
--[[ L["You can also send mission one by one clicking on each button."] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can open the menu clicking on the icon in top right corner"] = ""--]] 
--[[Translation missing --]]
--[[ L["You have ignored followers"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You never performed this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["You performed this mission %d times with a win ratio of"] = ""--]] 

return
end
L=l:NewLocale(me,"ruRU")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4\209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176:\209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\184; \209\129 %s"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "(\208\152\208\179\208\189\208\190\209\128\208\184\209\128\209\131\208\181\209\130 \208\189\208\184\208\183\208\186\208\184\208\185 \209\131\209\128\208\190\208\178\208\181\208\189\209\140 \209\129\208\188\208\181\209\137\208\181\208\189\208\184\209\143)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "\208\148\208\190\208\177\208\176\208\178\209\140\209\130\208\181 %1$d \209\131\209\128\208\190\208\178\208\189\208\184 \208\178 %2$s"
L["Adds a list of other useful followers to tooltip"] = "\208\148\208\190\208\177\208\176\208\178\208\187\209\143\208\181\209\130 \209\129\208\191\208\184\209\129\208\190\208\186 \208\180\209\128\209\131\208\179\208\184\209\133 \208\191\208\190\208\187\208\181\208\183\208\189\209\139\209\133 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178 \208\178\208\190 \208\178\209\129\208\191\208\187\209\139\208\178\208\176\209\142\209\137\209\131\209\142 \208\191\208\190\208\180\209\129\208\186\208\176\208\183\208\186\209\131"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "\208\146\208\187\208\184\209\143\208\181\209\130 \209\130\208\190\208\187\209\140\208\186\208\190 \208\189\208\176 \208\189\208\181\208\177\208\190\208\187\209\140\209\136\208\190\208\185 \209\141\208\186\209\128\208\176\208\189\208\189\209\139\208\185 \209\128\208\181\208\182\208\184\208\188, \209\129\208\186\209\128\209\139\208\178\208\176\209\143 \209\129\208\191\208\184\209\129\208\190\208\186 \208\188\208\184\209\129\209\129\208\184\208\185 \208\180\208\187\209\143 \208\186\208\176\208\182\208\180\208\190\208\179\208\190 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176, \208\181\209\129\208\187\208\184 \208\189\208\181 \209\131\209\129\209\130\208\176\208\189\208\190\208\178\208\187\208\181\208\189 \209\132\208\187\208\176\208\182\208\190\208\186"
L["Allowed Rewards"] = "\208\160\208\176\208\183\209\128\208\181\209\136\208\181\208\189\208\189\209\139\208\181 \208\189\208\176\208\179\209\128\208\176\208\180\209\139"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "\208\159\208\190\208\183\208\178\208\190\208\187\209\143\208\181\209\130 \209\129\208\189\208\184\208\183\208\184\209\130\209\140 \208\191\209\128\208\190\209\134\208\181\208\189\209\130 \209\131\209\129\208\191\208\181\209\133\208\176 \208\180\208\187\209\143 \208\188\208\184\209\129\209\129\208\184\208\185 \209\129 \209\128\208\181\209\129\209\131\209\128\209\129\208\176\208\188\208\184. \208\152\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\185\209\130\208\181 \208\186\208\190\208\188\208\176\208\189\208\180\209\131 /gac \208\180\208\187\209\143 \208\184\208\183\208\188\208\181\208\189\208\181\208\189\208\184\209\143 \208\191\209\128\208\190\209\134\208\181\208\189\209\130\208\176. \208\159\208\190 \209\131\208\188\208\190\208\187\209\135\208\176\208\189\208\184\209\142 80%"
L["Always counter increased resource cost"] = "\208\146\209\129\208\181\208\179\208\180\208\176 \208\190\209\130\209\128\208\176\208\182\208\176\209\130\209\140 \209\131\208\178\208\181\208\187\208\184\209\135\208\181\208\189\208\184\208\181 \209\129\209\130\208\190\208\184\208\188\208\190\209\129\209\130\208\184"
L["Always counter increased time"] = "\208\146\209\129\208\181\208\179\208\180\208\176 \208\190\209\130\209\128\208\176\208\182\208\176\209\130\209\140 \209\131\208\178\208\181\208\187\208\184\209\135\208\181\208\189\208\184\208\181 \208\178\209\128\208\181\208\188\208\181\208\189\208\184"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "\208\146\209\129\208\181\208\179\208\180\208\176 \208\190\209\130\209\128\208\176\208\182\208\176\209\130\209\140 \209\131\208\177\208\184\208\185\209\129\209\130\208\178\208\190 \208\190\209\130\209\128\209\143\208\180\208\190\208\178 (\208\184\208\179\208\189\208\190\209\128\208\184\209\128\209\131\208\181\209\130\209\129\209\143 \208\180\208\187\209\143 \208\190\209\130\209\128\209\143\208\180\208\190\208\178 \209\129 \208\190\208\180\208\189\208\190\208\185 \208\181\208\180\208\184\208\189\208\184\209\134\208\184\208\185 \208\182\208\184\208\183\208\189\208\176\208\189\208\189\208\190\208\185 \209\129\208\184\208\187\209\139)"
L["Always counter no bonus loot threat"] = "\208\146\209\129\208\181\208\179\208\180\208\176 \208\190\209\130\209\128\208\176\208\182\208\176\209\130\209\140 \208\190\209\130\209\129\209\131\209\130\209\129\209\130\208\178\208\184\208\181 \208\177\208\190\208\189\209\131\209\129\208\176"
L["Analyze parties"] = "\208\144\208\189\208\176\208\187\208\184\208\183\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\179\209\128\209\131\208\191\208\191\209\139"
L["and then by:"] = "\208\184 \208\191\208\190\209\130\208\190\208\188 \208\191\208\190:"
L["Applied when 'maximize result' is enabled. Default is 80%"] = "\208\159\209\128\208\184\208\188\208\181\208\189\209\143\208\181\209\130\209\129\209\143, \208\186\208\190\208\179\208\180\208\176 \208\178\208\186\208\187\209\142\209\135\208\181\208\189 \208\191\208\176\209\128\208\176\208\188\208\181\209\130\209\128 \194\171\208\188\208\176\208\186\209\129\208\184\208\188\208\184\208\183\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\128\208\181\208\183\209\131\208\187\209\140\209\130\208\176\209\130\194\187. \208\159\208\190 \209\131\208\188\208\190\208\187\209\135\208\176\208\189\208\184\209\142 80%"
L["Applies the best armor set"] = "\208\159\209\128\208\184\208\188\208\181\208\189\209\143\208\181\209\130 \208\187\209\131\209\135\209\136\208\184\208\185 \208\186\208\190\208\188\208\191\208\187\208\181\208\186\209\130 \208\177\209\128\208\190\208\189\208\184"
L["Applies the best armor upgrade"] = "\208\159\209\128\208\184\208\188\208\181\208\189\209\143\208\181\209\130 \208\187\209\131\209\135\209\136\208\181\208\181 \208\190\208\177\208\189\208\190\208\178\208\187\208\181\208\189\208\184\208\181 \208\177\209\128\208\190\208\189\208\184"
L["Applies the best weapon set"] = "\208\159\209\128\208\184\208\188\208\181\208\189\209\143\208\181\209\130 \208\187\209\131\209\135\209\136\208\184\208\185 \208\189\208\176\208\177\208\190\209\128 \208\190\209\128\209\131\208\182\208\184\209\143"
L["Applies the best weapon upgrade"] = "\208\159\209\128\208\184\208\188\208\181\208\189\209\143\208\181\209\130 \208\187\209\131\209\135\209\136\208\181\208\181 \208\190\208\177\208\189\208\190\208\178\208\187\208\181\208\189\208\184\208\181 \208\190\209\128\209\131\208\182\208\184\209\143"
L["Archaelogy"] = "\208\144\209\128\209\133\208\181\208\190\208\187\208\190\208\179\208\184\209\143"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
L["Attempting %s"] = "\208\159\209\139\209\130\208\176\208\181\208\188\209\129\209\143 %s"
L["Base Chance"] = "\208\145\208\176\208\183\208\190\208\178\208\176\208\185 \209\136\208\176\208\189\209\129"
L["Better parties available in next future"] = "\208\145\208\190\208\187\208\181\208\181 \208\187\209\131\209\135\209\136\208\184\208\181 \208\179\209\128\209\131\208\191\208\191\209\139 \209\129\209\130\208\176\208\189\209\131\209\130 \208\180\208\190\209\129\209\130\209\131\208\191\208\189\209\139 \208\178 \208\177\208\187\208\184\208\182\208\176\208\185\209\136\208\181\208\181 \208\178\209\128\208\181\208\188\209\143"
L["Big screen"] = "\208\145\208\190\208\187\209\140\209\136\208\190\208\185 \209\141\208\186\209\128\208\176\208\189"
L["Blacklisted"] = "\208\167\209\145\209\128\208\189\209\139\208\185 \209\129\208\191\208\184\209\129\208\190\208\186"
L["Blacklisted missions are ignored in Mission Control"] = "\208\156\208\184\209\129\209\129\208\184\208\184 \208\184\208\183 \209\135\208\181\209\128\208\189\208\190\208\179\208\190 \209\129\208\191\208\184\209\129\208\186\208\176 \208\184\208\179\208\189\208\190\209\128\208\184\209\128\209\131\209\142\209\130\209\129\209\143 \208\178 \209\131\208\191\209\128\208\176\208\178\208\187\208\181\208\189\208\184\208\184 \208\188\208\184\209\129\209\129\208\184\209\143\208\188\208\184"
L["Bonus Chance"] = "\208\168\208\176\208\189\209\129 \208\177\208\190\208\189\209\131\209\129\208\176"
L["Building Final report"] = "\208\159\208\190\209\129\209\130\209\128\208\190\208\181\208\189\208\184\208\181 \208\190\208\186\208\190\208\189\209\135\208\176\209\130\208\181\208\187\209\140\208\189\208\190\208\179\208\190 \208\190\209\130\209\135\208\181\209\130\208\176"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = [=[\208\148\208\190\209\129\209\130\208\184\208\179\208\189\209\131\209\130\208\190 %1$. \208\159\208\190\209\130\209\128\208\176\209\130\209\140\209\130\208\181 \209\133\208\190\209\130\209\143 \208\177\209\139 2%$
]=]
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "\208\151\208\176\208\178\208\181\209\128\209\136\208\184\209\130\209\140 \208\178\209\129\208\181 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \208\177\208\181\208\183 \208\191\208\190\208\180\209\130\208\178\208\181\209\128\208\182\208\180\208\181\208\189\208\184\209\143"
L["Configuration for mission party builder"] = "\208\157\208\176\209\129\209\130\209\128\208\190\208\185\208\186\208\184 \208\191\208\190\209\129\209\130\209\128\208\190\208\184\209\130\208\181\208\187\209\143 \208\179\209\128\209\131\208\191\208\191 \208\180\208\187\209\143 \208\183\208\176\208\180\208\176\208\189\208\184\208\185"
L["Consider again"] = "\208\146\208\189\208\190\208\178\209\140 \209\128\208\176\209\129\209\129\208\188\208\190\209\130\209\128\208\181\209\130\209\140"
L["Cost reduced"] = "\208\161\209\130\208\190\208\184\208\188\208\190\209\129\209\130\209\140 \209\131\208\188\208\181\208\189\209\140\209\136\208\181\208\189\208\176"
L["Could not fulfill mission, aborting"] = "\208\157\208\181\208\178\208\190\208\183\208\188\208\190\208\182\208\189\208\190 \208\183\208\176\208\191\208\190\208\187\208\189\208\184\209\130\209\140 \208\179\209\128\209\131\208\191\208\191\209\139 \208\180\208\187\209\143 \208\183\208\176\208\180\208\176\208\189\208\184\209\143. \208\158\209\130\208\188\208\181\208\189\209\143\208\181\208\188"
L["Counter kill Troops"] = "\208\159\208\176\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\129\208\188\208\181\209\128\209\130\209\140 \208\190\209\130\209\128\209\143\208\180\208\190\208\178"
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
L["Disable blacklisting"] = "\208\151\208\176\208\191\209\128\208\181\209\130\208\184\209\130\209\140 \208\180\208\190\208\177\208\176\208\178\208\187\208\181\208\189\208\184\208\181 \208\178 \209\135\209\145\209\128\208\189\209\139\208\185 \209\129\208\191\208\184\209\129\208\190\208\186"
L["Disable if you dont want the full Garrison Commander Header."] = "\208\158\209\130\208\186\208\187\209\142\209\135\208\184\209\130\208\181, \208\181\209\129\208\187\208\184 \208\178\209\139 \208\189\208\181 \209\133\208\190\209\130\208\184\209\130\208\181 \208\191\208\190\208\187\208\189\209\139\208\185 \208\183\208\176\208\179\208\190\208\187\208\190\208\178\208\190\208\186 Garrison Commander."
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "\208\158\209\130\208\186\208\187\209\142\209\135\208\176\208\181\209\130 \208\176\208\178\209\130\208\190\208\188\208\176\209\130\208\184\209\135\208\181\209\129\208\186\208\190\208\181 \208\183\208\176\208\191\208\190\208\187\208\189\208\181\208\189\208\184\208\181 \209\141\208\186\209\128\208\176\208\189\208\176 \209\129\209\130\209\128\208\176\208\189\208\184\209\134\209\139 \208\188\208\184\209\129\209\129\208\184\208\184. \208\146\209\139 \209\130\208\176\208\186\208\182\208\181 \208\188\208\190\208\182\208\181\209\130\208\181 \208\189\208\176\208\182\208\176\209\130\209\140 \208\186\208\189\208\190\208\191\208\186\209\131 \209\131\208\191\209\128\208\176\208\178\208\187\208\181\208\189\208\184\209\143, \209\135\209\130\208\190\208\177\209\139 \208\190\209\130\208\186\208\187\209\142\209\135\208\184\209\130\209\140 \208\181\208\179\208\190 \208\180\208\187\209\143 \208\190\208\180\208\189\208\190\208\185 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Disables warning: "] = "\208\151\208\176\208\191\209\128\208\181\209\137\208\176\208\181\209\130 \208\191\209\128\208\181\208\180\209\131\208\191\209\128\208\181\208\182\208\180\208\181\208\189\208\184\209\143:"
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "\208\158\209\130\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181 \209\141\209\130\208\190\208\179\208\190 \208\191\208\176\209\128\208\176\208\188\208\181\209\130\209\128\208\176 \208\180\208\176\209\129\209\130 \208\178\208\176\208\188 \208\184\208\189\209\130\208\181\209\128\209\132\208\181\208\185\209\129 \208\178\208\181\209\128\209\129\208\184\208\184 1.1.8. \208\157\208\181\208\190\208\177\209\133\208\190\208\180\208\184\208\188\208\190 \208\191\208\181\209\128\208\181\208\183\208\176\208\179\209\128\209\131\208\183\208\184\209\130\209\140 \208\184\208\189\209\130\208\181\209\128\209\132\208\181\208\185\209\129"
L["Do not show follower icon on plots"] = "\208\157\208\181 \208\191\208\190\208\186\208\176\208\183\209\139\208\178\208\176\209\130\209\140 \208\183\208\189\208\176\209\135\208\190\208\186 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176 \208\189\208\176 \208\179\209\128\208\176\209\132\208\184\208\186\208\176\209\133"
L["Dont use this slot"] = "\208\157\208\181 \208\184\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \209\141\209\130\208\190\209\130 \209\129\208\187\208\190\209\130"
L["Don't use troops"] = "\208\157\208\181 \208\184\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \208\190\209\130\209\128\209\143\208\180\209\139"
L["Duration reduced"] = "\208\148\208\187\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140 \209\131\208\188\208\181\208\189\209\140\209\136\208\181\208\189\208\176"
L["Duration Time"] = "\208\159\209\128\208\190\208\180\208\190\208\187\208\182\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140"
L["Elite: Prefer overcap"] = "\208\173\208\187\208\184\209\130\208\189\209\139\208\181: \208\191\209\128\208\181\208\180\208\191\208\190\209\135\208\181\209\129\209\130\209\140 \208\184\208\183\208\177\209\139\209\130\208\190\209\135\208\189\208\190\209\129\209\130\209\140"
L["Elites mission mode"] = "\208\160\208\181\208\182\208\184\208\188 \209\141\208\187\208\184\209\130\208\189\209\139\209\133 \208\183\208\176\208\180\208\176\208\189\208\184\208\185"
L["Empty missions sorted as last"] = "\208\159\209\131\209\129\209\130\209\139\208\181 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \208\190\209\130\209\129\208\190\209\128\209\130\208\184\209\128\208\190\208\178\208\176\208\189\209\139 \208\191\208\190\209\129\208\187\208\181\208\180\208\189\208\184\208\188\208\184"
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "\208\163\208\187\209\131\209\135\209\136\208\184\209\130\209\140 \208\191\208\190\208\180\209\129\208\186\208\176\208\183\208\186\209\131"
L["Environment Preference"] = "\208\158\208\186\209\128\209\131\208\182\208\176\209\142\209\137\208\176\209\143 \209\129\209\128\208\181\208\180\208\176"
L["Epic followers are NOT sent alone on xp only missions"] = "\208\173\208\191\208\184\209\135\208\181\209\129\208\186\208\184\208\181 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\184 \208\189\208\181 \208\190\209\130\208\191\209\128\208\176\208\178\208\187\209\143\209\142\209\130\209\129\209\143 \208\178 \208\190\208\180\208\184\208\189\208\190\209\135\208\186\209\131 \208\189\208\176 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \208\191\208\190 \208\191\208\190\208\187\209\131\209\135\208\181\208\189\208\184\209\142 \208\190\208\191\209\139\209\130\208\176"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "\208\146\209\128\208\181\208\188\209\143 \208\190\208\186\208\190\208\189\209\135\208\176\208\189\208\184\209\143 \209\129\209\128\208\190\208\186\208\176 \208\180\208\181\208\185\209\129\209\130\208\178\208\184\209\143"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "\208\161\208\190\209\128\208\176\209\130\208\189\208\184\208\186"
L["Follower equipment set or upgrade"] = "\208\163\208\187\209\131\209\135\209\136\208\181\208\189\208\184\208\181 \209\141\208\186\208\184\208\191\208\184\209\128\208\190\208\178\208\186\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
L["Follower experience"] = "\208\158\208\191\209\139\209\130 \208\161\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
L["Follower set minimum upgrade"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\208\190\208\181 \209\131\208\187\209\131\209\135\209\136\208\181\208\189\208\184\208\181 \209\141\208\186\208\184\208\191\208\184\209\128\208\190\208\178\208\186\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
L["Follower Training"] = "\208\162\209\128\208\181\208\189\208\184\209\128\208\190\208\178\208\186\208\176 \208\161\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
L["Followers status "] = "\208\161\209\130\208\176\209\130\209\131\209\129 \208\161\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "\208\146\208\189\208\181\209\136\208\189\208\184\208\185 \208\178\208\184\208\180 \208\179\208\176\209\128\208\189\208\184\208\183\208\190\208\189\208\176"
L["Garrison Comander Quick Mission Completion"] = "Garrison Comander \208\145\209\139\209\129\209\130\209\128\208\190\208\181 \208\183\208\176\208\178\208\181\209\128\209\136\208\181\208\189\208\184\208\181 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Garrison Commander Mission Control"] = "Garrison Commander \208\166\208\181\208\189\209\130\209\128 \208\163\208\191\209\128\208\176\208\178\208\187\208\181\208\189\208\184\209\143 "
L["General"] = "\208\158\209\129\208\189\208\190\208\178\208\189\208\190\208\181"
L["Global approx. xp reward"] = "\208\158\208\177\209\137\208\181\208\181 \208\191\209\128\208\184\208\177\208\184\208\182\208\181\208\189\208\184\208\181 \208\191\208\190\208\187\209\131\209\135\208\181\208\189\208\184\209\143 \208\190\208\191\209\139\209\130\208\176"
L["Global approx. xp reward per hour"] = "\208\158\208\177\209\137\208\181\208\181 \208\191\209\128\208\184\208\177\208\184\208\182\208\181\208\189\208\184\208\181 \208\191\208\190\208\187\209\131\209\135\208\181\208\189\208\184\209\143 \208\190\208\191\209\139\209\130\208\176 \208\178 \209\135\208\176\209\129"
L["Global success chance"] = "\208\147\208\187\208\190\208\177\208\176\208\187\209\140\208\189\209\139\208\185 \209\136\208\176\208\189\209\129 \208\189\208\176 \209\131\209\129\208\191\208\181\209\133"
L["Gold incremented!"] = "\208\151\208\190\208\187\208\190\209\130\208\190 \208\191\209\128\208\184\208\177\208\176\208\178\208\184\208\187\208\190\209\129\209\140!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "\208\161\208\186\209\128\209\139\209\130\209\140 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "\208\149\209\129\208\187\208\184 \209\141\209\130\208\190\209\130 \209\132\208\187\208\176\208\182\208\190\208\186 \209\131\209\129\209\130\208\176\208\189\208\190\208\178\208\187\208\181\208\189, \208\189\208\176\208\182\208\176\209\130\208\184\208\181 \208\189\208\176 \208\183\208\189\208\176\209\135\208\190\208\186 \208\190\208\177\208\189\208\190\208\178\208\187\208\181\208\189\208\184\209\143 \208\191\209\128\208\184\208\178\208\181\208\180\208\181\209\130 \208\186 \209\131\209\129\208\184\208\187\208\181\208\189\208\184\209\142 \209\141\208\186\208\184\208\191\208\184\209\128\208\190\208\178\208\186\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176, |cFFFF0000NO QUESTION ASKED|r"
L["IF checked, shows armors on the left and weapons on the right "] = "\208\149\209\129\208\187\208\184 \208\190\209\130\208\188\208\181\209\135\208\181\208\189, \208\191\208\190\208\186\208\176\208\183\209\139\208\178\208\176\208\181\209\130 \208\180\208\190\209\129\208\191\208\181\209\133\208\184 \209\129\208\187\208\181\208\178\208\176 \208\184 \208\190\209\128\209\131\208\182\208\184\208\181 \209\129\208\191\209\128\208\176\208\178\208\176"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "\208\149\209\129\208\187\208\184 \208\178\209\139 \208\191\209\128\208\190\208\180\208\190\208\187\208\182\208\184\209\130\208\181, \208\178\209\139 \208\191\208\190\209\130\208\181\209\128\209\143\208\181\209\130\208\181 \208\184\209\133"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "\208\149\209\129\208\187\208\184 \209\131 \208\178\208\176\209\129 \208\181\209\129\209\130\209\140 \208\161\208\186\208\187\208\176\208\180 \208\163\209\130\208\184\208\187\209\143 \208\178\209\139 \208\178\208\181\209\128\208\190\209\143\209\130\208\189\208\190 \208\189\208\181 \209\133\208\190\209\130\208\184\209\130\208\181 \209\135\209\130\208\190\208\177\209\139 \208\181\208\179\208\190 \208\191\209\128\208\190\208\178\208\181\209\128\208\184\208\187\208\184 "
L["Ignore \"maxed\""] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\131\208\182\208\181 \209\131\208\187\209\131\209\135\209\136\208\181\208\189\208\189\209\139\209\133 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
L["Ignore busy followers"] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\183\208\176\208\189\209\143\209\130\209\139\209\133 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
L["Ignore epic for xp missions."] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\141\208\191\208\184\208\186\208\184 \208\180\208\187\209\143 \208\188\208\184\209\129\209\129\208\184\208\185 \208\189\208\176 \208\190\208\191\209\139\209\130. "
L["Ignore for all missions"] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\178\209\129\208\181 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Ignore for this mission"] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\141\209\130\209\131 \208\188\208\184\209\129\209\129\208\184\209\142"
L["Ignore inactive followers"] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\189\208\181\208\176\208\186\209\130\208\184\208\178\208\189\209\139\209\133 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
L["Ignore rare missions"] = "\208\152\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\128\208\181\208\180\208\186\208\184\208\181 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Increased Rewards"] = "\208\163\208\178\208\181\208\187\208\184\209\135\208\181\208\189\208\184\208\181 \208\178\208\190\208\183\208\189\208\176\208\179\209\128\208\176\208\182\208\180\208\181\208\189\208\184\209\143"
L["Item minimum level"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\209\139\208\185 \209\131\209\128\208\190\208\178\208\181\208\189\209\140 \208\191\209\128\208\181\208\180\208\188\208\181\209\130\208\190\208\178"
L["Item Tokens"] = "\208\162\208\190\208\186\208\181\208\189"
L["Keep cost low"] = "\208\163\208\188\208\181\208\189\209\140\209\136\208\176\209\130\209\140 \209\129\209\130\208\190\208\184\208\188\208\190\209\129\209\130\209\140"
L["Keep extra bonus"] = "\208\148\208\190\208\177\208\184\208\178\208\176\209\130\209\140\209\129\209\143 \208\180\208\190\208\191\208\190\208\187\208\189\208\184\209\130\208\181\208\187\209\140\208\189\208\190\208\179\208\190 \208\177\208\190\208\189\209\131\209\129\208\176"
L["Keep time short"] = "\208\161\208\180\208\181\208\187\208\176\209\130\209\140 \208\178\209\128\208\181\208\188\209\143 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \208\186\208\190\209\128\208\190\209\130\208\186\208\184\208\188"
L["Keep time VERY short"] = "\208\161\208\180\208\181\208\187\208\176\209\130\209\140 \208\178\209\128\208\181\208\188\209\143 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \208\190\209\135\208\181\208\189\209\140 \208\186\208\190\209\128\208\190\209\130\208\186\208\184\208\188"
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "\208\169\208\181\208\187\208\186\208\189\208\184\209\130\208\181 \208\187\208\181\208\178\208\190\208\185 \208\186\208\189\208\190\208\191\208\186\208\190\208\185 \208\188\209\139\209\136\208\184, \209\135\209\130\208\190\208\177\209\139 \209\131\208\178\208\184\208\180\208\181\209\130\209\140 \208\180\208\190\209\129\209\130\209\131\208\191\208\189\209\139\208\181 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Legendary Items"] = "\208\155\208\181\208\179\208\181\208\189\208\180\208\176\209\128\208\189\209\139\208\185 \208\191\209\128\208\181\208\180\208\188\208\181\209\130"
L["Level"] = "\208\163\209\128\208\190\208\178\208\181\208\189\209\140"
L["Level 100 epic followers are not used for xp only missions."] = "\208\173\208\191\208\184\209\135\208\181\209\129\208\186\208\184\208\181 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\184 100 \209\131\209\128\208\190\208\178\208\189\209\143 \208\189\208\181 \208\184\209\129\208\191\208\190\208\187\209\140\208\183\209\131\209\142\209\130\209\129\209\143 \209\130\208\190\208\187\209\140\208\186\208\190 \208\180\208\187\209\143 \208\188\208\184\209\129\209\129\208\184\208\185 \208\189\208\176 \208\190\208\191\209\139\209\130."
L["Lock all"] = "\208\151\208\176\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\178\209\129\208\181\209\133"
L["Lock this follower"] = "\208\151\208\176\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\141\209\130\208\190\208\179\208\190 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "\208\148\208\181\208\187\208\176\208\181\209\130 \208\179\208\187\208\176\208\178\208\189\209\131\209\142 \208\191\208\176\208\189\208\181\208\187\209\140 \208\188\208\184\209\129\209\129\208\184\208\184 \208\191\208\190\208\180\208\178\208\184\208\182\208\189\208\190\208\185"
L["Makes shipyard panel movable"] = "\208\148\208\181\208\187\208\176\208\181\209\130 \208\191\208\176\208\189\208\181\208\187\209\140 \209\132\208\187\208\190\209\130\208\176 \208\191\208\190\208\180\208\178\208\184\208\182\208\189\208\190\208\185"
L["Makes sure that no troops will be killed"] = "\208\163\208\177\208\181\208\180\208\184\209\130\209\140\209\129\209\143, \209\135\209\130\208\190 \208\190\209\130\209\128\209\143\208\180\209\139 \208\189\208\181 \208\191\208\190\208\179\208\184\208\177\208\189\209\131\209\130"
L["Max champions"] = "\208\156\208\176\208\186\209\129\208\184\208\188\208\176\208\187\209\140\208\189\208\190 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
L["Maximize result"] = "\208\156\208\176\208\186\209\129\208\184\208\188\208\184\208\183\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\128\208\181\208\183\209\131\208\187\209\140\209\130\208\176\209\130"
L["Maximize xp gain"] = "\208\156\208\176\208\186\209\129\208\184\208\188\208\184\208\183\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\191\208\190\208\187\209\131\209\135\208\176\208\181\208\188\209\139\208\185 \208\190\208\191\209\139\209\130"
L["Maximum mission duration."] = "\208\156\208\176\208\186\209\129\208\184\208\188\208\176\208\187\209\140\208\189\208\176\209\143 \208\191\209\128\208\190\208\180\208\190\208\187\208\182\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140 \208\188\208\184\209\129\209\129\208\184\208\184."
L["Minimum chance"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\209\139\208\181 \209\136\208\176\208\189\209\129\209\139"
L["Minimum mission duration."] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\208\176\209\143 \208\191\209\128\208\190\208\180\208\190\208\187\208\182\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140 \208\188\208\184\209\129\209\129\208\184\208\184."
L["Minimum needed chance"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\209\139\208\185 \209\136\208\176\208\189\209\129"
L["Minimum requested level for equipment rewards"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\209\139\208\185 \208\183\208\176\208\191\209\128\208\176\209\136\208\184\208\178\208\176\208\181\208\188\209\139\208\185 \209\131\209\128\208\190\208\178\208\181\208\189\209\140 \208\178\208\190\208\183\208\189\208\176\208\179\209\128\208\176\208\182\208\180\208\181\208\189\208\184\209\143 \208\183\208\176 \208\183\208\176\208\180\208\176\208\189\208\184\208\181"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\208\190 \209\130\209\128\208\181\208\177\209\131\208\181\208\188\208\190\208\181 \208\190\208\177\208\189\208\190\208\178\208\187\208\181\208\189\208\184\208\181 \208\180\208\187\209\143 \209\141\208\186\208\184\208\191\208\184\209\128\208\190\208\178\208\186\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176 (\209\131\208\187\209\131\209\135\209\136\208\181\208\189\208\184\209\143 \208\178\209\129\208\181\208\179\208\180\208\176 \208\178\208\186\208\187\209\142\209\135\208\181\208\189\209\139)"
L["Minimun chance success under which ignore missions"] = "\208\156\208\184\208\189\208\184\208\188\208\176\208\187\209\140\208\189\209\139\208\181 \209\136\208\176\208\189\209\129\209\139 \208\189\208\176 \209\131\209\129\208\191\208\181\209\133, \208\191\209\128\208\184 \208\186\208\190\209\130\208\190\209\128\208\190\208\188 \208\184\208\179\208\189\208\190\209\128\208\184\209\128\209\131\209\142\209\130\209\129\209\143 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Minumum needed chance"] = "\208\156\208\184\208\189\208\184\208\188\209\131\208\188 \208\189\209\131\208\182\208\181\208\189 \209\136\208\176\208\189\209\129"
L["Mission Control"] = "\208\166\208\181\208\189\209\130\209\128 \208\163\208\191\209\128\208\176\208\178\208\187\208\181\208\189\208\184\209\143"
L["Mission Duration"] = "\208\159\209\128\208\190\208\180\208\190\208\187\208\182\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Mission duration reduced"] = "\208\148\208\187\208\184\209\130\208\181\208\187\209\140\208\189\208\190\209\129\209\130\209\140 \208\183\208\176\208\180\208\176\208\189\208\184\209\143 \209\131\208\188\208\181\208\189\209\140\209\136\208\181\208\189\208\176"
L["Mission shown"] = "\208\156\208\184\209\129\209\129\208\184\209\143 \208\191\208\190\208\186\208\176\208\183\208\176\208\189\208\176"
L["Mission shown for follower"] = "\208\156\208\184\209\129\209\129\208\184\209\143 \208\191\208\190\208\186\208\176\208\183\208\176\208\189\208\176 \208\180\208\187\209\143 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
L["Mission Success"] = "\208\163\209\129\208\191\208\181\209\133 \208\188\208\184\209\129\209\129\208\184\208\184"
L["Mission time reduced!"] = "\208\146\209\128\208\181\208\188\209\143 \208\188\208\184\209\129\209\129\208\184\208\184 \209\129\208\190\208\186\209\128\208\176\209\137\208\181\208\189\208\190!"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "\208\156\208\184\209\129\209\129\208\184\209\143 \209\129 \208\188\208\181\208\189\209\140\209\136\208\184\208\188 \209\136\208\176\208\189\209\129\208\190\208\188 \208\189\208\176 \209\131\209\129\208\191\208\181\209\133 \208\177\209\131\208\180\208\181\209\130 \208\191\209\128\208\190\208\184\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\208\189\208\176"
L["Missionlist"] = "\208\161\208\191\208\184\209\129\208\190\208\186 \208\188\208\184\209\129\209\129\208\184\208\185"
L["Missions"] = "\208\151\208\176\208\180\208\176\208\189\208\184\209\143"
L["Must reload interface to apply"] = "\208\157\209\131\208\182\208\189\208\190 \208\191\208\181\209\128\208\181\208\183\208\176\208\179\209\128\209\131\208\183\208\184\209\130\209\140 \208\184\208\189\209\130\208\181\209\128\209\132\208\181\208\185\209\129 \208\180\208\187\209\143 \208\191\209\128\208\184\208\188\208\181\208\189\208\181\208\189\208\184\209\143"
L["Never kill Troops"] = "\208\157\208\184\208\186\208\190\208\179\208\180\208\176 \208\189\208\181 \209\131\208\177\208\184\208\178\208\176\209\130\209\140 \208\190\209\130\209\128\209\143\208\180\209\139"
L["No confirmation"] = "\208\157\208\181\209\130 \208\191\208\190\208\180\209\130\208\178\208\181\209\128\208\182\208\180\208\181\208\189\208\184\209\143 "
L["No follower gained xp"] = "\208\157\208\184 \208\190\208\180\208\184\208\189 \208\184\208\183 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178 \208\189\208\181 \208\191\208\190\208\187\209\131\209\135\208\184\208\187 \208\190\208\191\209\139\209\130"
L["No mission prefill"] = "\208\157\208\184\208\186\208\176\208\186\208\190\208\185 \208\191\209\128\208\181\208\180\208\178\209\139\208\177\208\190\209\128\208\186\208\184 \208\188\208\184\209\129\209\129\208\184\208\184"
L["No suitable missions. Have you reserved at least one follower?"] = "\208\158\209\130\209\129\209\131\209\130\209\129\209\130\208\178\209\131\209\142\209\130 \208\191\208\190\208\180\209\133\208\190\208\180\209\143\209\137\208\184\208\181 \208\183\208\176\208\180\208\176\208\189\208\184\209\143. \208\152\208\188\208\181\208\181\209\130\209\129\209\143 \208\187\208\184 \209\133\208\190\209\130\209\143 \208\177\209\139 \208\190\208\180\208\184\208\189 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186?"
L["Not blacklisted"] = "\208\157\208\181 \208\178 \209\135\209\145\209\128\208\189\208\190\208\188 \209\129\208\191\208\184\209\129\208\190\208\186"
L["Not Selected"] = "\208\157\208\181 \208\178\209\139\208\177\209\128\208\176\208\189\208\190"
L["Nothing to report"] = "\208\157\208\181\209\135\208\181\208\179\208\190 \208\180\208\190\208\186\208\187\208\176\208\180\209\139\208\178\208\176\209\130\209\140"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "\208\154\208\190\208\187\208\184\209\135\208\181\209\129\209\130\208\178\208\190 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "\208\159\208\190\208\186\208\176\208\183\208\176\208\189\209\139 \209\130\208\190\208\187\209\140\208\186\208\190 \208\191\208\181\209\128\208\178\209\139\208\181 %1$d \208\188\208\184\209\129\209\129\208\184\208\184 \209\129 \208\178\208\181\209\128\208\190\209\143\209\130\208\189\208\190\209\129\209\130\209\140\209\142 \209\131\209\129\208\191\208\181\209\133\208\176 %2$d%%"
L["Only meaningful upgrades are shown"] = "\208\159\208\190\208\186\208\176\208\183\208\176\208\189\209\139 \209\130\208\190\208\187\209\140\208\186\208\190 \208\183\208\189\208\176\209\135\208\184\208\188\209\139\208\181 \208\190\208\177\208\189\208\190\208\178\208\187\208\181\208\189\208\184\209\143"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
L["Only ready"] = "\208\162\208\190\208\187\209\140\208\186\208\190 \208\179\208\190\209\130\208\190\208\178\209\139\208\181"
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "\208\158\209\128\208\184\208\179\208\184\208\189\208\176\208\187\209\140\208\189\208\176\209\143 \208\186\208\190\208\189\209\134\208\181\208\191\209\134\208\184\209\143 \208\184 \208\184\208\189\209\130\208\181\209\128\209\132\208\181\208\185\209\129 \208\189\208\176 %s"
L["Original method"] = "\208\158\209\128\208\184\208\179\208\184\208\189\208\176\208\187\209\140\208\189\209\139\208\185 \208\188\208\181\209\130\208\190\208\180"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "\208\158\209\128\208\184\208\179\208\184\208\189\208\176\208\187\209\140\208\189\208\176\209\143 \209\129\208\190\209\128\209\130\208\184\209\128\208\190\208\178\208\186\208\176 \208\178\208\190\209\129\209\129\209\130\208\176\208\189\208\176\208\178\208\187\208\184\208\178\208\176\208\181\209\130 \208\184\209\129\209\133\208\190\208\180\208\189\209\139\208\185 \208\188\208\181\209\130\208\190\208\180 \209\129\208\190\209\128\209\130\208\184\209\128\208\190\208\178\208\186\208\184, \208\189\208\181\208\183\208\176\208\178\208\184\209\129\208\184\208\188\208\190 \208\190\209\130 \209\130\208\190\208\179\208\190, \209\135\209\130\208\190 \208\177\209\139\208\187\208\190 (\208\181\209\129\208\187\208\184 \209\131 \208\178\208\176\209\129 \208\181\209\129\209\130\209\140 \208\180\209\128\209\131\208\179\208\176\209\143 \208\186\208\190\208\188\208\176\208\189\208\180\208\176 \209\129\208\190\209\128\209\130\208\184\209\128\208\190\208\178\208\186\208\184 \208\176\208\180\208\180\208\190\208\189\208\176, \208\190\208\189\208\176 \208\180\208\190\208\187\208\182\208\189\208\176 \209\129\208\189\208\190\208\178\208\176 \208\177\209\139\209\130\209\140 \208\178\208\178\208\181\208\180\208\181\208\189\208\176)"
L["Other"] = "\208\148\209\128\209\131\208\179\208\184\208\181"
L["Other rewards"] = "\208\148\209\128\209\131\208\179\208\184\208\181 \208\189\208\176\208\179\209\128\208\176\208\180\209\139"
L["Other settings"] = "\208\148\209\128\209\131\208\179\208\184\208\181 \208\189\208\176\209\129\209\130\209\128\208\190\208\185\208\186\208\184"
L["Other useful followers"] = "\208\148\209\128\209\131\208\179\208\184\208\181 \208\191\208\190\208\187\208\181\208\183\208\189\209\139\208\181 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\184"
L["Position is not saved on logout"] = "\208\159\208\190\208\183\208\184\209\134\208\184\209\143 \208\189\208\181 \209\129\208\190\209\133\209\128\208\176\208\189\209\143\208\181\209\130\209\129\209\143 \208\191\209\128\208\184 \208\178\209\139\209\133\208\190\208\180\208\181"
L["Prefer high durability"] = "\208\159\209\128\208\181\208\180\208\191\208\190\209\135\208\181\209\129\209\130\209\140 \208\177\208\190\208\187\209\140\209\136\208\181\208\181 \208\186\208\190\208\187\208\184\209\135\208\181\209\129\209\130\208\178\208\190 \208\182\208\184\208\183\208\189\208\181\208\189\208\189\209\139\209\133 \209\129\208\184\208\187 \208\190\209\130\209\128\209\143\208\180\208\190\208\178"
L["Processing mission %d of %d"] = "\208\158\208\177\209\128\208\176\208\177\208\190\209\130\208\186\208\176 \208\188\208\184\209\129\209\129\208\184\208\184 %d \208\184\208\183 %d"
L["Profession"] = "\208\159\209\128\208\190\209\132\208\181\209\129\209\129\208\184\209\143"
L["Quick start first mission"] = "\208\145\209\139\209\129\209\130\209\128\208\190\208\181 \208\189\208\176\209\135\208\176\208\187\208\190 \208\191\208\181\209\128\208\178\208\190\208\179\208\190 \208\183\208\176\208\180\208\176\208\189\208\184\209\143"
L["Racial Preference"] = "\208\160\208\176\209\129\208\190\208\178\208\190\208\181 \208\191\209\128\208\181\208\180\208\191\208\190\209\135\209\130\208\181\208\189\208\184\208\181"
L["Rare missions will not be considered"] = "\208\160\208\181\208\180\208\186\208\184\208\181 \208\188\208\184\209\129\209\129\208\184\208\184 \208\189\208\181 \208\177\209\131\208\180\209\131\209\130 \209\128\208\176\209\129\209\129\208\188\208\176\209\130\209\128\208\184\208\178\208\176\209\130\209\140\209\129\209\143"
L["Reagents"] = "\208\160\208\181\208\176\208\179\208\181\208\189\209\130\209\139"
L["Remove no champions warning"] = "\208\163\208\177\209\128\208\176\209\130\209\140 \208\191\209\128\208\181\208\180\209\131\208\191\209\128\208\181\208\182\208\180\208\181\208\189\208\184\208\181 \208\190\208\177 \208\190\209\130\209\129\209\131\209\130\209\129\209\130\208\178\208\184\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
L["Reputation Items"] = "\208\159\209\128\208\181\208\180\208\188\208\181\209\130\209\139 \208\180\208\187\209\143 \208\160\208\181\208\191\209\131\209\130\208\176\209\134\208\184\208\184"
L["Restart the tutorial"] = "\208\157\208\176\209\135\208\176\209\130\209\140 \208\190\208\177\209\131\209\135\208\181\208\189\208\184\208\181 \208\183\208\176\208\189\208\190\208\178\208\190"
L["Restart tutorial from beginning"] = "\208\157\208\176\209\135\208\176\209\130\209\140 \208\190\208\177\209\131\209\135\208\181\208\189\208\184\208\181 \209\129\208\189\208\176\209\135\208\176\208\187\208\176"
L["Resume tutorial"] = "\208\159\209\128\208\190\208\180\208\190\208\187\208\182\208\184\209\130\209\140 \208\190\208\177\209\131\209\135\208\181\208\189\208\184\208\181"
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "\208\162\208\184\208\191 \208\178\208\190\208\183\208\189\208\176\208\179\209\128\208\176\208\182\208\180\208\181\208\189\208\184\209\143"
L["Right-Click to blacklist"] = "\208\169\208\181\208\187\208\186\208\189\208\184\209\130\208\181 \208\191\209\128\208\176\208\178\208\190\208\185 \208\186\208\189\208\190\208\191\208\186\208\190\208\185 \208\188\209\139\209\136\208\184 \208\180\208\187\209\143 \208\180\208\190\208\177\208\176\208\178\208\187\208\181\208\189\208\184\209\143 \208\178 \209\135\208\181\209\128\208\189\209\139\208\185 \209\129\208\191\208\184\209\129\208\190\208\186"
L["Right-Click to remove from blacklist"] = "\208\169\208\181\208\187\208\186\208\189\208\184\209\130\208\181 \208\191\209\128\208\176\208\178\208\190\208\185 \208\186\208\189\208\190\208\191\208\186\208\190\208\185 \208\188\209\139\209\136\208\184, \209\135\209\130\208\190\208\177\209\139 \209\131\208\180\208\176\208\187\208\184\209\130\209\140 \208\184\208\183 \209\135\208\181\209\128\208\189\208\190\208\179\208\190 \209\129\208\191\208\184\209\129\208\186\208\176"
L["Rush orders"] = "\208\161\209\128\208\190\209\135\208\189\209\139\208\185 \208\183\208\176\208\186\208\176\208\183"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "\208\146\208\189\208\181\209\136\208\189\208\184\208\185 \208\178\208\184\208\180 \208\178\208\181\209\128\209\132\208\184"
L["Show Garrison Commander menu"] = "\208\159\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\188\208\181\208\189\209\142 Garrison Commander"
L["Show itemlevel"] = "\208\159\208\190\208\186\208\176\208\183\208\176\209\130\209\140 itemlevel"
L["Show upgrades"] = "\208\159\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \209\131\208\187\209\131\209\135\209\136\208\181\208\189\208\184\209\143"
L["Show xp"] = "\208\159\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\190\208\191\209\139\209\130"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "\208\163\208\177\208\184\208\185\209\134\208\176"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "\208\157\208\181\208\186\208\190\209\130\208\190\209\128\209\139\208\181 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\184"
L["Sort missions by:"] = "\208\161\208\190\209\128\209\130\208\184\209\128\208\190\208\178\208\186\208\176 \208\188\208\184\209\129\209\129\208\184\208\185 \208\191\208\190:"
L["Started with "] = "\208\157\208\176\209\135\208\176\208\187\208\184 \209\129 "
L["Submit all your mission at once. No question asked."] = "\208\158\209\130\208\191\209\128\208\176\208\178\208\184\209\130\209\140 \208\178\209\129\208\181\209\133 \208\189\208\176 \208\188\208\184\209\129\209\129\208\184\208\184. \208\145\208\181\208\183 \208\178\208\190\208\191\209\128\208\190\209\129\208\190\208\178."
L["Success Chance"] = "\208\168\208\176\208\189\209\129 \209\131\209\129\208\191\208\181\209\133\208\176"
L["Swap upgrades positions"] = true
L["Switch between Garrison Commander and Master Plan interface for missions"] = "\208\159\208\181\209\128\208\181\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181 \208\188\208\181\208\182\208\180\209\131 Garrison Commander \208\184 Master Plan \208\180\208\187\209\143 \208\188\208\184\209\129\209\129\208\184\208\185"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "\208\161\209\135\208\181\209\130\209\135\208\184\208\186 \209\131\208\179\209\128\208\190\208\183"
L["To go: %d"] = "\208\152\208\180\209\130\208\184: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "\208\146\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181/\208\178\209\139\208\186\208\187\209\142\209\135\208\181\208\189\208\184\208\181 \208\183\208\176\208\179\208\190\208\187\208\190\208\178\208\186\208\176 \208\188\208\181\208\189\209\142 Garrison Commander"
L["Toys and Mounts"] = "\208\152\208\179\209\128\209\131\209\136\208\186\208\184 \208\184 \208\181\208\183\208\180\208\190\208\178\209\139\208\181 \208\182\208\184\208\178\208\190\209\130\208\189\209\139\208\181"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
L["Unable to fill missions, raise \"%s\""] = "\208\157\208\181\208\178\208\190\208\183\208\188\208\190\208\182\208\189\208\190 \208\183\208\176\208\191\208\190\208\187\208\189\208\184\209\130\209\140 \208\183\208\176\208\180\208\176\208\189\208\184\209\143. \208\163\208\178\208\181\208\187\208\184\209\135\209\140\209\130\208\181 \"%s\""
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "\208\161\208\189\208\184\208\188\208\184\209\130\208\181 \209\132\208\187\208\176\208\182\208\190\208\186, \209\135\209\130\208\190\208\177\209\139 \209\131\209\129\209\130\208\176\208\189\208\190\208\178\208\184\209\130\209\140 \208\190\208\191\209\128\208\181\208\180\208\181\208\187\208\181\208\189\208\189\209\139\208\185 \209\136\208\176\208\189\209\129 \208\189\208\176 \209\131\209\129\208\191\208\181\209\133 \208\180\208\187\209\143 \208\186\208\176\208\182\208\180\208\190\208\179\208\190 \209\130\208\184\208\191\208\176 \208\178\208\190\208\183\208\189\208\176\208\179\209\128\208\176\208\182\208\180\208\181\208\189\208\184\209\143"
L["Unlock all"] = "\208\160\208\176\208\183\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\178\209\129\208\181\209\133"
L["Unlock Panel"] = "\208\160\208\176\208\183\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\191\208\176\208\189\208\181\208\187\209\140"
L["Unlock this follower"] = "\208\160\208\176\208\183\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \209\141\209\130\208\190\208\179\208\190 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176"
L["Unlocks all follower and slots at once"] = "\208\160\208\176\208\183\208\177\208\187\208\190\208\186\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\178\209\129\208\181\209\133 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178 \208\184 \208\178\209\129\208\181 \209\129\208\187\208\190\209\130\209\139"
L["Unsafe mission start"] = "\208\189\208\181\208\177\208\181\208\183\208\190\208\191\208\176\209\129\208\189\208\190\208\181 \208\189\208\176\209\135\208\176\208\187\208\190 \208\183\208\176\208\180\208\176\208\189\208\184\209\143"
L["Upgrade %1$s to  %2$d itemlevel"] = "\208\163\208\187\209\131\209\135\209\136\208\184\209\130\209\140 %1$s \208\186  %2$d itemlevel"
L["Upgrading to |cff00ff00%d|r"] = "\208\163\208\187\209\131\209\135\209\136\208\184\209\130\209\140 \208\186 |cff00ff00%d|r"
L["URL Copy"] = "\208\154\208\190\208\191\208\184\209\128\208\190\208\178\208\176\209\130\209\140 \208\176\208\180\209\128\208\181\209\129 \208\178 \208\184\208\189\209\130\208\181\209\128\208\189\208\181\209\130\208\181"
L["Use at most this many champions"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \208\188\208\176\208\186\209\129\208\184\208\188\209\131\208\188 \209\141\209\130\208\190 \208\186\208\190\208\187\208\184\209\135\208\181\209\129\209\130\208\178\208\190 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
L["Use big screen"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\185\209\130\208\181 \208\177\208\190\208\187\209\140\209\136\208\190\208\185 \209\141\208\186\209\128\208\176\208\189"
L["Use combat ally"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \209\130\208\181\208\187\208\190\209\133\209\128\208\176\208\189\208\184\209\130\208\181\208\187\209\143"
L["Use GC Interface"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \208\184\208\189\209\130\208\181\209\128\209\132\208\181\208\185\209\129 GC"
L["Use this slot"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\208\190\208\178\208\176\209\130\209\140 \209\141\209\130\208\190\209\130 \209\129\208\187\208\190\209\130"
L["Uses armor token"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\185\209\130\208\181 \208\180\208\187\209\143 \209\131\208\187\209\131\209\135\209\136\208\181\208\189\208\184\209\143 \208\177\209\128\208\190\208\189\208\184 "
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "\208\152\209\129\208\191\208\190\208\187\209\140\208\183\209\131\208\185\209\130\208\181 \208\180\208\187\209\143 \209\131\208\187\209\131\209\135\209\136\208\181\208\189\208\184\209\143 \208\190\209\128\209\131\208\182\208\184\209\143"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "\208\154\208\190\208\179\208\180\208\176 \209\131\209\129\209\130\208\176\208\189\208\190\208\178\208\187\208\181\208\189 \209\132\208\187\208\176\208\182\208\190\208\186, \208\191\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\189\208\176 \208\186\208\176\208\182\208\180\208\190\208\185 \208\184\208\186\208\190\208\189\208\186\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176 \209\129\208\186\208\190\208\187\209\140\208\186\208\190 \208\190\208\191\209\139\209\130\208\176 \208\189\209\131\208\182\208\189\208\190 \208\189\208\176 \209\129\208\187\208\181\208\180\209\131\209\142\209\137\208\184\208\185 \209\131\209\128\208\190\208\178\208\181\208\189\209\140."
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "\208\154\208\190\208\179\208\180\208\176 \209\131\209\129\209\130\208\176\208\189\208\190\208\178\208\187\208\181\208\189 \209\132\208\187\208\176\208\182\208\190\208\186, \208\191\208\190\208\186\208\176\208\183\208\176\209\130\209\140 \208\189\208\176 \208\186\208\176\208\182\208\180\208\190\208\185 \208\184\208\186\208\190\208\189\208\186\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\176 \209\129\208\186\208\190\208\187\209\140\208\186\208\190 \208\191\209\128\208\181\208\180\208\188\208\181\209\130\208\190\208\178 \208\190\209\128\209\131\208\182\208\184\208\184 \208\184 \208\177\209\128\208\190\208\189\208\184 \208\181\208\188\209\131 \208\181\209\137\208\181 \208\189\209\131\208\182\208\189\208\190"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
L["Would start with "] = "\208\157\208\176\209\135\208\176\209\130\209\140 \208\187\208\184 \209\129 "
L["XP"] = "\208\158\208\191\209\139\209\130"
L["Xp incremented!"] = "\208\158\208\191\209\139\209\130 \209\131\208\178\208\181\208\187\208\184\209\135\208\184\208\178\208\176\208\181\209\130\209\129\209\143!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "\208\146\209\139 \208\183\209\128\209\143 \209\130\209\128\208\176\209\130\208\184\209\130\208\181 |cffff0000%d|cffffd200 \208\191\209\128\208\181\208\180\208\188\208\181\209\130\209\139(s)!!!"
L["You can also send mission one by one clicking on each button."] = "\208\146\209\139 \209\130\208\176\208\186\208\182\208\181 \208\188\208\190\208\182\208\181\209\130\208\181 \208\190\209\130\208\191\209\128\208\176\208\178\208\184\209\130\209\140 \208\188\208\184\209\129\209\129\208\184\209\142 \208\191\208\190 \208\190\208\180\208\189\208\190\208\188\209\131 \208\189\208\176\208\182\208\176\209\130\208\184\209\142 \208\189\208\176 \208\186\208\176\208\182\208\180\209\131\209\142 \208\186\208\189\208\190\208\191\208\186\209\131."
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "\208\146\209\139 \208\188\208\190\208\182\208\181\209\130\208\181 \208\190\209\130\208\186\209\128\209\139\209\130\209\140 \208\188\208\181\208\189\209\142, \208\189\208\176\208\182\208\176\208\178 \208\189\208\176 \208\183\208\189\208\176\209\135\208\190\208\186 \208\178 \208\178\208\181\209\128\209\133\208\189\208\181\208\188 \208\191\209\128\208\176\208\178\208\190\208\188 \209\131\208\179\208\187\209\131"
L["You have ignored followers"] = "\208\146\209\139 \208\191\209\128\208\190\208\184\208\179\208\189\208\190\209\128\208\184\209\128\208\190\208\178\208\176\208\187\208\184 \209\129\208\190\209\128\208\176\209\130\208\189\208\184\208\186\208\190\208\178"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "\208\146\209\139 \208\189\208\184\208\186\208\190\208\179\208\180\208\176 \208\189\208\181 \208\178\209\139\208\191\208\190\208\187\208\189\209\143\208\187\208\184 \209\141\209\130\209\131 \208\188\208\184\209\129\209\129\208\184\209\142"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "\208\146\209\139 \208\178\209\139\208\191\208\190\208\187\208\189\208\184\208\187\208\184 \209\141\209\130\209\131 \208\188\208\184\209\129\209\129\208\184\209\142 %d \209\128\208\176\208\183 \209\129 \208\186\208\190\209\141\209\132\209\132\208\184\209\134\208\184\208\181\208\189\209\130\208\190\208\188 \208\178\209\139\208\184\208\179\209\128\209\139\209\136\208\176"

return
end
L=l:NewLocale(me,"zhCN")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4\233\154\143\228\187\142\239\188\154\233\154\143\228\187\142\229\144\171\230\156\137 %s"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "\239\188\136\229\191\189\231\149\165\228\189\142\229\140\185\233\133\141\231\154\132\239\188\137"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "\229\162\158\229\138\160 %1$d \231\173\137\231\186\167\229\136\176 %2$s"
L["Adds a list of other useful followers to tooltip"] = "\233\188\160\230\160\135\230\143\144\231\164\186\228\184\173\230\183\187\229\138\160\229\133\182\228\187\150\230\156\137\231\148\168\231\154\132\233\154\143\228\187\142\229\136\151\232\161\168"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "\229\143\150\230\182\136\233\128\137\228\184\173\228\187\165\233\154\144\232\151\143\230\175\143\228\184\170\232\191\189\233\154\143\232\128\133\231\154\132\228\187\187\229\138\161\229\136\151\232\161\168\239\188\140\228\187\133\229\176\143\231\170\151\229\143\163\230\168\161\229\188\143\230\156\137\230\149\136"
L["Allowed Rewards"] = "\229\143\175\231\148\168\230\148\182\231\155\138"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "\229\133\129\232\174\184\232\181\132\230\186\144\228\187\187\229\138\161\228\189\191\231\148\168\232\190\131\228\189\142\231\154\132\230\136\144\229\138\159\231\142\135\227\128\130\228\189\191\231\148\168 /gac \230\137\147\229\188\128\231\149\140\233\157\162\232\176\131\230\149\180\229\135\160\231\142\135\239\188\140\233\187\152\232\174\16480%"
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
L["Applied when 'maximize result' is enabled. Default is 80%"] = "\230\156\128\229\164\167\229\140\150\231\187\147\230\158\156\233\128\137\233\161\185\229\144\175\231\148\168\230\151\182\231\148\159\230\149\136\239\188\140\233\187\152\232\174\16480%"
L["Applies the best armor set"] = "\228\189\191\231\148\168\230\156\128\228\189\179\230\138\164\231\148\178\231\187\132\229\144\136"
L["Applies the best armor upgrade"] = "\228\189\191\231\148\168\230\156\128\228\189\179\230\138\164\231\148\178\229\141\135\231\186\167"
L["Applies the best weapon set"] = "\228\189\191\231\148\168\230\156\128\228\189\179\230\173\166\229\153\168\231\187\132\229\144\136"
L["Applies the best weapon upgrade"] = "\228\189\191\231\148\168\230\156\128\228\189\179\230\173\166\229\153\168\229\141\135\231\186\167"
L["Archaelogy"] = "\232\128\131\229\143\164\229\173\166"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "\229\164\167\231\170\151\229\143\163"
L["Blacklisted"] = "\229\183\178\229\138\160\229\133\165\233\187\145\229\144\141\229\141\149"
L["Blacklisted missions are ignored in Mission Control"] = "\229\156\168\228\187\187\229\138\161\233\157\162\230\157\191\229\183\178\229\136\151\229\133\165\233\187\145\229\144\141\229\141\149\231\154\132\228\187\187\229\138\161\229\176\134\232\162\171\229\191\189\231\149\165"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "\230\158\132\229\187\186\230\156\128\231\187\136\230\138\165\229\145\138"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "\230\156\128\229\164\154 %1$s\239\188\140\228\189\191\231\148\168\232\135\179\229\176\145 %2$d"
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "\230\151\160\233\156\128\231\161\174\232\174\164\229\174\140\230\136\144\230\137\128\230\156\137\228\187\187\229\138\161"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "\231\161\174\232\174\164"
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
L["Disable if you dont want the full Garrison Commander Header."] = "\231\166\129\231\148\168\229\174\140\230\149\180\231\154\132 Garrison Commander \230\160\135\233\162\152"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "\229\143\150\230\182\136\228\187\187\229\138\161\233\161\181\232\135\170\229\138\168\229\136\134\233\133\141\227\128\130\228\189\160\228\185\159\229\143\175\228\187\165\230\140\137\228\189\143Ctrl\233\148\174\231\130\185\229\135\187\229\143\150\230\182\136\229\141\149\228\184\170\228\187\187\229\138\161\227\128\130"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "\229\143\150\230\182\136\229\176\134\233\135\141\230\150\176\232\189\189\229\133\1651.1.8\231\137\136\230\156\172\231\149\140\233\157\162\239\188\140\229\143\150\230\182\136\230\136\150\231\161\174\232\174\164\227\128\130\233\156\128\232\166\129\233\135\141\232\189\189\231\149\140\233\157\162\227\128\130"
L["Do not show follower icon on plots"] = "\228\184\141\232\166\129\229\156\168\232\174\161\229\136\146\230\157\161\228\184\138\230\152\190\231\164\186\232\191\189\233\154\143\232\128\133\229\155\190\230\160\135"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "\229\145\168\230\156\159\230\151\182\233\151\180"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "\229\188\186\229\140\150\233\188\160\230\160\135\230\143\144\231\164\186"
L["Environment Preference"] = "\231\142\175\229\162\131\232\174\190\231\189\174"
L["Epic followers are NOT sent alone on xp only missions"] = "\231\180\171\232\137\178\232\191\189\233\154\143\232\128\133\228\184\141\228\188\154\229\141\149\231\139\172\229\136\134\233\133\141\229\136\176\229\143\170\230\156\137\231\187\143\233\170\140\231\154\132\228\187\187\229\138\161\228\184\138"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "\232\191\135\230\156\159\230\151\182\233\151\180"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "\233\154\143\228\187\142"
L["Follower equipment set or upgrade"] = "\233\154\143\228\187\142\232\163\133\229\164\135\232\174\190\231\189\174\230\136\150\229\141\135\231\186\167"
L["Follower experience"] = "\233\154\143\228\187\142\231\187\143\233\170\140"
L["Follower set minimum upgrade"] = "\233\154\143\228\187\142\232\174\190\231\189\174\230\156\128\229\176\143\229\141\135\231\186\167"
L["Follower Training"] = "\233\154\143\228\187\142\232\174\173\231\187\131"
L["Followers status "] = "\232\191\189\233\154\143\232\128\133\231\138\182\230\128\129"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "\229\133\181\232\144\165\231\149\140\233\157\162"
L["Garrison Comander Quick Mission Completion"] = "GC \229\191\171\233\128\159\228\187\187\229\138\161\229\174\140\230\136\144"
L["Garrison Commander Mission Control"] = "GC \228\187\187\229\138\161\231\174\161\231\144\134"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "\229\133\168\229\177\128\229\164\167\231\186\166\231\187\143\233\170\140\229\165\150\229\138\177"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "\229\133\168\229\177\128\230\136\144\229\138\159\231\142\135"
L["Gold incremented!"] = "\233\135\145\229\184\129\229\162\158\229\138\160\239\188\129"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "\233\154\144\232\151\143\232\191\189\233\154\143\232\128\133"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[\229\166\130\230\158\156\233\128\137\228\184\173\239\188\140\231\130\185\229\135\187\229\141\135\231\186\167\229\155\190\230\160\135\229\136\153\228\189\191\231\148\168\231\137\169\229\147\129\229\141\135\231\186\167\232\191\189\233\154\143\232\128\133
|cFFFF0000\230\151\160\233\156\128\231\161\174\232\174\164|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "\233\128\137\228\184\173\230\151\182\239\188\140\229\183\166\228\190\167\230\152\190\231\164\186\230\138\164\231\148\178\239\188\140\229\143\179\228\190\167\230\152\190\231\164\186\230\173\166\229\153\168"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "\229\166\130\230\158\156\233\128\137\230\139\169\231\187\167\231\187\173\239\188\140\228\189\160\229\143\175\232\131\189\228\188\154\229\164\177\229\142\187\228\187\150\228\187\172"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "\229\166\130\230\158\156\228\189\160\230\156\137\230\137\147\230\141\158\229\153\168\239\188\140\228\189\160\229\143\175\232\131\189\228\184\141\230\132\191\230\132\143\233\128\137\228\184\173\232\191\153\228\184\170"
L["Ignore \"maxed\""] = "\229\191\189\231\149\165\226\128\156\230\187\161\231\186\167\231\154\132\226\128\157"
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "\231\187\143\233\170\140\228\187\187\229\138\161\229\191\189\231\149\165\229\143\178\232\175\151\233\154\143\228\187\142"
L["Ignore for all missions"] = "\229\191\189\231\149\165\230\137\128\230\156\137\228\187\187\229\138\161"
L["Ignore for this mission"] = "\229\191\189\231\149\165\232\191\153\228\184\170\228\187\187\229\138\161"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "\229\191\189\231\149\165\231\168\128\230\156\137\228\187\187\229\138\161"
L["Increased Rewards"] = "\229\183\178\229\162\158\229\138\160\230\148\182\231\155\138"
L["Item minimum level"] = "\231\137\169\229\147\129\230\156\128\228\189\142\231\173\137\231\186\167"
L["Item Tokens"] = "\231\137\169\229\147\129\228\187\163\229\184\129"
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "\231\130\185\229\135\187\230\152\190\231\164\186\229\143\175\231\148\168\228\187\187\229\138\161"
L["Legendary Items"] = "\228\188\160\229\165\135\231\137\169\229\147\129"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "100\231\186\167\231\154\132\231\180\171\232\137\178\232\191\189\233\154\143\232\128\133\228\184\141\228\188\154\231\148\168\228\186\142\229\143\170\230\156\137\231\187\143\233\170\140\231\154\132\228\187\187\229\138\161"
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "\228\189\191\228\187\187\229\138\161\228\184\187\231\170\151\228\189\147\229\143\175\228\187\165\231\167\187\229\138\168"
L["Makes shipyard panel movable"] = "\228\189\191\232\136\176\232\136\185\233\157\162\230\157\191\229\143\175\228\187\165\231\167\187\229\138\168"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "\230\156\128\229\164\167\229\140\150\230\148\182\231\155\138"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "\230\156\128\229\164\167\228\187\187\229\138\161\229\145\168\230\156\159"
L["Minimum chance"] = "\230\156\128\229\176\143\229\135\160\231\142\135"
L["Minimum mission duration."] = "\230\156\128\229\176\143\228\187\187\229\138\161\229\145\168\230\156\159"
L["Minimum needed chance"] = "\230\156\128\229\176\143\229\191\133\233\161\187\229\135\160\231\142\135"
L["Minimum requested level for equipment rewards"] = "\232\174\190\229\164\135\229\165\150\229\138\177\230\137\128\233\156\128\230\156\128\229\176\143\231\173\137\231\186\167"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "\233\154\143\228\187\142\231\187\132\229\144\136\239\188\136\229\183\178\232\128\131\232\153\145\231\187\132\229\144\136\229\188\186\229\140\150\239\188\137\230\137\128\233\156\128\230\156\128\229\176\143\229\141\135\231\186\167"
L["Minimun chance success under which ignore missions"] = "\229\191\189\231\149\165\228\187\187\229\138\161\231\154\132\230\156\128\228\189\142\230\136\144\229\138\159\231\142\135"
L["Minumum needed chance"] = "\230\156\128\229\176\143\230\137\128\233\156\128\229\135\160\231\142\135"
L["Mission Control"] = "\228\187\187\229\138\161\233\157\162\230\157\191"
L["Mission Duration"] = "\228\187\187\229\138\161\229\145\168\230\156\159"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "\228\187\187\229\138\161\229\177\149\231\164\186"
L["Mission shown for follower"] = "\228\187\187\229\138\161\230\152\190\231\164\186\232\191\189\233\154\143\232\128\133"
L["Mission Success"] = "\228\187\187\229\138\161\230\136\144\229\138\159"
L["Mission time reduced!"] = "\228\187\187\229\138\161\230\151\182\233\151\180\229\135\143\229\176\145\239\188\129"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "\228\189\142\230\136\144\229\138\159\231\142\135\228\187\187\229\138\161\229\176\134\232\162\171\229\191\189\231\149\165"
L["Missionlist"] = "\228\187\187\229\138\161\229\136\151\232\161\168"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "\233\156\128\232\166\129\233\135\141\232\189\189\231\149\140\233\157\162\228\187\165\231\148\159\230\149\136"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "\230\178\161\230\156\137\231\161\174\232\174\164"
L["No follower gained xp"] = "\230\178\161\230\156\137\233\154\143\228\187\142\232\142\183\229\190\151\231\187\143\233\170\140"
L["No mission prefill"] = "\230\178\161\230\156\137\233\162\132\229\136\134\233\133\141\228\187\187\229\138\161"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "\230\178\161\230\156\137\232\162\171\229\136\151\229\133\165\233\187\145\229\144\141\229\141\149"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "\230\178\161\230\156\137\229\143\175\231\148\168\230\138\165\229\145\138"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "\232\191\189\233\154\143\232\128\133\230\149\176\233\135\143"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "\229\143\170\230\156\137\230\136\144\229\138\159\231\142\135\233\171\152\228\186\142 %2$d%% \231\154\132\229\137\141 %1$d \228\184\170\228\187\187\229\138\161\228\188\154\230\152\190\231\164\186"
L["Only meaningful upgrades are shown"] = "\229\143\170\230\156\137\230\152\142\230\152\190\231\154\132\229\141\135\231\186\167\228\188\154\230\152\190\231\164\186"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "\229\142\159\230\166\130\229\191\181\229\146\140\231\149\140\233\157\162\228\187\142 %s"
L["Original method"] = "\229\142\159\230\150\185\230\179\149"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "\229\188\186\229\136\182\230\129\162\229\164\141\229\142\159\230\142\146\229\186\143\239\188\136\229\166\130\230\158\156\228\189\160\230\156\137\229\143\166\228\184\128\228\184\170\230\143\146\228\187\182\230\142\146\229\186\143\228\187\187\229\138\161\239\188\140\229\174\131\229\186\148\232\175\165\228\188\154\229\134\141\230\172\161\229\144\175\229\138\168\239\188\137"
L["Other"] = "\229\133\182\228\187\150"
L["Other rewards"] = "\229\133\182\228\187\150\230\148\182\231\155\138"
L["Other settings"] = "\229\133\182\228\187\150\232\174\190\231\189\174"
L["Other useful followers"] = "\229\133\182\228\187\150\230\156\137\231\148\168\231\154\132\232\191\189\233\154\143\232\128\133"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "\230\137\167\232\161\140\228\187\187\229\138\161 %d / %d"
L["Profession"] = "\228\184\147\228\184\154\229\140\185\233\133\141"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "\231\167\141\230\151\143\229\140\185\233\133\141"
L["Rare missions will not be considered"] = "\231\168\128\230\156\137\228\187\187\229\138\161\229\176\134\228\184\141\232\162\171\232\128\131\232\153\145"
L["Reagents"] = "\232\175\149\229\137\130"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "\229\163\176\230\156\155\231\137\169\229\147\129"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "\230\148\182\231\155\138\231\177\187\229\158\139"
L["Right-Click to blacklist"] = "\229\143\179\229\135\187\229\138\160\229\133\165\233\187\145\229\144\141\229\141\149"
L["Right-Click to remove from blacklist"] = "\229\143\179\229\135\187\228\187\142\233\187\145\229\144\141\229\141\149\231\167\187\233\153\164"
L["Rush orders"] = "\229\136\183\232\174\162\229\141\149"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "\233\128\160\232\136\185\229\142\130\229\164\150\232\167\130"
L["Show Garrison Commander menu"] = "\230\152\190\231\164\186 GC \232\143\156\229\141\149"
L["Show itemlevel"] = "\230\152\190\231\164\186\231\137\169\229\147\129\231\173\137\231\186\167"
L["Show upgrades"] = "\230\152\190\231\164\186\229\141\135\231\186\167"
L["Show xp"] = "\230\152\190\231\164\186\231\187\143\233\170\140"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "\231\148\159\231\137\169\229\140\185\233\133\141"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "\228\184\128\228\186\155\233\154\143\228\187\142"
L["Sort missions by:"] = "\230\142\146\229\186\143\228\190\157\230\141\174\239\188\154"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "\230\143\144\228\186\164\230\137\128\230\156\137\228\187\187\229\138\161\227\128\130\230\151\160\233\156\128\231\161\174\232\174\164\227\128\130"
L["Success Chance"] = "\230\136\144\229\138\159\231\142\135"
L["Swap upgrades positions"] = "\228\186\164\230\141\162\229\141\135\231\186\167\228\189\141\231\189\174"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "\228\184\186\228\187\187\229\138\161\229\136\135\230\141\162 Garrison Commander \229\146\140 Master Plan \231\149\140\233\157\162"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "\230\138\128\232\131\189\229\140\185\233\133\141"
L["To go: %d"] = "\232\189\172\229\136\176\239\188\154%d"
L["Toggles Garrison Commander Menu Header on/off"] = "\229\136\135\230\141\162 GC \232\143\156\229\141\149\230\160\135\233\162\152\229\188\128\229\133\179"
L["Toys and Mounts"] = "\231\142\169\229\133\183\229\146\140\229\157\144\233\170\145"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "\229\143\150\230\182\136\232\191\153\228\184\170\233\128\137\233\161\185\239\188\140\228\189\160\229\143\175\228\187\165\232\135\170\232\161\140\232\174\190\231\189\174\229\144\132\233\161\185\230\148\182\231\155\138\231\154\132\230\136\144\229\138\159\231\142\135"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "\232\167\163\233\148\129\233\157\162\230\157\191"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "\229\141\135\231\186\167 %1$s \229\136\176 %2$d \231\137\169\229\147\129\231\173\137\231\186\167"
L["Upgrading to |cff00ff00%d|r"] = "\230\173\163\229\156\168\229\141\135\231\186\167\232\135\179 |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "\228\189\191\231\148\168\229\164\167\229\177\143"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "\228\189\191\231\148\168GC\231\149\140\233\157\162"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "\228\189\191\231\148\168\230\138\164\231\148\178\228\187\163\229\184\129"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "\228\189\191\231\148\168\230\173\166\229\153\168\228\187\163\229\184\129"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "\233\128\137\228\184\173\229\144\142\239\188\140\229\156\168\230\175\143\228\184\170\232\191\189\233\154\143\232\128\133\230\140\137\233\146\174\228\184\138\230\152\190\231\164\186\229\141\135\232\135\179\228\184\139\228\184\128\231\186\167\230\137\128\233\156\128\231\187\143\233\170\140"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "\233\128\137\228\184\173\229\144\142\239\188\140\229\156\168\230\175\143\228\184\170\230\187\161\231\186\167\232\191\189\233\154\143\232\128\133\230\140\137\233\146\174\228\184\138\230\152\190\231\164\186\230\173\166\229\153\168\229\146\140\230\138\164\231\148\178\231\173\137\231\186\167"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
L["Xp incremented!"] = "\231\187\143\233\170\140\229\162\158\229\138\160\239\188\129"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "\228\189\160\230\181\170\232\180\185\228\186\134 |cffff0000%d|cffffd200 \231\130\185\239\188\129"
L["You can also send mission one by one clicking on each button."] = "\228\189\160\228\185\159\229\143\175\228\187\165\231\130\185\229\135\187\230\140\137\233\146\174\233\128\144\228\184\170\229\136\134\233\133\141\228\187\187\229\138\161\227\128\130"
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "\228\189\160\229\143\175\228\187\165\231\130\185\229\135\187\229\143\179\228\184\138\232\167\146\231\154\132\229\155\190\230\160\135\230\137\147\229\188\128\232\143\156\229\141\149"
L["You have ignored followers"] = "\228\189\160\230\156\137\229\191\189\231\149\165\231\154\132\232\191\189\233\154\143\232\128\133"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "\228\189\160\228\187\142\230\156\170\230\137\167\232\161\140\232\191\153\228\184\170\228\187\187\229\138\161"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "\228\189\160\230\137\167\232\161\140\232\191\153\228\184\170\228\187\187\229\138\161 %d \230\172\161\239\188\140\230\136\144\229\138\159\231\142\135\228\184\186"

return
end
L=l:NewLocale(me,"esES")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["%s |4follower:followers; with %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["(Ignores low bias ones)"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Add %1$d levels to %2$s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Adds a list of other useful followers to tooltip"] = ""--]] 
--[[Translation missing --]]
--[[ L["Affects only little screen mode, hiding the per follower mission list if not checked"] = ""--]] 
--[[Translation missing --]]
--[[ L["Allowed Rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applied when 'maximize result' is enabled. Default is 80%"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best armor set"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best armor upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best weapon set"] = ""--]] 
--[[Translation missing --]]
--[[ L["Applies the best weapon upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Archaelogy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
--[[Translation missing --]]
--[[ L["Big screen"] = ""--]] 
--[[Translation missing --]]
--[[ L["Blacklisted"] = ""--]] 
--[[Translation missing --]]
--[[ L["Blacklisted missions are ignored in Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Building Final report"] = ""--]] 
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped %1$s. Spend at least %2$d of them"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
--[[Translation missing --]]
--[[ L["Complete all missions without confirmation"] = ""--]] 
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
--[[Translation missing --]]
--[[ L["Consider again"] = ""--]] 
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable if you dont want the full Garrison Commander Header."] = ""--]] 
--[[Translation missing --]]
--[[ L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
--[[Translation missing --]]
--[[ L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = ""--]] 
--[[Translation missing --]]
--[[ L["Do not show follower icon on plots"] = ""--]] 
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration Time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
--[[Translation missing --]]
--[[ L["Enhance tooltip"] = ""--]] 
--[[Translation missing --]]
--[[ L["Environment Preference"] = ""--]] 
--[[Translation missing --]]
--[[ L["Epic followers are NOT sent alone on xp only missions"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Expiration Time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower equipment set or upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower experience"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower set minimum upgrade"] = ""--]] 
--[[Translation missing --]]
--[[ L["Follower Training"] = ""--]] 
--[[Translation missing --]]
--[[ L["Followers status "] = ""--]] 
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Appearance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Comander Quick Mission Completion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Garrison Commander Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global approx. xp reward"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
--[[Translation missing --]]
--[[ L["Global success chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Gold incremented!"] = ""--]] 
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
--[[Translation missing --]]
--[[ L["Hide followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = ""--]] 
--[[Translation missing --]]
--[[ L["IF checked, shows armors on the left and weapons on the right "] = ""--]] 
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["If you continue, you will lose them"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["IF you have a Salvage Yard you probably dont want to have this one checked"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore \"maxed\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore epic for xp missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore for all missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Ignore rare missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Increased Rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item minimum level"] = ""--]] 
--[[Translation missing --]]
--[[ L["Item Tokens"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Left Click to see available missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Legendary Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
--[[Translation missing --]]
--[[ L["Level 100 epic followers are not used for xp only missions."] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes main mission panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes shipyard panel movable"] = ""--]] 
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximize result"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
--[[Translation missing --]]
--[[ L["Maximum mission duration."] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum mission duration."] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum needed chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum requested level for equipment rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimum requested upgrade for followers set (Enhancements are always included)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minimun chance success under which ignore missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Minumum needed chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Control"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Duration"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission shown for follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission Success"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission time reduced!"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
--[[Translation missing --]]
--[[ L["Mission with lower success chance will be ignored"] = ""--]] 
--[[Translation missing --]]
--[[ L["Missionlist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Must reload interface to apply"] = ""--]] 
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["No confirmation"] = ""--]] 
--[[Translation missing --]]
--[[ L["No follower gained xp"] = ""--]] 
--[[Translation missing --]]
--[[ L["No mission prefill"] = ""--]] 
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
--[[Translation missing --]]
--[[ L["Not blacklisted"] = ""--]] 
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
--[[Translation missing --]]
--[[ L["Nothing to report"] = ""--]] 
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
--[[Translation missing --]]
--[[ L["Number of followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only first %1$d missions with over %2$d%% chance of success are shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only meaningful upgrades are shown"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original concept and interface by %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original method"] = ""--]] 
--[[Translation missing --]]
--[[ L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other rewards"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other settings"] = ""--]] 
--[[Translation missing --]]
--[[ L["Other useful followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
--[[Translation missing --]]
--[[ L["Processing mission %d of %d"] = ""--]] 
--[[Translation missing --]]
--[[ L["Profession"] = ""--]] 
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Racial Preference"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rare missions will not be considered"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reagents"] = ""--]] 
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reputation Items"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
--[[Translation missing --]]
--[[ L["Reward type"] = ""--]] 
--[[Translation missing --]]
--[[ L["Right-Click to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Right-Click to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["Rush orders"] = ""--]] 
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shipyard Appearance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show Garrison Commander menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show upgrades"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show xp"] = ""--]] 
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["Slayer"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Some follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sort missions by:"] = ""--]] 
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
--[[Translation missing --]]
--[[ L["Submit all your mission at once. No question asked."] = ""--]] 
--[[Translation missing --]]
--[[ L["Success Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Swap upgrades positions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Switch between Garrison Commander and Master Plan interface for missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
--[[Translation missing --]]
--[[ L["Threat Counter"] = ""--]] 
--[[Translation missing --]]
--[[ L["To go: %d"] = ""--]] 
--[[Translation missing --]]
--[[ L["Toggles Garrison Commander Menu Header on/off"] = ""--]] 
--[[Translation missing --]]
--[[ L["Toys and Mounts"] = ""--]] 
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unchecking this will allow you to set specific success chance for each reward type"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock Panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
--[[Translation missing --]]
--[[ L["Upgrade %1$s to  %2$d itemlevel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Upgrading to |cff00ff00%d|r"] = ""--]] 
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use big screen"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use GC Interface"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses armor token"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uses weapon token"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["When checked, show on each follower button missing xp to next level"] = ""--]] 
--[[Translation missing --]]
--[[ L["When checked, show on each follower button weapon and armor level for maxed followers"] = ""--]] 
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
--[[Translation missing --]]
--[[ L["Xp incremented!"] = ""--]] 
--[[Translation missing --]]
--[[ L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = ""--]] 
--[[Translation missing --]]
--[[ L["You can also send mission one by one clicking on each button."] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can open the menu clicking on the icon in top right corner"] = ""--]] 
--[[Translation missing --]]
--[[ L["You have ignored followers"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You never performed this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["You performed this mission %d times with a win ratio of"] = ""--]] 

return
end
L=l:NewLocale(me,"zhTW")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4\232\191\189\233\154\168\232\128\133:\232\191\189\233\154\168\232\128\133; \230\156\137 %s"
--[[Translation missing --]]
--[[ L["%s for a wowhead link popup"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s no longer blacklist missions"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s start the mission without even opening the mission page. No question asked"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to actually start mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L["%s to remove from blacklist"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%s, please review the tutorial
(Click the icon to dismiss this message and start the tutorial)]=] ] = ""--]] 
L["(Ignores low bias ones)"] = "(\229\191\189\231\149\165\228\189\142\231\173\137\229\129\143\229\165\189\231\154\132)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "\229\162\158\229\138\160 %1$d \231\173\137\231\180\154\229\136\176 %2$s"
L["Adds a list of other useful followers to tooltip"] = "\229\156\168\229\183\165\229\133\183\230\143\144\231\164\186\229\162\158\229\138\160\229\133\182\228\187\150\230\156\137\231\148\168\231\154\132\232\191\189\233\154\168\232\128\133\230\184\133\229\150\174"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "\229\143\170\229\189\177\233\159\191\229\176\143\232\158\162\229\185\149\230\168\161\229\188\143\239\188\140\229\166\130\230\158\156\230\156\170\229\139\190\233\129\184\229\137\135\233\154\177\232\151\143\230\175\143\229\128\139\232\191\189\233\154\168\232\128\133\231\154\132\228\187\187\229\139\153\230\184\133\229\150\174"
L["Allowed Rewards"] = "\229\133\129\232\168\177\231\154\132\231\141\142\229\139\181"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "\229\133\129\232\168\177\228\189\142\230\136\144\229\138\159\231\142\135\231\154\132\232\179\135\230\186\144\228\187\187\229\139\153\227\128\130\228\189\191\231\148\168/gac gui\228\190\134\230\148\185\232\174\138\231\153\190\229\136\134\230\175\148\227\128\130\233\160\144\232\168\173\231\130\18680%"
--[[Translation missing --]]
--[[ L["Always counter increased resource cost"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter increased time"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Always counter no bonus loot threat"] = ""--]] 
--[[Translation missing --]]
--[[ L["Analyze parties"] = ""--]] 
--[[Translation missing --]]
--[[ L["and then by:"] = ""--]] 
L["Applied when 'maximize result' is enabled. Default is 80%"] = "\229\143\170\229\156\168'\230\156\128\229\164\167\229\140\150\231\181\144\230\158\156'\229\149\159\231\148\168\230\153\130\229\189\177\233\159\191\239\188\140\233\160\144\232\168\173\231\130\18680%"
L["Applies the best armor set"] = "\230\135\137\231\148\168\229\156\168\230\156\128\228\189\179\232\173\183\231\148\178\228\184\138"
L["Applies the best armor upgrade"] = "\230\135\137\231\148\168\229\156\168\230\156\128\228\189\179\232\173\183\231\148\178\229\141\135\231\180\154\228\184\138"
L["Applies the best weapon set"] = "\230\135\137\231\148\168\229\156\168\230\156\128\228\189\179\230\173\166\229\153\168\228\184\138"
L["Applies the best weapon upgrade"] = "\230\135\137\231\148\168\229\156\168\230\156\128\228\189\179\230\173\166\229\153\168\229\141\135\231\180\154\228\184\138"
L["Archaelogy"] = "\232\128\131\229\143\164\229\173\184"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "\229\164\167\232\158\162\229\185\149"
L["Blacklisted"] = "\229\136\151\229\133\165\233\187\145\229\144\141\229\150\174"
L["Blacklisted missions are ignored in Mission Control"] = "\233\187\145\229\144\141\229\150\174\228\184\173\231\154\132\228\187\187\229\139\153\230\156\131\229\156\168\228\187\187\229\139\153\230\142\167\229\136\182\228\184\173\229\191\189\231\149\165"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "\230\173\163\229\156\168\229\187\186\231\171\139\231\184\189\231\181\144\229\160\177\229\145\138"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s\229\183\178\231\182\147\230\187\191\228\186\134\239\188\140\232\135\179\229\176\145\230\156\131\230\181\170\232\178\187 %2$d \229\128\139\227\128\130"
--[[Translation missing --]]
--[[ L["Changes the second sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L["Changes the sort order of missions in Mission panel"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Clicking a party button will assign its followers to the current mission.
Use it to verify OHC calculated chance with Blizzard one.
If they differs please take a screenshot and open a ticket :).]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Combat ally is proposed for missions so you can consider unassigning him"] = ""--]] 
L["Complete all missions without confirmation"] = "\229\174\140\230\136\144\230\137\128\230\156\137\228\187\187\229\139\153\228\184\141\233\160\136\231\162\186\232\170\141"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "\229\134\141\230\172\161\232\128\131\233\135\143"
--[[Translation missing --]]
--[[ L["Cost reduced"] = ""--]] 
--[[Translation missing --]]
--[[ L["Could not fulfill mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Counter kill Troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
--[[Translation missing --]]
--[[ L["Disable blacklisting"] = ""--]] 
L["Disable if you dont want the full Garrison Commander Header."] = "\229\166\130\230\158\156\230\130\168\228\184\141\230\131\179\232\166\129\229\174\140\230\149\180\231\154\132Garrison Commander\230\168\153\233\161\140\229\143\175\228\187\165\229\129\156\231\148\168"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "\229\143\150\230\182\136\232\135\170\229\139\149\229\136\134\230\180\190\229\156\168\228\187\187\229\139\153\233\160\129\231\175\169\233\129\184\227\128\130\230\130\168\228\185\159\229\143\175\228\187\165\229\156\168\229\150\174\228\184\128\228\187\187\229\139\153\228\184\138\233\187\158\230\147\138Ctrl\228\190\134\229\143\150\230\182\136\227\128\130"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "\229\143\150\230\182\136\230\173\164\230\156\131\231\181\166\230\130\1681.1.8\228\187\165\228\190\134\231\154\132\228\187\139\233\157\162\239\188\140\231\181\166\228\186\136\230\136\150\229\143\150\229\190\151\227\128\130\233\156\128\232\166\129\233\135\141\232\188\137UI\227\128\130"
L["Do not show follower icon on plots"] = "\228\184\141\229\156\168\231\173\150\231\149\171\228\184\138\233\161\175\231\164\186\232\191\189\233\154\168\232\128\133\229\156\150\231\164\186"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "\230\140\129\231\186\140\230\153\130\233\150\147"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "\229\162\158\229\188\183\230\143\144\231\164\186"
L["Environment Preference"] = "\231\146\176\229\162\131\229\129\143\229\165\189"
L["Epic followers are NOT sent alone on xp only missions"] = "\229\143\178\232\169\169\232\191\189\233\154\168\232\128\133\"\228\184\141\"\230\156\131\229\150\174\231\141\168\230\180\190\231\153\188\229\136\176\229\143\170\230\156\137\231\182\147\233\169\151\229\128\188\231\154\132\228\187\187\229\139\153"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "\233\129\142\230\156\159\230\153\130\233\150\147"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "\232\191\189\233\154\168\232\128\133"
L["Follower equipment set or upgrade"] = "\232\191\189\233\154\168\232\128\133\232\163\157\229\130\153\229\165\151\232\163\157\230\136\150\229\141\135\231\180\154"
L["Follower experience"] = "\232\191\189\233\154\168\232\128\133\231\182\147\233\169\151"
L["Follower set minimum upgrade"] = "\232\191\189\233\154\168\232\128\133\229\165\151\232\163\157\230\156\128\229\176\143\231\154\132\229\141\135\231\180\154"
L["Follower Training"] = "\232\191\189\233\154\168\232\128\133\232\168\147\231\183\180"
L["Followers status "] = "\232\191\189\233\154\168\232\128\133\231\139\128\230\133\139"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "\232\166\129\229\161\158\229\164\150\232\167\128"
L["Garrison Comander Quick Mission Completion"] = "Garrison Comander\228\187\187\229\139\153\229\191\171\233\128\159\229\174\140\230\136\144"
L["Garrison Commander Mission Control"] = "Garrison Commander\228\187\187\229\139\153\230\142\167\229\136\182"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "\233\128\154\231\148\168\229\164\167\231\180\132\231\154\132\231\182\147\233\169\151\229\128\188\231\141\142\232\179\158"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "\229\133\168\229\177\128\230\136\144\229\138\159\230\169\159\231\142\135"
L["Gold incremented!"] = "\233\187\131\233\135\145\229\162\158\229\138\160\239\188\129"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "\233\154\177\232\151\143\232\191\189\233\154\168\232\128\133"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[\229\166\130\230\158\156\229\139\190\233\129\184\239\188\140\230\140\137\228\184\128\228\184\139\229\141\135\231\180\154\229\156\150\231\164\186\229\176\135\228\189\191\231\148\168\232\169\178\231\137\169\229\147\129\229\146\140\229\141\135\231\180\154\232\191\189\233\154\168\232\128\133
|cFFFF0000\228\184\141\233\160\136\231\162\186\232\170\141|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "\229\166\130\230\158\156\229\139\190\233\129\184\239\188\140\233\161\175\231\164\186\232\173\183\231\148\178\229\156\168\229\183\166\230\173\166\229\153\168\229\156\168\229\143\179"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "\229\166\130\230\158\156\230\130\168\231\185\188\231\186\140\239\188\140\230\130\168\230\156\131\229\164\177\229\142\187\229\174\131\229\128\145"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "\229\166\130\230\158\156\230\130\168\230\156\137\229\155\158\230\148\182\229\187\160\229\143\175\232\131\189\228\184\141\230\131\179\232\166\129\229\139\190\233\129\184\230\173\164\233\129\184\233\160\133"
L["Ignore \"maxed\""] = "\229\191\189\231\149\165\"\230\187\191\231\180\154\231\154\132\""
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "\229\191\189\231\149\165\229\143\178\232\169\169\231\182\147\233\169\151\228\187\187\229\139\153\227\128\130"
L["Ignore for all missions"] = "\229\191\189\231\149\165\230\137\128\230\156\137\228\187\187\229\139\153"
L["Ignore for this mission"] = "\229\191\189\231\149\165\230\173\164\228\187\187\229\139\153"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "\229\191\189\231\149\165\231\168\128\230\156\137\228\187\187\229\139\153"
L["Increased Rewards"] = "\230\143\144\233\171\152\231\141\142\229\139\181"
L["Item minimum level"] = "\231\137\169\229\147\129\230\156\128\229\176\143\231\173\137\231\180\154"
L["Item Tokens"] = "\231\137\169\229\147\129\233\129\147\229\133\183"
--[[Translation missing --]]
--[[ L["Keep cost low"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep extra bonus"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time short"] = ""--]] 
--[[Translation missing --]]
--[[ L["Keep time VERY short"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "\229\183\166\233\141\181\233\187\158\230\147\138\228\187\165\230\170\162\232\166\150\229\143\175\231\148\168\228\187\187\229\139\153"
L["Legendary Items"] = "\229\130\179\229\165\135\231\137\169\229\147\129"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "\231\173\137\231\180\154100\231\154\132\229\143\178\232\169\169\232\191\189\233\154\168\232\128\133\228\184\141\230\156\131\231\148\168\229\156\168\229\143\170\230\156\137\231\182\147\233\169\151\229\128\188\231\154\132\228\187\187\229\139\153\227\128\130"
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "\232\174\147\228\184\187\228\187\187\229\139\153\233\157\162\230\157\191\229\143\175\231\167\187\229\139\149"
L["Makes shipyard panel movable"] = "\232\174\147\232\136\185\229\161\162\233\157\162\230\157\191\229\143\175\231\167\187\229\139\149"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "\230\156\128\229\164\167\229\140\150\231\181\144\230\158\156"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "\230\156\128\229\164\167\228\187\187\229\139\153\230\140\129\231\186\140\230\153\130\233\150\147\227\128\130"
L["Minimum chance"] = "\230\156\128\229\176\143\230\169\159\231\142\135"
L["Minimum mission duration."] = "\230\156\128\229\176\143\228\187\187\229\139\153\230\140\129\231\186\140\230\153\130\233\150\147\227\128\130"
L["Minimum needed chance"] = "\230\156\128\229\176\143\233\156\128\232\166\129\231\154\132\230\169\159\231\142\135"
L["Minimum requested level for equipment rewards"] = "\232\163\157\229\130\153\231\141\142\229\139\181\230\156\128\229\176\143\233\156\128\230\177\130\231\173\137\231\180\154"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "\232\191\189\233\154\168\232\128\133\229\165\151\232\163\157\230\156\128\229\176\143\233\156\128\230\177\130\229\141\135\231\180\154(\229\162\158\229\188\183\231\137\169\229\147\129\230\156\131\230\176\184\233\129\160\229\140\133\229\144\171\229\156\168\229\133\167)"
L["Minimun chance success under which ignore missions"] = "\228\189\142\230\150\188\229\164\154\229\176\145\230\136\144\229\138\159\230\169\159\231\142\135\231\154\132\228\187\187\229\139\153\232\166\129\232\162\171\229\191\189\231\149\165"
L["Minumum needed chance"] = "\230\156\128\229\176\143\233\156\128\230\177\130\230\169\159\231\142\135"
L["Mission Control"] = "\228\187\187\229\139\153\230\142\167\229\136\182"
L["Mission Duration"] = "\228\187\187\229\139\153\230\140\129\231\186\140\230\153\130\233\150\147"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "\228\187\187\229\139\153\233\161\175\231\164\186"
L["Mission shown for follower"] = "\228\187\187\229\139\153\228\184\138\233\161\175\231\164\186\232\191\189\233\154\168\232\128\133"
L["Mission Success"] = "\228\187\187\229\139\153\230\136\144\229\138\159"
L["Mission time reduced!"] = "\228\187\187\229\139\153\230\153\130\233\150\147\231\184\174\231\159\173\239\188\129"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "\228\189\142\230\150\188\230\173\164\230\136\144\229\138\159\230\169\159\231\142\135\231\154\132\228\187\187\229\139\153\229\176\135\230\156\131\229\191\189\231\149\165"
L["Missionlist"] = "\228\187\187\229\139\153\229\136\151\232\161\168"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "\233\156\128\232\166\129\233\135\141\232\188\137UI\228\187\165\231\148\159\230\149\136"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "\228\184\141\231\162\186\232\170\141"
L["No follower gained xp"] = "\230\178\146\230\156\137\232\191\189\233\154\168\232\128\133\231\141\178\229\190\151\231\182\147\233\169\151\229\128\188"
L["No mission prefill"] = "\230\178\146\230\156\137\233\160\144\231\181\132\231\154\132\228\187\187\229\139\153"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "\233\157\158\233\187\145\229\144\141\229\150\174"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "\230\178\146\228\187\128\233\186\188\229\165\189\229\160\177\229\145\138"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "\232\191\189\233\154\168\232\128\133\230\149\184\233\135\143"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "\229\143\170\230\156\137\233\171\152\230\150\188%2$d%%\230\136\144\229\138\159\230\169\159\231\142\135\231\154\132\229\137\141%1$d\228\187\187\229\139\153\230\156\131\233\161\175\231\164\186"
L["Only meaningful upgrades are shown"] = "\229\143\170\230\156\137\230\152\142\233\161\175\231\154\132\229\141\135\231\180\154\230\137\141\230\156\131\233\161\175\231\164\186"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "\229\142\159\229\167\139\230\166\130\229\191\181\232\136\135\228\187\139\233\157\162\229\190\158%s"
L["Original method"] = "\229\142\159\229\167\139\231\154\132\230\150\185\230\179\149"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "\229\142\159\229\167\139\230\142\146\229\186\143\229\176\135\230\129\162\229\190\169\229\142\159\229\167\139\230\142\146\229\186\143\230\150\185\230\179\149\239\188\140\228\184\141\231\174\161\229\174\131\230\152\175\228\187\128\233\186\188(\229\166\130\230\158\156\228\189\160\230\156\137\229\143\166\228\184\128\229\128\139\230\143\146\228\187\182\230\142\146\229\186\143\228\187\187\229\139\153\239\188\140\229\174\131\230\135\137\232\169\178\229\134\141\229\149\159\229\139\149)"
L["Other"] = "\229\133\182\228\187\150"
L["Other rewards"] = "\229\133\182\228\187\150\231\141\142\229\139\181"
L["Other settings"] = "\229\133\182\228\187\150\232\168\173\229\174\154"
L["Other useful followers"] = "\229\133\182\228\187\150\230\156\137\231\148\168\231\154\132\232\191\189\233\154\168\232\128\133"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "\232\153\149\231\144\134\228\184\173\228\187\187\229\139\153%d\231\154\132%d"
L["Profession"] = "\232\129\183\230\165\173"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "\231\168\174\230\151\143\229\129\143\229\165\189"
L["Rare missions will not be considered"] = "\231\168\128\230\156\137\228\187\187\229\139\153\228\184\141\232\162\171\232\128\131\230\133\174"
L["Reagents"] = "\232\179\135\230\186\144"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "\232\129\178\230\156\155\231\137\169\229\147\129"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "\231\141\142\229\139\181\233\161\158\229\158\139"
L["Right-Click to blacklist"] = "\229\143\179\233\141\181\233\187\158\230\147\138\229\138\160\229\133\165\233\187\145\229\144\141\229\150\174"
L["Right-Click to remove from blacklist"] = "\229\143\179\233\141\181\233\187\158\230\147\138\229\190\158\233\187\145\229\144\141\229\150\174\231\167\187\233\153\164"
L["Rush orders"] = "\232\182\149\229\183\165\232\168\130\229\150\174"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "\232\136\185\229\161\162\229\164\150\232\167\128"
L["Show Garrison Commander menu"] = "\233\161\175\231\164\186Garrison Commander\233\129\184\229\150\174"
L["Show itemlevel"] = "\233\161\175\231\164\186\231\137\169\229\147\129\231\173\137\231\180\154"
L["Show upgrades"] = "\233\161\175\231\164\186\229\141\135\231\180\154"
L["Show xp"] = "\233\161\175\231\164\186\231\182\147\233\169\151\229\128\188"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "\230\174\186\230\137\139"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "\230\159\144\228\186\155\232\191\189\233\154\168\232\128\133"
L["Sort missions by:"] = "\230\142\146\229\186\143\228\187\187\229\139\153\228\190\157\230\147\154\239\188\154"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "\228\184\128\230\172\161\230\180\190\233\129\163\230\130\168\230\137\128\230\156\137\231\154\132\228\187\187\229\139\153\227\128\130\231\132\161\233\160\136\231\162\186\232\170\141\227\128\130"
L["Success Chance"] = "\230\136\144\229\138\159\230\169\159\231\142\135"
L["Swap upgrades positions"] = "\228\186\164\230\143\155\229\141\135\231\180\154\228\189\141\231\189\174"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "\229\156\168Garrison Commander\232\136\135Master Plan\231\154\132\228\187\187\229\139\153\228\187\139\233\157\162\228\184\173\229\136\135\230\143\155"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "\229\168\129\232\132\133\229\143\141\229\136\182"
L["To go: %d"] = "\233\130\132\233\156\128\232\166\129\239\188\154%d"
L["Toggles Garrison Commander Menu Header on/off"] = "\229\136\135\230\143\155Garrison Commander\233\129\184\229\150\174\230\168\153\233\161\140 \233\150\139/\233\151\156"
L["Toys and Mounts"] = "\231\142\169\229\133\183\232\136\135\229\157\144\233\168\142"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions, raise \"%s\""] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "\229\143\150\230\182\136\229\139\190\233\129\184\229\143\175\228\187\165\229\133\129\232\168\177\230\130\168\231\130\186\230\175\143\231\168\174\231\141\142\229\139\181\233\161\158\229\158\139\232\168\173\229\174\154\231\137\185\229\174\154\231\154\132\230\136\144\229\138\159\230\169\159\231\142\135"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "\232\167\163\233\142\150\233\157\162\230\157\191"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "\229\141\135\231\180\154%1$s\229\136\176%2$d\231\137\169\229\147\129\231\173\137\231\180\154"
L["Upgrading to |cff00ff00%d|r"] = "\229\141\135\231\180\154\229\136\176 |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "\228\189\191\231\148\168\229\164\167\232\158\162\229\185\149"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "\228\189\191\231\148\168GC\228\187\139\233\157\162"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "\228\189\191\231\148\168\232\173\183\231\148\178\233\129\147\229\133\183"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "\228\189\191\231\148\168\230\173\166\229\153\168\233\129\147\229\133\183"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "\231\149\182\229\139\190\233\129\184\229\190\140\239\188\140\233\161\175\231\164\186\230\175\143\229\128\139\232\191\189\233\154\168\232\128\133\229\136\176\228\184\139\228\184\128\231\173\137\231\180\154\230\137\128\233\156\128\231\154\132\231\182\147\233\169\151\229\128\188"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "\231\149\182\229\139\190\233\129\184\229\190\140\239\188\140\233\161\175\231\164\186\230\175\143\229\128\139\230\187\191\231\180\154\232\191\189\233\154\168\232\128\133\230\173\166\229\153\168\232\136\135\232\173\183\231\148\178\231\173\137\231\180\154\231\154\132\230\140\137\233\136\149"
--[[Translation missing --]]
--[[ L["When no free followers are available shows empty follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["When we cant achieve the requested %1$s, we try to reach at least this one without (if possible) going over 100%%"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %1$s you ask to always counter the Hazard kill troop.
This means that OHC will try to counter it OR use a troop with just one durability left.
The target for this switch is to avoid wasting durability point, NOT to avoid troops' death.]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[With %2$s you ask to never let a troop die.
This not only implies %1$s and %3$s, but force OHC to never send to mission a troop which will die.
The target for this switch is to totally avoid killing troops, even it for this we cant fill the party]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Would start with "] = ""--]] 
--[[Translation missing --]]
--[[ L["XP"] = ""--]] 
L["Xp incremented!"] = "\231\182\147\233\169\151\229\128\188\229\162\158\229\138\160\239\188\129"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "\230\130\168\230\181\170\232\178\187\228\186\134|cffff0000%d|cffffd200 \233\187\158\230\149\184!!!"
L["You can also send mission one by one clicking on each button."] = "\230\130\168\228\185\159\229\143\175\228\187\165\233\128\143\233\129\142\233\187\158\230\147\138\230\175\143\229\128\139\230\140\137\233\136\149\228\184\128\229\128\139\228\184\128\229\128\139\230\180\190\233\129\163\227\128\130"
--[[Translation missing --]]
--[[ L[ [=[You can blacklist missions right clicking mission button.
Since 1.5.1 you can start a mission witout passing from mission page shift-clicking the mission button.
Be sure you liked the party because no confirmation is asked]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["You can choose not to use a troop type clicking its icon"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[You can choose to limit how much champions are sent together.
Right now OHC is not using more than %3$s champions in the same mission-

Note that %2$s overrides it.]=] ] = ""--]] 
L["You can open the menu clicking on the icon in top right corner"] = "\230\130\168\229\143\175\228\187\165\233\187\158\230\147\138\229\143\179\228\184\138\232\167\146\231\154\132\229\156\150\231\164\186\228\187\165\233\150\139\229\149\159\233\129\184\229\150\174"
L["You have ignored followers"] = "\230\130\168\230\156\137\229\191\189\231\149\165\231\154\132\232\191\189\233\154\168\232\128\133"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "\230\130\168\230\156\170\230\155\190\229\159\183\232\161\140\233\128\153\229\128\139\228\187\187\229\139\153"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "\230\130\168\229\159\183\232\161\140\233\129\142\230\173\164\228\187\187\229\139\153 %d\230\172\161\228\184\166\228\184\148\230\136\144\229\138\159\230\169\159\231\142\135\230\156\137"

return
end
