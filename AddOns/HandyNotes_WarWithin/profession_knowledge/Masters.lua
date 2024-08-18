local myname, ns = ...

local KNOWLEDGE = {
    note="Profession master; talk to them for knowledge",
    texture=ns.atlas_texture("Professions-Crafting-Orders-Icon", {r=0.5,g=1,b=1,}),
    group="professionknowledge",
    minimap=true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    -- [73276971] = { -- Zenzi
    --     quest=70259,
    --     npc=194844,
    --     currency=2033,
    --     requires=ns.conditions.Profession(ns.PROF_DF_SKINNING),
    --     active=ns.conditions.Profession(ns.PROF_DF_SKINNING, 25),
    -- },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
}, KNOWLEDGE)
