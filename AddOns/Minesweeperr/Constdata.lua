local _, _MS = ...
local L = LibStub ("AceLocale-3.0"):GetLocale("Minesweeperr", true)


_MS.VERSION = 101

_MS.CONSTDATA = {}
local _CD = _MS.CONSTDATA



Minesweeperr = LibStub("AceAddon-3.0"):NewAddon("Minesweeperr", "AceConsole-3.0")
_MS.addon = Minesweeperr

_CD.autoshowQC = true

_CD.playerGUID = nil
_CD.partyMembers = {}
_CD.partyMembersTempl = {"player", "party1", "party2", "party3", "party4"}

_CD.historyMembers = nil

_CD.curRequestGUID = nil
_CD.curRequestUID = nil

_CD.linkCache = {}
_CD.curPartyNum = 1

_CD.mainAchiID = 14145
_CD.childAchi1ID = 13781
_CD.childAchi2ID = 13449
_CD.childAchi3ID = 13080

_CD.unitInfoTempl = {
    ["classIndex"] = 13,
    ["name"] = L["watingRefresh"],
    ["server"] = L["watingRefresh"]
}

_CD.classIdx = {
   [1] = "WARRIOR",
   [2] = "PALADIN",
   [3] = "HUNTER",
   [4] = "ROGUE",
   [5] = "PRIEST",
   [6] = "DEATHKNIGHT",
   [7] = "SHAMAN",
   [8] = "MAGE",
   [9] = "WARLOCK",
   [10] = "MONK",
   [11] = "DRUID",
   [12] = "DEMONHUNTER",
   [13] = "none"
}

_CD.dungeonIds = { 12749, 12752, 12763, 12768, 12773, 12776, 12779, 12745, 12782, 12785 }

_CD.dungeonNames = {
    L["D_AD"],
    L["D_FH"],
    L["D_KR"],
    L["D_SOTS"],
    L["D_SOB"],
    L["D_TOSL"],
    L["D_TML"],
    L["D_TUR"],
    L["D_TD"],
    L["D_WM"],
}

_CD.dungeonChallengeMapNames = {
    [244] = L["D_AD"],
    [245] = L["D_FH"],
    [246] = L["D_TD"],
    [247] = L["D_TML"],
    [248] = L["D_WM"],
    [249] = L["D_KR"],
    [250] = L["D_TOSL"],
    [251] = L["D_TUR"],
    [252] = L["D_SOTS"],
    [353] = L["D_SOB"],
    [370] = L["D_OPMW"],
    [369] = L["D_OPMJ"],
}


