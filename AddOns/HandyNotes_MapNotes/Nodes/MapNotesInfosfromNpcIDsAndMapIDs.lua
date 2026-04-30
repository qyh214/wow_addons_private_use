local ADDON_NAME, ns = ...

local function MN_GetSavedNpcInfo(id)
    local db = HandyNotes_MapNotesRetailNpcCacheDB
    local locale = GetLocale() or "enUS"
    local bucket = db and db.names and db.names[locale]
    if not bucket then return nil, nil end

    local packed = bucket[id] or bucket[tostring(id)]
    if type(packed) ~= "string" then return nil, nil end

    local name, title = packed:match("^(.-)\031(.*)$")
    if type(name) == "string" and name ~= "" then
        if title == "" then title = nil end
        return name, title
    end

    return nil, nil
end

local function MN_GetMapNotesInfoCache(category)
    HandyNotes_MapNotesRetailNpcCacheDB = HandyNotes_MapNotesRetailNpcCacheDB or {}
    HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo = HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo or {}

    local locale = GetLocale() or "enUS"
    HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo[locale] = HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo[locale] or {}
    HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo[locale][category] = HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo[locale][category] or {}

    return HandyNotes_MapNotesRetailNpcCacheDB.mapNotesInfo[locale][category]
end

local function MN_IsSafeText(value)
    if type(value) ~= "string" then return false end

    local ok, isNotEmpty = pcall(function()
        return value ~= ""
    end)

    return ok and isNotEmpty
end

local function MN_CacheMapNotesInfo(category, id, value)
    local cache = MN_GetMapNotesInfoCache(category)

    if MN_IsSafeText(cache[id]) then
        return cache[id]
    end

    if MN_IsSafeText(value) then
        cache[id] = value
        return value
    end

    return ""
end

local MN_MapNotesInfoResolvers = {}
local MN_MapNotesInfoRetryTicker
local MN_MapNotesInfoRetryCount = 0

local function MN_StartMapNotesInfoRetry()
    if MN_MapNotesInfoRetryTicker then return end

    MN_MapNotesInfoRetryTicker = C_Timer.NewTicker(1, function()
        MN_MapNotesInfoRetryCount = MN_MapNotesInfoRetryCount + 1
        local missing = 0

        for category, data in pairs(MN_MapNotesInfoResolvers) do
            for id, entry in pairs(data) do
                local value = MN_CacheMapNotesInfo(category, id, entry.resolver())

                if entry.key then
                    ns[entry.key] = value
                end

                if not MN_IsSafeText(value) then
                    missing = missing + 1
                end
            end
        end

        if missing == 0 or MN_MapNotesInfoRetryCount >= 30 then
            MN_MapNotesInfoRetryTicker:Cancel()
            MN_MapNotesInfoRetryTicker = nil
            MN_MapNotesInfoRetryCount = 0
        end
    end)
end

local function MN_RegisterMapNotesInfo(category, id, nsKey, resolver)
    MN_MapNotesInfoResolvers[category] = MN_MapNotesInfoResolvers[category] or {}
    MN_MapNotesInfoResolvers[category][id] = {
        key = nsKey,
        resolver = resolver,
    }

    local value = MN_CacheMapNotesInfo(category, id, resolver())

    if nsKey then
        ns[nsKey] = value
    end

    if not MN_IsSafeText(value) then
        MN_StartMapNotesInfoRetry()
    end

    return value
end

function ns.RebuildMapNotesInfoCache()
    local changed = false

    for category, data in pairs(MN_MapNotesInfoResolvers) do
        for id, entry in pairs(data) do
            local value = MN_CacheMapNotesInfo(category, id, entry.resolver())

            if entry.key and ns[entry.key] ~= value then
                ns[entry.key] = value
                changed = true
            end

            if not MN_IsSafeText(value) then
                MN_StartMapNotesInfoRetry()
            end
        end
    end

    if changed then
        C_Timer.After(0.1, function()
            if ns.Addon and ns.Addon.LoadOptions then
                ns.Addon:LoadOptions()
            end

            if LibStub then
                local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
                if AceConfigRegistry then
                    AceConfigRegistry:NotifyChange("HandyNotes_MapNotes")
                end
            end
        end)
    end
end

