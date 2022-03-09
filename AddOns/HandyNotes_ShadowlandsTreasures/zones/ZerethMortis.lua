local myname, ns = ...

local path = ns.path

ns.groups["puzzlecache"] = "Caches of Creation"
ns.groups["lostovoid"] = "{item:190239}"

-- Note to self: first Pocopoc costume unlock gets 65531
-- wicked pocopoc: 65530 (but not really point-friendly)
-- gravid repose, interior locus arrangement 65330

local MOUNT = "|A:StableMaster:15:15|a"
local PET = "|A:WildBattlePetCapturable:15:15|a"

-- Treasures of Zerith Mortis
ns.RegisterPoints(1970, { -- Zereth Mortis
    [61153710] = { -- Architect's Reserve
        quest=65520,
        active={ns.conditions.GarrisonTalent(1931), ns.conditions.QuestComplete(65427)},
        achievement=15331, criteria=53053,
        -- achievement=15508, criteria=53290, -- Fashion of the First Ones
        loot={
            {187833, quest=65528}, -- Dapper Pocopoc
        },
        note="Unlocked by completing Pilgrim's Grace quests: {quest:64829} from {npc:180630} and {quest:65426} from {npc:181273}",
    },

    [47459525] = { -- Bushel of Progenitor Produce
        quest=65573,
        achievement=15331, criteria=53071,
        -- achievement=15508, criteria=53286, -- Fashion of the First Ones
        loot={
            {190853, toy=true}, -- Bushel of Mysterious Fruit
            {189451, quest=65524}, -- Chef Pocopoc
        },
        note="Kill a {npc:182368} to the north with {spell:360945} to get {spell:360945} yourself. Kill more to get 5 stacks, then open the door.",
    },

    [56756415] = { -- Crushed Supply Crate
        quest=65489,
        achievement=15331, criteria=53054,
        note="Get {item:189767} from the pillar above the crate, give to {npc:185151} nearby for a {item:189768}, break the rocks",
    },

    [38253725] = { -- Damaged Jiro Stash
        quest=64667,
        achievement=15331, criteria=52965,
        loot={
            190637, -- Percussive Maintenance Instrument
        },
    },

    [60001800] = { -- Domination Cache
        quest=65468,
        achievement=15331, criteria=53018,
        active=ns.conditions.Item(189704),
        loot={
            190638, -- Tormented Mawsteel Greatsword
            189863, -- Spatial Opener
        },
        note="{item:189704} drops from {npc:181403} and {npc:182426} nearby",
    },

    [35157020] = { -- Drowned Broker Supplies
        quest=65523,
        achievement=15331, criteria=53061,
        -- achievement=15508, criteria=53288, -- Fashion of the First Ones
        active=ns.conditions.GarrisonTalent(1932),
        loot={
            {190059, quest=65526}, -- Pirate Pocopoc
        },
        note="Have {npc:181059} use the {npc:185282} nearby",
    },

    [51550990] = { -- Fallen Vault
        quest=65487,
        achievement=15331, criteria=53016,
        loot={
            189863, -- Spatial Opener
        }
    },

    [49758725] = { -- Filched Artifact
        quest=65503,
        achievement=15331, criteria=53052,
        loot={
            189863, -- Spatial Opener
        },
        note="Jump up the spheres",
    },

    [67006935] = { -- Forgotten Proto-Vault
        quest=65178,
        achievement=15331, criteria=52967,
        requires_worldquest=65089,
        loot={
            {189469, quest=65393, note=MOUNT}, -- Schematic: Prototype Leaper
        },
        note="Only reachable during the {quest:65089} world quest",
    },

    [38957320] = { -- Gnawed Valise
        quest=65480,
        achievement=15331, criteria=53017,
        loot={
            188054, -- Antecedent Drape (shared, but really high droprate here)
        },
        note="Fly, or try jumping from the top of the Cradle of Nascence. You'll probably need a glider, though.",
    },

    [37157830] = { -- Grateful Boon
        quest=65545,
        achievement=15331, criteria=53066,
        loot={
            {189478, quest=65401, note=MOUNT}, -- Schematic: Adorned Vombata
        },
        note="Needs flying or movement abilities to reach. Soothe 12 creatures nearby, {npc:185293} will give you the reward",
    },

    [58857705] = { -- Library Vault
        quest=65173,
        achievement=15331, criteria=52887,
        loot={
            {189447, quest=65360, note=MOUNT}, -- Schematic: Viperid Menace
        },
        note="In cave. Use tablets to find the correct {spell:362062} buff to make the chest appear",
    },
    [59258145] = path{quest=65173, achievement=15331, criteria=52887,},

    [60603055] = { -- Mawsworn Cache
        quest=65441,
        achievement=15331, criteria=52969,
        loot={
            {189456, quest=65379, note=MOUNT},-- Schematic: Sundered Zerethsteed
        },
    },

    [34805605] = { -- Offering to the First Ones
        quest=65537,
        achievement=15331, criteria=53062,
        loot={
            190339, -- Enlightened Offering
        },
    },

    [35254410] = { -- Overgrown Protofruit
        quest=65536,
        achievement=15331, criteria=53056,
        loot={
            190953, -- Protofruit Flesh
        },
    },

    [60854295] = { -- Pilfered Curio
        quest=65542,
        achievement=15331, criteria=53064,
        -- achievement=15508, criteria=53294, -- Fashion of the First Ones
        loot={
            {190098, quest=65538}, -- Pepepec
        },
        note="On top of the pillar, you'll need flying",
    },

    [52557145] = { -- Protoflora Harvester
        quest=65546,
        achievement=15331, criteria=53067,
        loot={
            190952, -- Protoflora Harvester
        },
    },

    [46653095] = { -- Protomineral Extractor
        quest=65540,
        achievement=15331, criteria=53063,
        active=ns.conditions.QuestComplete(64889), -- Match Made in Zereth Mortis
        loot={
            190942, -- Protomineral Extractor
        },
    },

    [37906520] = { -- Stolen Relic
        quest=65447,
        achievement=15331, criteria=52970,
        note="Jump up the spheres",
    },

    [34056765] = { -- Stolen Scroll
        quest=65543,
        achievement=15331, criteria=53065,
        loot={
            189863, -- Spatial Opener
        },
        note="Climb the Slumbering Vault and jump over",
    },

    [58707300] = { -- Submerged Chest
        quest=64545,
        achievement=15331, criteria=52964,
        -- achievement=15508, criteria=53291, -- Fashion of the First Ones
        loot={
            {190061, quest=65529}, -- Admiral Pocopoc
            189863, -- Spatial Opener
        },
        note="Use the Dangerous Orb of Power to the south then the Forgotten Pump to raise the treasure",
    },
    [59407685] = {
        label="Dangerous Orb of Power",
        quest=64545, achievement=15331, criteria=52964,
        texture=ns.atlas_texture("playerpartyblip", {r=0.7,g=0,b=0,a=1,scale=0.8}),
        minimap=true,
        note="Take north to the Forgotten Pump",
    },

    [52606295] = { -- Symphonic Vault
        quest=65270,
        achievement=15331, criteria=52968,
        loot={
            189863, -- Spatial Opener
        },
        note="Interact with {npc:183998} to learn the order, then use the {npc:183952}s to play the sounds.\n"..
            "Order is probably: SW, NE, SW, NW, NE.",
    },

    [58704280] = { -- Template Archive
        quest=65175,
        achievement=15331, criteria=52966,
        -- achievement=15508, criteria=53289, -- Fashion of the First Ones
        loot={
            {190060, quest=65527}, -- Adventurous Pocopoc
        },
        note="Inside the Nexus of Actualization",
    },
})

