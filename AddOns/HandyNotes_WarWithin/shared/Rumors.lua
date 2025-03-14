local myname, ns = ...
local _, myfullname = C_AddOns.GetAddOnInfo(myname)

-- Rumor Brokers

local RUMOR = {
    label="Rumor Broker",
    atlas="notoriety-32x32",
    loot={},
    hide_before=ns.WORLDQUESTS,
    group="rumor",
}

--[[
[] = {quest=82642, vignette=6295,},
[] = {quest=82644, vignette=6296,},
[] = {quest=82642, vignette=6299,},
[] = {quest=82642, vignette=6301,},
[] = {quest=82644, vignette=6303,},
[] = {quest=82644, vignette=6304,},
[] = {quest=82646, vignette=6306,},
[] = {quest=82648, vignette=6307,},
[] = {quest=82581, vignette=6542,},
[] = {quest=82646, vignette=6543,},
[] = {quest=82640, vignette=6544,},
[] = {quest=82644, vignette=6545,},
[] = {quest=82642, vignette=6547,},
[] = {quest=82640, vignette=6548,},
[] = {quest=82581, vignette=6549,},
[] = {quest=82581, vignette=6550,},
[] = {quest=82581, vignette=6551,},
[] = {quest=82640, vignette=6552,},
[] = {quest=82640, vignette=6554,},
[] = {quest=82581, vignette=6555,},
[] = {quest=82640, vignette=6556,},
[] = {quest=82642, vignette=6557,},
[] = {quest=82581, vignette=6558,},
[] = {quest=82648, vignette=6559,},
[] = {quest=82648, vignette=6560,},
[] = {quest=82648, vignette=6561,},
[] = {quest=82644, vignette=6562,},
--]]

ns.RegisterPoints(ns.AZJKAHET, {
    [33274910] = {quest=82642, vignette=6300,}, -- Eirzay 224162, gave 81487
    [61432414] = {quest=82646, vignette=6308,}, -- Eirzay 224176, gave 81494
    [64217526] = { -- Ru'murh 224200
        quest=82648,
        vignette=6541,
        -- gave 81503 terror made manifest
    },
    [54476362] = {quest=82646, vignette=6305,}, -- Eirzay 224172, gave 81492
}, RUMOR)
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [30892302] = { -- Ghos'opp 224189
        quest=82642,
        vignette=6553,
        -- gave
    },
    [77855369] = { -- Ru'murh 224196
        quest=82581,
        vignette=6546,
        -- gave
    },
    [52021664] = {quest=82640, vignette=6564,}, -- Ghos'opp 224177, gave 81479
    [64162119] = {quest=82640, vignette=6563,}, -- Ghos'opp 224178, gave 81495
}, RUMOR)
ns.RegisterPoints(ns.CITYOFTHREADSLOWER, {
    [49664432] = { -- Eirzay 224168
        quest=82644,
        vignette=6302,
        -- gave 81490 bounty balaxir the bully
        levels=true,
    },
}, RUMOR)

-- Weave-Rat caches

local CACHE = {
    label="Weave-Rat Cache", -- Thimble
    atlas="notoriety-32x32",
    loot={},
    -- TODO: detect pact for the week
    -- 80544 for chosing the Weaver?
    hide_before={ns.conditions.QuestComplete(80544)},
    group="rumor",
}

--[[
[] = {quest=80559, vignette=6338,},
[] = {quest=80580, vignette=6340,},
[] = {quest=82855, vignette=6342,},
[] = {quest=82856, vignette=6343,},
[] = {quest=82858, vignette=6345,},
[] = {quest=82859, vignette=6346,},
[] = {quest=82860, vignette=6347,},
[] = {quest=82862, vignette=6349,},
[] = {quest=80559, vignette=6388,},
[] = {quest=80579, vignette=6389,},
[] = {quest=80580, vignette=6390,},
[] = {quest=82854, vignette=6391,},
[] = {quest=82855, vignette=6392,},
[] = {quest=82856, vignette=6393,},
[] = {quest=82857, vignette=6394,},
[] = {quest=82858, vignette=6395,},
[] = {quest=82859, vignette=6396,},
[] = {quest=82860, vignette=6397,},
[] = {quest=82861, vignette=6398,},
[] = {quest=82862, vignette=6399,},
--]]

