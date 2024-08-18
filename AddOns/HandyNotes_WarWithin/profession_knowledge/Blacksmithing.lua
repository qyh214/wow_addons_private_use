local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2786,
    requires = ns.conditions.Profession(ns.PROF_WW_BLACKSMITHING),
    -- active = ns.conditions.Profession(ns.PROF_WW_BLACKSMITHING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [59816183] = {
        quest=83848,
        loot={226276}, -- Ancient Earthen Anvil
        vignette=6433,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [47763204] = {
        quest=83849,
        loot={226277}, -- Dornogal Hammer
        vignette=6434,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [47673317] = {
        quest=83850,
        loot={226278}, -- Ringing Hammer Vise
        vignette=6435,
    },
    [60555373] = {
        quest=83851,
        loot={226279}, -- Earthen Chisels
        vignette=6436,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [47586113] = {
        quest=83852,
        loot={226280}, -- Holy Flame Forge
        vignette=6437,
    },
    [44035563] = {
        quest=83853,
        loot={226281}, -- Radiant Tongs
        vignette=6438,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [53005128] = {
        quest=83855,
        loot={226283}, -- Spiderling's Wire Brush
        vignette=6440,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [46552279] = {
        quest=83854,
        loot={226282}, -- Nerubian Smith's Kit
        vignette=6439,
        parent=true, levels=true, translate={[2256]=true},
    },
    -- [] = {
    --     quest=82631,
    --     loot={224038}, -- Smithing After Saronite
    --     note="Buy from {npc::}",
    --     parent=true, levels=true, translate={[2256]=true},
    -- },
}, KNOWLEDGE)