ns.RegisterPoints(1970, {
    [77555820] = { -- Syntactic Vault
        quest=65565, -- 65670 is when you unlock it
        achievement=15331, criteria=53068,
        active=ns.conditions.QuestComplete(64844), -- The Pilgrimage Ends (campaign chapter 4)
        loot={
            {190457, toy=true}, -- Protopological Cube
        },
        note="In a cave. Find all six runic syllables before their {spell:367499} buff runs out to unlock the vault.",
    },
})
ns.RegisterPoints(1970, {
    [78065339] = {label="Runic Syllable", note="Under the platform between waterfalls"},
    [76924667] = {label="Runic Syllable"},
    [78214795] = path{label="Path to Runic Syllable",route={78214795,80904790,81265045,r=1,g=0,b=1}},
    [81265045] = {label="Runic Syllable", note="Behind the Sepulcher's North side"},
    [78255917] = path{label="Path to Runic Syllable",route={78255917,80005810,80935626,r=1,g=0,b=1}},
    [80935626] = {label="Runic Syllable", note="Behind the Sepulcher's South side"},
    [77056032] = {label="Runic Syllable"},
    [76995879] = {label="Runic Syllable", note="In a cave"},
    [76315959] = path{label="Cave Entrance",route={76315959,76995879,r=1,g=0,b=1}}, -- also to the vault
}, {
    quest=65565,
    achievement=15331, criteria=53068,
    hide_before=ns.conditions.QuestComplete(64844), -- The Pilgrimage Ends (campaign chapter 4)
    atlas="Rune-09-light",
    minimap=true,
    note="Find all six runic syllables before their {spell:367499} buff runs out to unlock the Syntactic Vault."
})

-- Just the Ovoids...
ns.RegisterPoints(1970, {
    [53557225] = { -- Mistaken Ovoid
        quest=65522, -- 65524 also trips for when you place the eggs
        achievement=15331, criteria=53060,
        active=ns.conditions.Item(190239, 5),
        loot={
            {189435, quest=65333, note=PET}, -- Schematic: Multichicken
        },
        note="Inside the cave, under the {npc:185280}.",
    },
})
ns.RegisterPoints(1970, {
    -- Lost Ovoids
    -- https://ptr.wowhead.com/object=375411/mistaken-ovoid#comments:id=5299055
    [34316656] = {quest=65522,achievement=15331,criteria=53060},
    [33964576] = {quest=65522,achievement=15331,criteria=53060,note="In a cave."},
    [34204869] = {quest=65522,achievement=15331,criteria=53060,note="In a cave."},
    [34494976] = {quest=65522,achievement=15331,criteria=53060,note="In a cave."},
    [35204889] = {quest=65522,achievement=15331,criteria=53060,note="In a cave."},
    [34676925] = {quest=65522,achievement=15331,criteria=53060},
    [35974620] = {quest=65522,achievement=15331,criteria=53060},
    [36735967] = {quest=65522,achievement=15331,criteria=53060},
    [39345098] = {quest=65522,achievement=15331,criteria=53060},
    [41386931] = {quest=65522,achievement=15331,criteria=53060},
    [41855715] = {quest=65522,achievement=15331,criteria=53060},
    [43228490] = {quest=65522,achievement=15331,criteria=53060},
    [44565985] = {quest=65522,achievement=15331,criteria=53060},
    [44755183] = {quest=65522,achievement=15331,criteria=53060},
    [46686301] = {quest=65522,achievement=15331,criteria=53060},
    [48157357] = {quest=65522,achievement=15331,criteria=53060},
    [49187153] = {quest=65522,achievement=15331,criteria=53060},
    [50807081] = {quest=65522,achievement=15331,criteria=53060},
    [52427364] = {quest=65522,achievement=15331,criteria=53060},
    [53836486] = {quest=65522,achievement=15331,criteria=53060},
    [55207685] = {quest=65522,achievement=15331,criteria=53060},
    [55986879] = {quest=65522,achievement=15331,criteria=53060},
    [58916831] = {quest=65522,achievement=15331,criteria=53060},
    [60847592] = {quest=65522,achievement=15331,criteria=53060},
    [61076515] = {quest=65522,achievement=15331,criteria=53060},
}, {
    quest=65522,
    achievement=15331, criteria=53060,
    label="{item:190239}",
    texture=ns.atlas_texture("playerpartyblip", {r=0.6,g=0.6,b=0.1,a=1,scale=0.8}),
    minimap=true,
    found=ns.conditions.Item(190239, 5),
    group="lostovoid",
    note="Find 5x {item:190239} around the zone and take them to the {npc:185280}. There's a lot of spawn points and they vanish after someone loots them. You're looking for a small brown lump with no sparkles.",
})

