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
L["(Ignores low bias ones)"] = "(Ignorer celles à basse priorité)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "Ajoute %1$d niveaux à %2$s"
L["Adds a list of other useful followers to tooltip"] = "Ajoute une liste d'autres sujets utiles dans l'infobulle"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "N'affecte que le mode petit écran, masquant la liste par mission de sujet si décoché"
L["Allowed Rewards"] = "Récompenses reçues"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Permet un pourcentage de réussite inférieur pour des missions de ressources. Utiliser /gac gui pour le changer. Il est par défaut à 80 %."
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
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Affecter quand « maximiser le résultat » est actif. Il est par défaut de 80 %"
L["Applies the best armor set"] = "Applique le meilleur ensemble d'armure"
L["Applies the best armor upgrade"] = "Applique la meilleure amélioration d'armure"
L["Applies the best weapon set"] = "Applique le meilleur ensemble d'arme"
L["Applies the best weapon upgrade"] = "Applique la meilleure amélioration d'arme"
L["Archaelogy"] = "Archéologie"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "Grand écran"
L["Blacklisted"] = "Liste noire"
L["Blacklisted missions are ignored in Mission Control"] = "Les missions en liste noire sont ignorées dans Contrôle de mission"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "Création du rapport final"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "Maxi pour %1$s. En dépensera au moins %2$d"
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
L["Consider again"] = "Reconsidérer"
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
L["Disable if you dont want the full Garrison Commander Header."] = "À désactiver si vous ne voulez pas de l'intitulé naval complet"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Désactive le remplissage automatique des sujets sur la page de mission, ou maintenir CTRL tout en cliquant sur une mission."
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Désactiver ceci vous donnera l'interface de version 1.1.8. Rechargera l'interface maintenant."
L["Do not show follower icon on plots"] = "Ne pas afficher l'icône des sujets dans leurs emplacements"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "Durée"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "Infobulle améliorée"
L["Environment Preference"] = "Préférence d'environnement"
L["Epic followers are NOT sent alone on xp only missions"] = "Les sujets épiques ne sont PAS envoyés seuls dans des missions d'XP uniquement"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "Délai avant expiration"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "Sujet"
L["Follower equipment set or upgrade"] = "Équipement du sujet défini ou amélioré"
L["Follower experience"] = "Expérience du sujet"
L["Follower set minimum upgrade"] = "Amélioration minimale du sujet définie"
L["Follower Training"] = "Formation de sujet"
L["Followers status "] = "Statuts des sujets"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "Arrivée de fief"
L["Garrison Comander Quick Mission Completion"] = "Terminer rapidement toutes les missions navales"
L["Garrison Commander Mission Control"] = "Contrôle des missions navales"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "Évaluation totale du gain en XP"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "Chance totale de succès"
L["Gold incremented!"] = "Or augmenté !"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "Masquer les sujets"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[Si activé, cliquer sur une icône d'amélioration fera disparaître l'objet et améliorera le sujet
|cFFFF0000AUCUNE CONFIRMATION !|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "SI coché, affiche les armures à gauche et les armes à droite"
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
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "SI vous avez un centre de tri, vous ne voulez probablement pas avoir ça une fois vérifié"
L["Ignore \"maxed\""] = "Ignorer \"maximisé\""
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "Ignorer sujet épique pour les missions à XP."
L["Ignore for all missions"] = "Ignorer pour toutes les missions"
L["Ignore for this mission"] = "Ignorer pour cette mission"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "Ignorer les missions rares"
L["Increased Rewards"] = "Augmentation des récompenses"
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
L["Legendary Items"] = "Objet légendaire"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "Les sujets épiques de niveau 100 ne sont pas utilisés pour les missions d'XP uniquement."
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
L["Maximize result"] = "Maximiser le résultat"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "Durée maximale de mission."
L["Minimum chance"] = "Chance minimale"
L["Minimum mission duration."] = "Durée minimale de mission."
L["Minimum needed chance"] = "Chance minimale nécessaire"
L["Minimum requested level for equipment rewards"] = "Niveau requis minimum pour les récompenses d'équipement"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Amélioration minimale requise pour l'équipement des sujets (les améliorations sont toujours inclus)"
L["Minimun chance success under which ignore missions"] = "Réussite minimale en dessous de laquelle les missions seront ignorées"
L["Minumum needed chance"] = "Chance minimale nécessaire"
L["Mission Control"] = "Contrôle de missions"
L["Mission Duration"] = "Durée de missions"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "Affichage de missions"
L["Mission shown for follower"] = "Mission affichée pour les sujets"
L["Mission Success"] = "Succès de missions"
L["Mission time reduced!"] = "Durée de mission réduite !"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "Les missions avec des chances faibles seront ignorées"
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
L["Nothing to report"] = "Rien à signaler"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "Nombre de sujets"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Seuls les %1$d premières missions avec plus de %2$d%% de chances de succès sont affichées"
L["Only meaningful upgrades are shown"] = "N'afficher que les améliorations utiles"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "Conception et interface originels de %s"
L["Original method"] = "Méthode originale"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Trie original restaure la méthode de trie par défaut, quelle qu'elle fût (si vous avez un autre addon pour trier les missions, il devrait fonctionner à nouveau)"
L["Other"] = "Autre"
L["Other rewards"] = "Autres récompenses"
L["Other settings"] = "Autres paramètres"
L["Other useful followers"] = "Autres sujets utiles"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "Traitement de la mission %d sur %d"
L["Profession"] = "Métier"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "Préférence de race"
L["Rare missions will not be considered"] = "Les missions rares ne sont pas examinées"
L["Reagents"] = "Réactifs"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "Objets de réputations"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "Type de récompense"
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
L["Show upgrades"] = "Affiche les améliorations"
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
L["Submit all your mission at once. No question asked."] = "Soumettre toutes vos missions en une fois. Aucune confirmation demandée."
L["Success Chance"] = "Chance de succès"
L["Swap upgrades positions"] = "Mettre à jour les positions permutées"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "Permuter l'interface entre Garrison Commander et Master Plan pour les missions"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "Niveau de menace"
L["To go: %d"] = "Aller à : %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Activer/désactiver le menu d'intitulé de Garrison Commander"
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
L["Unchecking this will allow you to set specific success chance for each reward type"] = "Décocher pour définir les chances de réussite pour chaque type de récompense"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "Déverrouille le panneau"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "Amélioration du ilvl de %1$s à %2$d"
L["Upgrading to |cff00ff00%d|r"] = "Amélioration à |cff00ff00%d|r"
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
L["When checked, show on each follower button missing xp to next level"] = "Quand coché, affiche l'XP nécessaire, pour le prochain niveau, sur chaque bouton de sujets"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Quand coché, affiche le niveau d'arme et d'armure sur chaque bouton des sujets maximisés"
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
L["Xp incremented!"] = "XP augmentée !"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Vous gaspillez |cffff0000%d|cffffd200 point(s) !!!"
L["You can also send mission one by one clicking on each button."] = "Vous pouvez aussi débuter les missions une par une en cliquant sur chaque bouton."
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
L["You can open the menu clicking on the icon in top right corner"] = "Vous pouvez ouvrir le menu en cliquant sur l'icône dans le coin supérieur droit"
L["You have ignored followers"] = "Vous avez ignoré des sujets"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "Vous n'avez jamais effectué cette mission"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "Vous avez effectué cette mission %d fois avec un rapport de"

return
end
L=l:NewLocale(me,"deDE")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4Anhänger:Anhänger; mit %s"
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
L["Add %1$d levels to %2$s"] = "Erhöhe die %2$s um %1$d Stufen"
L["Adds a list of other useful followers to tooltip"] = "Füge dem Tooltip eine Liste anderer nützlicher Anhänger hinzu"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "Nur für den Kleinfenstermodus; Versteckt die Pro-Anhänger-Missionsliste, wenn hier das Häkchen fehlt."
L["Allowed Rewards"] = "Erlaubte Belohnungen"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Erlaubt eine geringere Erfolgschance für Ressourcenmissionen. Mit \"/gac gui\" kannst du diesen Prozentwert ändern. Standard ist 80%."
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
L["Applies the best armor set"] = "Wendet das beste Rüstungsset an."
L["Applies the best armor upgrade"] = "Wendet die beste Rüstungsverbesserung an."
L["Applies the best weapon set"] = "Wendet das beste Waffenset an."
L["Applies the best weapon upgrade"] = "Wendet die beste Waffenverbesserung an."
L["Archaelogy"] = "Archäologie"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "Großes Fenster"
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
L["Complete all missions without confirmation"] = "Beende alle Missionen ohne Bestätigung"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "Wieder berücksichtigen"
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
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Deaktiviert das automatische Befüllen von Missionen auf der Missionsseite. Du kannst auch STRG+MAUSKLICK drücken, um einzelne Missionen zu befüllen."
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Durch Deaktivieren dieser Option erhältst du das Interface von 1.1.8. Das Interface muss dabei neu geladen werden."
L["Do not show follower icon on plots"] = "Anhängersymbole auf den Flächen nicht anzeigen"
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
L["Epic followers are NOT sent alone on xp only missions"] = "Epische Anhänger werden NICHT allein auf EP-Missionen geschickt"
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
L["Follower"] = "Anhänger"
L["Follower equipment set or upgrade"] = "Anhängerausrüstungsset oder -verbesserung"
L["Follower experience"] = "Anhängererfahrung"
L["Follower set minimum upgrade"] = "Minimale Aufwertung für Anhängersets"
L["Follower Training"] = "Anhängerausbildung"
L["Followers status "] = "Anhängerstatus"
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
L["Global approx. xp reward"] = "Globale ungefähre EP-Belohnung"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "Gesamte Erfolgschance"
L["Gold incremented!"] = "Gold erhöht!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "Anhänger verstecken"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[Wenn aktiviert, wird beim Anklicken eines Aufwertungssymbols der Gegenstand verbraucht und der Anhänger verbessert
|cFFFF0000OHNE BESTÄTIGUNGSABFRAGE|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "Wenn markiert, werden Rüstungen auf der linken Seite und Waffen auf der rechten Seite angezeigt"
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
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "Wenn du ein Wiederverwertungsgebäude hast, sollte diese Option deaktiviert bleiben"
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
L["Left Click to see available missions"] = "Linksklicke hier, um alle verfügbaren Missionen zu sehen"
L["Legendary Items"] = "Legendäre Gegenstände"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "Epische Stufe-100-Anhänger werden nicht bei Nur-EP-Missionen benutzt."
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
L["Minimum needed chance"] = "Kleinstmögliche Chance"
L["Minimum requested level for equipment rewards"] = "Kleinstmögliche Stufe für Ausrüstungsbelohnungen"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Kleinstmögliche Aufwertung für Anhängersets (Verbesserungen sind immer enthalten)"
L["Minimun chance success under which ignore missions"] = "Minimale Erfolgschance – alle Missionen, die darunter liegen, werden ignoriert"
L["Minumum needed chance"] = "Kleinstmögliche Chance"
L["Mission Control"] = "Missionssteuerung"
L["Mission Duration"] = "Missionsdauer"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "Anzahl gezeigter Missionen"
L["Mission shown for follower"] = "Angezeigte Missionen für einen Anhänger"
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
L["No follower gained xp"] = "Kein Anhänger bekam Erfahrung"
L["No mission prefill"] = "Kein Vorab-Auffüllen bei Missionen"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "Nicht ignoriert"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "Es gibt nichts zu berichten"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "Anzahl der Anhänger"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Nur die ersten %1$d Missionen mit einer Erfolgschance von über %2$d%% werden angezeigt"
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
L["Other useful followers"] = "Andere nützliche Anhänger"
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
L["Reputation Items"] = "Rufgegenstände"
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
L["Rush orders"] = "Eilaufträge"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "Werftdarstellung"
L["Show Garrison Commander menu"] = "Das Menü von Garrison Commander zeigen"
L["Show itemlevel"] = "Gegenstandsstufe zeigen"
L["Show upgrades"] = "Aufwertungen zeigen"
L["Show xp"] = "EP zeigen"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "Schlächter"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "Manche Anhänger"
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
L["Toggles Garrison Commander Menu Header on/off"] = "Schalte Menü-Header vom Garrison Commander an/aus"
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
L["Unchecking this will allow you to set specific success chance for each reward type"] = "Entferne hier das Häkchen, wenn du für jeden Belohnungstyp eine spezifische Erfolgschance angeben willst."
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
L["Use big screen"] = "Benutze das große Fenster"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "GC-Interface benutzen"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "Benutzt Rüstungsverbesserung"
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
L["When checked, show on each follower button missing xp to next level"] = "Wenn aktiviert, wird auf jedem Anhänger-Button die fehlende EP bis zur nächsten Stufe angezeigt"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Wenn aktiviert, wird auf jedem Anhänger-Button die Waffen- und Rüstungsstufe bei maximierten Anhängern angezeigt"
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
L["Xp incremented!"] = "EP erhöht!"
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
L["You can open the menu clicking on the icon in top right corner"] = "Du kannst das Menü öffnen, indem du auf das Symbol in der oberen rechten Ecke klickst."
L["You have ignored followers"] = "Du hast ignorierte Anhänger"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "Du hast diese Mission noch nie durchgeführt."
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "Du hast diese Mission %d-mal durchgeführt, mit einem Gewinnverhältnis von"

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
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "Si applica solo alla modalità dimensioni native, nascode la lista missioni per seguace se inattivo"
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
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Si applica quando 'massimizza risultato' è abilitato. Default 80%"
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
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Disabilitando questo avrete la vecchia interfaccia (1.1.8). Verrà effettuato un reload dell' interfaccia"
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
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "Se marcato, cliccando un upgrade l'oggetto verrà consumato e il seguace aggiornato |cFFFF0000SENZA CONFERME|r"
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
L["Level 100 epic followers are not used for xp only missions."] = "I seguaci di livello 100 e qualità epica non sono usati per le missioni di soli pe"
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
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Ripristina il metodo di ordinamento originale, Se avete un altro addon che oridna le missioni, saraà questo addon a agestirlo."
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
L["Success Chance"] = "Probabilità di successo"
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
L["%s |4follower:followers; with %s"] = "%2$s|1이;가; 있는 %1$s 추종자"
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
L["(Ignores low bias ones)"] = "(하나의 낮은 성향 무시)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "%2$s에 %1$d 레벨 추가"
L["Adds a list of other useful followers to tooltip"] = "다른 유용한 추종자의 목록을 툴팁에 추가"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "작은 화면 모드에만 영향을 줍니다, 선택하지 않으면 추종자 별로 임무 목록을 숨깁니다"
L["Allowed Rewards"] = "적용된 보상"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "자원 임무에 낮은 성공 확률을 허용합니다. 백분율을 변경하려면 /gac gui를 사용하세요. 기본값은 80%입니다"
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
L["Applied when 'maximize result' is enabled. Default is 80%"] = "'결과 최대화'가 활성화되어 있을 때 적용됩니다. 기본값은 80%입니다"
L["Applies the best armor set"] = "최고 방어구 세트 적용"
L["Applies the best armor upgrade"] = "최고 방어구 강화 적용"
L["Applies the best weapon set"] = "최고 무기 세트 적용"
L["Applies the best weapon upgrade"] = "최고 무기 강화 적용"
L["Archaelogy"] = "고고학"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "큰 화면"
L["Blacklisted"] = "차단됨"
L["Blacklisted missions are ignored in Mission Control"] = "차단된 임무는 임무 제어에서 무시됩니다"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "최종 보고서 작성"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s에 도달했습니다. 최소 %2$d의 자원을 사용하세요"
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
L["Complete all missions without confirmation"] = "확인없이 모든 임무 완료"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "다시 고려하기"
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
L["Disable if you dont want the full Garrison Commander Header."] = "전체 Garrison Commander 헤더를 원하지 않으면 비활성하세요."
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "임무 페이지 화면의 자동 채우기를 비활성합니다. 또한 Ctrl 키를 누르고 클릭하면 단일 임무에서 비활성합니다"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "이것을 비활성하면 1.1.8의 인터페이스를 제공합니다, 인터페이스 재시작이 필요합니다"
L["Do not show follower icon on plots"] = "구성에 추종자 아이콘 표시하지 않기"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "임무 수행 시간"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "툴팁 강화"
L["Environment Preference"] = "선호 환경"
L["Epic followers are NOT sent alone on xp only missions"] = "영웅 등급 추종자는 경험치 임무에 혼자 보내지지 않습니다"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "만료 시간"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "추종자"
L["Follower equipment set or upgrade"] = "추종자 장비 세트 또는 강화"
L["Follower experience"] = "추종자 경험치"
L["Follower set minimum upgrade"] = "추종자 세트 최소 강화"
L["Follower Training"] = "추종자 훈련"
L["Followers status "] = "추종자 상태"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "주둔지 모양"
L["Garrison Comander Quick Mission Completion"] = "Garrison Comander 빠른 임무 완료"
L["Garrison Commander Mission Control"] = "Garrison Commander 임무 제어"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "전역 예상 경험치 보상"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "공통 성공 확률"
L["Gold incremented!"] = "골드 증가됨!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "추종자 숨기기"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "선택하고 강화 아이콘을 클릭하면 아이템을 소비하고 추종자를 강화합니다, |cFFFF0000아무것도 묻지 않습니다|r"
L["IF checked, shows armors on the left and weapons on the right "] = "선택하면 방어구를 왼쪽에 무기를 오른쪽에 표시합니다"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "계속하면 그것들을 잃습니다"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "재활용 처리장이 있다면 이것을 선택하고 싶지 않을 것입니다"
L["Ignore \"maxed\""] = "\"최대 레벨\" 무시"
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "경험치 임무에 영웅 등급 무시."
L["Ignore for all missions"] = "모든 임무 무시"
L["Ignore for this mission"] = "이 임무 무시"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "희귀 임무 무시"
L["Increased Rewards"] = "증가된 보상"
L["Item minimum level"] = "아이템 최소 레벨"
L["Item Tokens"] = "아이템 토큰"
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
L["Left Click to see available missions"] = "왼쪽 클릭하여 수행 가능한 임무 확인"
L["Legendary Items"] = "전설 아이템"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "레벨 100 영웅 등급 추종자는 경험치 임무에 사용하지 않습니다."
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "주 임무 창 이동 가능하게 만들기"
L["Makes shipyard panel movable"] = "해상 임무 창 이동 가능하게 만들기"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "결과 최대화"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "최대 임무 지속시간."
L["Minimum chance"] = "최소 확률"
L["Minimum mission duration."] = "최소 임무 지속시간."
L["Minimum needed chance"] = "최소 요구 확률"
L["Minimum requested level for equipment rewards"] = "장비 보상에 대한 최소 요구 레벨"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "추종자 세트에 대한 최소 요구 강화 (향상은 언제나 포함)"
L["Minimun chance success under which ignore missions"] = "임무를 무시할 최소 성공 확률"
L["Minumum needed chance"] = "최소 요구 확률"
L["Mission Control"] = "임무 제어"
L["Mission Duration"] = "임무 지속시간"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "표시된 임무"
L["Mission shown for follower"] = "추종자에 표시된 임무"
L["Mission Success"] = "임무 성공"
L["Mission time reduced!"] = "임무 시간 감소됨!"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "낮은 성공 확률의 임무는 무시합니다"
L["Missionlist"] = "임무 목록"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "적용하려면 인터페이스를 반드시 재시작해야 합니다"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "확인 없음"
L["No follower gained xp"] = "경험치를 획득한 추종자 없음"
L["No mission prefill"] = "임무 미리 채우지 않기"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "차단 목록 없음"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "보고할 내용 없음"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "추종자의 수"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "성공 확률 %2$d%% 이상의 첫 %1$d개 임무만 표시합니다"
L["Only meaningful upgrades are shown"] = "의미있는 강화만 표시합니다"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "%s에 의한 원래의 개념과 인터페이스"
L["Original method"] = "원래의 방법"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "원래의 정렬은 원래의 정렬 방법을 복원합니다 (임무를 정렬하는 다른 애드온이 있다면 다시 시작해야 합니다)"
L["Other"] = "기타"
L["Other rewards"] = "기타 보상"
L["Other settings"] = "기타 설정"
L["Other useful followers"] = "다른 유용한 추종자"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "%d / %d 임무 처리 중"
L["Profession"] = "전문 기술"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "선호 종족"
L["Rare missions will not be considered"] = "희귀 임무는 고려하지 않습니다"
L["Reagents"] = "재료"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "평판 아이템"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "보상 유형"
L["Right-Click to blacklist"] = "오른쪽 클릭하여 차단"
L["Right-Click to remove from blacklist"] = "오른쪽 클릭하여 차단 목록에서 제거"
L["Rush orders"] = "긴급 주문"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "해상 함대 모양"
L["Show Garrison Commander menu"] = "Garrison Commander 메뉴 표시"
L["Show itemlevel"] = "아이템 레벨 표시"
L["Show upgrades"] = "강화 표시"
L["Show xp"] = "경험치 표시"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "학살자"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "몇몇 추종자"
L["Sort missions by:"] = "임무 정렬 방법:"
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "당신의 임무를 한번에 제출합니다. 아무 것도 묻지 않습니다."
L["Success Chance"] = "성공 확률"
L["Swap upgrades positions"] = "강화 위치 전환"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "임무에 Garrison Commander와 Master Plan 인터페이스 간에 전환하기"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "위협 요소 대응"
L["To go: %d"] = "레벨 상승: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Garrison Commander 메뉴 헤더 켜기/끄기 전환"
L["Toys and Mounts"] = "장난감과 탈것"
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
L["Unchecking this will allow you to set specific success chance for each reward type"] = "선택해제하면 각 보상 유형에 특정 성공 확률을 설정할 수 있습니다"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "창 잠금해제"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "%1$s에서 %2$d 아이템 레벨로 강화"
L["Upgrading to |cff00ff00%d|r"] = "|cff00ff00%d|r|1으로;로; 업그레이드 중"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "큰 화면 사용"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "GC 인터페이스 사용"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "방어구 토큰 사용"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "무기 토큰 사용"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "선택하면 각 추종자 버튼에 다음 레벨까지 부족한 경험치가 표시됩니다"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "선택하면 최고 레벨 추종자의 무기와 방어구 레벨이 각 추종자 버튼에 표시됩니다"
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
L["Xp incremented!"] = "경험치 증가됨!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "|cffff0000%d|cffffd200 포인트를 낭비 중입니다!!!"
L["You can also send mission one by one clicking on each button."] = "각 버튼을 한번 클릭하여 임무를 하나씩 보낼 수 있습니다."
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
L["You can open the menu clicking on the icon in top right corner"] = "우측 상단 모서리에 있는 아이콘을 클릭하면 메뉴를 열 수 있습니다"
L["You have ignored followers"] = "무시된 추종자가 있습니다"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "이 임무를 수행한 적이 없습니다"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "이 임무를 다음의 성공 확률로 %d번 수행했습니다:"

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
L["%s |4follower:followers; with %s"] = "%s |4соратника:соратники; с %s"
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
L["(Ignores low bias ones)"] = "(Игнорирует низкий уровень смещения)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "Добавьте %1$d уровни в %2$s"
L["Adds a list of other useful followers to tooltip"] = "Добавляет список других полезных соратников во всплывающую подсказку"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "Влияет только на небольшой экранный режим, скрывая список миссий для каждого соратника, если не установлен флажок"
L["Allowed Rewards"] = "Разрешенные награды"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "Позволяет снизить процент успеха для миссий с ресурсами. Используйте команду /gac для изменения процента. По умолчанию 80%"
L["Always counter increased resource cost"] = "Всегда отражать увеличение стоимости"
L["Always counter increased time"] = "Всегда отражать увеличение времени"
L["Always counter kill troops (ignored if we can only use troops with just 1 durability left)"] = "Всегда отражать убийство отрядов (игнорируется для отрядов с одной единиций жизнанной силы)"
L["Always counter no bonus loot threat"] = "Всегда отражать отсутствие бонуса"
L["Analyze parties"] = "Анализировать группы"
L["and then by:"] = "и потом по:"
L["Applied when 'maximize result' is enabled. Default is 80%"] = "Применяется, когда включен параметр «максимизировать результат». По умолчанию 80%"
L["Applies the best armor set"] = "Применяет лучший комплект брони"
L["Applies the best armor upgrade"] = "Применяет лучшее обновление брони"
L["Applies the best weapon set"] = "Применяет лучший набор оружия"
L["Applies the best weapon upgrade"] = "Применяет лучшее обновление оружия"
L["Archaelogy"] = "Археология"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
L["Attempting %s"] = "Пытаемся %s"
L["Base Chance"] = "Базовай шанс"
L["Better parties available in next future"] = "Более лучшие группы станут доступны в ближайшее время"
L["Big screen"] = "Большой экран"
L["Blacklisted"] = "Чёрный список"
L["Blacklisted missions are ignored in Mission Control"] = "Миссии из черного списка игнорируются в управлении миссиями"
L["Bonus Chance"] = "Шанс бонуса"
L["Building Final report"] = "Построение окончательного отчета"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = [=[Достигнуто %1$. Потратьте хотя бы 2%$
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
L["Complete all missions without confirmation"] = "Завершить все задания без подтверждения"
L["Configuration for mission party builder"] = "Настройки построителя групп для заданий"
L["Consider again"] = "Вновь рассмотреть"
L["Cost reduced"] = "Стоимость уменьшена"
L["Could not fulfill mission, aborting"] = "Невозможно заполнить группы для задания. Отменяем"
L["Counter kill Troops"] = "Парировать смерть отрядов"
--[[Translation missing --]]
--[[ L["Customization options (non mission related)"] = ""--]] 
L["Disable blacklisting"] = "Запретить добавление в чёрный список"
L["Disable if you dont want the full Garrison Commander Header."] = "Отключите, если вы не хотите полный заголовок Garrison Commander."
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "Отключает автоматическое заполнение экрана страницы миссии. Вы также можете нажать кнопку управления, чтобы отключить его для одной миссии"
L["Disables warning: "] = "Запрещает предупреждения:"
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "Отключение этого параметра даст вам интерфейс версии 1.1.8. Необходимо перезагрузить интерфейс"
L["Do not show follower icon on plots"] = "Не показывать значок соратника на графиках"
L["Dont use this slot"] = "Не использовать этот слот"
L["Don't use troops"] = "Не использовать отряды"
L["Duration reduced"] = "Длительность уменьшена"
L["Duration Time"] = "Продолжительность"
L["Elite: Prefer overcap"] = "Элитные: предпочесть избыточность"
L["Elites mission mode"] = "Режим элитных заданий"
L["Empty missions sorted as last"] = "Пустые задания отсортированы последними"
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "Улучшить подсказку"
L["Environment Preference"] = "Окружающая среда"
L["Epic followers are NOT sent alone on xp only missions"] = "Эпические соратники не отправляются в одиночку на задания по получению опыта"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "Время окончания срока действия"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "Соратник"
L["Follower equipment set or upgrade"] = "Улучшение экипировки соратника"
L["Follower experience"] = "Опыт Соратника"
L["Follower set minimum upgrade"] = "Минимальное улучшение экипировки соратника"
L["Follower Training"] = "Тренировка Соратника"
L["Followers status "] = "Статус Соратника"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "Внешний вид гарнизона"
L["Garrison Comander Quick Mission Completion"] = "Garrison Comander Быстрое завершение миссии"
L["Garrison Commander Mission Control"] = "Garrison Commander Центр Управления "
L["General"] = "Основное"
L["Global approx. xp reward"] = "Общее прибижение получения опыта"
L["Global approx. xp reward per hour"] = "Общее прибижение получения опыта в час"
L["Global success chance"] = "Глобальный шанс на успех"
L["Gold incremented!"] = "Золото прибавилось!"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "Скрыть соратников"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = "Если этот флажок установлен, нажатие на значок обновления приведет к усилению экипировки соратника, |cFFFF0000NO QUESTION ASKED|r"
L["IF checked, shows armors on the left and weapons on the right "] = "Если отмечен, показывает доспехи слева и оружие справа"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "Если вы продолжите, вы потеряете их"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "Если у вас есть Склад Утиля вы вероятно не хотите чтобы его проверили "
L["Ignore \"maxed\""] = "Игнорировать уже улучшенных соратников"
L["Ignore busy followers"] = "Игнорировать занятых соратников"
L["Ignore epic for xp missions."] = "Игнорировать эпики для миссий на опыт. "
L["Ignore for all missions"] = "Игнорировать все миссии"
L["Ignore for this mission"] = "Игнорировать эту миссию"
L["Ignore inactive followers"] = "Игнорировать неактивных соратников"
L["Ignore rare missions"] = "Игнорировать редкие миссии"
L["Increased Rewards"] = "Увеличение вознаграждения"
L["Item minimum level"] = "Минимальный уровень предметов"
L["Item Tokens"] = "Токен"
L["Keep cost low"] = "Уменьшать стоимость"
L["Keep extra bonus"] = "Добиваться дополнительного бонуса"
L["Keep time short"] = "Сделать время задания коротким"
L["Keep time VERY short"] = "Сделать время задания очень коротким"
--[[Translation missing --]]
--[[ L[ [=[Launch the first filled mission with at least one locked follower.
Keep SHIFT pressed to actually launch, a simple click will only print mission name with its followers list]=] ] = ""--]] 
L["Left Click to see available missions"] = "Щелкните левой кнопкой мыши, чтобы увидеть доступные миссии"
L["Legendary Items"] = "Легендарный предмет"
L["Level"] = "Уровень"
L["Level 100 epic followers are not used for xp only missions."] = "Эпические соратники 100 уровня не используются только для миссий на опыт."
L["Lock all"] = "Заблокировать всех"
L["Lock this follower"] = "Заблокировать этого соратника"
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "Делает главную панель миссии подвижной"
L["Makes shipyard panel movable"] = "Делает панель флота подвижной"
L["Makes sure that no troops will be killed"] = "Убедиться, что отряды не погибнут"
L["Max champions"] = "Максимально соратников"
L["Maximize result"] = "Максимизировать результат"
L["Maximize xp gain"] = "Максимизировать получаемый опыт"
L["Maximum mission duration."] = "Максимальная продолжительность миссии."
L["Minimum chance"] = "Минимальные шансы"
L["Minimum mission duration."] = "Минимальная продолжительность миссии."
L["Minimum needed chance"] = "Минимальный шанс"
L["Minimum requested level for equipment rewards"] = "Минимальный запрашиваемый уровень вознаграждения за задание"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "Минимально требуемое обновление для экипировки соратника (улучшения всегда включены)"
L["Minimun chance success under which ignore missions"] = "Минимальные шансы на успех, при котором игнорируются миссии"
L["Minumum needed chance"] = "Минимум нужен шанс"
L["Mission Control"] = "Центр Управления"
L["Mission Duration"] = "Продолжительность миссии"
L["Mission duration reduced"] = "Длительность задания уменьшена"
L["Mission shown"] = "Миссия показана"
L["Mission shown for follower"] = "Миссия показана для соратника"
L["Mission Success"] = "Успех миссии"
L["Mission time reduced!"] = "Время миссии сокращено!"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "Миссия с меньшим шансом на успех будет проигнорирована"
L["Missionlist"] = "Список миссий"
L["Missions"] = "Задания"
L["Must reload interface to apply"] = "Нужно перезагрузить интерфейс для применения"
L["Never kill Troops"] = "Никогда не убивать отряды"
L["No confirmation"] = "Нет подтверждения "
L["No follower gained xp"] = "Ни один из соратников не получил опыт"
L["No mission prefill"] = "Никакой предвыборки миссии"
L["No suitable missions. Have you reserved at least one follower?"] = "Отсутствуют подходящие задания. Имеется ли хотя бы один соратник?"
L["Not blacklisted"] = "Не в чёрном список"
L["Not Selected"] = "Не выбрано"
L["Nothing to report"] = "Нечего докладывать"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "Количество соратников"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "Показаны только первые %1$d миссии с вероятностью успеха %2$d%%"
L["Only meaningful upgrades are shown"] = "Показаны только значимые обновления"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
L["Only ready"] = "Только готовые"
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "Оригинальная концепция и интерфейс на %s"
L["Original method"] = "Оригинальный метод"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "Оригинальная сортировка восстанавливает исходный метод сортировки, независимо от того, что было (если у вас есть другая команда сортировки аддона, она должна снова быть введена)"
L["Other"] = "Другие"
L["Other rewards"] = "Другие награды"
L["Other settings"] = "Другие настройки"
L["Other useful followers"] = "Другие полезные соратники"
L["Position is not saved on logout"] = "Позиция не сохраняется при выходе"
L["Prefer high durability"] = "Предпочесть большее количество жизненных сил отрядов"
L["Processing mission %d of %d"] = "Обработка миссии %d из %d"
L["Profession"] = "Профессия"
L["Quick start first mission"] = "Быстрое начало первого задания"
L["Racial Preference"] = "Расовое предпочтение"
L["Rare missions will not be considered"] = "Редкие миссии не будут рассматриваться"
L["Reagents"] = "Реагенты"
L["Remove no champions warning"] = "Убрать предупреждение об отсутствии соратников"
L["Reputation Items"] = "Предметы для Репутации"
L["Restart the tutorial"] = "Начать обучение заново"
L["Restart tutorial from beginning"] = "Начать обучение сначала"
L["Resume tutorial"] = "Продолжить обучение"
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "Тип вознаграждения"
L["Right-Click to blacklist"] = "Щелкните правой кнопкой мыши для добавления в черный список"
L["Right-Click to remove from blacklist"] = "Щелкните правой кнопкой мыши, чтобы удалить из черного списка"
L["Rush orders"] = "Срочный заказ"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "Внешний вид верфи"
L["Show Garrison Commander menu"] = "Показать меню Garrison Commander"
L["Show itemlevel"] = "Показать itemlevel"
L["Show upgrades"] = "Показать улучшения"
L["Show xp"] = "Показать опыт"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "Убийца"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "Некоторые соратники"
L["Sort missions by:"] = "Сортировка миссий по:"
L["Started with "] = "Начали с "
L["Submit all your mission at once. No question asked."] = "Отправить всех на миссии. Без вопросов."
L["Success Chance"] = "Шанс успеха"
L["Swap upgrades positions"] = true
L["Switch between Garrison Commander and Master Plan interface for missions"] = "Переключение между Garrison Commander и Master Plan для миссий"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "Счетчик угроз"
L["To go: %d"] = "Идти: %d"
L["Toggles Garrison Commander Menu Header on/off"] = "Включение/выключение заголовка меню Garrison Commander"
L["Toys and Mounts"] = "Игрушки и ездовые животные"
--[[Translation missing --]]
--[[ L["Troop ready alert"] = ""--]] 
L["Unable to fill missions, raise \"%s\""] = "Невозможно заполнить задания. Увеличьте \"%s\""
--[[Translation missing --]]
--[[ L["Unable to fill missions. Check your switches"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unable to start mission, aborting"] = ""--]] 
--[[Translation missing --]]
--[[ L["Uncapped"] = ""--]] 
L["Unchecking this will allow you to set specific success chance for each reward type"] = "Снимите флажок, чтобы установить определенный шанс на успех для каждого типа вознаграждения"
L["Unlock all"] = "Разблокировать всех"
L["Unlock Panel"] = "Разблокировать панель"
L["Unlock this follower"] = "Разблокировать этого соратника"
L["Unlocks all follower and slots at once"] = "Разблокировать всех соратников и все слоты"
L["Unsafe mission start"] = "небезопасное начало задания"
L["Upgrade %1$s to  %2$d itemlevel"] = "Улучшить %1$s к  %2$d itemlevel"
L["Upgrading to |cff00ff00%d|r"] = "Улучшить к |cff00ff00%d|r"
L["URL Copy"] = "Копировать адрес в интернете"
L["Use at most this many champions"] = "Использовать максимум это количество соратников"
L["Use big screen"] = "Используйте большой экран"
L["Use combat ally"] = "Использовать телохранителя"
L["Use GC Interface"] = "Использовать интерфейс GC"
L["Use this slot"] = "Использовать этот слот"
L["Uses armor token"] = "Используйте для улучшения брони "
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "Используйте для улучшения оружия"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "Когда установлен флажок, показать на каждой иконки соратника сколько опыта нужно на следующий уровень."
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "Когда установлен флажок, показать на каждой иконки соратника сколько предметов оружии и брони ему еще нужно"
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
L["Would start with "] = "Начать ли с "
L["XP"] = "Опыт"
L["Xp incremented!"] = "Опыт увеличивается!"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "Вы зря тратите |cffff0000%d|cffffd200 предметы(s)!!!"
L["You can also send mission one by one clicking on each button."] = "Вы также можете отправить миссию по одному нажатию на каждую кнопку."
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
L["You can open the menu clicking on the icon in top right corner"] = "Вы можете открыть меню, нажав на значок в верхнем правом углу"
L["You have ignored followers"] = "Вы проигнорировали соратников"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "Вы никогда не выполняли эту миссию"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "Вы выполнили эту миссию %d раз с коэффициентом выигрыша"

return
end
L=l:NewLocale(me,"zhCN")
if (L) then
--[[Translation missing --]]
--[[ L["%1$d%% lower than %2$d%%. Lower %s"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[%1$s and %2$s switches work together to customize how you want your mission filled

The value you set for %1$s (right now %3$s%%) is the minimum acceptable chance for attempting to achieve bonus while the value to set for %2$s (right now %4$s%%) is the chance you want achieve when you are forfaiting bonus (due to not enough powerful followers)]=] ] = ""--]] 
L["%s |4follower:followers; with %s"] = "%s |4随从：随从含有 %s"
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
L["(Ignores low bias ones)"] = "（忽略低匹配的）"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "增加 %1$d 等级到 %2$s"
L["Adds a list of other useful followers to tooltip"] = "鼠标提示中添加其他有用的随从列表"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "取消选中以隐藏每个追随者的任务列表，仅小窗口模式有效"
L["Allowed Rewards"] = "可用收益"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "允许资源任务使用较低的成功率。使用 /gac 打开界面调整几率，默认80%"
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
L["Applied when 'maximize result' is enabled. Default is 80%"] = "最大化结果选项启用时生效，默认80%"
L["Applies the best armor set"] = "使用最佳护甲组合"
L["Applies the best armor upgrade"] = "使用最佳护甲升级"
L["Applies the best weapon set"] = "使用最佳武器组合"
L["Applies the best weapon upgrade"] = "使用最佳武器升级"
L["Archaelogy"] = "考古学"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "大窗口"
L["Blacklisted"] = "已加入黑名单"
L["Blacklisted missions are ignored in Mission Control"] = "在任务面板已列入黑名单的任务将被忽略"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "构建最终报告"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "最多 %1$s，使用至少 %2$d"
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
L["Complete all missions without confirmation"] = "无需确认完成所有任务"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "确认"
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
L["Disable if you dont want the full Garrison Commander Header."] = "禁用完整的 Garrison Commander 标题"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "取消任务页自动分配。你也可以按住Ctrl键点击取消单个任务。"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "取消将重新载入1.1.8版本界面，取消或确认。需要重载界面。"
L["Do not show follower icon on plots"] = "不要在计划条上显示追随者图标"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "周期时间"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "强化鼠标提示"
L["Environment Preference"] = "环境设置"
L["Epic followers are NOT sent alone on xp only missions"] = "紫色追随者不会单独分配到只有经验的任务上"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "过期时间"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "随从"
L["Follower equipment set or upgrade"] = "随从装备设置或升级"
L["Follower experience"] = "随从经验"
L["Follower set minimum upgrade"] = "随从设置最小升级"
L["Follower Training"] = "随从训练"
L["Followers status "] = "追随者状态"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "兵营界面"
L["Garrison Comander Quick Mission Completion"] = "GC 快速任务完成"
L["Garrison Commander Mission Control"] = "GC 任务管理"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "全局大约经验奖励"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "全局成功率"
L["Gold incremented!"] = "金币增加！"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "隐藏追随者"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[如果选中，点击升级图标则使用物品升级追随者
|cFFFF0000无需确认|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "选中时，左侧显示护甲，右侧显示武器"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "如果选择继续，你可能会失去他们"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "如果你有打捞器，你可能不愿意选中这个"
L["Ignore \"maxed\""] = "忽略“满级的”"
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "经验任务忽略史诗随从"
L["Ignore for all missions"] = "忽略所有任务"
L["Ignore for this mission"] = "忽略这个任务"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "忽略稀有任务"
L["Increased Rewards"] = "已增加收益"
L["Item minimum level"] = "物品最低等级"
L["Item Tokens"] = "物品代币"
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
L["Left Click to see available missions"] = "点击显示可用任务"
L["Legendary Items"] = "传奇物品"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "100级的紫色追随者不会用于只有经验的任务"
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "使任务主窗体可以移动"
L["Makes shipyard panel movable"] = "使舰船面板可以移动"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "最大化收益"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "最大任务周期"
L["Minimum chance"] = "最小几率"
L["Minimum mission duration."] = "最小任务周期"
L["Minimum needed chance"] = "最小必须几率"
L["Minimum requested level for equipment rewards"] = "设备奖励所需最小等级"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "随从组合（已考虑组合强化）所需最小升级"
L["Minimun chance success under which ignore missions"] = "忽略任务的最低成功率"
L["Minumum needed chance"] = "最小所需几率"
L["Mission Control"] = "任务面板"
L["Mission Duration"] = "任务周期"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "任务展示"
L["Mission shown for follower"] = "任务显示追随者"
L["Mission Success"] = "任务成功"
L["Mission time reduced!"] = "任务时间减少！"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "低成功率任务将被忽略"
L["Missionlist"] = "任务列表"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "需要重载界面以生效"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "没有确认"
L["No follower gained xp"] = "没有随从获得经验"
L["No mission prefill"] = "没有预分配任务"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "没有被列入黑名单"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "没有可用报告"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "追随者数量"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "只有成功率高于 %2$d%% 的前 %1$d 个任务会显示"
L["Only meaningful upgrades are shown"] = "只有明显的升级会显示"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "原概念和界面从 %s"
L["Original method"] = "原方法"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "强制恢复原排序（如果你有另一个插件排序任务，它应该会再次启动）"
L["Other"] = "其他"
L["Other rewards"] = "其他收益"
L["Other settings"] = "其他设置"
L["Other useful followers"] = "其他有用的追随者"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "执行任务 %d / %d"
L["Profession"] = "专业匹配"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "种族匹配"
L["Rare missions will not be considered"] = "稀有任务将不被考虑"
L["Reagents"] = "试剂"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "声望物品"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "收益类型"
L["Right-Click to blacklist"] = "右击加入黑名单"
L["Right-Click to remove from blacklist"] = "右击从黑名单移除"
L["Rush orders"] = "刷订单"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "造船厂外观"
L["Show Garrison Commander menu"] = "显示 GC 菜单"
L["Show itemlevel"] = "显示物品等级"
L["Show upgrades"] = "显示升级"
L["Show xp"] = "显示经验"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "生物匹配"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "一些随从"
L["Sort missions by:"] = "排序依据："
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "提交所有任务。无需确认。"
L["Success Chance"] = "成功率"
L["Swap upgrades positions"] = "交换升级位置"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "为任务切换 Garrison Commander 和 Master Plan 界面"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "技能匹配"
L["To go: %d"] = "转到：%d"
L["Toggles Garrison Commander Menu Header on/off"] = "切换 GC 菜单标题开关"
L["Toys and Mounts"] = "玩具和坐骑"
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
L["Unchecking this will allow you to set specific success chance for each reward type"] = "取消这个选项，你可以自行设置各项收益的成功率"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "解锁面板"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "升级 %1$s 到 %2$d 物品等级"
L["Upgrading to |cff00ff00%d|r"] = "正在升级至 |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "使用大屏"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "使用GC界面"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "使用护甲代币"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "使用武器代币"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "选中后，在每个追随者按钮上显示升至下一级所需经验"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "选中后，在每个满级追随者按钮上显示武器和护甲等级"
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
L["Xp incremented!"] = "经验增加！"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "你浪费了 |cffff0000%d|cffffd200 点！"
L["You can also send mission one by one clicking on each button."] = "你也可以点击按钮逐个分配任务。"
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
L["You can open the menu clicking on the icon in top right corner"] = "你可以点击右上角的图标打开菜单"
L["You have ignored followers"] = "你有忽略的追随者"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "你从未执行这个任务"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "你执行这个任务 %d 次，成功率为"

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
L["%s |4follower:followers; with %s"] = "%s |4追隨者:追隨者; 有 %s"
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
L["(Ignores low bias ones)"] = "(忽略低等偏好的)"
--[[Translation missing --]]
--[[ L[ [=[A requested window is not open
Tutorial will resume as soon as possible]=] ] = ""--]] 
L["Add %1$d levels to %2$s"] = "增加 %1$d 等級到 %2$s"
L["Adds a list of other useful followers to tooltip"] = "在工具提示增加其他有用的追隨者清單"
L["Affects only little screen mode, hiding the per follower mission list if not checked"] = "只影響小螢幕模式，如果未勾選則隱藏每個追隨者的任務清單"
L["Allowed Rewards"] = "允許的獎勵"
L["Allows a lower success percentage for resource missions. Use /gac gui to change percentage. Default is 80%"] = "允許低成功率的資源任務。使用/gac gui來改變百分比。預設為80%"
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
L["Applied when 'maximize result' is enabled. Default is 80%"] = "只在'最大化結果'啟用時影響，預設為80%"
L["Applies the best armor set"] = "應用在最佳護甲上"
L["Applies the best armor upgrade"] = "應用在最佳護甲升級上"
L["Applies the best weapon set"] = "應用在最佳武器上"
L["Applies the best weapon upgrade"] = "應用在最佳武器升級上"
L["Archaelogy"] = "考古學"
--[[Translation missing --]]
--[[ L["Artifact shown value is the base value without considering knowledge multiplier"] = ""--]] 
--[[Translation missing --]]
--[[ L["Attempting %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["Base Chance"] = ""--]] 
--[[Translation missing --]]
--[[ L["Better parties available in next future"] = ""--]] 
L["Big screen"] = "大螢幕"
L["Blacklisted"] = "列入黑名單"
L["Blacklisted missions are ignored in Mission Control"] = "黑名單中的任務會在任務控制中忽略"
--[[Translation missing --]]
--[[ L["Bonus Chance"] = ""--]] 
L["Building Final report"] = "正在建立總結報告"
--[[Translation missing --]]
--[[ L["but using troops with just one durability left"] = ""--]] 
--[[Translation missing --]]
--[[ L["Capped"] = ""--]] 
L["Capped %1$s. Spend at least %2$d of them"] = "%1$s已經滿了，至少會浪費 %2$d 個。"
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
L["Complete all missions without confirmation"] = "完成所有任務不須確認"
--[[Translation missing --]]
--[[ L["Configuration for mission party builder"] = ""--]] 
L["Consider again"] = "再次考量"
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
L["Disable if you dont want the full Garrison Commander Header."] = "如果您不想要完整的Garrison Commander標題可以停用"
L["Disables automatic population of mission page screen. You can also press control while clicking to disable it for a single mission"] = "取消自動分派在任務頁篩選。您也可以在單一任務上點擊Ctrl來取消。"
--[[Translation missing --]]
--[[ L["Disables warning: "] = ""--]] 
L["Disabling this will give you the interface from 1.1.8, given or taken. Need to reload interface"] = "取消此會給您1.1.8以來的介面，給予或取得。需要重載UI。"
L["Do not show follower icon on plots"] = "不在策畫上顯示追隨者圖示"
--[[Translation missing --]]
--[[ L["Dont use this slot"] = ""--]] 
--[[Translation missing --]]
--[[ L["Don't use troops"] = ""--]] 
--[[Translation missing --]]
--[[ L["Duration reduced"] = ""--]] 
L["Duration Time"] = "持續時間"
--[[Translation missing --]]
--[[ L["Elite: Prefer overcap"] = ""--]] 
--[[Translation missing --]]
--[[ L["Elites mission mode"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty missions sorted as last"] = ""--]] 
--[[Translation missing --]]
--[[ L["Empty or 0% success mission are sorted as last. Does not apply to \"original\" method"] = ""--]] 
L["Enhance tooltip"] = "增強提示"
L["Environment Preference"] = "環境偏好"
L["Epic followers are NOT sent alone on xp only missions"] = "史詩追隨者\"不\"會單獨派發到只有經驗值的任務"
--[[Translation missing --]]
--[[ L[ [=[Equipment and upgrades are listed here as clickable buttons.
Due to an issue with Blizzard Taint system, drag and drop from bags raise an error.
if you drag and drop an item from a bag, you receive an error.
In order to assign equipments which are not listed (I update the list often but sometimes Blizzard is faster), you can right click the item in the bag and the left click the follower.
This way you dont receive any error]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L["Equipped by following champions:"] = ""--]] 
L["Expiration Time"] = "過期時間"
--[[Translation missing --]]
--[[ L["Favours leveling follower for xp missions"] = ""--]] 
L["Follower"] = "追隨者"
L["Follower equipment set or upgrade"] = "追隨者裝備套裝或升級"
L["Follower experience"] = "追隨者經驗"
L["Follower set minimum upgrade"] = "追隨者套裝最小的升級"
L["Follower Training"] = "追隨者訓練"
L["Followers status "] = "追隨者狀態"
--[[Translation missing --]]
--[[ L["For elite missions, tries hard to not go under 100% even at cost of overcapping"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[For example, let's say a mission can reach 95%%, 130%% and 180%% success chance.
If %1$s is set to 170%%, the 180%% one will be choosen.
If %1$s is set to 200%% OHC will try to find the nearest to 100%% respecting %2$s setting
If for example %2$s is set to 100%%, then the 130%% one will be choosen, but if %2$s is set to 90%% then the 95%% one will be choosen]=] ] = ""--]] 
L["Garrison Appearance"] = "要塞外觀"
L["Garrison Comander Quick Mission Completion"] = "Garrison Comander任務快速完成"
L["Garrison Commander Mission Control"] = "Garrison Commander任務控制"
--[[Translation missing --]]
--[[ L["General"] = ""--]] 
L["Global approx. xp reward"] = "通用大約的經驗值獎賞"
--[[Translation missing --]]
--[[ L["Global approx. xp reward per hour"] = ""--]] 
L["Global success chance"] = "全局成功機率"
L["Gold incremented!"] = "黃金增加！"
--[[Translation missing --]]
--[[ L["HallComander Quick Mission Completion"] = ""--]] 
L["Hide followers"] = "隱藏追隨者"
--[[Translation missing --]]
--[[ L["If %1$s is lower than this, then we try to achieve at least %2$s without going over 100%%. Ignored for elite missions."] = ""--]] 
L["If checked, clicking an upgrade icon will consume the item and upgrade the follower, |cFFFF0000NO QUESTION ASKED|r"] = [=[如果勾選，按一下升級圖示將使用該物品和升級追隨者
|cFFFF0000不須確認|r]=]
L["IF checked, shows armors on the left and weapons on the right "] = "如果勾選，顯示護甲在左武器在右"
--[[Translation missing --]]
--[[ L["If instead you just want to always see the best available mission just set %1$s to 100%% and %2$s to 0%%"] = ""--]] 
--[[Translation missing --]]
--[[ L["If not checked, inactive followers are used as last chance"] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[If you %s, you will lose them
Click on %s to abort]=] ] = ""--]] 
L["If you continue, you will lose them"] = "如果您繼續，您會失去它們"
--[[Translation missing --]]
--[[ L[ [=[If you dont understand why OHC choosed a setup for a mission, you can request a full analysis.
Analyze party will show all the possible combinations and how OHC evaluated them]=] ] = ""--]] 
L["IF you have a Salvage Yard you probably dont want to have this one checked"] = "如果您有回收廠可能不想要勾選此選項"
L["Ignore \"maxed\""] = "忽略\"滿級的\""
--[[Translation missing --]]
--[[ L["Ignore busy followers"] = ""--]] 
L["Ignore epic for xp missions."] = "忽略史詩經驗任務。"
L["Ignore for all missions"] = "忽略所有任務"
L["Ignore for this mission"] = "忽略此任務"
--[[Translation missing --]]
--[[ L["Ignore inactive followers"] = ""--]] 
L["Ignore rare missions"] = "忽略稀有任務"
L["Increased Rewards"] = "提高獎勵"
L["Item minimum level"] = "物品最小等級"
L["Item Tokens"] = "物品道具"
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
L["Left Click to see available missions"] = "左鍵點擊以檢視可用任務"
L["Legendary Items"] = "傳奇物品"
--[[Translation missing --]]
--[[ L["Level"] = ""--]] 
L["Level 100 epic followers are not used for xp only missions."] = "等級100的史詩追隨者不會用在只有經驗值的任務。"
--[[Translation missing --]]
--[[ L["Lock all"] = ""--]] 
--[[Translation missing --]]
--[[ L["Lock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Locked follower are only used in this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Make Order Hall Mission Panel movable"] = ""--]] 
L["Makes main mission panel movable"] = "讓主任務面板可移動"
L["Makes shipyard panel movable"] = "讓船塢面板可移動"
--[[Translation missing --]]
--[[ L["Makes sure that no troops will be killed"] = ""--]] 
--[[Translation missing --]]
--[[ L["Max champions"] = ""--]] 
L["Maximize result"] = "最大化結果"
--[[Translation missing --]]
--[[ L["Maximize xp gain"] = ""--]] 
L["Maximum mission duration."] = "最大任務持續時間。"
L["Minimum chance"] = "最小機率"
L["Minimum mission duration."] = "最小任務持續時間。"
L["Minimum needed chance"] = "最小需要的機率"
L["Minimum requested level for equipment rewards"] = "裝備獎勵最小需求等級"
L["Minimum requested upgrade for followers set (Enhancements are always included)"] = "追隨者套裝最小需求升級(增強物品會永遠包含在內)"
L["Minimun chance success under which ignore missions"] = "低於多少成功機率的任務要被忽略"
L["Minumum needed chance"] = "最小需求機率"
L["Mission Control"] = "任務控制"
L["Mission Duration"] = "任務持續時間"
--[[Translation missing --]]
--[[ L["Mission duration reduced"] = ""--]] 
L["Mission shown"] = "任務顯示"
L["Mission shown for follower"] = "任務上顯示追隨者"
L["Mission Success"] = "任務成功"
L["Mission time reduced!"] = "任務時間縮短！"
--[[Translation missing --]]
--[[ L["Mission was capped due to total chance less than"] = ""--]] 
L["Mission with lower success chance will be ignored"] = "低於此成功機率的任務將會忽略"
L["Missionlist"] = "任務列表"
--[[Translation missing --]]
--[[ L["Missions"] = ""--]] 
L["Must reload interface to apply"] = "需要重載UI以生效"
--[[Translation missing --]]
--[[ L["Never kill Troops"] = ""--]] 
L["No confirmation"] = "不確認"
L["No follower gained xp"] = "沒有追隨者獲得經驗值"
L["No mission prefill"] = "沒有預組的任務"
--[[Translation missing --]]
--[[ L["No suitable missions. Have you reserved at least one follower?"] = ""--]] 
L["Not blacklisted"] = "非黑名單"
--[[Translation missing --]]
--[[ L["Not Selected"] = ""--]] 
L["Nothing to report"] = "沒什麼好報告"
--[[Translation missing --]]
--[[ L["Notifies you when you have troops ready to be collected"] = ""--]] 
L["Number of followers"] = "追隨者數量"
--[[Translation missing --]]
--[[ L["Only accept missions with time improved"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only consider elite missions"] = ""--]] 
L["Only first %1$d missions with over %2$d%% chance of success are shown"] = "只有高於%2$d%%成功機率的前%1$d任務會顯示"
L["Only meaningful upgrades are shown"] = "只有明顯的升級才會顯示"
--[[Translation missing --]]
--[[ L["Only need %s instead of %s to start a mission from mission list"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only ready"] = ""--]] 
--[[Translation missing --]]
--[[ L["Only use champions even if troops are available"] = ""--]] 
L["Original concept and interface by %s"] = "原始概念與介面從%s"
L["Original method"] = "原始的方法"
L["Original sort restores original sorting method, whatever it was (If you have another addon sorting mission, it should kick in again)"] = "原始排序將恢復原始排序方法，不管它是什麼(如果你有另一個插件排序任務，它應該再啟動)"
L["Other"] = "其他"
L["Other rewards"] = "其他獎勵"
L["Other settings"] = "其他設定"
L["Other useful followers"] = "其他有用的追隨者"
--[[Translation missing --]]
--[[ L["Position is not saved on logout"] = ""--]] 
--[[Translation missing --]]
--[[ L["Prefer high durability"] = ""--]] 
L["Processing mission %d of %d"] = "處理中任務%d的%d"
L["Profession"] = "職業"
--[[Translation missing --]]
--[[ L["Quick start first mission"] = ""--]] 
L["Racial Preference"] = "種族偏好"
L["Rare missions will not be considered"] = "稀有任務不被考慮"
L["Reagents"] = "資源"
--[[Translation missing --]]
--[[ L["Remove no champions warning"] = ""--]] 
L["Reputation Items"] = "聲望物品"
--[[Translation missing --]]
--[[ L["Restart the tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Restart tutorial from beginning"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resume tutorial"] = ""--]] 
--[[Translation missing --]]
--[[ L["Resurrect troops effect"] = ""--]] 
L["Reward type"] = "獎勵類型"
L["Right-Click to blacklist"] = "右鍵點擊加入黑名單"
L["Right-Click to remove from blacklist"] = "右鍵點擊從黑名單移除"
L["Rush orders"] = "趕工訂單"
--[[Translation missing --]]
--[[ L["See all possible parties for this mission"] = ""--]] 
--[[Translation missing --]]
--[[ L["Sets all switches to a very permissive setup. Very similar to 1.4.4"] = ""--]] 
L["Shipyard Appearance"] = "船塢外觀"
L["Show Garrison Commander menu"] = "顯示Garrison Commander選單"
L["Show itemlevel"] = "顯示物品等級"
L["Show upgrades"] = "顯示升級"
L["Show xp"] = "顯示經驗值"
--[[Translation missing --]]
--[[ L["Show/hide OrderHallCommander mission menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Shows only parties with available followers"] = ""--]] 
L["Slayer"] = "殺手"
--[[Translation missing --]]
--[[ L[ [=[Slots (non the follower in it but just the slot) can be banned.
When you ban a slot, that slot will not be filled for that mission.
Exploiting the fact that troops are always in the leftmost slot(s) you can achieve a nice degree of custom tailoring, reducing the overall number of followers used for a mission]=] ] = ""--]] 
L["Some follower"] = "某些追隨者"
L["Sort missions by:"] = "排序任務依據："
--[[Translation missing --]]
--[[ L["Started with "] = ""--]] 
L["Submit all your mission at once. No question asked."] = "一次派遣您所有的任務。無須確認。"
L["Success Chance"] = "成功機率"
L["Swap upgrades positions"] = "交換升級位置"
L["Switch between Garrison Commander and Master Plan interface for missions"] = "在Garrison Commander與Master Plan的任務介面中切換"
--[[Translation missing --]]
--[[ L["Terminate the tutorial. You can resume it anytime clicking on the info icon in the side menu"] = ""--]] 
--[[Translation missing --]]
--[[ L["Thank you for reading this, enjoy %s"] = ""--]] 
--[[Translation missing --]]
--[[ L["There are %d tutorial step you didnt read"] = ""--]] 
L["Threat Counter"] = "威脅反制"
L["To go: %d"] = "還需要：%d"
L["Toggles Garrison Commander Menu Header on/off"] = "切換Garrison Commander選單標題 開/關"
L["Toys and Mounts"] = "玩具與坐騎"
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
L["Unchecking this will allow you to set specific success chance for each reward type"] = "取消勾選可以允許您為每種獎勵類型設定特定的成功機率"
--[[Translation missing --]]
--[[ L["Unlock all"] = ""--]] 
L["Unlock Panel"] = "解鎖面板"
--[[Translation missing --]]
--[[ L["Unlock this follower"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unlocks all follower and slots at once"] = ""--]] 
--[[Translation missing --]]
--[[ L["Unsafe mission start"] = ""--]] 
L["Upgrade %1$s to  %2$d itemlevel"] = "升級%1$s到%2$d物品等級"
L["Upgrading to |cff00ff00%d|r"] = "升級到 |cff00ff00%d|r"
--[[Translation missing --]]
--[[ L["URL Copy"] = ""--]] 
--[[Translation missing --]]
--[[ L["Use at most this many champions"] = ""--]] 
L["Use big screen"] = "使用大螢幕"
--[[Translation missing --]]
--[[ L["Use combat ally"] = ""--]] 
L["Use GC Interface"] = "使用GC介面"
--[[Translation missing --]]
--[[ L["Use this slot"] = ""--]] 
L["Uses armor token"] = "使用護甲道具"
--[[Translation missing --]]
--[[ L["Uses troops with the highest durability instead of the ones with the lowest"] = ""--]] 
L["Uses weapon token"] = "使用武器道具"
--[[Translation missing --]]
--[[ L[ [=[Usually OrderHallCOmmander tries to use troops with the lowest durability in order to let you enque new troops request as soon as possible.
Checking %1$s reverse it and OrderHallCOmmander will choose for each mission troops with the highest possible durability]=] ] = ""--]] 
--[[Translation missing --]]
--[[ L[ [=[Welcome to a new release of OrderHallCommander
Please follow this short tutorial to discover all new functionalities.
You will not regret it]=] ] = ""--]] 
L["When checked, show on each follower button missing xp to next level"] = "當勾選後，顯示每個追隨者到下一等級所需的經驗值"
L["When checked, show on each follower button weapon and armor level for maxed followers"] = "當勾選後，顯示每個滿級追隨者武器與護甲等級的按鈕"
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
L["Xp incremented!"] = "經驗值增加！"
L["You are wasting |cffff0000%d|cffffd200 point(s)!!!"] = "您浪費了|cffff0000%d|cffffd200 點數!!!"
L["You can also send mission one by one clicking on each button."] = "您也可以透過點擊每個按鈕一個一個派遣。"
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
L["You can open the menu clicking on the icon in top right corner"] = "您可以點擊右上角的圖示以開啟選單"
L["You have ignored followers"] = "您有忽略的追隨者"
--[[Translation missing --]]
--[[ L[ [=[You need to close and restart World of Warcraft in order to update this version of OrderHallCommander.
Simply reloading UI is not enough]=] ] = ""--]] 
L["You never performed this mission"] = "您未曾執行這個任務"
--[[Translation missing --]]
--[[ L["You now need to press both %s and %s to start mission"] = ""--]] 
L["You performed this mission %d times with a win ratio of"] = "您執行過此任務 %d次並且成功機率有"

return
end
