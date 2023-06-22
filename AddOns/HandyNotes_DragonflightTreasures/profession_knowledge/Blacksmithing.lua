local myname, ns = ...

local dfbsknowledge = {
    note = "This can only be looted once per character.",
    currency=2023,
    requires = ns.conditions.Profession(ns.PROF_DF_BLACKSMITHING),
    hide_before = ns.conditions.Profession(ns.PROF_DF_BLACKSMITHING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    minimap = true,
}
-- https://www.wowhead.com/guide/professions/knowledge-point-treasure-locations-dragon-isles
ns.RegisterPoints(ns.WAKINGSHORES, {
    [56401950] = {
        note = "Craft Primal Molten Alloy near the Dim Forge to make it appear the Slack Tub",
        loot = {
            198791, -- Glimmer of Blacksmithing Wisdom
        },
        quest = 70232, -- 71352 also triggers
    },
    [22008700] = {
        note = "Apex Canopy; four yellow Enchanted Bulwarks surrounding a sword on a pedestal",
        loot = {
            201007, -- Ancient Monument
        },
        quest = 70246,
    },
    [65502570] = {
        note = "Scalecracker Keep, ingot on the ground near a big hut next to a forge",
        loot = {
            201005, -- Curious Ingots
        },
        quest = 70312,
    },
    [35506430] = {
        note = "West of Obsidian Bulwark by a lava river, near a fishing trainer. Kick 3 ingots into the lava to spawn a mob. Chest that spawns afterward contains the item. Just north of {item:201010:Qalashi Weapon Diagram}",
        loot = {
            201008, -- Molten Ingot
        },
        quest = 70296,
    },
    [34506701] = {
        note = "West of Obsidian Bulwark in an island surrounded by lava, on top of an anvil. Just south of {item:201008:Molten Ingot}",
        loot = {
            201010, -- Qalashi Weapon Diagram
        },
        quest = 70310,
    },
}, dfbsknowledge)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [81103790] = {
        note = "Inside a cave west of Rusza'thar Reach. Cave inhabited by neutral Shale Giants",
        loot = {
            201004, -- Ancient Spear Shards
        },
        path = 79403650,
        quest = 70313,
    },
    [50906650] = {
        note = "Island in the sea, inside a hut",
        loot = {
            201009, -- Falconer Gauntlet Drawings
        },
        quest = 70353,
    },
}, dfbsknowledge)

ns.RegisterPoints(ns.AZURESPAN, {
    [53106530] = {
        note = "Azure Archives, inside a small cave. Blocked by a Rock Wall, so you will need to be a miner or get one to help you open the wall",
        loot = {
            201011, -- Spelltouched Tongs
        },
        quest = 70314,
    },
}, dfbsknowledge)

ns.RegisterPoints(ns.THALDRASZUS, {
    [52208050] = {
        note = "Shifting Sands, west of the Shifting Sands flightpoint. Inside a building, a bit high up",
        loot = {
            201006, -- Draconic Flux
        },
        quest = 70311,
    },
}, dfbsknowledge)

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [48302195] = {
        loot={205987}, -- Brimstone Rescue Ring
        quest=76079,
        vignette=5734,
    },
    [57155464] = {
        loot={205986}, -- Well-Worn Kiln
        quest=76078,
        vignette=5733,
    },
    [27534287] = {
        loot={205988}, -- Zaqali Elder Spear
        quest=76080,
        vignette=5735,
    },
}, dfbsknowledge)
