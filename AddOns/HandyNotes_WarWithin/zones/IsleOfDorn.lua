local myname, ns = ...

--[[
notes:

Earthern coffer 6230
38523951 - in cave from 36354156

Worldsoul Memory
55627771
]]

-- Treasures

ns.RegisterPoints(ns.ISLEOFDORN, {
    [48513004] = { -- Tree's Treasure
        criteria=68197,
        quest=83242, -- 82160 when treasure appears
        loot={{224585, toy=true}}, -- Hanna's Locket
        note="In cave; talk to {npc:222940:Freysworn Letitia} for a {item:224185:Crab-Guiding Branch}, then go find {npc:222941:Pearlescent Shellcrab} around the zone",
        related={
            [19715844] = {quest=82755},
            [50717055] = {quest=82751},
            [74924940] = {quest=82752},
            [70752001] = {quest=82753, note="On the rocks above the tree"},
            [41822704] = {quest=82754},
            [38364194] = {quest=82756, note="Up in the branches"},
            --
            label="{npc:222941:Pearlescent Shellcrab}",
            color={r=1, g=0.5, b=0.5}, minimap=true,
            required=ns.conditions.Item(224185), -- Crab-Guiding Branch
            note="Chase away all six crabs then return to {npc:222940:Freysworn Letitia}",
        },
        vignette=6210,
    },
    [40655988] = { -- Magical Treasure Chest
        criteria=68199,
        quest=83243,
        loot={{224579, pet=3362}}, -- Sapphire Crab
        note="Push {npc:223104:Lionel} into the water, talk to it, then go gather 5x {item:223159:Plump Snapcrab} nearby",
        vignette=6224,
    },
    [54001914] = { -- Mysterious Orb
        criteria=68201,
        quest=83244, -- 82047 after talking, 82134 after giving, also 82252 when looted
        loot={224373}, -- Waterlord's Iridescent Gem
        note="Talk to {npc:222847:Weary Water Elemental}, then go fetch its {item:221504:Elemental Pearl}",
        nearby={53051857, label="{item:221504:Elemental Pearl}"},
    },
    [55006564] = { -- Mushroom Cap
        criteria=68202,
        quest=83245, -- 82142 after giving cap, 82253 as well on loot
        loot={210796}, -- Mycobloom
        note="Talk to {npc:222894:U'llort the Self-Exiled} then fetch a {item:221550:Boskroot Cap} from the nearby woods",
            vignette=6209,
    },
    [38074358] = { -- Thak's Treasure
        criteria=68203,
        quest=82246,
        loot={
            212498, -- Ambivalent Amber
            212511, -- Ostentatious Onyx
        },
        note="Talk to {npc:223227:One-Eyed Thak} and follow him to the treasure",
        vignette=6236,
    },
    [59622459] = { -- Mosswool Flower
        criteria=68204,
        quest=83246, -- 82145 when flower spawns, 82251 also when looted
        loot={{224450, pet=4527}}, -- Lil' Moss Rosy
        nearby={
            -- In this order: (but no helpful quests)
            -- 59622459, -- 222956
            59102706, -- 222963
            59752870, -- 222965
            label="{npc:222956:Lost Mosswool}",
        },
        route={59622459, 59102706, 59752870},
        minimap=true,
        note="Chase {npc:222956:Lost Mosswool} to the flower",
    },
    [62574327] = { -- Kobold Pickaxe
        criteria=68205,
        quest=82325,
        loot={223484}, -- Kobold Mastermind's "Pivel"
        vignette=6273,
        note="Despawns for a while after someone loots it, so you might need to wait around",
    },
    [77232446] = { -- Jade Pearl
        criteria=68206,
        quest=82287,
        loot={223280}, -- Jade Pearl
        vignette=6262,
        note="Despawns for a while after someone loots it, so you might need to wait around",
    },
    [48896086] = { -- Shimmering Opal Lily
        criteria=68207,
        quest=82326,
        loot={
            213197, -- Null Lotus
            210800, -- Luredrop
        },
        path=47316149,
        note="At the bottom of the cave; despawns for a while after someone loots it, so you might need to wait around",
        vignette=2248,
    },
    [56226094] = { -- Infused Cinderbrew
        criteria=68208,
        quest=82714,
        loot={224263}, -- Infused Fire-Honey Milk
        note="On the desk; despawns for a while after someone loots it, so you might need to wait around"
    },
    [59122347] = { -- Web-Wrapped Axe
        criteria=68209,
        quest=82715,
        loot={224290}, -- Storm Defender's Axe
        note="Inside the building; despawns for a while after someone loots it, so you might need to wait around",
        vignette=2248,
    },
}, {
    achievement=40434, -- Treasures
})
-- Turtle's Thanks
ns.RegisterPoints(ns.ISLEOFDORN, {
    [40917377] = { -- Turtle's Thanks (initial)
        criteria=68198,
        quest=79585, -- pike
        loot={{224549,pet=4594}}, -- Sewer Turtle Whistle
        note="Give {npc:223338:Dalaran Sewer Turtle} 5x {item:220143:Dornish Pike}, then leave the area and return to give it 1x {item:222533:Goldengill Trout}. Then go find it again in Dornegal.",
        active=ns.conditions.Item(220143, 5),
        vignette=6244,
    },
    [40917376] = { -- Turtle's Thanks (after pike)
        criteria=68198,
        quest=79586, -- trout
        loot={{224549,pet=4594}}, -- Sewer Turtle Whistle
        note="Give {npc:223338:Dalaran Sewer Turtle} 1x {item:222533:Goldengill Trout}. Then go find it again in Dornegal.",
        active=ns.conditions.Item(222533),
        vignette=6245,
    },
}, {achievement=40434}) -- Treasures
ns.RegisterPoints(ns.DORNOGAL, {
    [58283027] = { -- Turtle's Thanks (after trout)
        achievement=40434, -- Treasures
        criteria=68198,
        quest=82716, -- final!, also 82255 when treasure spawns
        loot={{224549,pet=4594}}, -- Sewer Turtle Whistle
        note="Talk to the turtle to spawn the treasure",
        vignette=6246, -- Dalaran Sewer Turtle, then 6579 Turtle's Thanks
        parent=true,
    },
})

