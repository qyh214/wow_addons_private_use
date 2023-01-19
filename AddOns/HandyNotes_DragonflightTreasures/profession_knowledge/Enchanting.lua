local myname, ns = ...

local dfenchknowledge = {
    note = "This can only be looted once per character.",
    currency=2030,
    requires = ns.conditions.Profession(ns.PROF_DF_ENCHANTING),
    hide_before = ns.conditions.Profession(ns.PROF_DF_ENCHANTING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    minimap = true,
}
-- https://www.wowhead.com/guide/professions/knowledge-point-treasure-locations-dragon-isles
ns.RegisterPoints(ns.WAKINGSHORES, {
    [57508359] = {
        note = "Flashfrozen Enclave, in frozen cave system.",
        loot = {
            198798, -- Flashfrozen Scroll
        },
        quest = 70320,
    },
    [67962677] = {
        note = "Scalecracker Keep, next to a lava flower in a flower.",
        loot = {
            198675, -- Lava-Infused Seed
        },
        quest = 70283,
    },
    [57525849] = {
        note = "Use Disenchanted Broom and follow Enchanted Broom, then loot the debris at path's end.",
        loot = {
            201012, -- Enchanted Debris
        },
        quest = 70272,
    },
}, dfenchknowledge)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [61556763] = {
        note = "Windsong Rise, north of Ohn'iri Springsr.",
        loot = {
            198689, -- Stormbound Horn
        },
        quest = 70291,
    },
}, dfenchknowledge)

ns.RegisterPoints(ns.AZURESPAN, {
    [38505911] = {
        note = "Azure Archives, in a leveled tomb with a rare mob on the NW side. Tome is lying on the floor to the right of the entrance.",
        loot = {
            198799, -- Forgotten Arcane Tome
        },
        quest = 70336,
    },
    [45186108] = {
        note = "Just east of Azure Archives. Click on Mana-Starved Crystal Cluster to spawn a mob. Kill the mob and click the crystal that spawns.",
        loot = {
            201013, -- Faintly Enchanted Remains
        },
        quest = 70290,
    },
    [21564554] = {
        loot = {
            198694, -- Enriched Earthen Shard
        },
        quest = 70298,
    },
}, dfenchknowledge)

ns.RegisterPoints(ns.THALDRASZUS, {
    [59927034] = {
        note = "South of Tyrhold.",
        loot = {
            198800, -- Fractured Titanic Sphere
        },
        quest = 70342,
    },
}, dfenchknowledge)
