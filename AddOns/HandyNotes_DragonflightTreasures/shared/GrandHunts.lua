local myname, ns = ...

--[[
areaPois
Waking Shores continent: 7343
Waking Shores: 7092 @ 68906680
Ohn'Ahran Plains: 7053 @ 82202030
Ohn'Ahran Plains: 7089 @ 61005330 (70002 / 70519?)
Ohn'Ahran Plains: 7090 @ 81104940 (71137?)
Ohn'Ahran Plains: 7091 @ 54401840 (/ Waking Shores 23909520)
Azure Span continent: 7345
Azure Span: 7094 @ 38603540 (70004 / 70906?)
Azure Span: 7096 @ 68505370 (70006)
Thaldraszus continent: 7344
Thaldraszus: 7097 @ 34406750 (70007 / 71136)

Grand hunt spoils: 200468 (epic), 200513 (rare), 200515 (uncommon), 200516 (common)
{194089, quest=71046}, -- Bakar Companion Color: Orange
{194095, quest=71052}, -- Ohuna Companion Color: Sepia
{193205, quest=71050}, -- Ohuna Companion Color: Brown

Siege on Dragonsbane Keep: 7267 @ Waking Shores 30607790, quest 71210 (+72671) / 70866+74295
-- 74295 seems to be the daily, for the blue strongbox (202142)
Dragonbane Keep Strongbox: 200072 (epic),
192007, -- Wyrmforged Sabatons
192008, -- Wyrmforged Gauntlets
--]]

local hunt = {
    achievement=16545, criteria=true,
    group="hunts",
    texture=ns.atlas_texture("Warfront-NeutralHero", nil, 0.2),
    requires=ns.conditions.MajorFaction(ns.FACTION_MARUUK, 2), -- they start dropping trophies at 2
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [41158455] = { -- Degmakh
        npc=194251,
        quest=73911,
        loot={
            198990, -- Drakewatcher's Cord
        },
        vignette=5266,
    },
    [47767707] = { -- Muugurv
        npc=194225,
        quest=73927,
        loot={
            198985, -- Drakewatcher's Vestement
        },
        vignette=5264,
    },
    [26618872] = { -- Uurtus
        quest=73945, -- then 71136+69998 for end-of-hunt
        npc=193724,
        loot={
            200164, -- Iceloop
            200187, -- Rod of Glacial Force
            200245, -- Leviathan Lure
            200552, -- Torrent Caller's Shell
            200563, -- Primal Ritual Shell
            {197001, quest=69201}, -- Cliffside Wylderdrake: Finned Cheek
            {197098, quest=69299}, -- Highland Drake: Finned Back
        },
        vignette=5255,
    },
    [23328912] = { -- Tomnu
        quest=70519, -- 73940
        npc=193722,
        loot={},
        vignette=5254,
    },
}, hunt)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [72374558] = { -- Zumakh
        quest=70003, -- 70906
        npc=194624,
        loot={
            200563, -- Primal Ritual Shell
        },
        vignette=5277,
    },
    [80715432] = { -- Kholdeg
        quest=73920,
        npc=194608,
        loot={},
        vignette=5276,
    },
    [57554763] = { -- Ergburk
        quest=73914,
        npc=194409,
        loot={},
        vignette=5270,
    },
    [55765070] = { -- Rokzul
        quest=73930,
        npc=194458,
        note="In cave",
        vignette=5274,
    },
}, hunt)

ns.RegisterPoints(ns.AZURESPAN, {
    [38634371] = { -- Khuumog
        npc=194761,
        quest=73922,
        vignette=5282,
    },
    [66035180] = { -- Yamakh
        npc=195283,
        quest=73947,
        loot={
            200193, -- Manafrond Sandals
        },
        vignette=5359,
    },
    [36733726] = { -- Uurhilt
        npc=194760,
        quest=73944,
        loot={
            200131, -- Reclaimed Survivalist's Dagger
        },
        vignette=5281,
    },
    [33214095] = { -- Tenmod
        npc=194763,
        quest=73938,
        vignette=5283,
    },
    [66385959] = { -- Arkhuu
        npc=195300,
        quest=73907,
        vignette=5361,
    },
}, hunt)
