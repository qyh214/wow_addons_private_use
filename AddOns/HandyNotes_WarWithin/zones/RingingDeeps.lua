local myname, ns = ...

--[[
Notes:
Rappelling anchor 47834752, trips 84585
Rappelling anchor 43911230, trips 84584
Rappelling anchor 41116860, trips 84586

awakening the machine: 5 84631, 10 84632, 15 84633, 20 84633
looting the cache afterwards: 84642 84644 84646 84647

Worldsoul memories (vignette 6358)
55726981
]]

-- Treasures

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [64334056] = { -- Webbed Knapsack
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
            213256, -- Wax Spoon
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=71,
        vignette=5994,
        nearby={64483883},
        note="In cave",
    },
    [59076311] = { -- Cursed Pickaxe
        criteria=69281,
        quest=82230,
        loot={
            224837, -- Cursed Pickaxe
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=71,
        vignette=6232,
    },
    [51871385] = { -- Munderut's Forgotten Stash
        criteria=69282,
        quest=82235,
        loot={
            212508, -- Stunning Sapphire
            212505, -- Extravagant Emerald
            212495, -- Radiant Ruby
            212498, -- Ambivalent Amber
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=71,
        vignette=6233,
    },
    [42611745] = { -- Discarded Toolbox
        criteria=69283,
        quest=82239,
        loot={
            224644, -- Lava-Forged Cogwheel
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=73,
        vignette=6235,
    },
    [61993342] = { -- Waterlogged Refuse
        criteria=69304,
        quest=83030,
        loot={
            -- various grays
            213250, 213255, 213253, 213254,
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=71,
        vignette=6356,
    },
    [55183028] = { -- Scary Dark Chest
        criteria=69307,
        quest=82818,
        loot={
            {224439, pet=4470}, -- Oop'lajax
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=71,
        vignette=6277,
    },
    [55256440] = { -- Kaja'Cola Machine
        criteria=69308,
        quest=82819,
        loot={
            220774, -- Goblin Mini Fridge
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        note="Order four drinks in the right order: Bluesberry, Orange, Oyster, Mangoro (BOOM!)",
        vignette=6241,
    },
    [45184896] = { -- Dislodged Blockage
        criteria=69311,
        quest=82820,
        loot={
            {221548, pet=4536}, -- Blightbud
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        note="Solve a sliding-tiles puzzle",
        level=71, -- can solve the puzzle, but not loot the chest
        vignette=6284,
    },
    [45933163] = { -- Dusty Prospector's Chest
        criteria=69312,
        quest=82464,
        loot={
            212495, 212505, 212508, -- some gems
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        level=71,
        note="At the back of the inn; gather the five shards first",
        related={
            [53622196] = {label="{item:223880:Rough Deepamethyst Shard}", loot={223880}, inbag=223880, color={r=1,g=0,b=1}, minimap=true,},
            [41852280] = {label="{item:223880:Rough Deepamethyst Shard}", loot={223880}, inbag=223880, color={r=1,g=0,b=1}, minimap=true,},
            [37271990] = {label="{item:223880:Rough Deepamethyst Shard}", loot={223880}, inbag=223880, color={r=1,g=0,b=1}, minimap=true,},
            --
            [55283804] = {label="{item:223881:Rough Deepemerald Shard}", loot={223881}, inbag=223881, color={r=0,g=1,b=0}, minimap=true,},
            [55904080] = {label="{item:223881:Rough Deepemerald Shard}", loot={223881}, inbag=223881, color={r=0,g=1,b=0}, minimap=true,},
            --
            [63865316] = {label="{item:223882:Rough Deepdiamond Shard}", loot={223882}, inbag=223882, color={r=0,g=0,b=1}, minimap=true,},
            [63024770] = {label="{item:223882:Rough Deepdiamond Shard}", loot={223882}, inbag=223882, color={r=0,g=0,b=1}, minimap=true,},
            --
            [53774943] = {label="{item:223878:Rough Deepruby Shard}", loot={223878}, inbag=223878, color={r=1,g=0,b=0}, minimap=true,},
            [56095300] = {label="{item:223878:Rough Deepruby Shard}", loot={223878}, inbag=223878, color={r=1,g=0,b=0}, minimap=true,},
            --
            [58566313] = {label="{item:223879:Rough Deeptopaz Shard}", loot={223879}, inbag=223879, color={r=1,g=1,b=0}, minimap=true,},
            [62836310] = {label="{item:223879:Rough Deeptopaz Shard}", loot={223879}, inbag=223879, color={r=1,g=1,b=0}, minimap=true,},
            [55509417] = {label="{item:223879:Rough Deeptopaz Shard}", loot={223879}, inbag=223879, color={r=1,g=1,b=0}, minimap=true,},
        },
        vignette=6286,
    },
    [48775327] = { -- Forgotten Treasure (this is the entrance, actually at 47275349)
        criteria=69313,
        quest=80485, -- chests: 80488, 80489, 80490, 80487
        loot={
            {224783, toy=true}, -- Sovereign's Finery chest
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        note="Cave behind the waterfall; open chests until you find the key",
        level=71,
        vignette=6074,
    },
}, {
    achievement=40724
})

-- Not So Quick Fix
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [42424644] = {criteria=68658, quest=83475, note="By the stairs"}, -- Water Console
    [55249330] = {criteria=68659, quest=83479, note="In the building"}, -- Abyssal Console
    [59656110] = {criteria=68660, quest=83480, note="On the bridge"}, -- Taelloch Console
    [64704880] = {criteria=68661, quest=83481}, -- Obsidian Console
    [52802250] = {criteria=68662, quest=83482}, -- Lost Console
    [43351409] = {criteria=68663, quest=83483}, -- Earthen Console
}, {
    achievement=40473,
    atlas="mechagon-projects",
    minimap=true,
})

-- Rocked to Sleep
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45447065] = {criteria=68690}, -- Alfritha
    [58863637] = {criteria=68684, note="Up on the ledge"}, -- Attwogaz
    [61258379] = {criteria=68691, note="Up on the ledge"}, -- Gundrig
    [41531354] = {criteria=68682}, -- Hathlaz
    [40394087] = {criteria=68685}, -- Krattdaz
    [55439371] = {criteria=68688, note="Up on the pipes"}, -- Merunth
    [59985573] = {criteria=68692}, -- Sathilga
    [51543023] = {criteria=68686, note="Up on the ledge"}, -- Uisgaz
    [46244904] = {criteria=68689}, -- Varerko
    [45493178] = {criteria=68687, note="By the pipes above the inn"}, -- Venedaz
}, {
    achievement=40504,
    atlas="reagents", color={r=0.5, g=1, b=1},
    minimap=true,
})

-- Notable Machines
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [42972880] = {criteria=68991}, -- Notes On The Machine Speakers: Fragment I
    [45822593] = {criteria=68992}, -- Notes On The Machine Speakers: Fragment II
    [47821448] = {criteria=68993}, -- Notes On The Machine Speakers: Fragment III
    [37352099] = {criteria=68994, note="Up on the scaffolding"}, -- Notes On The Machine Speakers: Fragment IV
    [59655878] = {criteria=68995, note="Up on the arch"}, -- Notes On The Machine Speakers: Fragment V
    [60967955] = {criteria=68996}, -- Notes On The Machine Speakers: Fragment VI
}, {
    achievement=40628,
    texture=ns.atlas_texture("profession", {r=0, g=1, b=1}),
    minimap=true,
})

