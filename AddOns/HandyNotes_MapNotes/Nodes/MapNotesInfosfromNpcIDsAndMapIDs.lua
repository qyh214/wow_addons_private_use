local ADDON_NAME, ns = ...

------------------------------------ mapID Names
local function mapName(id)
    local info = C_Map.GetMapInfo(id)
    local name = info and info.name
    if (not name or name == "") and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
        print("|cffff0000[MapNotes]|r missing mapName(ID) for " .. tostring(id))
    end
    return name or ""
end

------------------------------------ Housing Zones
ns.Razorwind = mapName(2351) -- Horde
ns.FoundersPoint = mapName(2352) -- Alliance

------------------------------------ Kalimdor Zones
ns.Durotar = mapName(1)
ns.Barrens = mapName(10)
ns.WailingCaverns = mapName(11)
ns.Teldrassil = mapName(57)
ns.Darkshore = mapName(62)
ns.DustwallowMarsh = mapName(70)
ns.CavernsOfTime = mapName(75)
ns.UnGoroCrater = mapName(78)
ns.Silithus = mapName(81)
ns.Orgrimmar = mapName(85)
ns.Darnassus = mapName(89)
ns.ThunderBluff = mapName(88)
ns.AzuremystIsle = mapName(97)
ns.Exodar = mapName(103)
ns.Hyjal = mapName(198)
ns.Uldum = mapName(249)
ns.EchoIsles = mapName(463)
------------------------------------ Eastern Kingdom Zones
ns.ArathiHighlands = mapName(14)
ns.Badlands = mapName(15)
ns.BlastedLands = mapName(17)
ns.TirisfalGlades = mapName(18)
ns.EasternPlagueland = mapName(23)
ns.NewTinkertown = mapName(30)
ns.BlackrockDeeps = mapName(35)
ns.Westfall = mapName(52)
ns.Stormwind = mapName(84)
ns.Ironforge = mapName(87)
ns.Undercity = mapName(90)
ns.Silvermoon = mapName(110)
ns.IsleOfQuelDanas = mapName(122)
ns.Vashjir = mapName(203)
ns.RuinsofGilneas = mapName(217)
ns.TolBarad = mapName(245)
ns.TwilightHighlands = mapName(241)
ns.Deepruntram = mapName(499)
ns.Deadmines = mapName(835)
ns.Gnomeregan = mapName(840)
ns.Stratholme = mapName(1505)
------------------------------------ Outland Zones
ns.HellfirePeninsula = mapName(100)
ns.Zangarmarsh = mapName(102)
ns.ShadowmoonValley = mapName(104)
ns.BladesEdgeMountains = mapName(105)
ns.Nagrand = mapName(107)
ns.TerokkarForest = mapName(108)
ns.Shattrath = mapName(111)
------------------------------------ Northrend Zones
ns.BoreanTundra = mapName(114)
ns.HowlingFjord = mapName(117)
ns.Icecrown = mapName(118)
ns.SholazarBasin = mapName(119)
ns.Wintergrasp = mapName(123)
ns.Dalaran = mapName(125)
------------------------------------ Pandaria Zones
ns.JadeForest = mapName(371)
ns.ValleyOfTheFourWinds = mapName(376)
ns.KunLaiSummit = mapName(379)
ns.TownlongSteppes = mapName(388)
ns.ValeOfEternalBlossoms = mapName(390)
ns.Shrine2Moons = mapName(391)
ns.Shrine7Stars = mapName(393)
ns.KrasarangWilds = mapName(418)
ns.IsleOfThunder = mapName(504)
------------------------------------ Draenor Zones
ns.FrostfireRidge = mapName(525)
ns.TanaanJungle = mapName(534)
ns.Talador = mapName(535)
ns.SpiresOfArak = mapName(542)
ns.Gorgrond = mapName(543)
ns.Moonfall = mapName(582)
ns.Ashran = mapName(588)
ns.Frostwall = mapName(590)
ns.Stormshield = mapName(622)
ns.Warspear = mapName(624)
------------------------------------ Broken Isles Zones
ns.Azsuna = mapName(630)
ns.TelogrusRift = mapName(971)
------------------------------------ Kul Tiras Zones
ns.TiragardeSound = mapName(895)
ns.Drustvar = mapName(896)
ns.StormsongValley = mapName(942)
ns.Boralus = mapName(1161)
------------------------------------ Zandalar Zones
ns.Zuldazar = mapName(862)
ns.Nazmir = mapName(863)
ns.Voldun = mapName(864)
ns.Dazaralor = mapName(1165)
ns.Nazjatar = mapName(1355)
------------------------------------ Shadowlands Zones
ns.Revendreth = mapName(1525)
ns.Bastion = mapName(1533)
ns.Maldraxxus = mapName(1536)
ns.TheMaw = mapName(1543)
ns.Ardenweald = mapName(1565)
ns.Oribos = mapName(1670)
ns.Torghast = mapName(1911)
ns.Korthia = mapName(1961)
ns.ZerethMortis = mapName(1970)
------------------------------------ Dragonflight Zones
ns.TheWakingShores = mapName(2022)
ns.OhnahranPlains = mapName(2023)
ns.Valdrakken = mapName(2112)
ns.EmeraldDream = mapName(2200)
ns.Amirdrassil = mapName(2239)
------------------------------------ Khaz Algar Zones
ns.CityOfThreads = mapName(2213)
ns.HallofAwakening = mapName(2322)
ns.Dornogal = mapName(2339)
ns.SirenIsle = mapName(2369)
ns.Tazavesh = mapName(2472)
------------------------------------ Housing
ns.RazorwindShores = mapName(2351)
ns.FoundersPoint = mapName(2352)
------------------------------------ continents
ns.Kalimdor = mapName(12)
ns.EasternKingdom = mapName(13)
ns.Outland = mapName(101)
ns.Northrend = mapName(113)
ns.Pandaria = mapName(424)
ns.Draenor = mapName(572)
ns.BrokenIsles = mapName(619)
ns.KulTiras = mapName(876)
ns.Zandalar = mapName(875)
ns.Shadowlands = mapName(1550)
ns.DragonIsles = mapName(1978)
ns.KhazAlgar = mapName(2274)

