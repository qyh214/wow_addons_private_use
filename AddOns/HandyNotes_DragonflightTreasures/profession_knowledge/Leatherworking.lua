local myname, ns = ...

local dflwknowledge = {
    note= "This can only be looted once per character.",
    currency=2025,
    requires = ns.conditions.Profession(ns.PROF_DF_LEATHERWORKING),
    hide_before = ns.conditions.Profession(ns.PROF_DF_LEATHERWORKING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    minimap = true,
}
-- https://www.wowhead.com/guide/professions/knowledge-point-treasure-locations-dragon-isles
ns.RegisterPoints(ns.WAKINGSHORES, {
    [39008600] = {
        note = "Next to a dead Vulpera laying beside the riverbed.",
        loot = {
            198711, -- Poacher's Pack
        },
        quest = 70308,
    },
    [64302540] = {
        note = "Lying next to dead red dragon.",
        loot = {
            198667, -- Spare Djardin Tools
        },
        quest = 70280,
    },
}, dflwknowledge)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [86405370] = {
        note = "Inside Shikaar Highlands Centaur camp.",
        loot = {
            198696, -- Wind-Blessed Hide
        },
        quest = 70300,
    },
}, dflwknowledge)

ns.RegisterPoints(ns.AZURESPAN, {
    [12504940] = {
        note = "Iskaara, in an underground building with {npc:186446:Elder Nappa} and {npc:186448:Elder Poa}. Activate the treasure by fixing the {item:380573:Broken Drum} next to {npc:194862:Raq}. Once he dances on it, you can loot the item.",
        loot = {
            201018, -- Well-Danced Drum
        },
        quest = 70269,
    },
    [16703880] = {
        note = "North of Iskaara, in the barrel in a gnoll camp.",
        loot = {
            198658, -- Decay-Infused Tanning Oil
        },
        quest = 70266,
    },
    [57504130] = {
        note = "Snowhide camp east of Camp Antonidas.",
        loot = {
            198683, -- Treated Hides
        },
        quest = 70286,
    },
}, dflwknowledge)

ns.RegisterPoints(ns.THALDRASZUS, {
    [56803050] = {
        note = "Inside a basket within the Fetid's camp.",
        loot = {
            198690, -- Decayed Scales
        },
        quest = 70294,
    },
}, dflwknowledge)