-- Rares

ns.RegisterPoints(ns.ISLEOFDORN, {
    [22985829] = { -- Alunira
        criteria=68225,
        quest=82196,
        npc=219281,
        loot={{223270, mount=2176}},
        active={ns.conditions.Item(224025, 10), ns.conditions.Item(224026)},
        note="Get 10x {item:224025:Crackling Shard} from zone mobs, combine into {item:224026:Storm Vessel}, use to break the shield",
        vignette=6055,
        --route={16606120,23205840},
    },
    [72043881] = { -- Tephratennae
        criteria=68229,
        quest=81923,
        npc=221126,
        -- tameable=true, -- wasp
        vignette=6112,
    },
    [57003460] = { -- Warphorn
        criteria=68213,
        quest=81894,
        npc=219263,
        loot={
            223341, -- Warphorn's Resilient Mane
            223342, -- Warphorn's Resilient Chestplate
            223343, -- Warphorn's Resilient Chainmail
            223344, -- Warphorn's Resilient Vest
        },
        route={57003460, 58403560, 58403680, 57803780, 56603840, 56003780, 56403660, loop=true,},
        vignette=6044,
    },
    [48202703] = { -- Kronolith, Might of the Mountain
        criteria=68220,
        quest=81902,
        npc=219270,
        vignette=6051,
    },
    [74082756] = { -- Shallowshell the Clacker
        criteria=68221,
        quest=81903,
        npc=219278,
        vignette=6052,
    },
    [41137679] = { -- Bloodmaw
        criteria=68214,
        quest=81893,
        npc=219264,
        loot={
            223349, -- Wolf Packleader's Cowl
            223350, -- Wolf Packleader's Helm
            223351, -- Wolf Packleader's Hood
            223370, -- Wolf Packleader's Visor
        },
        vignette=6045,
    },
    [58766068] = { -- Springbubble
        criteria=68212,
        quest=81892,
        npc=219262,
        loot={
            223356, -- Shoulderpads of the Steamsurger
            223357, -- Spaulders of the Steamsurger
            -- 223358, -- Mantle of the Steamsurger (name matches, but not listed?)
            223359, -- Epaulets of the Steamsurger
        },
        vignette=6043,
    },
    [62776842] = { -- Sandres the Relicbearer
        criteria=68211,
        quest=79685,
        npc=217534,
        loot={
            223376, -- Band of the Relic Bearer
        },
        vignette=6026,
    },
    [76403620] = { -- Clawbreaker K'zithix
        -- [80003500]
        criteria=68224,
        quest=81920,
        npc=221128,
        vignette=6115,
    },
    [47946014] = { -- Emperor Pitfang
        criteria=68215,
        quest=81895,
        npc=219265,
        loot={
            223345, -- Viper's Stone Grips
            223346, -- Viper's Stone Handguards
            223347, -- Viper's Stone Mitts
            223348, -- Viper's Stone Gauntlets
        },
        vignette=6046,
        note="At the bottom of the cave",
    },
    [25784503] = { -- Escaped Cutthroat
        criteria=68218,
        quest=81907,
        npc=219266,
        vignette=6049,
    },
    [73004010] = { -- Matriarch Charfuria
        criteria=68231,
        quest=81921,
        npc=220890,
        vignette=6114,
    },
    [57461625] = { -- Tempest Lord Incarnus
        criteria=68219,
        quest=81901,
        npc=219269,
        vignette=6050,
    },
    [53348006] = { -- Gar'loc
        criteria=68217,
        quest=81899,
        npc=219268,
        vignette=6048,
    },
    [57072279] = { -- Twice-Stinger the Wretched
        criteria=68222,
        quest=81904,
        npc=219271,
        -- tameable=true, -- blood beast
        vignette=6053,
    },
    [36477505] = { -- Rustul Titancap
        criteria=68210,
        quest=78619,
        npc=213115,
        loot={
            223364, -- Wristwraps of the Titancap
            223365, -- Wristguards of the Titancap
            223366, -- Bracers of the Titancap
            223367, -- Cuffs of the Titancap
        },
        vignette=5959,
        note="Wanders the quarry",
    },
    [63994055] = { -- Flamekeeper Graz
        criteria=68223,
        quest=81905,
        npc=219279,
        loot={
            221244, -- Flamekeeper's Footpads
        },
        vignette=6054,
    },
    [50876984] = { -- Plaguehart
        criteria=68216,
        quest=81897,
        npc=219267,
        loot={
            221213, -- Shawl of the Plagued
            221247, -- Cavernous Critter Shooter
        },
        --tameable=true, -- stag
        vignette=6047,
    },
    [69853847] = { -- Sweetspark the Oozeful
        criteria=68230,
        quest=81922,
        npc=220883,
        vignette=6113,
    },
    -- Violet Hold prisoners:
    -- These all technically spawn exactly at 30915238
    [29915238] = { -- Kereke
        criteria=68227,
        quest=82204,
        npc=222378,
        loot={
            226111, -- Arakkoan Ritual Staff
            226113, -- Kereke's Flourishing Sabre
        },
        vignette=6215,
        note="Violet Hold Prisoner",
    },
    [30915238] = { -- Zovex
        criteria=68226,
        quest=82203,
        npc=219284,
        loot={
            226117, -- Dalaran Guardian's Arcanotool
            226118, -- Arcane Prisoner's Puncher
            226119, -- Arcane Sharpshooter's Crossbow
        },
        vignette=6058,
        note="Violet Hold Prisoner",
    },
    [31915238] = { -- Rotfist
        criteria=68228,
        quest=82205,
        npc=222380,
        loot={
            -- Going by the name, but not currently in the drops on wowhead...
            226112, -- Rotfist Flesh Carver
        },
        vignette=6216,
        note="Violet Hold Prisoner",
    },
}, {
    achievement=40435, -- Adventurer
})

ns.RegisterPoints(ns.ISLEOFDORN, {
    [31495529] = { -- Malfunctioning Spire
        quest=81891,
        npc=220068,
        vignette=6073,
    },
    [46003180] = { -- Rowdy Rubble
        quest=81515,
        npc=220846,
        vignette=6102,
    },
    [69204960] = { -- Elusive Ironhide Maelstrom Wolf
        quest=nil,
        npc=224515,
    },
})