-- Gobblin' with Glublurb
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [41515024] = {
        label="{npc:227132:Glublurb}",
        texture=ns.atlas_texture("BuildanAbomination-32x32", {r=0, g=1, b=1}),
        note="Get {spell:456739:Etheral Vision} from a Glimmering Crystal, then go to the pond to the northwest of it to find a {npc:227138:Ethereal Glimmerling}, and bring it here",
        route={
            41485020, 54653360, 56094110,
            highlightOnly=true, r=1, g=0, b=1,
        },
    },
    [54653360] = {
        label="{npc:227138:Ethereal Glimmerling}",
        active=ns.conditions.AuraActive(456739), -- Essence of Awakening
        atlas="Vehicle-TempleofKotmogu-PurpleBall",
        note="Take this to {npc:227132:Glublurb}; {spell:456739:Etheral Vision} only lasts 5 minutes, but can be refilled from the crystals",
        route=41485020,
    },
    [56134100] = {
        label="Glimmering Crystal",
        spell=456739, -- Ethereal Vision
        texture=ns.atlas_texture("keyflameon-32x32", {r=0, g=0.5, b=1}),
        note="Get {spell:456739:Etheral Vision}, then go to the pond to the northwest to find a {npc:227138:Ethereal Glimmerling}",
        route=41485020,
    },
}, {
    achievement=40614,
    quest=83623,
    minimap=true,
})

