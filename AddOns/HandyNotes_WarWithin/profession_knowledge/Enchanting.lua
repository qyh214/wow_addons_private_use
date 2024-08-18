local myname, ns = ...

local KNOWLEDGE = {
    note = "This can only be looted once per character.",
    currency=2787,
    requires = ns.conditions.Profession(ns.PROF_WW_ENCHANTING),
    -- active = ns.conditions.Profession(ns.PROF_WW_ENCHANTING, 25),
    group = "professionknowledge",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5,g=1,b=1,}),
    -- minimap = true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [57636163] = {
        quest=83856,
        loot={226284}, -- Grinded Earthen Gem
        vignette=6441,
    },
}, KNOWLEDGE)
ns.RegisterPoints(ns.DORNOGAL, {
    [59286628] = {
        quest=83859,
        loot={226285}, -- Silver Dornogal Rod
        vignette=6442,
        parent=true,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [44612226] = { -- ?
        quest=83860,
        loot={226286}, -- Soot-Coated Orb
        vignette=6443,
    },
    [67126585] = {
        quest=83861,
        loot={226287}, -- Animated Enchanting Dust
        vignette=6444,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [40047051] = {
        quest=83862,
        loot={226288}, -- Essence of Holy Fire
        vignette=6445,
    },
    [48646453] = {
        quest=83863,
        loot={226289}, -- Enchanted Arathi Scroll
        vignette=6446,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.AZJKAHET, {
    [57314411] = {
        quest=83865,
        loot={226291}, -- Void Shard
        vignette=6448,
    },
}, KNOWLEDGE)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [61492167] = {
        quest=83864,
        loot={226290}, -- Book of Dark Magic
        vignette=6447,
        parent=true, levels=true, translate={[2256]=true},
    },
    -- [] = {
    --     quest=82635,
    --     loot={224050}, -- Web Sparkles: Pretty and Powerful
    --     note="Buy from {npc::}",
    --     parent=true,
    -- },
}, KNOWLEDGE)
