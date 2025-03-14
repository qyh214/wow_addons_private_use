local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2791,
    requires = ns.conditions.Profession(ns.PROF_WW_JEWELCRAFTING),
    -- active = ns.conditions.Profession(ns.PROF_WW_JEWELCRAFTING, 25),
    group = "professionknowledge",
    atlas="worldquest-icon-jewelcrafting",
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [63536683] = {
        quest=83890,
        loot={226316}, -- Gentle Jewel Hammer
        vignette=6473,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [34655199] = { -- or 33386163?
        quest=83891,
        loot={226317}, -- Earthen Gem Pliers
        vignette=6474,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45433517] = {
        quest=83892,
        loot={226318}, -- Carved Stone File
        vignette=6475,
    },
    [53355463] = {
        quest=83893,
        loot={226319}, -- Jeweler's Delicate Drill
        vignette=6476,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [47396063] = {
        quest=83894,
        loot={226320}, -- Arathi Sizing Gauges
        vignette=6477,
    },
    [44655094] = {
        quest=83895,
        loot={226321}, -- Librarian's Magnifiers
        vignette=6478,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [56165877] = {
        quest=83897,
        loot={226323}, -- Nerubian Bench Blocks
        vignette=6480,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [47741940] = {
        quest=83896,
        loot={226322}, -- Ritual Caster's Crystal
        vignette=6479,
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
