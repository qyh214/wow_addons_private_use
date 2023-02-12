local myname, ns = ...

local dfengknowledge = {
    note = "This can only be looted once per character.",
    currency=2027,
    requires = ns.conditions.Profession(ns.PROF_DF_ENGINEERING),
    hide_before = ns.conditions.Profession(ns.PROF_DF_ENGINEERING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    minimap = true,
}
-- https://www.wowhead.com/guide/professions/knowledge-point-treasure-locations-dragon-isles
ns.RegisterPoints(ns.WAKINGSHORES, {
    [56004490] = {
        note = "Pick up 4 different items to loot the rocket. Ashes are in the same building; other 3 items are in the bigger building across the open area.",
        loot = {
            201014, -- Boomthyr Rocket
        },
        quest = 70270,
        related = {
            [56054494] = {
                label = "Note on the floor",
                note = "Read this first!",
            },
            [55914529] = {
                label = "{item:198815:Ash}",
            },
            [57844446] = {
                label = "Look for {item:198814:Boom Fumes}/{item:198817:Durable Crystal}/{item:198816:Aerospace Grade Draconium} around this area",
            },
        },
    },
    [49097754] = {
        note = "Click 3x Exposed Wires nearby before looting",
        loot = {
            198789, -- Intact Coil Capacitor
        },
        quest = 70275,
    },
}, dfengknowledge)
--[[
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [] = {
        note = "",
        loot = {
            , -- 
        },
        quest = nil,
    },
}, dfengknowledge)

ns.RegisterPoints(ns.AZURESPAN, {
    [] = {
        note = "",
        loot = {
            , -- 
        },
        quest = nil,
    },
}, dfengknowledge)

ns.RegisterPoints(ns.THALDRASZUS, {
    [] = {
        note = "",
        loot = {
            , -- 
        },
        quest = nil,
    },
}, dfengknowledge)
]]