------------------------------------ mapID Names
local function mapName(key, id)
    return MN_RegisterMapNotesInfo("map", id, key, function()
        local info = C_Map.GetMapInfo(id)
        local name = info and info.name

        if not MN_IsSafeText(name) and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
            print("|cffff0000[MapNotes]|r missing mapName(ID) for " .. tostring(id))
        end

        return name
    end)
end

------------------------------------ Kalimdor Zones
ns.Durotar = mapName("Durotar", 1)
ns.Barrens = mapName("Barrens", 10)
ns.WailingCaverns = mapName("WailingCaverns", 11)
ns.Teldrassil = mapName("Teldrassil", 57)
ns.Darkshore = mapName("Darkshore", 62)
ns.DustwallowMarsh = mapName("DustwallowMarsh", 70)
ns.CavernsOfTime = mapName("CavernsOfTime", 75)
ns.UnGoroCrater = mapName("UnGoroCrater", 78)
ns.Silithus = mapName("Silithus", 81)
ns.Orgrimmar = mapName("Orgrimmar", 85)
ns.Darnassus = mapName("Darnassus", 89)
ns.ThunderBluff = mapName("ThunderBluff", 88)
ns.AzuremystIsle = mapName("AzuremystIsle", 97)
ns.Exodar = mapName("Exodar", 103)
ns.Hyjal = mapName("Hyjal", 198)
ns.Uldum = mapName("Uldum", 249)
ns.EchoIsles = mapName("EchoIsles", 463)
------------------------------------ Eastern Kingdom Zones
ns.ArathiHighlands = mapName("ArathiHighlands", 14)
ns.Badlands = mapName("Badlands", 15)
ns.BlastedLands = mapName("BlastedLands", 17)
ns.TirisfalGlades = mapName("TirisfalGlades", 18)
ns.EasternPlagueland = mapName("EasternPlagueland", 23)
ns.NewTinkertown = mapName("NewTinkertown", 30)
ns.BlackrockDeeps = mapName("BlackrockDeeps", 35)
ns.Westfall = mapName("Westfall", 52)
ns.Stormwind = mapName("Stormwind", 84)
ns.Ironforge = mapName("Ironforge", 87)
ns.Undercity = mapName("Undercity", 90)
ns.Ghostlands = mapName("Ghostlands", 95)
ns.Silvermoon = mapName("Silvermoon", 110)
ns.IsleOfQuelDanas = mapName("IsleOfQuelDanas", 122)
ns.Vashjir = mapName("Vashjir", 203)
ns.RuinsofGilneas = mapName("RuinsofGilneas", 217)
ns.TolBarad = mapName("TolBarad", 245)
ns.TwilightHighlands = mapName("TwilightHighlands", 241)
ns.Deepruntram = mapName("Deepruntram", 499)
ns.Deadmines = mapName("Deadmines", 835)
ns.Gnomeregan = mapName("Gnomeregan", 840)
ns.Stratholme = mapName("Stratholme", 1505)
------------------------------------ Outland Zones
ns.HellfirePeninsula = mapName("HellfirePeninsula", 100)
ns.Zangarmarsh = mapName("Zangarmarsh", 102)
ns.ShadowmoonValley = mapName("ShadowmoonValley", 104)
ns.BladesEdgeMountains = mapName("BladesEdgeMountains", 105)
ns.Nagrand = mapName("Nagrand", 107)
ns.TerokkarForest = mapName("TerokkarForest", 108)
ns.Shattrath = mapName("Shattrath", 111)
------------------------------------ Northrend Zones
ns.BoreanTundra = mapName("BoreanTundra", 114)
ns.HowlingFjord = mapName("HowlingFjord", 117)
ns.Icecrown = mapName("Icecrown", 118)
ns.SholazarBasin = mapName("SholazarBasin", 119)
ns.Wintergrasp = mapName("Wintergrasp", 123)
ns.Dalaran = mapName("Dalaran", 125)
------------------------------------ Pandaria Zones
ns.JadeForest = mapName("JadeForest", 371)
ns.ValleyOfTheFourWinds = mapName("ValleyOfTheFourWinds", 376)
ns.KunLaiSummit = mapName("KunLaiSummit", 379)
ns.TownlongSteppes = mapName("TownlongSteppes", 388)
ns.ValeOfEternalBlossoms = mapName("ValeOfEternalBlossoms", 390)
ns.Shrine2Moons = mapName("Shrine2Moons", 391)
ns.Shrine7Stars = mapName("Shrine7Stars", 393)
ns.KrasarangWilds = mapName("KrasarangWilds", 418)
ns.IsleOfThunder = mapName("IsleOfThunder", 504)
------------------------------------ Draenor Zones
ns.FrostfireRidge = mapName("FrostfireRidge", 525)
ns.TanaanJungle = mapName("TanaanJungle", 534)
ns.Talador = mapName("Talador", 535)
ns.SpiresOfArak = mapName("SpiresOfArak", 542)
ns.Gorgrond = mapName("Gorgrond", 543)
ns.Moonfall = mapName("Moonfall", 582)
ns.Ashran = mapName("Ashran", 588)
ns.Frostwall = mapName("Frostwall", 590)
ns.Stormshield = mapName("Stormshield", 622)
ns.Warspear = mapName("Warspear", 624)
------------------------------------ Broken Isles Zones
ns.Suramar = mapName("Suramar", 680)
ns.Azsuna = mapName("Azsuna", 630)
ns.TelogrusRift = mapName("TelogrusRift", 971)
ns.Eredath = mapName("Eredath", 882)
------------------------------------ Kul Tiras Zones
ns.TiragardeSound = mapName("TiragardeSound", 895)
ns.Drustvar = mapName("Drustvar", 896)
ns.StormsongValley = mapName("StormsongValley", 942)
ns.Boralus = mapName("Boralus", 1161)
------------------------------------ Zandalar Zones
ns.Zuldazar = mapName("Zuldazar", 862)
ns.Nazmir = mapName("Nazmir", 863)
ns.Voldun = mapName("Voldun", 864)
ns.Dazaralor = mapName("Dazaralor", 1165)
ns.Nazjatar = mapName("Nazjatar", 1355)
------------------------------------ Shadowlands Zones
ns.Revendreth = mapName("Revendreth", 1525)
ns.Bastion = mapName("Bastion", 1533)
ns.Maldraxxus = mapName("Maldraxxus", 1536)
ns.TheMaw = mapName("TheMaw", 1543)
ns.Ardenweald = mapName("Ardenweald", 1565)
ns.Oribos = mapName("Oribos", 1670)
ns.Torghast = mapName("Torghast", 1911)
ns.Korthia = mapName("Korthia", 1961)
ns.ZerethMortis = mapName("ZerethMortis", 1970)
------------------------------------ Dragonflight Zones
ns.TheWakingShores = mapName("TheWakingShores", 2022)
ns.OhnahranPlains = mapName("OhnahranPlains", 2023)
ns.Valdrakken = mapName("Valdrakken", 2112)
ns.EmeraldDream = mapName("EmeraldDream", 2200)
ns.Amirdrassil = mapName("Amirdrassil", 2239)
ns.Thaldraszus = mapName("Thaldraszus", 2025)
------------------------------------ Khaz Algar Zones
ns.CityOfThreads = mapName("CityOfThreads", 2213)
ns.TheRingingDeeps = mapName("TheRingingDeeps", 2214)
ns.HallofAwakening = mapName("HallofAwakening", 2322)
ns.Dornogal = mapName("Dornogal", 2339)
ns.SirenIsle = mapName("SirenIsle", 2369)
ns.Tazavesh = mapName("Tazavesh", 2472)
------------------------------------ Housing
ns.RazorwindShores = mapName("RazorwindShores", 2351)
ns.FoundersPoint = mapName("FoundersPoint", 2352)
------------------------------------ Midnight
ns.EversongWoodsMidnight = mapName("EversongWoodsMidnight", 2395)
ns.VoidTempest = mapName("VoidTempest", 2405)
ns.SilvermoonMN = mapName("SilvermoonMN", 2393)
ns.Harandar = mapName("Harandar", 2413)
------------------------------------ delves
ns.TheDarkway = mapName("TheDarkway", 2525)
ns.CollegiateCalamity = mapName("CollegiateCalamity", 2547)
------------------------------------ continents
ns.Kalimdor = mapName("Kalimdor", 12)
ns.EasternKingdom = mapName("EasternKingdom", 13)
ns.Outland = mapName("Outland", 101)
ns.Northrend = mapName("Northrend", 113)
ns.Pandaria = mapName("Pandaria", 424)
ns.Draenor = mapName("Draenor", 572)
ns.BrokenIsles = mapName("BrokenIsles", 619)
ns.KulTiras = mapName("KulTiras", 876)
ns.Zandalar = mapName("Zandalar", 875)
ns.Shadowlands = mapName("Shadowlands", 1550)
ns.DragonIsles = mapName("DragonIsles", 1978)
ns.KhazAlgar = mapName("KhazAlgar", 2274)
ns.QuelThalas = mapName("QuelThalas", 2537)