local protopear = { -- Ripened Protopear
    quest=65566,
    active=ns.conditions.GarrisonTalent(1931),
    achievement=15331, criteria=53069,
    -- achievement=15508, criteria=53287, -- Fashion of the First Ones
    loot={
        {190058, quest=65525}, -- Peaceful Pocopoc
    },
    note="Bring {spell:367180} from the green clouds to the {npc:185416} inside the Blooming Foundry",
}
ns.RegisterPoints(2027, { -- Blooming Foundry
    [65655025] = protopear,
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [63717374] = protopear,
})

ns.RegisterPoints(2030, { -- Nexus of Actualization
    [51618820] = { -- Template Archive
        quest=65175,
        achievement=15331, criteria=52966,
        -- achievement=15508, criteria=53289, -- Fashion of the First Ones
        loot={
            {190060, quest=65527}, -- Adventurous Pocopoc
        },
        route={72024882, 63855973},
        note="Push the orb",
    },
})

local lock = ns.nodeMaker{
    label="{npc:185390}",
    achievement=15331, criteria=53070,
    atlas="warfronts-basemapicons-empty-workshop-minimap",
    minimap=true,
}
ns.RegisterPoints(2066, { -- Catalyst Wards
    [49253440] = { -- Undulating Foliage
        quest=65572,
        achievement=15331, criteria=53070,
        loot={
            {190926, toy=true}, -- Infested Automa Core
            189863, -- Spatial Opener
        },
        note="Activate the four {npc:185390} to activate the teleporter in the main room.",
    },
    -- TODO: ...per-lock questids?
    [39406900] = lock{quest=65589},
    [60208720] = lock{quest=65590},
    [69755245] = lock{quest=65591},
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [49657785] = path{quest=65572, achievement=15331, criteria=53070, note="Activate the four {npc:185390} to open the barrier."},
    [50007665] = lock{quest=65592},
})

-- Miscellaneous treasures

ns.RegisterPoints(1970, { -- Zereth Mortis
    [46003900] = {
        quest=nil,
        label="Torn Ethereal Drape",
        active={ns.conditions.GarrisonTalent(1902),ns.conditions.QuestComplete(65328)},
    },
    [42005185] = {
        quest=65183,
        label="Provis Cache",
        active=ns.conditions.Item(188231),
        note="Use {item:187908} to get 15x {item:187728}, which will sometimes give you the {item:188231}",
    },
})

ns.RegisterPoints(1970, { -- Zereth Mortis
    -- Prying Eye Discovery
    [34354430] = {},
    [35254370] = {},
    [48006640] = {},
    [51757790] = {},
}, {
    quest=65184,
    label="Prying Eye Discovery",
    -- achievement=15508, criteria=53293, -- Fashion of the First Ones
    note="Multiple spawn points; might be easier once you can fly",
    loot={
        {190096, quest=65534}, -- Pocobold
    },
})

ns.RegisterPoints(1970, { -- Zereth Mortis
    -- Pulp-Covered Relic
    [41903400] = {},
    [50304120] = {},
    [52804580] = {},
    [53402570] = {},
    [64356345] = {},
}, {
    quest=65501,
    label="Pulp-Covered Relic",
    note="Multiple spawn points",
    loot={
        {189474, quest=65397, note=MOUNT}, -- Schematic: Buzz
    },
})

ns.RegisterPoints(1970, { -- Zereth Mortis
    -- Sandworn Chest
    [60002585] = {},
    [60853785] = {},
    [61401765] = {},
    [63202605] = {},
    [65952695] = {},
}, {
    quest=65611,
    label="Sandworn Chest",
    active=ns.conditions.Item(190197), -- Sandworn Chest Key
    note="Multiple spawn points. Get 5x {item:190198} from nearby mobs to make {item:190197}",
    loot={
        {190734, toy=true} -- Makaris's Satchel of Mines
    },
})

ns.RegisterPoints(1970, { -- Zereth Mortis
    [61805895] = { -- Synthesis Forge
        label="{npc:184172}",
        note="Make pets here",
        texture=ns.atlas_texture("teleportationnetwork-32x32", {r=1,g=0.6,b=0.2,a=1,scale=1.2}),
        minimap=true,
        hide_before=ns.conditions.QuestComplete(65419), -- Protoform Synthesis
    },
    [68703005] = { -- Protoform Repository
        label="Protoform Repository",
        note="Make mounts here",
        texture=ns.atlas_texture("teleportationnetwork-32x32", {r=1,g=0.6,b=0.2,a=1,scale=1.2}),
        minimap=true,
        hide_before=ns.conditions.QuestComplete(65427), -- A New Architect
    },
    [61505370] = { -- Wellspring of the First Ones
        label="Wellspring of the First Ones",
        texture=ns.atlas_texture("teleportationnetwork-32x32", {r=0,g=0.8,b=0.8,a=1,scale=1}),
        minimap=true,
        hide_before=ns.conditions.QuestComplete(65448), -- A Return To Grace
        note="Stand in the wellspring to receive {spell:368622}",
        spell=368622, -- Grace of the First Ones
    },
})