-- To All the Slimes I Love
ns.RegisterPoints(ns.RINGINGDEEPS, {
    [54876920] = {criteria=68670, --[[npc=226626--]]}, -- Spring Mole
    [48321660] = {criteria=68673, --[[npc=217756--]]}, -- Snake
    [59745010] = {criteria=68673, --[[npc=217756--]]}, -- Snake
    [60493380] = {criteria=68674, --[[npc=220173--]]}, -- Lightdarter
    [42143100] = {criteria=68674, --[[npc=220173--]]}, -- Lightdarter
    [50945080] = {criteria=68674, --[[npc=220173--]]}, -- Lightdarter
    [57497520] = {criteria=68674, --[[npc=220173--]]}, -- Lightdarter
    [49255340] = {criteria=68676, --[[npc=221146--]]}, -- Tiny Sporbit
    [39891500] = {criteria=68677, --[[npc=220369--]]}, -- Dustcrawler Beetle
    [45511740] = {criteria=68677, --[[npc=220369--]]}, -- Dustcrawler Beetle
    [41202880] = {criteria=68677, --[[npc=220369--]]}, -- Dustcrawler Beetle
    [58624140] = {criteria=68677, --[[npc=220369--]]}, -- Dustcrawler Beetle
    [57687300] = {criteria=68677, --[[npc=220369--]]}, -- Dustcrawler Beetle
    [51873560] = {criteria=68677, --[[npc=220369--]]}, -- Dustcrawler Beetle
    [57308580] = {criteria=68675, --[[npc=219585--]]}, -- Mass of Worms
    [51506960] = {criteria=68731, --[[npc=217461--]]}, -- Grottoscale Hatchling
    [54122440] = {criteria=68729, --[[npc=220177--]]}, -- Crackcreeper
    [45691560] = {criteria=68730, --[[npc=214726--]]}, -- Lava Slug
    [45511760] = {criteria=68732, --[[npc=220370--]]}, -- Earthenwork Stoneskitterer
    [67044200] = {criteria=68733, --[[npc=223663--]]}, -- Cavern Skiplet
    [52446940] = {criteria=68734, --[[npc=217316--]]}, -- Moss Sludglet
    [56936960] = {criteria=68747, --[[npc=219366--]]}, -- Cavern Mote
    [57873960] = {criteria=68747, --[[npc=219366--]]}, -- Cavern Mote
    [40821220] = {criteria=68747, --[[npc=219366--]]}, -- Cavern Mote
    [60683300] = {criteria=68748, --[[npc=220168--]]}, -- Stumblegrub
    [50193220] = {criteria=69805, --[[npc=219842--]]}, -- Darkgrotto Hopper
    [61613920] = {criteria=68749, --[[npc=220413--]]}, -- Oozeling
    [53755080] = {criteria=68750, --[[npc=217559--]]}, -- Pebble Scarab
    [48501120] = {criteria=68751, --[[npc=216058--]]}, -- Rock Snail
    [59185120] = {criteria=68751, --[[npc=216058--]]}, -- Rock Snail
}, {
    achievement=40475,
    texture=ns.atlas_texture("delves-scenario-heart-icon", nil, 0, 0.9, 0, 0.9),
    note=EMOTE152_CMD1 .. "\nCoords are approximate, these are critters that spawn in this general area", -- /love
})

