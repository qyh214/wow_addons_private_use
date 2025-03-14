local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2794,
    requires = ns.conditions.Profession(ns.PROF_WW_SKINNING),
    -- active = ns.conditions.Profession(ns.PROF_WW_SKINNING, 25),
    group = "professionknowledge",
    atlas="worldquest-icon-skinning",
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [60042800] = { -- or 60002807
        quest=83915,
        loot={226341}, -- Earthen Worker's Beams
        vignette=6498,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [28765174] = { -- or 26346095
        quest=83914,
        loot={226340}, -- Dornogal Carving Knife
        vignette=6497,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [44232837] = {
        quest=83916,
        loot={226342}, -- Artisan's Drawing Knife
        vignette=6499,
    },
    [61536190] = { -- 61626188
        quest=83917,
        loot={226343}, -- Fungarian's Rich Tannin
        vignette=6500,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [49356211] = {
        quest=83918,
        loot={226344}, -- Arathi Tanning Agent
        vignette=6501,
    },
    [42305391] = { -- 42275378
        quest=83919,
        loot={226345}, -- Arathi Craftsman's Spokeshave
        vignette=6502,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [56995864] = { -- 56585529
        quest=83921,
        loot={226347}, -- Carapace Shiner
        vignette=6504,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [44604929] = { -- to lower?
        quest=83920,
        loot={226346}, -- Nerubian's Slicking Iron
        vignette=6503,
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
