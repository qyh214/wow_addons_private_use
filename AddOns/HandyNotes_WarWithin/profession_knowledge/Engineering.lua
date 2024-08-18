local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2788,
    requires = ns.conditions.Profession(ns.PROF_WW_ENGINEERING),
    -- active = ns.conditions.Profession(ns.PROF_WW_ENGINEERING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [61306953] = {
        quest=83866,
        loot={226292}, -- Rock Engineer's Wrench
        vignette=6449,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [66906192] = {
        quest=83867,
        loot={226293}, -- Dornogal Spectacles
        vignette=6450,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [42672729] = {
        quest=83868,
        loot={226294}, -- Inert Mining Bomb
        vignette=6451,
    },
    [64535879] = {
        quest=83869,
        loot={226295}, -- Earthen Construct Blueprints
        vignette=6452,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [46336142] = {
        quest=83870,
        loot={226296}, -- Holy Firework Dud
        vignette=6453,
    },
    [41614889] = {
        quest=83871,
        loot={226297}, -- Arathi Safety Gloves
        vignette=6454,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [56903864] = {
        quest=83872,
        loot={226298}, -- Puppeted Mechanical Spider
        vignette=6455,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [63171133] = {
        quest=83873,
        loot={226299}, -- Emptied Venom Canister
        vignette=6456,
        parent=true, levels=true, translate={[2256]=true},
    },
    [46802020] = {
        quest=82632,
        loot={224052}, -- Clocks, Gears, Sprockets, and Legs
        note="Buy from {npc:218195:Rukku}",
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