_CD.corruptionData = {
    ["6483"] = {spellID = 315607, name="Avoidant", level = "I", value = 8},
    ["6484"] = {spellID = 315608, name="Avoidant", level = "II", value = 12},
    ["6485"] = {spellID = 315609, name="Avoidant", level = "III", value = 16},
    ["6474"] = {spellID = 315544, name="Expedient", level = "I", value = 10},
    ["6475"] = {spellID = 315545, name="Expedient", level = "II", value = 15},
    ["6476"] = {spellID = 315546, name="Expedient", level = "III", value = 20},
    ["6471"] = {spellID = 315529, name="Masterful", level = "I", value = 10},
    ["6472"] = {spellID = 315530, name="Masterful", level = "II", value = 15},
    ["6473"] = {spellID = 315531, name="Masterful", level = "III", value = 20},
    ["6480"] = {spellID = 315554, name="Severe", level = "I", value = 10},
    ["6481"] = {spellID = 315557, name="Severe", level = "II", value = 15},
    ["6482"] = {spellID = 315558, name="Severe", level = "III", value = 20},
    ["6477"] = {spellID = 315549, name="Versatile", level = "I", value = 10},
    ["6478"] = {spellID = 315552, name="Versatile", level = "II", value = 15},
    ["6479"] = {spellID = 315553, name="Versatile", level = "III", value = 20},
    ["6493"] = {spellID = 315590, name="Siphoner", level = "I", value = 17},
    ["6494"] = {spellID = 315591, name="Siphoner", level = "II", value = 28},
    ["6495"] = {spellID = 315592, name="Siphoner", level = "III", value = 45},
    ["6437"] = {spellID = 315277, name="Strikethrough", level = "I", value = 10},
    ["6438"] = {spellID = 315281, name="Strikethrough", level = "II", value = 15},
    ["6439"] = {spellID = 315282, name="Strikethrough", level = "III", value = 20},
    ["6555"] = {spellID = 318266, name="Racing Pulse", level = "I", value = 15},
    ["6559"] = {spellID = 318492, name="Racing Pulse", level = "II", value = 20},
    ["6560"] = {spellID = 318496, name="Racing Pulse", level = "III", value = 35},
    ["6556"] = {spellID = 318268, name="Deadly Momentum", level = "I", value = 15},
    ["6561"] = {spellID = 318493, name="Deadly Momentum", level = "II", value = 20},
    ["6562"] = {spellID = 318497, name="Deadly Momentum", level = "III", value = 35},
    ["6558"] = {spellID = 318270, name="Surging Vitality", level = "I", value = 15},
    ["6565"] = {spellID = 318495, name="Surging Vitality", level = "II", value = 20},
    ["6566"] = {spellID = 318499, name="Surging Vitality", level = "III", value = 35},
    ["6557"] = {spellID = 318269, name="Honed Mind", level = "I", value = 15},
    ["6563"] = {spellID = 318494, name="Honed Mind", level = "II", value = 20},
    ["6564"] = {spellID = 318498, name="Honed Mind", level = "III", value = 35},
    ["6549"] = {spellID = 318280, name="Echoing Void", level = "I", value = 25},
    ["6550"] = {spellID = 318485, name="Echoing Void", level = "II", value = 35},
    ["6551"] = {spellID = 318486, name="Echoing Void", level = "III", value = 60},
    ["6552"] = {spellID = 318274, name="Infinite Stars", level = "I", value = 20},
    ["6553"] = {spellID = 318487, name="Infinite Stars", level = "II", value = 50},
    ["6554"] = {spellID = 318488, name="Infinite Stars", level = "III", value = 75},
    ["6547"] = {spellID = 318303, name="Ineffable Truth", level = "I", value = 12},
    ["6548"] = {spellID = 318484, name="Ineffable Truth", level = "II", value = 30},
    ["6537"] = {spellID = 318276, name="Twilight Devastation", level = "I", value = 25},
    ["6538"] = {spellID = 318477, name="Twilight Devastation", level = "II", value = 50},
    ["6539"] = {spellID = 318478, name="Twilight Devastation", level = "III", value = 75},
    ["6543"] = {spellID = 318481, name="Twisted Appendage", level = "I", value = 10},
    ["6544"] = {spellID = 318482, name="Twisted Appendage", level = "II", value = 35},
    ["6545"] = {spellID = 318483, name="Twisted Appendage", level = "III", value = 66},
    ["6540"] = {spellID = 318286, name="Void Ritual", level = "I", value = 15},
    ["6541"] = {spellID = 318479, name="Void Ritual", level = "II", value = 35},
    ["6542"] = {spellID = 318480, name="Void Ritual", level = "III", value = 66},
    ["6573"] = {spellID = 318272, name="Gushing Wound", level = "", value = 15},
    ["6546"] = {spellID = 318239, name="Glimpse of Clarity", level = "", value = 15},
    ["6571"] = {spellID = 318293, name="Searing Flames", level = "", value = 30},
    ["6572"] = {spellID = 316651, name="Obsidian Skin", level = "", value = 50},
    ["6567"] = {spellID = 318294, name="Devour Vitality", level = "", value = 35},
    ["6568"] = {spellID = 316780, name="Whispered Truths", level = "", value = 25},
    ["6570"] = {spellID = 318299, name="Flash of Insight", level = "", value = 20},
    ["6569"] = {spellID = 317290, name="Lash of the Void", level = "", value = 25},
}

_CD.essenceTextureIDs = {
    [2967101] = true,
    [3193842] = true,
    [3193843] = true,
    [3193844] = true,
    [3193845] = true,
    [3193846] = true,
    [3193847] = true,
}

_CD.cloakResString = "(%d+)%s?"..ITEM_MOD_CORRUPTION_RESISTANCE

_CD.gemSlots = {
    EMPTY_SOCKET = true,
    EMPTY_SOCKET_BLUE = true,
    EMPTY_SOCKET_COGWHEEL = true,
    EMPTY_SOCKET_HYDRAULIC = true,
    EMPTY_SOCKET_META = true,
    EMPTY_SOCKET_NO_COLOR = true,
    EMPTY_SOCKET_PRISMATIC = true,
    EMPTY_SOCKET_RED = true,
    EMPTY_SOCKET_YELLOW = true,
    EMPTY_SOCKET_PUNCHCARDYELLOW = false,
    EMPTY_SOCKET_PUNCHCARDRED = false,
    EMPTY_SOCKET_PUNCHCARDBLUE = false,
}