-- Schematics

-- ns.RegisterPoints(1970, { -- Zereth Mortis
--     [50553200] = { -- Schematic: Bronzewing Vespoid
--         quest=65396, -- todo: quest for looting?
--         label="{item:189473}",
--         loot={
--             {189473, quest=65396, note=MOUNT},
--         },
--         note="Inside the Gravid Repose",
--     }
-- }, {
--     hide_before=ns.conditions.QuestComplete(65427), -- A New Architect
-- })
-- ns.RegisterPoints(2029, { -- Gravid Repose
--     [49004060] = { -- Schematic: Bronzewing Vespoid
--         quest=65396, -- todo: quest for looting?
--         label="{item:189473}",
--         loot={
--             {189473, quest=65396, note=MOUNT},
--         },
--         hide_before=ns.conditions.QuestComplete(65427), -- A New Architect
--     },
-- })

-- Puzzle caches
-- The WQs for these all use 65418 + a WQ quest regardless of the type of cache

local puzzle = ns.nodeMaker{
    group="puzzlecache",
    active=ns.conditions.GarrisonTalent(1972),
    minimap=true,
}
ns.RegisterPoints(1970, { -- Zereth Mortis
    [38556365] = {quest=65094},
    [43652150] = {quest=65094},
    [53004560] = {quest=65094},
    [65654095] = {quest=65094},
    [48608745] = {quest=65318},
    [54954800] = {quest=65318},
    [55957960] = {quest=65318},
    [44209010] = {quest=65323},
    [44757610] = {quest=65323},
    [47504620] = {quest=65323},
}, puzzle{
    label="Cantaric Cache",
    texture=ns.atlas_texture("VignetteLoot", {r=0,g=1,b=1,a=0.8,scale=0.9}),
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [46056460] = {quest=65093},
    [47107720] = {quest=65093},
    [57506575] = {quest={65093,65418,any=true}},
    [63103740] = {quest=65093},
    [44303095] = {quest=65317},
    [47603910] = {quest={65317,65418,any=true}},
    [59702290] = {quest=65317},
    [36455645] = {quest=65322},
    [39204665] = {quest=65322},
    [42206880] = {quest=65322},
}, puzzle{
    label="Fugueal Cache",
    texture=ns.atlas_texture("VignetteLoot", {r=1,g=0.5,b=0,a=0.8,scale=0.9}),
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [41853130] = {quest=65092},
    [54254280] = {quest=65092},
    [58903635] = {quest=65092},
    [45109410] = {quest=65316},
    [56008415] = {quest={65316,65418,any=true}},
    [56656140] = {quest=65316},
    [33805425] = {quest=65321},
    [39957285] = {quest=65321},
    [44655055] = {quest=65321},
    [51302575] = {quest=65412},
}, puzzle{
    label="Glissandian Cache",
    texture=ns.atlas_texture("VignetteLoot", {r=1,g=1,b=0,a=0.8,scale=0.9}),
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [38357035] = {quest={65091,65418,any=true}},
    [39356045] = {quest=65091},
    [52357200] = {quest=65091},
    [55655000] = {quest=65091},
    [35805910] = {quest=65315},
    [57853165] = {quest=65315},
    [64705280] = {quest=65315},
    [38503550] = {quest=65320},
    [43604035] = {quest=65320},
    [49953045] = {quest=65320},
}, puzzle{
    label="Mezzonic Cache",
    texture=ns.atlas_texture("VignetteLoot", {r=0,g=0.8,b=0,a=0.8,scale=0.9}),
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [32055260] = {quest={64972,65418,any=true}},
    [34606880] = {quest=64972},
    [37004645] = {quest=64972},
    [46806700] = {quest=64972},
    [52455705] = {quest=65314},
    [53258685] = {quest={65314,65418,any=true}},
    [62807390] = {quest=65314},
    [64306330] = {quest=65319},
    [65604760] = {quest=65319},
    [67802745] = {quest=65319},
}, puzzle{
    label="Toccatian Cache",
    texture=ns.atlas_texture("VignetteLoot", {r=1,g=0,b=1,a=0.8,scale=0.8}),
})

-- Lore concordances

local lore = ns.nodeMaker{
    group="Lore Concordances",
    note=function(point)
        if point.quest_ then
            local known = C_QuestLog.IsQuestFlaggedCompleted(point.quest_)
            return "Unlocks lore entries at the Lore Console in Exile's Hollow\n" ..
                "This lore is " ..
                (known and GREEN_FONT_COLOR or RED_FONT_COLOR):WrapTextInColorCode(known and "known" or "unknown")
        else
            return "Unlocks lore entries at the Lore Console in Exile's Hollow"
        end
    end,
    minimap=true,
}
local metrial = ns.conditions.GarrisonTalent(1901)
local dealic = {ns.conditions.GarrisonTalent(1932)}
local trebalim = {ns.conditions.GarrisonTalent(1907)}
ns.RegisterPoints(1970, { -- Zereth Mortis
    [31775466] = {quest_=65179, hide_before=dealic},
    [38953127] = {quest_=65213, hide_before=dealic},
    [50405096] = {quest_=65216, hide_before=dealic},
    [64616035] = {quest_=65210, hide_before=dealic},
}, lore{
    label="Excitable concordance",
    atlas="vehicle-templeofkotmogu-purpleball",
    spell=362757, -- Hasty Understanding
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [35037144] = {quest_=65180, hide_before=trebalim},
    [39702572] = {quest_=65214, hide_before=trebalim},
    [51579134] = {quest_=65211, hide_before=trebalim},
    [64262397] = {quest_=65217, hide_before=trebalim},
}, lore{
    label="Mercurial concordance",
    atlas="vehicle-templeofkotmogu-orangeball",
    spell=362759, -- Powerful Knowledge
})
ns.RegisterPoints(1970, { -- Zereth Mortis
    [32196281] = {quest_=64940, hide_before=metrial},
    [38844857] = {quest_=65212, hide_before=metrial},
    [49367149] = {quest_=65209, hide_before=metrial},
    [60204707] = {quest_=65215, hide_before=dealic},
}, lore{
    label="Tranquil concordance",
    atlas="vehicle-templeofkotmogu-greenball",
    spell=362498, -- Critical Potency
})