------------------------------------ Class Hall
ns.ValSharah = mapName(641)
ns.HighMountains = mapName(650)


------------------------------------ areaID Names
local function areaName(id)
    local name = C_Map.GetAreaInfo(id)
    if (not name or name == "") and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
        print("|cffff0000[MapNotes]|r missing areaName(ID) for " .. tostring(id))
    end
    return name or ""
end

------------------------------------ Sub Zones Neutral
ns.BootyBay = areaName(35)
ns.Ratchet = areaName(392)
ns.TheramoreIsle = areaName(15)
ns.DarkPortal = areaName(72)
ns.ShadoPanGarison = areaName(6197)
------------------------------------ Sub Zones Horde
ns.Gromgol = areaName(117)
ns.RuinsofLordaeron = areaName(153)
ns.Volmar = areaName(7523)
------------------------------------ Sub Zones Alliance
ns.Ruttheran = areaName(702)
ns.LionsWatch = areaName(7522)


------------------------------------ instanceID Names
local function instanceName(id)
    local name = EJ_GetInstanceInfo(id)
    if (not name or name == "") and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
        print("|cffff0000[MapNotes]|r missing instanceName(ID) for " .. tostring(id))
    end
    return name or ""
end

------------------------------------ Kalimdor
ns.BlackfathomDeeps = instanceName(227)
ns.DireMaul = instanceName(230)
ns.TempleOfAhnQiraj = instanceName(744)
------------------------------------ Eastern Kingdom
ns.ShadowfangKeep = instanceName(64)
ns.Scholomance = instanceName(246)
ns.ScarletMonastery = instanceName(316)
ns.Naxxramas = instanceName(754)
ns.Rookery = instanceName(1268)


------------------------------------ npcNameID Names
local function npcName(id)
    if ns.GetNpcInfo then
        local name = ns.GetNpcInfo(id)
        if name and name ~= "" then
            return name
        end
    end

    local link = "unit:Creature-0-0-0-0-" .. id .. "-0000000000"
    local data = C_TooltipInfo and C_TooltipInfo.GetHyperlink and C_TooltipInfo.GetHyperlink(link)
    local name = data and data.lines and data.lines[1] and data.lines[1].leftText
    if (not name or name == "") and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
        print("|cffff0000[MapNotes]|r missing npcNameID for " .. tostring(id))
    end
    return name or ""
end

ns.ScoutingMap = npcName(98093)
ns.JackFindel = npcName(97004) -- Rogue Dalaran
ns.LucianTrias = npcName(96782) -- Rogue Dalaran
ns.Mongar = npcName(93188) -- Rogue Dalaran
ns.Aludane = npcName(96813) -- FP Dalaran Legion
------------------------------------ Travel Npc
ns.Manapuff = npcName(147642)
------------------------------------ Travel Npc Horde
ns.DreadAdmiralTattersail = npcName(135690)
ns.CaptainKrooz = npcName(152506)
ns.ErulDawnbrook = npcName(139524)
ns.Swellthrasher = npcName(139519)
ns.GrokSeahandler = npcName(143282)
ns.ThrallmarMage = npcName(150131)
------------------------------------ Travel Npc Alliance
ns.GrandAdmiralJesTereth = npcName(135681)
ns.BarnardTheSmasherBayswort = npcName(135383)
ns.DeshaStormwallow = npcName(139620)
ns.DariaSmithson = npcName(143334)
ns.HonorHoldMage = npcName(150122)
------------------------------------ Timetravel Npc
ns.Zidormi = npcName(128607)
------------------------------------ LFR Registrant Npc
ns.Auridormi = npcName(80675)
ns.ArchmageTimear = npcName(111246)
ns.LorewalkerHan = npcName(80633)
ns.Eppu = npcName(177208)
ns.Kiku = npcName(177193)
ns.SeerKazal = npcName(94870)
ns.Taelfar = npcName(205959)