------------------------------------ Class Hall
ns.ValSharah = mapName("ValSharah", 641)
ns.HighMountains = mapName("HighMountains", 650)


------------------------------------ areaID Names
local function areaName(key, id)
    return MN_RegisterMapNotesInfo("area", id, key, function()
        local name = C_Map.GetAreaInfo(id)

        if not MN_IsSafeText(name) and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
            print("|cffff0000[MapNotes]|r missing areaName(ID) for " .. tostring(id))
        end

        return name
    end)
end

------------------------------------ Sub Zones Neutral
ns.BootyBay = areaName("BootyBay", 35)
ns.Ratchet = areaName("Ratchet", 392)
ns.TheramoreIsle = areaName("TheramoreIsle", 15)
ns.DarkPortal = areaName("DarkPortal", 72)
ns.ShadoPanGarison = areaName("ShadoPanGarison", 6197)
ns.Amanizar = areaName("Amanizar", 16183)
ns.Arati = areaName("Arati", 16183)
------------------------------------ Sub Zones Horde
ns.Gromgol = areaName("Gromgol", 117)
ns.RuinsofLordaeron = areaName("RuinsofLordaeron", 153)
ns.Volmar = areaName("Volmar", 7523)
------------------------------------ Sub Zones Alliance
ns.Ruttheran = areaName("Ruttheran", 702)
ns.LionsWatch = areaName("LionsWatch", 7522)