-- Tales of the Exile

ns.RegisterPoints(1970, { -- Zereth Mortis
    [35755546] = {criteria=53299}, -- Part 1
    [41796247] = {criteria=53300}, -- Part 2
    [37544601] = {criteria=53301}, -- Part 3
    [49827656] = {criteria=53302}, -- Part 4
    [39033109] = {criteria=53303}, -- Part 5
    [67422518] = {criteria=53304}, -- Part 6
    [64833364] = {criteria=53305}, -- Part 7
}, {
    achievement=15509,
    atlas="poi-workorders", -- 4072784?
    minimap=true,
})

-- Patient Bufonid

ns.RegisterPoints(1970, { -- Zereth Mortis
    [34506550] = {
        npc=185798,
        quest={65732, 65724, any=true}, -- 65724 is the daily
        progress={65727, 65725, 65726, 65728, 65729, 65730, 65731},
        hide_before=ns.conditions.QuestComplete(65768), -- Our Forward Scouts
        texture=ns.merge(ns.atlas_texture("stablemaster"), {r=1,g=1,b=0,a=1,scale=1.2}),
        minimap=true,
        loot={
            {188808, mount=1569},
        },
        group="dailymount",
        note=function()
            local function q(quest, label)
                return (C_QuestLog.IsQuestFlaggedCompleted(quest) and GREEN_FONT_COLOR or RED_FONT_COLOR):WrapTextInColorCode(label)
            end
            return "Gather items over a week of quests:\n"..
                q(65727, "Day 1") ..": 15x {item:190852} from Vespoid\n"..
                q(65725, "Day 2") ..": 30x {item:172053}\n"..
                q(65726, "Day 3") ..": 200x {item:173202}\n"..
                q(65728, "Day 4") ..": 10x {item:173037}\n"..
                q(65729, "Day 5") ..": 5x {item:187704}\n"..
                q(65730, "Day 6") ..": 5x {item:190880} from {npc:185748} near Pilgrim's Grace\n"..
                q(65731, "Day 7") ..": 1x {item:187171} from {npc:180114} in Tazavesh the Veiled Market\n"
        end,
    },
    [58554980] = {
        label="{npc:185748}", -- Mai Toa
        quest=65730,
        hide_before=ns.conditions.QuestComplete(65729),
        note="Buy 5x {item:190880} for day 6 of the Patient Bufonid",
        atlas="food",
        minimap=true,
    },
})

-- Adventurer of Zerith Mortis