------------------------------------ npcTitleLine1 second line
local function npcTitleLine1(id)
    if ns.GetNpcInfo then
        local _, title = ns.GetNpcInfo(id)
        if title and title ~= "" then
            return title
        end
        return ""
    end

    if not (C_TooltipInfo and C_TooltipInfo.GetHyperlink) then
        if ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode then
            print("|cffff0000[MapNotes]|r missing npcTitleID for " .. tostring(id))
        end
        return ""
    end
    local data = C_TooltipInfo.GetHyperlink("unit:Creature-0-0-0-0-" .. id .. "-0000000000")
    if not (data and data.lines and data.lines[2]) then return "" end
    if TooltipUtil and TooltipUtil.SurfaceArgs then
        TooltipUtil.SurfaceArgs(data); TooltipUtil.SurfaceArgs(data.lines[2])
    end
    local title = data.lines[2].leftText or ""
    if (title == "") and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
        print("|cffff0000[MapNotes]|r missing npcTitleID for " .. tostring(id))
    end
    return title or ""
end

ns.Archivar = npcTitleLine1(102641) -- Filius Funkenbart
ns.QuartermasterF = npcTitleLine1(105986) -- Kelsey Stahlfunken
ns.QuartermasterM = npcTitleLine1(196637) -- Tethalash
ns.RenownQuartermaster = npcTitleLine1(223728) -- Auditor Balwurz
ns.Upgrade = npcTitleLine1(108527) -- Loramus Thalipedes
ns.RecruitM = npcTitleLine1(106442) -- Yaris Darkclow
ns.RecruitF = npcTitleLine1(108393) -- Sister Lilith
ns.WeaponsSupplierM = npcTitleLine1(110434) -- Kristoff
ns.WeaponsSupplierF = npcTitleLine1(110595) -- Lilith
ns.InnkeeperM = npcTitleLine1(98106) -- Elliot Theodric
ns.InnkeeperF = npcTitleLine1(100746) -- Folla Strenghuf
ns.StablemasterM = npcTitleLine1(44788) -- Lonto
ns.StablemasterF = npcTitleLine1(53780) -- Lonto
ns.SkinningM = npcTitleLine1(7088) -- Thuwd
ns.CookingM = npcTitleLine1(133261) -- Feng Su
ns.CookingF = npcTitleLine1(46709) -- Arugi
ns.TailoringM = npcTitleLine1(3363) -- Magar
ns.FishingM = npcTitleLine1(70398) -- Ben mit der dröhnenden Stimme
ns.ArchaeologyM = npcTitleLine1(47571) -- Bellok Leuchtklinge


------------------------------------ TaxiIDs Text for Retail only
local function TaxiID(id)
  local raw = C_TaxiMap.GetTaxiNodeName and C_TaxiMap.GetTaxiNodeName(id)
  local base = raw and raw:match("^(.-),") or raw
  return base or raw or ""
end

ns.TaxiRatchet = TaxiID(80)


------------------------------------ SpellID Text
local GetSpellInfo = C_Spell and C_Spell.GetSpellInfo or GetSpellInfo
local function spellName(id)
    local info = GetSpellInfo(id)
    local name = info and (info.name or info)
    if (not name or name == "") and (ns.Addon and ns.Addon.db and ns.Addon.db.profile and ns.Addon.db.profile.DeveloperMode) then
        print("|cffff0000[MapNotes]|r missing spellName(ID) for " .. tostring(id))
    end
    return name or ""
end

ns.HallOfTheGuardian = spellName(193759) -- Teleport Hall of the Guardian -- Mage
ns.Dreamwalk = spellName(193753) -- Teleport Dreamwalk - Druid
ns.DeathGate = spellName(50977) -- Teleport Death Gate -- DK
ns.ZenPilgrimage = spellName(126892) -- Teleport Zen Pilgrimage -- Monk
ns.JumpToSkyhold = spellName(192085) -- Teleport -- Warrior Class Hall
ns.WarbandExploreAllMapsFromMainchar = spellName(431280) -- Warband explore all maps


------------------------------------ CurrencyID Text
function ns.GetCurrencyName(currencyID)
    local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
    local name = info and info.name
    return name or ""
end

ns.WakeningEssence = ns.GetCurrencyName(1533) -- Dalaran Vendor Arkonomant Vridiel