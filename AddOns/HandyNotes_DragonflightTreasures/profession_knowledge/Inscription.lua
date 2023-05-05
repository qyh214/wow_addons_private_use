local myname, ns = ...

local dfinsknowledge = {
    note = "This can only be looted once per character.",
    currency=2028,
    requires = ns.conditions.Profession(ns.PROF_DF_INSCRIPTION),
    hide_before = ns.conditions.Profession(ns.PROF_DF_INSCRIPTION, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    minimap = true,
}
-- https://www.wowhead.com/guide/professions/knowledge-point-treasure-locations-dragon-isles
ns.RegisterPoints(ns.WAKINGSHORES, {
    [67905800] = {
        note = "Behind a small stone table. Loot this before looting the {item:198669:How to Train Your Whelpling} in Valdrakken item due to a possible bug!",
        loot = {
            198704, -- Pulsing Earth Rune
        },
        quest = 70306,
        vignette = 5329, -- Sign Language Reference Sheet (this *has* to be a bug, but it's what's there... it also doesn't disappear when you loot it)
        minimap = false,
    },
}, dfinsknowledge)

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [85702520] = {
        note = "Timberstep Outpost, hanging on tent entrance.",
        loot = {
            198703, -- Sign Language Reference Sheet
        },
        quest = 70307,
        vignette = 5329, -- Sign Language Reference Sheet
        minimap = false,
    },
}, dfinsknowledge)

ns.RegisterPoints(ns.AZURESPAN, {
    [46192400] = {
        note = "Cobalt Assembly, inside a building on an upper level.",
        loot = {
            198693, -- Dusty Darkmoon Card
        },
        quest = 70297,
        vignette = 5322, -- Dusty Darkmoon Card
        minimap = false,
    },
    [43703090] = {
        note = "Behind an Arcane Commander.",
        loot = {
            198686, -- Frosted Parchment
        },
        quest = 70293,
    },
}, dfinsknowledge)

ns.RegisterPoints(ns.THALDRASZUS, {
    [56304120] = {
        note = "West of Algeth'ar Academy entrance, on a table near a big telescope. Tome #1",
        loot = {
            198659, -- Forgetful Apprentice's Tome #1
        },
        quest = 70264,
        vignette = 5291,
        hide_before = false, -- this one doesn't require a specific level of inscription to collect
        minimap = false,
    },
    [47244010] = {
        note = "Above Algeth'era FP, just west in a small building. Interactable {item:380584:Curious Glyph} inside. Click and phase, cross the bridge with some 70 mobs, and kill the neutral mob inside the house. Deliver its dropped item to the glyph to get the item. Tome #2",
        loot = {
            198659, -- Forgetful Apprentice's Tome #2
        },
        nearby = {49844033, label="{npc:194880:Confusion Manifest}"},
        quest = 70248,
    },
    [56084102] = {
        note = "Speak to {npc:194856:Siennagosa}. Offer to help set back her Darkmoon Deck. Scattered at her feet are 8 Darkmoon cards. Click them in the correct order (Ace through 8). Speak to her afterward to get the deck.",
        loot = {
            201015, -- Counterfit Darkmoon Deck
        },
        quest = 70287,
    },
}, dfinsknowledge)

ns.RegisterPoints(ns.VALDRAKKEN, {
    [13206368] = {
        note = "Little Scales Day Care area, brown book lying in the sandbox.\nLoot the {item:198704:Pulsing Earth Rune} in Waking Shores before looting this due to a possible bug!",
        loot = {
            198669, -- How to Train Your Whelpling
        },
        quest = 70281,
        vignette = 5305, -- How to Train Your Whelpling
        parent = true,
    },
}, dfinsknowledge)

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [53027426] = {
        loot={206034}, -- Hissing Rune Draft
        quest=76120,
        vignette=5740,
    },
    [36734630] = {
        loot={206031}, -- Intact Zaqali Runes
        quest=76117,
        vignette=5739,
    },
}, dfinsknowledge)
