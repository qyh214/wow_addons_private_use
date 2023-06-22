local myname, ns = ...

local dfjcknowledge = {
    note= "This can only be looted once per character.",
    currency=2029,
    requires = ns.conditions.Profession(ns.PROF_DF_JEWELCRAFTING),
    hide_before = ns.conditions.Profession(ns.PROF_DF_JEWELCRAFTING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    minimap = true,
}
-- https://www.wowhead.com/guide/professions/knowledge-point-treasure-locations-dragon-isles
ns.RegisterPoints(ns.WAKINGSHORES, {
    [50404510] = {
        note = "Right before a waterfall, look for a beaver's nest. Underneath the tree cover next to the nest is a blue gem.",
        loot = {
            198687, -- Closely Guarded Shiny
        },
        quest = 70292,
    },
    [33966366] = {
        note = "Dragonbane Keep, locked behind a minigame. Click 3 different crystals on small islands inside the magma. Kill the big magma frog jumping around before you do this. After clicking the first one, you only have a limited time to click the other two. Once all 3 are channeling, the item is unlocked.",
        loot = {
            201017, -- Igneous Gem
        },
        quest = 70273,
    },
}, dfjcknowledge)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [25203540] = {
        note = "Storm Scar, inside a cave, floating in the air.",
        loot = {
            198670, -- Lofty Malygite
        },
        quest = 70282,
        vignette = 5304,
    },
    [61771302] = {
        note = "Neltharan Plains, crumbled building with a tree growing inside. Look for it under the tree's roots. Comes with a bonus treasure.",
        loot = {
            198660, -- Fragmented Key
        },
        quest = 70263,
    },
}, dfjcknowledge)

ns.RegisterPoints(ns.AZURESPAN, {
    [45006130] = {
        note = "Azure Archives, next to a small pond/starting point of a river.",
        loot = {
            198664, -- Crystalline Overgrowth
        },
        quest = 70277,
    },
    [44606120] = {
        note = "Azure Archives, locked behind a minigame. There is a chest inside the pond with a large silver key. Click it to receive a buff. While buff is active, click 3 nearby crystals.",
        loot = {
            201016, -- Harmonic Crystal Harmonizer
        },
        quest = 70271,
    },
}, dfjcknowledge)

ns.RegisterPoints(ns.THALDRASZUS, {
    [59856523] = {
        note = "Tyrhold, right at the base of the letter 'T' on the map.",
        loot = {
            198682, -- Alexstraszite Cluster
        },
        quest = 70285,
    },
    [56914366] = {
        note = "Inside the lantern. Currently bugged and need to use the interact key to loot it.",
        loot = {
            198656, -- Painter's Pretty Jewel
        },
        quest = 70261,
    },
}, dfjcknowledge)

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [54413247] = {
        loot={205219}, -- Broken Barter Boulder
        quest=75654,
        vignette=5698,
    },
    [34474543] = {
        loot={205216}, -- Gently Jostled Jewels
        quest=75653,
        vignette=5697,
    },
    [40378066] = {
        loot={205214}, -- Snubbed Snail Shells
        quest=75652,
        vignette=5696,
    },
}, dfjcknowledge)