ns.RegisterPoints(1970, { -- Zereth Mortis
    [64753370] = { -- Akkaris
        npc=179006,
        quest=65552,
        --vignette=4747,
        criteria=52977,
        loot={
            189903, -- Sand Sifting Sandals
            189958, -- Tunneler's Penetrating Greathelm
            190053, -- Underground Circler's Crossbow
            190733, -- Circle of Akkaris
        },
        note="This doesn't spawn every day",
    },

    [49556750] = { -- Chitali the Eldest
        npc=183596,
        quest=65553,
        criteria=52978,
        --vignette=4948,
        loot={
            189906, -- Mask of the Resolute Cervid
            189947, -- Majestic Watcher's Girdle
            189994, -- Chitali's Command
            190729, -- Vigorous Sentinel's Seal
        },
        note="This doesn't spawn every day",
    },

    [47506230] = { -- Corrupted Architect
        npc=183953,
        quest=65273,
        criteria=53047,
        --vignette=4989,
        loot={
            189907, -- Crown of Contorted Thought
            189940, -- Architect's Polluting Touch
            190009, -- Hammer of Shattered Works
            190732, -- Strand of Tainted Relics
        },
        note="Fight {npc:183958} and {npc:183961} to trigger",
    },

    [53654435] = { -- Destabilized Core
        npc=180917,
        quest=64716,
        criteria=52974,
        loot={
            189910, -- Adornment of Jingling Fractals
            189930, -- Restraints of Boundless Chaos
            189985, -- Curtain of Untold Realms
            189999, -- Dark Sky Gavel
            189153, -- Unformed Lattice
            187837, -- Schematic: Erratic Genesis Matrix (engineer only)
        },
    },

    [47454515] = { -- Euv'ouk
        npc=184409,
        quest=65555,
        criteria=52982,
        --vignette=4961,
        loot={
            189949, -- Shackles of the Bound Guardian
            189956, -- Perverse Champion's Handguards
            189993, -- Twisted Judicator's Gavel
            190047, -- Converted Broker's Staff
        },
        note="This doesn't spawn every day",
    },

    [61806060] = { -- Feasting
        npc=178229,
        quest=65557,
        criteria=52973,
        loot={
            187848, -- Recipe: Sustaining Armor Polish
            189936, -- Feasting's Feeding Cloak
            189969, -- Vespoid's Clanging Legguards
            189970, -- Visor of Visceral Cravings
        },
    },

    [64605865] = { -- Furidian
        npc=183646,
        quest=65544,
        criteria=53031,
        loot={
            189920, -- Viperid Keeper's Gloves
            189932, -- Slick Scale Chitin
            189963, -- Sculpted Ouroboros Clasp
            190004, -- Furidian's Inscribed Barb
        },
        note="Find 3x Empowered Keys nearby then unlock the Suspiciously Angry Vault",
    },
    [62605980] = {quest=65544, criteria=53031, atlas="adventuremapicon-lock", label="Empowered Key: cube", minimap=true},
    [64005730] = {quest=65544, criteria=53031, atlas="adventuremapicon-lock", label="Empowered Key: star", minimap=true},
    [64456040] = {quest=65544, criteria=53031, atlas="adventuremapicon-lock", label="Empowered Key: sphere", minimap=true},

    [69053660] = { -- Garudeon
        npc=180924,
        quest=64719,
        criteria=53025,
        --vignette=4982,
        loot={
            189937, -- Garudeon's Blanket of Feathers
            189951, -- Sunbathed Avian Armor
            190602, -- Symbol of the Raptora
            190057, -- Protective Raptora's Wing-Glaive
            187832, -- Schematic: Pure-Air Sail Extensions (engineer only)
        },
        note="Gather {npc:183562} nearby, feed to {npc:183554}",
    },

    [59852110] = { -- General Zarathura
        npc=182318,
        quest=65583,
        criteria=52985,
        --vignette=4909,
        loot={
            189968, -- Dreadlord General's Tunic
            189948, -- Strangulating Chainlink Lasso
            190731, -- Deceiver's Illusionary Signet
            190125, -- Kris of Intricate Secrets
        },
        note="This doesn't spawn every day",
    },

    [53109305] = { -- Gluttonous Overgrowth
        npc=178778,
        quest=65579,
        criteria=52971,
        loot={
            189929, -- Vinebound Strap
            189953, -- Lush-Stained Footguards
            190008, -- Enlightened Botanist's Machete
            190049, -- Perennial Punching Dagger
        },
        note="Break nearby {npc:184048}. This is often bugged.",
    },

    [80404705] = { -- Gorkek
        npc=178963,
        quest=63988,
        criteria=52986,
        --vignette=4746,
        loot={
            189926, -- Poison-Licked Spaulders
            189960, -- Crouching Legs of the Bufonid
            190001, -- Gorkek's Glistening Throatguard
        },
        note="This doesn't spawn every day",
    },

    [52602505] = { -- Hadeon the Stonebreaker
        npc=178563,
        quest=65581,
        criteria=52984,
        loot={
            189919, -- Skittering Scarabid Treads
            189942, -- Hadeon's Indomitable Faceguard
            190000, -- Carapace of Gliding Sands
            190051, -- Elder's Opulent Stave
        },
        note="This doesn't spawn every day",
    },

    [58206835] = { -- Helmix
        npc=183748,
        quest=65551,
        criteria=53048,
        loot={
            189931, -- Annelid's Hinge Wrappings
            189965, -- Armored Cuffs of Helmix
            190054, -- Facet Sharpening Crossbow
            190056, -- Enlightened Explorer's Lantern
        },
        note="This doesn't spawn every day. To spawn it, kill Annelid mobs nearby.",
    },

    [52307540] = { -- Hirukon
        npc=180978,
        quest=65548, -- 65785 for killing with the lure buff, 65039 for making the lure
        criteria=52990,
        active=ns.conditions.Item(187923),
        atlas="VignetteKillElite", scale=1.2,
        loot={
            189905, -- Hirukon's Syrupy Squeezers
            189946, -- Jellied Aurelid Mantle
            190005, -- Hirukon's Radiant Reach
            187636, -- Aurelid Lattice
            {187676, mount=1434}, -- Deepstar Aurelid
        },
        -- TODO: add notes on the other maps?
        note=function()
            local attempted = C_QuestLog.IsQuestFlaggedCompleted(65785)
            return "You have to make a {item:187923}:\n"..
                "* Fish up {item:187662} nearby\n"..
                "* Fish up {item:187915} from Coilfang Reservoir in Zangarmarsh\n"..
                "* Fish up {item:187922} near Keyla's Grave in Nazjatar\n"..
                "* Find {item:187916} in Nar'shola Terrace in the Shimmering Expanse (34.7, 75.0)\n"..
                "* Ask {npc:182194} south of the Seat of the Primus in Maldraxxus to make your {item:187923}\n"..
                "* Bring it back here, use it, and fish in the Aurelid Cluster you can now see.\n"..
                "The lure will be consumed on use, but you can ask {npc:182194} for a new one each week without having to do the fishing again.\n"..
                "You " .. (attempted and GREEN_FONT_COLOR or RED_FONT_COLOR):WrapTextInColorCode(attempted and "have" or "have not") .. " used the lure this week."
        end,
    },

    [58654040] = { -- Otaris the Provoked
        npc=183814,
        quest=65257,
        criteria=53046,
        loot={
            189909, -- Pantaloons of Cold Recesses
            189945, -- Shoulders of the Missing Giant
            189957, -- Colossus' Focusing Headpiece
        },
        note="Inside a cave",
    },

    [54103495] = { -- Mother Phestis
        npc=178508,
        quest=65547,
        criteria=53020,
        loot={
            189769, -- Fang of Phestis
            189923, -- Tarachnid's Terrifying Visage
            189950, -- Constrained Prey's Binds
            190045, -- Flowing Sandbender's Staff
        },
    },
    [55953260] = path{quest=65547, criteria=53020},

    [56406820] = { -- Orixal
        npc=179043,
        quest=65582,
        criteria=52981,
        loot={
            189912, -- Orixal's Moist Sash
            189934, -- Slime-Wake Sabatons
            189952, -- Celestial Mollusk's Chestshell
        },
        note="Kill {npc:185487} and it might spawn",
    },

    [43308760] = { -- Otiosen
        npc=183746,
        quest=65556,
        criteria=52972,
        loot={
            189914, -- Otiosen's Regenerative Wristwraps
            189925, -- Amphibian's Nimble Leggings
            190046, -- Broker's Stolen Cane
            189995, -- Builder's Alignment Hammer
            187634, -- Ambystan Lattice
        },
    },

    [38852760] = { -- Protector of the First Ones
        npc=180746,
        quest=64668,
        criteria=52989,
        loot={
            189961, -- Enduring Protector's Shoulderguards
            189984, -- Drape of Idolized Symmetry
            190002, -- Bulwark of the Broken
            190390, -- Protector's Diffusion Implement
            189176, -- Protoform Sentience Crown
            189177, -- Revelation Key
        },
        note="Two people required to open the barrier",
    },

    [53404705] = { -- Sand Matriarch Ileus
        npc=183927,
        quest=65574,
        criteria=52975,
        loot={
            189927, -- Broker's Gnawed Spaulders
            189955, -- Scarabid's Clattering Handguards
            189998, -- Ornate Stone Mallet
            190730, -- Matriarch's Shell Band
        },
    },

    [42302100] = { -- Shifting Stargorger
        npc=184413,
        quest=65549,
        criteria=52988,
        loot={
            189908, -- Gorger's Leggings of Famine
            189916, -- Mutated Devourer's Harness
            189941, -- Voracious Diadem
            {189972, quest=65505, covenant=Enum.CovenantType.NightFae}, -- Scorpid Soul
        },
    },

    [35857120] = { -- Sorranos
        npc=183722,
        quest=65240,
        criteria=52980,
        loot={
            189911, -- Sublime Fur Mantle
            189944, -- Immovable Stance of the Vombata
            189962, -- Sorranos' Gleaming Pauldrons
            190582, -- Protector's Diffusion Implement
            187826, -- Formula: Cosmic Protoweave
        },
        note="This doesn't spawn every day",
    },

    [49803915] = { -- Tahkwitz
        npc=183925,
        quest=65272,
        criteria=52979,
        loot={
            189915, -- Tahkwitz' Cloth Ribbon
            189933, -- Vigilant Raptora's Crest
            189954, -- Lustrous Sentinel's Sabatons
            190003, -- Skyward Savior's Talon
            187832, -- Schematic: Pure-Air Sail Extensions (engineer only)
        },
    },

    [54507345] = { -- Tethos
        npc=181249,
        quest=65550,
        criteria=52987,
        --vignette=4903,
        loot={
            189928, -- Centripetal Waistband
            189966, -- Singing Metal Wristbands
            189967, -- Hood of Star Topology
            190055, -- Coalescing Energy Implement
            187830, -- Design: Aealic Harmonizing Stone
            189146, -- Geomental Lattice
        },
        note="This doesn't spawn every day",
    },

    [43957530] = { -- The Engulfer
        npc=183516,
        quest=65580,
        criteria=53050,
        loot={
            189913, -- Engulfer's Tightening Cinch
            189921, -- Devourer's Insatiable Grips
            190006, -- Anima-Siphoning Sword
        },
        note="Protect {npc:183505} until this appears",
    },

    [39555735] = { -- Vexis
        npc=181360,
        quest=65239,
        criteria=53049,
        loot={
            189900, -- Vexis' Gentle Heartcloth
            189959, -- Legs of Graceful Landing
            189997, -- The Lupine Prime's Might
            190048, -- Vexis' Wisest Fang
            190597, -- Symbol of the Lupine
        },
        note="This doesn't spawn every day",
    },

    [47054700] = { -- Vitiane
        npc=183747,
        quest=65584,
        criteria=52983,
        loot={
            189901, -- Vitiane's Defiled Vestment
            189922, -- Cowl of Shameful Proliferation
            189935, -- Harrowing Hope Squashers
        },
        note="This doesn't spawn every day",
    },

    [64054975] = { -- Xy'rath the Covetous
        npc=183737,
        quest=65241,
        --vignette=4938,
        criteria=52976,
        loot={
            189918, -- Fleeting Broker's Strides
            189964, -- Multi-Faceted Belt
            190052, -- Xy'rath's Letter Opener
            190007, -- Xy'rath's Signature Saber
            {190238, toy=true}, -- Xy'rath's Booby-Trapped Cache
            190389, -- Broker's Lucky Coin
            187828, -- Recipe: Infusion: Corpse Purification
        },
        note="This doesn't spawn every day",
    },

    [43503295] = { -- Zatojin
        npc=183764,
        quest=65251,
        criteria=53044,
        loot={
            189902, -- Hapless Traveler's Treads
            189924, -- Buzzing Predator's Legs
            189939, -- Zatojin's Paralytic Grip
            190726, -- Extract of Prodigious Sands
        },
        note="Engage the {npc:183721} to get 20 stacks of {spell:362976} and be {spell:362983}. Make sure you're standing on the {npc:183774} corpses.",
    },
}, {
    achievement=15391, -- Adventurer of Zereth Mortis
})

