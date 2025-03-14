local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2795,
    requires = ns.conditions.Profession(ns.PROF_WW_TAILORING),
    -- active = ns.conditions.Profession(ns.PROF_WW_TAILORING, 25),
    group = "professionknowledge",
    atlas="worldquest-icon-tailoring",
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [56216102] = {
        quest=83923,
        loot={226349}, -- Earthen Tape Measure
        vignette=6506,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [61561850] = {
        quest=83922,
        loot={226348}, -- Dornogal Seam Ripper
        vignette=6505,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45713286] = {
        quest=83924,
        loot={226350}, -- Runed Earthen Pins
        vignette=6507,
    },
    [60046034] = {
        quest=83925,
        loot={226351}, -- Earthen Stitcher's Snips
        vignette=6508,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [49316233] = {
        quest=83926,
        loot={226352}, -- Arathi Rotary Cutter
        vignette=6509,
    },
    [40116812] = {
        quest=83927,
        loot={226353}, -- Royal Outfitter's Protractor
        vignette=6510,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [53265311] = {
        quest=83928,
        loot={226354}, -- Nerubian Quilt
        vignette=6511,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [50281665] = {
        quest=83929,
        loot={226355}, -- Nerubian's Pincushion
        vignette=6512,
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
