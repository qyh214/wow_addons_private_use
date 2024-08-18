local myname, ns = ...

local ECHOES = {
    achievement=40222,
    note="During Worldsoul Memory events",
    group="echoes",
}

ns.RegisterPoints(ns.HALLOWFALL, {
    [47002280] = { -- Gurl the Feaster
        criteria=67515,
        quest=nil,
        npc=222655,
        vignette=6227,
    },
    [47402300] = { -- Zaniga the Tracker
        criteria=67513,
        quest=nil,
        npc=222639,
        vignette=6229,
    },
}, ECHOES)

ns.RegisterPoints(ns.AZJKAHET, {
    [64805540] = { -- Soulboil
        -- [64805540, 64805560]
        criteria=39,
        quest=nil,
        npc=224282,
        vignette=6311,
    },
    [65605580] = { -- Azerite Manifestation
        criteria=67549,
        quest=nil,
        npc=222670,
        vignette=6314,
    },
}, ECHOES)
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [22204460] = { -- Vin'ris The Corruptor
        criteria=67545, -- "The Rebellious Queen"?
        quest=nil,
        npc=222630,
        vignette=6270,
    },
    [19004640] = { -- Yoh'nath The Ender
        criteria=67548,
        quest=nil,
        npc=222628,
        vignette=6218,
    },
}, ECHOES)

--[[
[] = {criteria=67509, npc=222605}, -- Aqu'yinra
[] = {criteria=67510, npc=222629}, -- S'toth The Insatiable
[] = {criteria=67507, npc=222611}, -- Bor'zal the Lurking
[] = {criteria=67508, npc=222632}, -- Yor'sith
[] = {criteria=67511, npc=222640}, -- Venox
[] = {criteria=67512, npc=222621}, -- Hand of Azshara
[] = {criteria=67514, npc=222637}, -- Ankoan Champion Utaari
[] = {criteria=67516, npc=222627}, -- Utmoth the Tidetwister
[] = {criteria=67517, npc=222720}, -- Kiji the Stomper
[] = {criteria=67518, npc=222682}, -- Clawmother Tengi
[] = {criteria=67519, npc=222691}, -- Nalo'xic
[] = {criteria=67520, npc=222718}, -- Pterrordaxus
[] = {criteria=67521, npc=222690}, -- Tor'go
[] = {criteria=67523, npc=222762}, -- Flame Viscerator Ignes
[] = {criteria=67524, npc=222743}, -- Oremex Flamebreaker
[] = {criteria=67525, npc=222741}, -- Earthfury Cragshar
[] = {criteria=67526, npc=222756}, -- Deepwalker Cavelord
[] = {criteria=67527, npc=222791}, -- Crateron
[] = {criteria=67528, npc=222733}, -- Stormlord Kao'dar
[] = {criteria=67529, npc=222659}, -- Toaka the Explorer
[] = {criteria=67530, npc=222723}, -- Conqueror Or'sosh
[] = {criteria=67531, npc=222728}, -- Wavecrasher Jurvak
[] = {criteria=67532, npc=223896}, -- Warmonger Ogli
[] = {criteria=67534, npc=221974}, -- Gong'tze the Riverhewer
[] = {criteria=67535, npc=221970}, -- First Blade Grimskarn
[] = {criteria=28, npc=0}, -- Zeeben and Zillix
[] = {criteria=67540, npc=221972}, -- Talinhet
[] = {criteria=67541, npc=221973}, -- Temaya
[] = {criteria=67544, npc=222616}, -- The Rebellious Queen
[] = {criteria=67546, npc=222626}, -- Vil'Vim
[] = {criteria=67547, npc=222654}, -- Spiz'na the Traitor
[] = {criteria=67550, npc=222660}, -- Shard of Gorribal
[] = {criteria=67552, npc=222671}, -- Widowcore
[] = {criteria=67553, npc=222667}, -- Heartsear
--]]