-- Dune Dominance
ns.RegisterPoints(1970, { -- Zereth Mortis
    [63202605] = {
        label="{achievement:15392}",
        achievement=15392, criteria=true,
        atlas="VignetteKillElite", scale=1.2,
        quest={
            65585, -- Iska, Outrider of Ruin, criteria 52992 (mount Rhuv, 65706)
            65586, -- High Reaver Damaris, criteria 52993 (mount Edra, 65558)
            65587, -- Reanimatrox Marzan, criteria 52994
            all=true,
        },
        note="One of these rares is here each day",
        loot={
            -- Iska
            {190102, note="Iska"}, -- Chains of Infectious Serrations
            {190103, note="Iska"}, -- Pillar of Noxious Dissemination
            {190126, note="Iska"}, -- Rotculler's Encroaching Shears
            {190458, note="Iska"}, -- Atrophy's Ominous Bulwark
            -- Iska's mount, Rhuv
            {190765, mount=1584, note="Iska's mount"}, -- Iska's Mawrat Leash
            -- Damaris
            {190105, note="Damaris"}, -- Chilling Domination Mace
            {190106, note="Damaris"}, -- Approaching Terror's Torch
            {190459, note="Damaris"}, -- Cold Dispiriting Barricade
            {190460, note="Damaris"}, -- High Reaver's Sickle
            -- Marzan
            {190108, note="Marzan"}, -- Aegis of Laughing Souls
            {190109, note="Marzan"}, -- Cudgel of Mortality's Chains
            {190127, note="Marzan"}, -- Marzan's Dancing Twin-Scythe
            {190461, note="Marzan"}, -- Reanimator's Beguiling Baton
            -- All of them
            {190050, note="All"}, -- Entropic Broker's Ripper
            {190104, note="All"}, -- Deadeye's Spirit Piercer
            {190107, note="All"}, -- Staff of Broken Coils
            {190124, note="All"}, -- Interrogator's Vicious Dirk
            {190463, note="All"}, -- Dismal Mystic's Glaive
        },
    },
})

