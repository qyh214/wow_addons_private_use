local L = LibStub("AceLocale-3.0"):NewLocale("Details_DeathGraphs", "deDE") 
if not L then return end 

--[[Translation missing --]]
L["STRING_BRESS"] = "Battle Ress"
--[[Translation missing --]]
L["STRING_DEATH_DESC"] = "Show panel containing player deaths."
--[[Translation missing --]]
L["STRING_DEATHS"] = "Deaths"
--[[Translation missing --]]
L["STRING_ENCOUNTER_MAXSEGMENTS"] = "Current Encounter Max Segments"
--[[Translation missing --]]
L["STRING_ENCOUNTER_MAXSEGMENTS_DESC"] = "Maximum amount of segments to store on the 'Current Encounter' display."
--[[Translation missing --]]
L["STRING_ENDURANCE"] = "Endurance"
--[[Translation missing --]]
L["STRING_ENDURANCE_DEATHS_THRESHOLD"] = "Endurance Deaths Threshold"
--[[Translation missing --]]
L["STRING_ENDURANCE_DEATHS_THRESHOLD_DESC"] = "The first |cFFFFFF00X|r players to die loses endurance percentage."
--[[Translation missing --]]
L["STRING_ENDURANCE_DESC"] = [=[Endurance is conceptual score where the goal is to tell who is surviving more during raid encounters.

The percentage of endurance is calculated taking into account only the first deaths (configurable under '|cFFFFDD00Config Death Limits|r').]=]
--[[Translation missing --]]
L["STRING_FLAWLESS"] = "|cFF44FF44Flawless Player!|r"
--[[Translation missing --]]
L["STRING_HEROIC"] = "Heroic"
--[[Translation missing --]]
L["STRING_HEROIC_DESC"] = "Record deaths when you are playing on heroic difficulty."
--[[Translation missing --]]
L["STRING_LATEST"] = "Latest"
--[[Translation missing --]]
L["STRING_MYTHIC"] = "Mythic"
--[[Translation missing --]]
L["STRING_MYTHIC_DESC"] = "Record deaths when you are playing on mythic difficulty."
--[[Translation missing --]]
L["STRING_NORMAL"] = "Normal"
--[[Translation missing --]]
L["STRING_NORMAL_DESC"] = "Record deaths when you are playing on normal difficulty."
--[[Translation missing --]]
L["STRING_OPTIONS"] = "Options"
--[[Translation missing --]]
L["STRING_OVERALL_DEATHS_THRESHOLD"] = "Overall Deaths Threshold"
--[[Translation missing --]]
L["STRING_OVERALL_DEATHS_THRESHOLD_DESC"] = "The first |cFFFFFF00X|r players to die has their deaths registered into overall deaths."
--[[Translation missing --]]
L["STRING_OVERTIME"] = "Over Time"
--[[Translation missing --]]
L["STRING_PLUGIN_DESC"] = [=[During boss encounters, capture raid members deaths and build statistics from it.

- |cFFFFFFFFCurrent Encounter|r: |cFFFF9900show deaths for the latest segments.

- |cFFFFFFFFTimeline|r: |cFFFF9900show a graph telling when debuffs and spells from the boss are casted on raid members and draw lines representing where deaths are happening.

- |cFFFFFFFFEndurance|r: |cFFFF9900show a list of players with a percentage indicating how much tries they were alive in the encounter.

- |cFFFFFFFFOverall|r: |cFFFF9900Mantain a list of players with their death and also the damage taken by spell before the death.]=]
--[[Translation missing --]]
L["STRING_PLUGIN_NAME"] = "Advanced Death Logs"
--[[Translation missing --]]
L["STRING_PLUGIN_WELCOME"] = [=[Welcome to Advanced Death Logs!


-|cFFFFFF00Current Encounter|r: show deaths from the last boss encouter, by default it stores deaths for the last two segments, you may increase this at the options panel.

- |cFFFFFF00Timeline|r: Show where your raid is dying most at time, also shows the time for enemy abilities.

- |cFFFFFF00Endurance|r: Measure player skill from who is dying first in a encounter, by default the first 5 players to die loses Endurance Percentage.

- |cFFFFFF00Overall|r: show common death logs plus the overall damage taken before the player's death.


- You can always close the window by clicking with the right mouse button!]=]
--[[Translation missing --]]
L["STRING_RAIDFINDER"] = "Raid Finder"
--[[Translation missing --]]
L["STRING_RAIDFINDER_DESC"] = "Record deaths when you are playing on raid finder."
--[[Translation missing --]]
L["STRING_RESET"] = "Reset Data"
--[[Translation missing --]]
L["STRING_SURVIVAL"] = "Survival"
--[[Translation missing --]]
L["STRING_TIMELINE_DEATHS_THRESHOLD"] = "Timeline Deaths Threshold"
--[[Translation missing --]]
L["STRING_TIMELINE_DEATHS_THRESHOLD_DESC"] = "The first |cFFFFFF00X|r deaths in the encounter are registered to show on the timeline graphic."
--[[Translation missing --]]
L["STRING_TOOLTIP"] = "Show death graphics"
