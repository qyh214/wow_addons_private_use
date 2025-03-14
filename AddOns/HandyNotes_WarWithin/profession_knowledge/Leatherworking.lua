local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2792,
    requires = ns.conditions.Profession(ns.PROF_WW_LEATHERWORKING),
    -- active = ns.conditions.Profession(ns.PROF_WW_LEATHERWORKING, 25),
    group = "professionknowledge",
    atlas="worldquest-icon-leatherworking",
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [58693072] = {
        quest=83899,
        loot={226325}, -- Dornogal Craftsman's Flat Knife
        vignette=6482,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [68202334] = {
        quest=83898,
        loot={226324}, -- Earthen Lacing Tools
        vignette=6481,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [44063485] = {
        quest=83900,
        loot={226326}, -- Underground Stropping Compound
        vignette=6483,
        note="Inside the house",
    },
    [60216535] = {
        quest=83901,
        loot={226327}, -- Earthen Awl
        vignette=6484,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [47466511] = {
        quest=83902,
        loot={226328}, -- Arathi Beveler Set
        vignette=6485,
    },
    [41525781] = {
        quest=83903,
        loot={226329}, -- Arathi Leather Burnisher
        vignette=6486,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [60005393] = {
        quest=83905,
        loot={226331}, -- Curved Nerubian Skinning Knife
        vignette=6488,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [55202685] = {
        quest=83904,
        loot={226330}, -- Nerubian Tanning Mallet
        vignette=6487,
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