------------------------------------ instanceID Names
local function instanceName(key, id)
    return MN_RegisterMapNotesInfo("instance", id, key, function()
        local name = EJ_GetInstanceInfo(id)

        if not MN_IsSafeText(name) and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
            print("|cffff0000[MapNotes]|r missing instanceName(ID) for " .. tostring(id))
        end

        return name
    end)
end

------------------------------------ Kalimdor
ns.BlackfathomDeeps = instanceName("BlackfathomDeeps", 227)
ns.DireMaul = instanceName("DireMaul", 230)
ns.TempleOfAhnQiraj = instanceName("TempleOfAhnQiraj", 744)
------------------------------------ Eastern Kingdom
ns.ShadowfangKeep = instanceName("ShadowfangKeep", 64)
ns.Scholomance = instanceName("Scholomance", 246)
ns.ScarletMonastery = instanceName("ScarletMonastery", 316)
ns.Naxxramas = instanceName("Naxxramas", 754)
ns.Rookery = instanceName("Rookery", 1268)
------------------------------------ Outland
ns.PitOfSaron = instanceName("PitOfSaron", 278)
------------------------------------ Broken Isles
ns.SeatOfTheTriumvirate = instanceName("SeatOfTheTriumvirate", 945)
------------------------------------ Draenor
ns.Skyreach = instanceName("Skyreach", 476)
------------------------------------ Dragonflight
ns.AlgetharAcademy = instanceName("AlgetharAcademy", 1201)
------------------------------------ Midnight
ns.MurderRow = instanceName("MurderRow", 1304)


------------------------------------ npcNameID Names
local function npcName(key, id)
    return MN_RegisterMapNotesInfo("npcName", id, key, function()
        local name = MN_GetSavedNpcInfo(id)

        if not MN_IsSafeText(name) and ns.GetNPCName then
            name = ns.GetNPCName(id)
        end

        if not MN_IsSafeText(name) and ns.GetNpcInfo then
            name = ns.GetNpcInfo(id)
        end

        return name
    end)
end

