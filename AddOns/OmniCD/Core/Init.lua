local AddOnName, NS = ...

local AddOn = CreateFrame("Frame")
AddOn.L = LibStub("AceLocale-3.0"):GetLocale(AddOnName)
AddOn.defaults = { global = {}, profile = { modules = { ["Party"] = true } } }

NS[1] = AddOn
NS[2] = AddOn.L
NS[3] = AddOn.defaults.profile
NS[4] = AddOn.defaults.global

function NS:unpack()
	return self[1], self[2], self[3], self[4]
end

NS[1].Libs = {}
NS[1].Libs.ACD = LibStub("AceConfigDialog-3.0-OmniCD")
NS[1].Libs.ACR = LibStub("AceConfigRegistry-3.0")
NS[1].Libs.CBH = LibStub("CallbackHandler-1.0"):New(NS[1])
NS[1].Libs.LSM = LibStub("LibSharedMedia-3.0")
NS[1].Libs.OmniCDC = LibStub("OmniCDC")

NS[1].Party = CreateFrame("Frame")
NS[1].Comm = CreateFrame("Frame")
NS[1].Cooldowns = CreateFrame("Frame")

NS[1].AddOn = AddOnName
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
NS[1].Version = GetAddOnMetadata(AddOnName, "Version")
NS[1].Author = GetAddOnMetadata(AddOnName, "Author")
NS[1].Notes = GetAddOnMetadata(AddOnName, "Notes")
NS[1].License = GetAddOnMetadata(AddOnName, "X-License")
NS[1].Localizations = GetAddOnMetadata(AddOnName, "X-Localizations")
NS[1].userGUID = UnitGUID("player")
NS[1].userName = UnitName("player")
NS[1].userRealm = GetRealmName()
NS[1].userNameWithRealm = format("%s-%s", NS[1].userName, NS[1].userRealm)
NS[1].userClass = select(2, UnitClass("player"))
NS[1].userRaceID = select(3, UnitRace("player"))
NS[1].userLevel = UnitLevel("player")
NS[1].userFaction = UnitFactionGroup("player")
NS[1].userClassHexColor = "|c" .. select(4, GetClassColor(NS[1].userClass))
NS[1].WoWPatch, NS[1].WoWBuild, NS[1].WoWPatchReleaseDate, NS[1].TocVersion = GetBuildInfo()
NS[1].LoginMessage = format("%sOmniCD v%s|r - /oc", NS[1].userClassHexColor, NS[1].Version)

NS[1].isDF = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
NS[1].isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
NS[1].isBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
NS[1].isWOTLKC = WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
NS[1].isWOTLKC341 = NS[1].isWOTLKC and NS[1].TocVersion >= 30401
NS[1].isClassic1144 = NS[1].isClassic and NS[1].TocVersion >= 11404
NS[1].isCata = WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
NS[1].preWOTLKC = LE_EXPANSION_LEVEL_CURRENT < 2
NS[1].preCata = LE_EXPANSION_LEVEL_CURRENT < 3
NS[1].preMoP = LE_EXPANSION_LEVEL_CURRENT < 4
NS[1].postBFA = LE_EXPANSION_LEVEL_CURRENT > 7

OmniCD = NS