-- Rares

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [49241991] = { -- Automaxor
        criteria=69634,
        quest=81674, -- 84046
        npc=220265,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84046}),
            221218, -- Reinforced Construct's Greaves
            221238, -- Pillar of Constructs
        },
        vignette=6128,
    },
    [38731692] = { -- Charmonger
        criteria=69632,
        quest=81562, -- 84044
        npc=220267,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84044}),
            221209, -- Flame Trader's Gloves
            221249, -- Kobold Rodent Squasher
        },
        vignette=6104,
    },
    [40053508] = { -- King Splash
        criteria=69624,
        quest=80547,
        npc=220275,
        loot={
            223352, -- Waterskipper's Legplates
            223353, -- Waterskipper's Trousers
            223354, -- Waterskipper's Chain Leggings
            223355, -- Waterskipper's Leggings
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        --tameable=true, -- hopper
        vignette=6088,
    },
    [61802840] = { -- Candleflyer Captain
        criteria=69623,
        quest=80505,
        npc=220276,
        loot={
            223360, -- Flying Kobold's Seatbelt (plate)
            223361, -- Flying Kobold's Seatbelt (cloth)
            223362, -- Flying Kobold's Seatbelt (mail)
            223363, -- Flying Kobold's Seatbelt (leather)
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        note="Patrols the area",
        vignette=6080,
    },
    [47624651] = { -- Cragmund
        criteria=69630,
        quest=80560, -- 84042
        npc=220269,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84042}),
            221205, -- Vest of the River
            221254, -- Earthshatter Lance
            221507, -- Earth Golem's Wrap
        },
        vignette=6090,
    },
    [51560843] = { -- Deepflayer Broodmother
        criteria=69636,
        quest=80536, -- 85162
        npc=220286,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=85162}),
            221254, -- Earthshatter Lance
            221507, -- Earth Golem's Wrap
            225999, -- Earthen Adventurer's Tabard
        },
        note="Flys around anticlockwise",
        route={
            51560843, 49630880, 46410836, 45991007, 42410955, 41000822, 39940871, 41410973, 41511083, 42281312,
            40421750, 45581919, 49652244, 50331761, 52521023,
            loop=true,
        },
        vignette=6082,
    },
    [46406619] = { -- Aquellion
        criteria=69625,
        quest=80557,
        npc=220274,
        loot={
            223340, -- Footguards of Shallow Waters
            223371, -- Slippers of Shallow Waters
            223372, -- Sabatons of Shallow Waters
            223373, -- Treads of Shallow Waters
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        vignette=6089,
    },
    [48712657] = { -- Zilthara
        criteria=69629,
        quest=80506, -- 84041
        npc=220270,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84041}),
            221220, -- Basilisk Scale Pauldrons
            221246, -- Fierce Beast Staff
            221247, -- Cavernous Critter Shooter
            221251, -- Bestial Underground Cleaver
            221265, -- Charm of the Underground Beast
        },
        vignette=6079,
    },
    [54213813] = { -- Coalesced Monstrosity
        criteria=69633,
        quest=81511, -- 84045
        npc=220266,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84045}),
            221226, -- Voidtouched Waistguard
            223006, -- Signet of Dark Horizons
        },
        vignette=6101,
    },
    [43731209] = { -- Terror of the Forge
        criteria=69628,
        quest=80507, -- 84040
        npc=220271,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84040}),
            221233, -- Deephunter's Bloody Hook
            221234, -- Tidal Pendant
            221242, -- Forgeborn Helm
            221248, -- Deep Terror Carver
            221255, -- Sharpened Scalepiercer
        },
        vignette=6081,
        note="Walking in the lava",
    },
    [44214696] = { -- Kelpmire
        criteria=69635,
        quest=81485, -- 84047
        npc=220287,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84047}),
            221204, -- Spore Giant's Stompers
            221250, -- Creeping Lasher Machete
            221253, -- Cultivator's Plant Puncher
            221264, -- Fungarian Mystic's Cluster
            223005, -- String of Fungal Fruits
        },
        vignette=6099,
    },
    [53395480] = { -- Rampaging Blight
        criteria=69626,
        quest=81563,
        npc=220273,
        loot={
            223401, -- Corrupted Earthen Wristwraps
            223402, -- Corrupted Earthen Wristguards
            223403, -- Corrupted Earthen Binds
            223404, -- Corrupted Earthen Cuffs
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        vignette=6105,
    },
    [67094629] = { -- Trungal
        criteria=69631,
        quest=80574, -- 84043
        npc=220268,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84043}),
            221228, -- Infested Fungal Wristwraps
            221250, -- Creeping Lasher Machete
            221253, -- Cultivator's Plant Puncher
            221264, -- Fungarian Mystic's Cluster
            223005, -- String of Fungal Fruits
        },
        note="Kill the {npc:220615:Root of Trungal} to spawn",
        path={67914569, 68204444},
        vignette=6126,
    },
    [64054754] = { -- Spore-infused Shalewing
        criteria=69638,
        quest=81652, -- 84049
        npc=221217,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84049}),
            223918, -- Specter Stalker's Shotgun
            223919, -- Abducted Lawman's Gavel
            223942, -- Spore-Encrusted Ribbon
        },
        vignette=6121,
        note="Flies around clockwise",
        route={
            64234852, 64365012, 64305047, 63875137, 63725156, 63435171, 63235176, 62945176, 62805174, 62345120, 62024896,
            62044870, 62174840, 62014817, 61544779, 61394760, 61304737, 61364711, 61544669, 61644655, 61844644, 62684640,
            63324608, 63464620, 63764659, 63874680, 64054754,
            loop=true,
        },
    },
    [61204949] = { -- Hungerer of the Deeps
        criteria=69639,
        quest=81648, -- 84048
        npc=221199,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84048}),
            221233, -- Deephunter's Bloody Hook
            221234, -- Tidal Pendant
            221248, -- Deep Terror Carver
            221255, -- Sharpened Scalepiercer
            223949, -- Dark Depth Stompers
        },
        vignette=6119,
    },
    [62815262] = { -- Disturbed Earthgorger
        criteria=69640,
        quest=80003,
        npc=218393,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=84050}),
            221237, -- Lamentable Vagrant's Lantern
            223926, -- Earthgorger's Chain Bib
            223943, -- Cord of the Earthbreaker
        },
        note="Stand in the dust cloud and use {spell:437003:Stomp} several times",
        vignette=6031,
    },
    [62466881] = { -- Deathbound Husk
        criteria=69627,
        quest=81566,
        npc=220272,
        loot={
            223368, -- Twisted Earthen Signet
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150),
        },
        vignette=6106,
        note="In cave",
        path=62786796,
    },
    [57017682] = { -- Lurker of the Deeps
        criteria=69637,
        quest=81633, -- 85163
        npc=220285,
        loot={
            ns.rewards.Currency(ns.CURRENCY_ASSEMBLY, 150, {quest=85163}),
            {223501, mount=2205}, -- Regurgitated Mole Reins
            221233, -- Deephunter's Bloody Hook
            221234, -- Tidal Pendant
            221248, -- Deep Terror Carver
            221255, -- Sharpened Scalepiercer
        },
        vignette=6110,
        note="Pull 5 levers across the zone at the same time to summon; they stay activated for ~10 seconds, so you'll need a group",
        related={
            [46320882] = {label="Inconspicuous Lever", note="Pull all 5 levers simultaneously to summon {npc:220285:Lurker of the Deeps}"},
            [50482530] = {label="Inconspicuous Lever", note="Pull all 5 levers simultaneously to summon {npc:220285:Lurker of the Deeps}"},
            [53942358] = {label="Inconspicuous Lever", note="Pull all 5 levers simultaneously to summon {npc:220285:Lurker of the Deeps}"},
            [55319239] = {label="Inconspicuous Lever", note="Pull all 5 levers simultaneously to summon {npc:220285:Lurker of the Deeps}"},
            [58854464] = {label="Inconspicuous Lever", note="Pull all 5 levers simultaneously to summon {npc:220285:Lurker of the Deeps}"},
        },
    },
}, {
    achievement=40837, -- Adventurer
})

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [58805000] = { -- Slatefang
        quest=nil,
        npc=228439,
        requires=ns.conditions.Profession(ns.PROF_WW_SKINNING),
        active=ns.conditions.Item(219008), -- Supreme Beast Lure
    },
})
