local L = LibStub("AceLocale-3.0"):NewLocale("WorldQuestTrackerAddon", "itIT") 
if not L then return end 

-- L["S_APOWER_AVAILABLE"] = ""
-- L["S_APOWER_DOWNVALUE"] = ""
-- L["S_APOWER_NEXTLEVEL"] = ""
-- L["S_ENABLED"] = ""
-- L["S_ERROR_NOTIMELEFT"] = ""
-- L["S_ERROR_NOTLOADEDYET"] = ""
-- L["S_FLYMAP_SHOWTRACKEDONLY"] = ""
-- L["S_FLYMAP_SHOWTRACKEDONLY_DESC"] = ""
-- L["S_FLYMAP_SHOWWORLDQUESTS"] = ""
-- L["S_MAPBAR_AUTOWORLDMAP"] = ""
-- L["S_MAPBAR_AUTOWORLDMAP_DESC"] = ""
-- L["S_MAPBAR_FILTER"] = ""
-- L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES"] = ""
-- L["S_MAPBAR_FILTERMENU_FACTIONOBJECTIVES_DESC"] = ""
-- L["S_MAPBAR_OPTIONS"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ARROWSPEED"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_HIGH"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_MEDIUM"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_REALTIME"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ARROWSPEED_SLOW"] = ""
-- L["S_MAPBAR_OPTIONSMENU_EQUIPMENTICONS"] = ""
-- L["S_MAPBAR_OPTIONSMENU_QUESTTRACKER"] = ""
-- L["S_MAPBAR_OPTIONSMENU_REFRESH"] = ""
-- L["S_MAPBAR_OPTIONSMENU_SHARE"] = ""
-- L["S_MAPBAR_OPTIONSMENU_SOUNDENABLED"] = ""
-- L["S_MAPBAR_OPTIONSMENU_STATUSBARANCHOR"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TOMTOM_WPPERSISTENT"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TRACKERCONFIG"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TRACKER_CURRENTZONE"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_AUTO"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_CUSTOM"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TRACKERMOVABLE_LOCKED"] = ""
-- L["S_MAPBAR_OPTIONSMENU_TRACKER_SCALE"] = ""
-- L["S_MAPBAR_OPTIONSMENU_UNTRACKQUESTS"] = ""
-- L["S_MAPBAR_OPTIONSMENU_WORLDMAPCONFIG"] = ""
-- L["S_MAPBAR_OPTIONSMENU_YARDSDISTANCE"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ZONEMAPCONFIG"] = ""
-- L["S_MAPBAR_OPTIONSMENU_ZONE_QUESTSUMMARY"] = ""
-- L["S_MAPBAR_RESOURCES_TOOLTIP_TRACKALL"] = ""
-- L["S_MAPBAR_SORTORDER"] = ""
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_FADE"] = ""
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_OPTION"] = ""
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SHOWTEXT"] = ""
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_SORTBYTIME"] = ""
-- L["S_MAPBAR_SORTORDER_TIMELEFTPRIORITY_TITLE"] = ""
-- L["S_MAPBAR_SUMMARY"] = ""
-- L["S_MAPBAR_SUMMARYMENU_ACCOUNTWIDE"] = ""
-- L["S_MAPBAR_SUMMARYMENU_MOREINFO"] = ""
-- L["S_MAPBAR_SUMMARYMENU_NOATTENTION"] = ""
-- L["S_MAPBAR_SUMMARYMENU_REQUIREATTENTION"] = ""
-- L["S_MAPBAR_SUMMARYMENU_TODAYREWARDS"] = ""
-- L["S_OVERALL"] = ""
-- L["S_PARTY"] = ""
-- L["S_PARTY_DESC1"] = ""
-- L["S_PARTY_DESC2"] = ""
-- L["S_PARTY_PLAYERSWITH"] = ""
-- L["S_PARTY_PLAYERSWITHOUT"] = ""
-- L["S_QUESTSCOMPLETED"] = ""
-- L["S_QUESTTYPE_ARTIFACTPOWER"] = ""
-- L["S_QUESTTYPE_DUNGEON"] = ""
-- L["S_QUESTTYPE_EQUIPMENT"] = ""
-- L["S_QUESTTYPE_GOLD"] = ""
-- L["S_QUESTTYPE_PETBATTLE"] = ""
-- L["S_QUESTTYPE_PROFESSION"] = ""
-- L["S_QUESTTYPE_PVP"] = ""
-- L["S_QUESTTYPE_RESOURCE"] = ""
-- L["S_QUESTTYPE_TRADESKILL"] = ""
-- L["S_SHAREPANEL_THANKS"] = ""
-- L["S_SHAREPANEL_TITLE"] = ""
-- L["S_SUMMARYPANEL_EXPIRED"] = ""
-- L["S_SUMMARYPANEL_LAST15DAYS"] = ""
-- L["S_SUMMARYPANEL_LIFETIMESTATISTICS_ACCOUNT"] = ""
-- L["S_SUMMARYPANEL_LIFETIMESTATISTICS_CHARACTER"] = ""
-- L["S_SUMMARYPANEL_OTHERCHARACTERS"] = ""
-- L["S_TUTORIAL_AMOUNT"] = ""
-- L["S_TUTORIAL_CLICKTOTRACK"] = ""
-- L["S_TUTORIAL_CLOSE"] = ""
-- L["S_TUTORIAL_FACTIONBOUNTY"] = ""
-- L["S_TUTORIAL_FACTIONBOUNTY_AMOUNTQUESTS"] = ""
-- L["S_TUTORIAL_HOWTOADDTRACKER"] = ""
-- L["S_TUTORIAL_PARTY"] = ""
-- L["S_TUTORIAL_RARITY"] = ""
-- L["S_TUTORIAL_REWARD"] = ""
-- L["S_TUTORIAL_TIMELEFT"] = ""
-- L["S_TUTORIAL_WORLDMAPBUTTON"] = ""
-- L["S_UNKNOWNQUEST"] = ""
-- L["S_WORLDQUESTS"] = ""