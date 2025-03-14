local addon, Engine = ...
local SI = LibStub("AceAddon-3.0"):NewAddon(addon, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

Engine[1] = SI
Engine[2] = {}

_G.SavedInstances = Engine

SI.Libs = {}
SI.Libs.QTip = LibStub("LibQTip-1.0")
SI.Libs.LDB = LibStub("LibDataBroker-1.1", true)
SI.Libs.LDBI = SI.Libs.LDB and LibStub("LibDBIcon-1.0", true)

SI.ScanTooltip = CreateFrame("GameTooltip", "SavedInstancesScanTooltip", UIParent, "GameTooltipTemplate")
SI.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")

SI.playerName = UnitName("player")
SI.playerLevel = UnitLevel("player")
SI.realmName = GetRealmName()
SI.thisToon = SI.playerName .. " - " .. SI.realmName
SI.maxLevel = GetMaxLevelForPlayerExpansion()
SI.locale = GetLocale()

SI.questCheckMark = "\124A:UI-LFG-ReadyMark:14:14\124a"
SI.questTurnin = "\124A:QuestTurnin:14:14\124a"
SI.questNormal = "\124A:QuestNormal:14:14\124a"
