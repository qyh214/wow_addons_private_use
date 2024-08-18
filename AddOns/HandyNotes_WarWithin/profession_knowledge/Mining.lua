local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2793,
    requires = ns.conditions.Profession(ns.PROF_WW_MINING),
    -- active = ns.conditions.Profession(ns.PROF_WW_MINING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [58136201] = {
        quest=83906,
        loot={226332}, -- Earthen Miner's Gavel
        vignette=6489,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [53225301] = { -- 35329153
        quest=83907,
        loot={226333}, -- Dornogal Chisel
        vignette=6490,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [49442773] = {
        quest=83908,
        loot={226334}, -- Earthen Excavator's Shovel
        vignette=6491,
    },
    [66276626] = {
        quest=83909,
        loot={226335}, -- Regenerating Ore
        vignette=6492,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [46126438] = {
        quest=83910,
        loot={226336}, -- Arathi Precision Drill
        vignette=6493,
    },
    [43075684] = {
        quest=83911,
        loot={226337}, -- Devout Archaeologist's Excavator
        vignette=6494,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [48314080] = { -- by "the burrows"
        quest=83913,
        loot={226339}, -- Nerubian Mining Supplies
        vignette=6496, -- Nerubian Mining Cart
        parent=true, levels=true, translate={[2256]=true},
    },
    [46732165] = {
        quest=83912,
        loot={226338}, -- Heavy Spider Crusher
        vignette=6495,
        parent=true, levels=true, translate={[2256]=true},
    },
    -- [] = {
    --     quest=82614,
    --     loot={224055}, -- A Rocky Start
    --     note="Buy from {npc::}",
    --     parent=true,
    -- },
}, KNOWLEDGE)
