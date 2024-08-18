local myname, ns = ...

--[[
Notes:

https://www.wowhead.com/beta/achievement=40585/super-size-snuffling
https://www.wowhead.com/beta/object=422531/disturbed-earth
Disturbed Earth, (Odd Glob of Wax 212493)
64816894, quest 84543, spawned enemy
58148698, spawned slime to bounce on
60488818, rockfall to dodge
60969336, just spawned waxy lump
62259498, spawned enemy (2229812)
57907229, spawned enemy (216250)
55773373, spawned enemy (229808)
53493438, just spawned waxy lump
45042805, fired into the air to catch waxy sprockets
43551959, waxy lump

Worldsoul memories (vignette 6358)
59516981
]]

-- Treasures

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [68704056] = { -- Webbed Knapsack
        criteria=69280,
        quest=79308,
        loot={
            213254, -- Big Gold Nugget
            213251, -- Cinderbee Wax Jar
            213250, -- Cracked Gem
            213253, -- Gilded Candle
            213255, -- Wax Canary
            213252, -- Stolen Earthen Contraption
            213257, -- Wax Shovel
        },
        level=71,
        vignette=5994,
        nearby={68863883},
        note="In cave",
    },
    [63086311] = { -- Cursed Pickaxe
        criteria=69281,
        quest=82230,
        loot={224837}, -- Cursed Pickaxe
        level=71,
        vignette=6232,
    },
    [55401385] = { -- Munderut's Forgotten Stash
        criteria=69282,
        quest=82235,
        loot={212498}, -- Ambivalent Amber + commendations
        level=71,
        vignette=6233,
    },
    [45511745] = { -- Discarded Toolbox
        criteria=69283,
        quest=82239,
        loot={224644}, -- Lava-Forged Cogwhee
        level=73,
        vignette=6235,
    },
    [66203342] = { -- Waterlogged Refuse
        criteria=69304,
        quest=83030,
        loot={213250, 213255, 213253, 213254}, -- various grays
        level=71,
        vignette=6356,
    },
    [58933028] = { -- Scary Dark Chest
        criteria=69307,
        quest=82818,
        loot={{224439, pet=4470}}, -- Oop'lajax
        level=71,
        vignette=6277,
    },
    [59016440] = { -- Kaja'Cola Machine
        criteria=69308,
        quest=82819,
        loot={220774}, -- Goblin Mini Fridge
        note="Order four drinks in the right order: Bluesberry, Orange, Oyster, Mangoro (BOOM!)",
        vignette=6241,
    },
    [48254896] = { -- Dislodged Blockage
        criteria=69311,
        quest=82820,
        loot={{221548, pet=4536}}, -- Blightbud
        note="Solve a sliding-tiles puzzle",
        level=71, -- can solve the puzzle, but not loot the chest
        vignette=6284,
    },
    [49053163] = { -- Dusty Prospector's Chest
        criteria=69312,
        quest=82464,
        loot={212495, 212505, 212508}, -- some gems
        level=71,
        note="At the back of the inn; gather the five shards first",
        related={
            [57272196] = {label="{item:223880:Rough Deepamethyst Shard}", loot={223880}, inbag=223880, color={r=1,g=0,b=1}, minimap=true,},
            [59043804] = {label="{item:223881:Rough Deepemerald Shard}", loot={223881}, inbag=223881, color={r=0,g=1,b=0}, minimap=true,},
            [68205316] = {label="{item:223882:Rough Deepdiamond Shard}", loot={223882}, inbag=223882, color={r=0,g=0,b=1}, minimap=true,},
            [57434943] = {label="{item:223878:Rough Deepruby Shard}", loot={223878}, inbag=223878, color={r=1,g=0,b=0}, minimap=true,},
            [62546313] = {label="{item:223879:Rough Deeptopaz Shard}", loot={223879}, inbag=223879, color={r=0,g=1,b=1}, minimap=true,},
        },
        vignette=6286,
    },
    [52085327] = { -- Forgotten Treasure (this is the entrance, actually at 50485349)
        criteria=69313,
        quest=80485, -- chests: 80488, 80489, 80490, 80487
        loot={{224783, toy=true}},
        note="Cave behind the waterfall; open chests until you find the key",
        level=71,
        vignette=6074,
    },
}, {
    achievement=40724
})

-- Not So Quick Fix
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45304644] = {criteria=68658, quest=83475, note="By the stairs"}, -- Water Console
    [59009330] = {criteria=68659, quest=83479, note="In the building"}, -- Abyssal Console
    [63706110] = {criteria=68660, quest=83480, note="On the bridge"}, -- Taelloch Console
    [69104880] = {criteria=68661, quest=83481}, -- Obsidian Console
    [56392250] = {criteria=68662, quest=83482}, -- Lost Console
    [46301409] = {criteria=68663, quest=83483}, -- Earthen Console
}, {
    achievement=40473,
    atlas="mechagon-projects",
    minimap=true,
})

-- Rocked to Sleep
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [48537065] = {criteria=68690}, -- Alfritha
    [62863637] = {criteria=68684, note="Up on the ledge"}, -- Attwogaz
    [65418379] = {criteria=68691, note="Up on the ledge"}, -- Gundrig
    [44351354] = {criteria=68682}, -- Hathlaz
    [43144087] = {criteria=68685}, -- Krattdaz
    [59209371] = {criteria=68688, note="Up on the pipes"}, -- Merunth
    [64065573] = {criteria=68692}, -- Sathilga
    [55043023] = {criteria=68686, note="Up on the ledge"}, -- Uisgaz
    [49384904] = {criteria=68689}, -- Varerko
    [48583178] = {criteria=68687, note="By the pipes above the inn"}, -- Venedaz
}, {
    achievement=40504,
    atlas="reagents", color={r=0.5, g=1, b=1},
    minimap=true,
})