-- Completing the Code

ns.RegisterPoints(1970, { -- Zereth Mortis
    [41456245] = { -- Bitterbeak
        npc=181352,
        criteria=52577,
    },

    [38855860] = { -- Cipherclad
        npc=181349,
        criteria=52576,
    },

    [50306390] = { -- Corrupted Runehoarder
        npc=181290,
        criteria=52569,
        note="Patrols around the eastern pools, /tar macros will help",
    },

    [48651370] = { -- Dominated Irregular
        npc=184819,
        criteria=52568,
    },

    [62202500] = { -- Enchained Servitor
        npc=181208,
        criteria=52567,
    },

    [60756475] = { -- Gaiagantic
        npc=181223,
        criteria=52553,
        note="You'll get this during the {quest:64785} daily",
    },

    [36153850] = { -- Gorged Runefeaster
        npc=181287,
        criteria=52566,
    },

    [56154805] = { -- Misaligned Enforcer
        npc=181292,
        criteria=52570,
        note="Spawns here, walks around the area, and eventually despawns; watch out for a running automata",
        route={
            56154805, 55504760, 55004655, 55104540, 55754505, 56254505,
            56254380, 55754315, 55754175, 55104095, 54354095, 53854110,
            53154180, 52404245, 51904165, 51504095, 52254055, 52703985,
            53254025, 53404130, 53204270, 53704330, 54154385, 54454545,
            55054590, 55504700, 56204690, 57004675, 57804680, 58204630,
            57954455, 58104430,
            r=1,g=1,b=0,
        },
    },

    -- Moss-Choked Guardian
    [43609020] = {npc=181219, criteria=52554,},
    [45809520] = {npc=181219, criteria=52554,},
    [50659440] = {npc=181219, criteria=52554,},
    [53809360] = {npc=181219, criteria=52554,},

    [62806830] = { -- Overgrown Geomental
        npc=179007,
        criteria=52565,
    },
    [61257440] = { -- Bygone Geomental
        npc=181221,
        criteria=52552,
        note="Can spawn instead of nearby {npc:179007}",
    },

    [63205800] = { -- Over-charged Vespoid
        npc=181222,
        criteria=52606,
        note="Spawns in this general area",
    },

    [39805205] = { -- Runefur
        npc=181344,
        criteria=52575,
    },

    [50256015] = { -- Runegorged Bufonid
        npc=181294,
        criteria=52572,
    },

    [61855180] = { -- Runethief Xy'lora
        npc=181295,
        criteria=52574,
        note="Appears stealthed in Pilgrim's Grace",
    },

    [53557520] = { -- Sharpeye Collector
        npc=178835,
        criteria=52573,
    },

    [35056375] = { -- Suspicious Nesmin
        npc=181293,
        criteria=52571,
    },

    [45202190] = { -- Twisted Warpcrafter
        npc=182798,
        criteria=52686,
    },
}, {
    achievement=15211,
    texture=ns.atlas_texture("VignetteKill", {r=1,g=0.5,b=0,a=1,scale=1}),
    minimap=true,
    active=ns.conditions.Item(187909),
    note="You need to have completed the daily quest {quest:64785} to get the {item:187909}."
})

-- Transportation

-- Ancient Translocator
-- ns.RegisterPoints(1970, {
--     [46122172] = {route=47301340,},
--     [47301340] = {route={47301340,46122172,r=0,g=0.75,b=0},},
-- }, {
--     label="{npc:183968}",
--     atlas="progenitorflightmaster-32x32", scale=1,
--     group="Transportation",
-- })
-- -- Ancient Translocator
-- ns.RegisterPoints(1970, {
--     [64855355] = {route=73305340,},
--     [73305340] = {route={73305340,64855355,r=0,g=0.75,b=0},},
-- }, {
--     label="{npc:183970}",
--     atlas="progenitorflightmaster-32x32", scale=1,
--     hide_before=ns.conditions.QuestComplete(64844), -- The Pilgrimage Ends
--     group="Transportation",
-- })
