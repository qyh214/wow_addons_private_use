local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2785,
    requires = ns.conditions.Profession(ns.PROF_WW_ALCHEMY),
    -- active = ns.conditions.Profession(ns.PROF_WW_ALCHEMY, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [57706177] = {
        quest=83841,
        loot={226266}, -- Metal Dornogal Frame
        vignette=6426,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [47207040] = { -- or 32456034 or 3061994
        quest=83840,
        loot={226265}, -- Earthen Iron Powder
        vignette=6425,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [42202410] = {
        quest=83842,
        loot={226267}, -- Reinforced Beaker
        vignette=6427,
    },
    [64936182] = {
        quest=83843,
        loot={226268}, -- Engraved Stirring Rod
        vignette=6428,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [42655505] = {
        quest=83844,
        loot={226269}, -- Chemist's Purified Water
        vignette=6429,
    },
    [41675581] = { -- 42645503
        quest=83845,
        loot={226270}, -- Sanctified Mortar and Pestle
        vignette=6430,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [44476052] = { -- 42875725
        quest=83847,
        loot={226272}, -- Dark Apothecary's Vial
        vignette=6432,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [45371322] = {
        quest=83846,
        loot={226271}, -- Nerubian Mixing Salts
        vignette=6431,
        parent=true, levels=true, translate={[2256]=true},
    },
    [55604700] = {
        quest=82633,
        loot={224024}, -- Theories of Bodily Transmutation, Chapter 8
        note="Buy from {npc:224337:Zara'azj the Magnificent}",
        parent=true, levels=true, translate={[2256]=true},
    }
}, KNOWLEDGE)