-- Notable Machines
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45892880] = {criteria=68991}, -- Notes On The Machine Speakers: Fragment I
    [48932593] = {criteria=68992}, -- Notes On The Machine Speakers: Fragment II
    [51071448] = {criteria=68993}, -- Notes On The Machine Speakers: Fragment III
    [39892099] = {criteria=68994, note="Up on the scaffolding"}, -- Notes On The Machine Speakers: Fragment IV
    [63705878] = {criteria=68995}, -- Notes On The Machine Speakers: Fragment V
    [65107955] = {criteria=68996}, -- Notes On The Machine Speakers: Fragment VI
}, {
    achievement=40628,
    texture=ns.atlas_texture("profession", {r=0, g=1, b=1}),
    minimap=true,
})

-- Rares

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [52591991] = { -- Automaxor
        criteria=69634,
        quest=81674,
        npc=220265,
        vignette=6128,
    },
    [41361692] = { -- Charmonger
        -- wowhead says 60802540 too
        criteria=69632,
        quest=81562,
        npc=220267,
        vignette=6104,
    },
    [42773508] = { -- King Splash
        criteria=69624,
        quest=80547,
        npc=220275,
        loot={
            223352, -- Waterskipper's Legplates
            223353, -- Waterskipper's Trousers
            223354, -- Waterskipper's Chain Leggings
            223355, -- Waterskipper's Leggings
        },
        --tameable=true, -- hopper
        vignette=6088,
    },
    [66002840] = { -- Candleflyer Captain
        criteria=69623,
        quest=80505,
        npc=220276,
        loot={
            223360, -- Flying Kobold's Seatbelt (plate)
            223361, -- Flying Kobold's Seatbelt (cloth)
            223362, -- Flying Kobold's Seatbelt (mail)
            223363, -- Flying Kobold's Seatbelt (leather)
        },
        note="Patrols the area",
        vignette=6080,
    },
    [50864651] = { -- Cragmund
        criteria=69630,
        quest=80560, -- 84042?
        npc=220269,
        loot={
            221205, -- Vest of the River
        },
        vignette=6090,
    },
    [55060843] = { -- Deepflayer Broodmother
        criteria=69636,
        quest=  80536,
        npc=220286,
        note="Flys around anticlockwise",
        route={
            55060843, 53000880, 49560836, 49121007, 45290955, 43790822, 42650871, 44220973, 44331083, 45151312,
            43171750, 48681919, 53022244, 53751761, 56091023,
            loop=true,
        },
        vignette=6082,
    },
    [49556619] = { -- Aquellion
        criteria=69625,
        quest=80557,
        npc=220274,
        loot={
            223340, -- Footguards of Shallow Waters
            223371, -- Slippers of Shallow Waters
            223372, -- Sabatons of Shallow Waters
            223373, -- Treads of Shallow Waters
        },
        vignette=6089,
    },
    [52022657] = { -- Zilthara
        criteria=69629,
        quest=80506,
        npc=220270,
        vignette=6079,
    },
    [57903813] = { -- Coalesced Monstrosity
        criteria=69633,
        quest=81511,
        npc=220266,
        vignette=6101,
    },
    [46701209] = { -- Terror of the Forge
        criteria=69628,
        quest=80507,
        npc=220271,
        vignette=6081,
        note="Walking in the lava",
    },
    [47074696] = { -- Kelpmire
        criteria=69635,
        quest=81485,
        npc=220287,
        vignette=6099,
    },
    [57025480] = { -- Rampaging Blight
        criteria=69626,
        quest=81563,
        npc=220273,
        loot={
            223401, -- Corrupted Earthen Wristwraps
            223402, -- Corrupted Earthen Wristguards
            223403, -- Corrupted Earthen Binds
            223404, -- Corrupted Earthen Cuffs
        },
        vignette=6105,
    },
    [71654629] = { -- Trungal
        criteria=69631,
        quest=80574,
        npc=220268,
        note="Kill the {npc:220615:Root of Trungal} to spawn",
        path={72534569, 72844444},
        vignette=6126,
    },
    [68224378] = { -- Spore-infused Shalewing
        criteria=69638,
        quest=81652,
        npc=221217,
        vignette=6121,
        note="Flies around",
    },
    [65364949] = { -- Hungerer of the Deeps
        criteria=69639,
        quest=81648,
        npc=221199,
        vignette=6119,
    },
    [67085262] = { -- Disturbed Earthgorger
        criteria=69640,
        quest=80003,
        npc=218393,
        vignette=6031,
    },
    [66716881] = { -- Deathbound Husk
        criteria=69627,
        quest=81566,
        npc=220272,
        loot={
            223368, -- Twisted Earthen Signet
        },
        vignette=6106,
        note="In cave",
        path=67056796,
    },
    [12009000] = { -- Lurker of the Deeps
        criteria=69637,
        quest=81633,
        npc=220285,
        vignette=6110,
        note="UNKNOWN LOCATION",
    },
}, {
    achievement=40837, -- Adventurer
})
