local myname, ns = ...

-- 79929 for random herbing of Khaz Algar Herbalism Knowledge (currency 2789)
-- 81417 for herbing a Deepgrove Petal (224264)
-- 81418 for herbing a Deepgrove Petal from Mycobloom (224264)
-- 81419 for herbing a Deepgrove Petal from Mycobloom (224264)

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2789,
    requires = ns.conditions.Profession(ns.PROF_WW_HERBALISM),
    -- active = ns.conditions.Profession(ns.PROF_WW_HERBALISM, 25),
    group = "professionknowledge",
    atlas="worldquest-icon-herbalism",
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [57556146] = {
        quest=83874,
        loot={226300}, -- Ancient Flower
        vignette=6457,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [59242352] = {
        quest=83875,
        loot={226301}, -- Dornogal Gardening Scythe
        vignette=6458,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45173504] = {
        quest=83876,
        loot={226302}, -- Earthen Digging Fork
        vignette=6459,
    },
    [49546581] = {
        quest=83877,
        loot={226303}, -- Fungarian Slicer's Knife
        vignette=6460,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [47786330] = {
        quest=83878,
        loot={226304}, -- Arathi Garden Trowel
        vignette=6461,
    },
    [35975501] = {
        quest=83879,
        loot={226305}, -- Arathi Herb Pruner
        vignette=6462,
    },
}, KNOWLEDGE)

-- ns.RegisterPoints(ns.AZJKAHET, {
-- }, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [46771612] = {
        quest=83881,
        loot={226307}, -- Tunneler's Shovel
        vignette=6464,
        parent=true, levels=true, translate={[2256]=true},
    },
    [54602088] = {
        quest=83880,
        loot={226306}, -- Web-Entangled Lotus
        vignette=6463,
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