ns.ScoutingMap = npcName("ScoutingMap", 98093)
ns.JackFindel = npcName("JackFindel", 97004) -- Rogue Dalaran
ns.LucianTrias = npcName("LucianTrias", 96782) -- Rogue Dalaran
ns.Mongar = npcName("Mongar", 93188) -- Rogue Dalaran
ns.Aludane = npcName("Aludane", 96813) -- FP Dalaran Legion
------------------------------------ Travel Npc
ns.Manapuff = npcName("Manapuff", 147642)
------------------------------------ Travel Npc Horde
ns.DreadAdmiralTattersail = npcName("DreadAdmiralTattersail", 135690)
ns.CaptainKrooz = npcName("CaptainKrooz", 152506)
ns.ErulDawnbrook = npcName("ErulDawnbrook", 139524)
ns.Swellthrasher = npcName("Swellthrasher", 139519)
ns.GrokSeahandler = npcName("GrokSeahandler", 143282)
ns.ThrallmarMage = npcName("ThrallmarMage", 150131)
------------------------------------ Travel Npc Alliance
ns.GrandAdmiralJesTereth = npcName("GrandAdmiralJesTereth", 135681)
ns.BarnardTheSmasherBayswort = npcName("BarnardTheSmasherBayswort", 135383)
ns.DeshaStormwallow = npcName("DeshaStormwallow", 139620)
ns.DariaSmithson = npcName("DariaSmithson", 143334)
ns.HonorHoldMage = npcName("HonorHoldMage", 150122)
------------------------------------ Timetravel Npc
ns.Zidormi = npcName("Zidormi", 128607)
------------------------------------ LFR Registrant Npc
ns.Auridormi = npcName("Auridormi", 80675)
ns.ArchmageTimear = npcName("ArchmageTimear", 111246)
ns.LorewalkerHan = npcName("LorewalkerHan", 80633)
ns.Eppu = npcName("Eppu", 177208)
ns.Kiku = npcName("Kiku", 177193)
ns.SeerKazal = npcName("SeerKazal", 94870)
ns.Taelfar = npcName("Taelfar", 205959)


------------------------------------ npcTitleLine1 second line
local function npcTitleLine1(key, id)
    return MN_RegisterMapNotesInfo("npcTitle", id, key, function()
        local _, title = MN_GetSavedNpcInfo(id)

        if not MN_IsSafeText(title) and ns.GetNpcInfo then
            local _, t = ns.GetNpcInfo(id)
            title = t
        end

        return title
    end)
end

ns.Archivar = npcTitleLine1("Archivar", 102641) -- Filius Funkenbart
ns.QuartermasterF = npcTitleLine1("QuartermasterF", 105986) -- Kelsey Stahlfunken
ns.QuartermasterM = npcTitleLine1("QuartermasterM", 196637) -- Tethalash
ns.RenownQuartermaster = npcTitleLine1("RenownQuartermaster", 223728) -- Auditor Balwurz
ns.Upgrade = npcTitleLine1("Upgrade", 108527) -- Loramus Thalipedes
ns.RecruitM = npcTitleLine1("RecruitM", 106442) -- Yaris Darkclow
ns.RecruitF = npcTitleLine1("RecruitF", 108393) -- Sister Lilith
ns.WeaponsSupplierM = npcTitleLine1("WeaponsSupplierM", 110434) -- Kristoff
ns.WeaponsSupplierF = npcTitleLine1("WeaponsSupplierF", 110595) -- Lilith
ns.InnkeeperM = npcTitleLine1("InnkeeperM", 98106) -- Elliot Theodric
ns.InnkeeperF = npcTitleLine1("InnkeeperF", 100746) -- Folla Strenghuf
ns.StablemasterM = npcTitleLine1("StablemasterM", 44788) -- Lonto
ns.StablemasterF = npcTitleLine1("StablemasterF", 53780) -- Lonto
ns.SkinningM = npcTitleLine1("SkinningM", 7088) -- Thuwd
ns.CookingM = npcTitleLine1("CookingM", 133261) -- Feng Su
ns.CookingF = npcTitleLine1("CookingF", 46709) -- Arugi
ns.TailoringM = npcTitleLine1("TailoringM", 3363) -- Magar
ns.FishingM = npcTitleLine1("FishingM", 70398) -- Ben mit der dröhnenden Stimme
ns.ArchaeologyM = npcTitleLine1("ArchaeologyM", 47571) -- Bellok Leuchtklinge
ns.DecorExpertW = npcTitleLine1("DecorExpertW", 256828) -- Dennia Silberzunge
ns.DecorExpertM = npcTitleLine1("DecorExpertM", 108017) -- Torv Dubstampf

