local myname, ns = ...

-- 83264 for random-drop of 225226 Striated Inkstone
-- 83262 for 225227 Wax-Sealed Records in Deep-Lost Satchel

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2790,
    requires = ns.conditions.Profession(ns.PROF_WW_INSCRIPTION),
    -- active = ns.conditions.Profession(ns.PROF_WW_INSCRIPTION, 25),
    group = "professionknowledge",
    atlas="worldquest-icon-inscription",
    backdrop=ns.atlas_texture("CircleMask", {r=0.5, g=1, b=1}),
    border=ns.atlas_texture("AutoQuest-badgeborder", 1.1),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [55976001] = {
        quest=83883,
        loot={226309}, -- Historian's Dip Pen
        vignette=6466,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [57254689] = {
        quest=83882,
        loot={226308}, -- Dornogal Scribe's Quill
        vignette=6465,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45473432] = {
        quest=83884,
        loot={226310}, -- Runic Scroll
        vignette=6467,
    },
    [58485801] = {
        quest=83885,
        loot={226311}, -- Blue Earthen Pigment
        vignette=6468,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [43255894] = {
        quest=83886,
        loot={226312}, -- Informant's Fountain Pen
        vignette=6469,
    },
    [42834907] = {
        quest=83887,
        loot={226313}, -- Calligrapher's Chiseled Marker
        vignette=6470,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [55834390] = {
        quest=83888,
        loot={226314}, -- Nerubian Texts
        vignette=6471,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [50233085] = {
        quest=83889,
        loot={226315}, -- Venomancer's Ink Well
        vignette=6472,
        note="Inside",
        parent=true, levels=true, translate={[2256]=true},
    },
}, KNOWLEDGE)