ns.RegisterPoints(ns.AZJKAHET, {
    [43752660] = { -- from map 83781
        quest=82854,
        vignette=6341,
    },
    [65938810] = {
        quest=82857,
        vignette=6344,
    },
    [60441058] = {
        quest=82861,
        vignette=6348,
    },
}, CACHE)
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [55873247] = { -- Thimble 224885
        quest=80579,
        vignette=6339,
    },
}, CACHE)

-- Forgotten Memorial

local MEMORIAL = {
    label="Forgotten Memorial",
    atlas="notoriety-32x32",
    loot={},
    hide_before={ns.conditions.QuestComplete(80545)}, -- Selected the General
    group="rumor",
}

--[[
[] = {vignette=6087, quest=80688},
[] = {vignette=6097, quest=81467},
[] = {vignette=6107, quest=81572},
[] = {vignette=6317, quest=82873},
[] = {vignette=6318, quest=82874},
[] = {vignette=6319, quest=82875},
[] = {vignette=6320, quest=82876},
[] = {vignette=6321, quest=82877},
[] = {vignette=6322, quest=82878},
[] = {vignette=6324, quest=82880},
[] = {vignette=6325, quest=82881},
[] = {vignette=6400, quest=80688},
[] = {vignette=6401, quest=81467},
[] = {vignette=6402, quest=81572},
[] = {vignette=6403, quest=82873},
[] = {vignette=6404, quest=82874},
[] = {vignette=6405, quest=82875},
[] = {vignette=6406, quest=82876},
[] = {vignette=6407, quest=82877},
[] = {vignette=6408, quest=82878},
[] = {vignette=6409, quest=82879},
[] = {vignette=6410, quest=82880},
[] = {vignette=6411, quest=82881},
--]]

ns.RegisterPoints(ns.AZJKAHET, {
    [41012901] = {vignette=6324, quest=82880},
    [48515960] = {vignette=6323, quest=82879},
}, MEMORIAL)
-- ns.RegisterPoints(ns.CITYOFTHREADS, {
-- }, MEMORIAL)


-- Kaheti Excavation

local EXCAVATION = {
    label="Kaheti Excavation",
    atlas="notoriety-32x32",
    loot={},
    hide_before={ns.conditions.QuestComplete(80546)}, -- Selected the Vizier
    group="rumor",
}

--[[
[] = {vignette=6326, quest=81567},
[] = {vignette=6327, quest=81569},
[] = {vignette=6329, quest=82864},
[] = {vignette=6331, quest=82866},
[] = {vignette=6332, quest=82867},
[] = {vignette=6333, quest=82868},
[] = {vignette=6334, quest=82869},
[] = {vignette=6335, quest=82870},
[] = {vignette=6336, quest=82871},
[] = {vignette=6337, quest=82872},
[] = {vignette=6413, quest=81567},
[] = {vignette=6414, quest=81569},
[] = {vignette=6415, quest=82863},
[] = {vignette=6416, quest=82864},
[] = {vignette=6417, quest=82865},
[] = {vignette=6418, quest=82866},
[] = {vignette=6419, quest=82867},
[] = {vignette=6420, quest=82868},
[] = {vignette=6421, quest=82869},
[] = {vignette=6422, quest=82870},
[] = {vignette=6423, quest=82871},
[] = {vignette=6424, quest=82872},
--]]

ns.RegisterPoints(ns.AZJKAHET, {
    [66555875] = {vignette=6328, quest=82863},
    [79936206] = {vignette=6330, quest=82865},
}, EXCAVATION)
-- ns.RegisterPoints(ns.CITYOFTHREADS, {
-- }, EXCAVATION)