------------------------------------ TaxiIDs Text for Retail only
local function TaxiID(key, id)
    return MN_RegisterMapNotesInfo("taxi", id, key, function()
        local raw = C_TaxiMap.GetTaxiNodeName and C_TaxiMap.GetTaxiNodeName(id)
        local base = raw and raw:match("^(.-),") or raw
        return base or raw
    end)
end

ns.TaxiRatchet = TaxiID("TaxiRatchet", 80)


------------------------------------ SpellID Text
local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo
local function spellName(key, id)
    return MN_RegisterMapNotesInfo("spell", id, key, function()
        local info = GetSpellInfo(id)
        local name = info and (info.name or info)

        if not MN_IsSafeText(name) and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
            print("|cffff0000[MapNotes]|r missing spellName(ID) for " .. tostring(id))
        end

        return name
    end)
end

ns.HallOfTheGuardian = spellName("HallOfTheGuardian", 193759) -- Teleport Hall of the Guardian -- Mage
ns.Dreamwalk = spellName("Dreamwalk", 193753) -- Teleport Dreamwalk - Druid
ns.DeathGate = spellName("DeathGate", 50977) -- Teleport Death Gate -- DK
ns.ZenPilgrimage = spellName("ZenPilgrimage", 126892) -- Teleport Zen Pilgrimage -- Monk
ns.JumpToSkyhold = spellName("JumpToSkyhold", 192085) -- Teleport -- Warrior Class Hall
ns.WarbandExploreAllMapsFromMainchar = spellName("WarbandExploreAllMapsFromMainchar", 431280) -- Warband explore all maps


------------------------------------ CurrencyID Text
function ns.GetCurrencyName(currencyID)
    return MN_RegisterMapNotesInfo("currency", currencyID, nil, function()
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        return info and info.name
    end)
end

local function currencyName(key, currencyID)
    return MN_RegisterMapNotesInfo("currency", currencyID, key, function()
        local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
        return info and info.name
    end)
end

ns.WakeningEssence = currencyName("WakeningEssence", 1533) -- Dalaran Vendor Arkonomant Vridiel


------------------------------------ factionID Text
function ns.FactionName(factionID)
    return MN_RegisterMapNotesInfo("faction", factionID, nil, function()
        local name

        if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
            local mf = C_MajorFactions.GetMajorFactionData(factionID)
            name = mf and mf.name
            if MN_IsSafeText(name) then
                return name
            end
        end

        if C_ReputationManager and C_ReputationManager.GetFactionDataByID then
            local data = C_ReputationManager.GetFactionDataByID(factionID)
            name = data and data.name
            if MN_IsSafeText(name) then
                return name
            end
        end

        return nil
    end)
end

local function factionName(key, factionID)
    return MN_RegisterMapNotesInfo("faction", factionID, key, function()
        local name

        if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
            local mf = C_MajorFactions.GetMajorFactionData(factionID)
            name = mf and mf.name
            if MN_IsSafeText(name) then
                return name
            end
        end

        if C_ReputationManager and C_ReputationManager.GetFactionDataByID then
            local data = C_ReputationManager.GetFactionDataByID(factionID)
            name = data and data.name
            if MN_IsSafeText(name) then
                return name
            end
        end

        return nil
    end)
end

ns.Amanistamm = factionName("Amanistamm", 2696)
ns.TheSingularity = factionName("TheSingularity", 2699)
ns.Harati = factionName("Harati", 2704)
ns.SilvermoonCourt = factionName("SilvermoonCourt", 2710)

SLASH_MNINFOTEST1 = "/mninfotest"
SlashCmdList["MNINFOTEST"] = function()
    local loc = GetLocale() or "enUS"
    local db = HandyNotes_MapNotesRetailNpcCacheDB

    local mapNotesValue = db
        and db.mapNotesInfo
        and db.mapNotesInfo[loc]
        and db.mapNotesInfo[loc].npcName
        and db.mapNotesInfo[loc].npcName[98093]

    local npcPacked = db
        and db.names
        and db.names[loc]
        and db.names[loc][98093]

    print("----- MapNotes Info Test -----")
    print("Locale:", tostring(loc))
    print("ns.ScoutingMap:", tostring(ns.ScoutingMap))
    print("mapNotesInfo npcName[98093]:", tostring(mapNotesValue))
    print("names[98093]:", tostring(npcPacked))
end