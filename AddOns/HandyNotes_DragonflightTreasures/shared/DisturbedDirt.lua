local myname, ns = ...

local dirt = {
    label="Disturbed Dirt",
    loot={
        -- all the treasure-prerequisite items
        {199061, quest=70527}, -- A Guide To Rare Fish
        {194540, quest=67046}, -- Nokhud Armorer's Notes
        {199065, quest=70534}, -- Sorrowful Letter
        {199066, quest=70535}, -- Letter of Caution
        {199068, quest=70537}, -- Time-Lost Memo
        {199062, quest=70528, requires=ns.conditions.MajorFaction(ns.FACTION_DRAGONSCALE, 21)}, -- Ruby Gem Cluster Map
        {198843, quest=70392, requires=ns.conditions.MajorFaction(ns.FACTION_DRAGONSCALE, 21)}, -- Emerald Gardens Explorer's Notes
        {199067, quest=70536, requires=ns.conditions.MajorFaction(ns.FACTION_DRAGONSCALE, 21)}, -- Precious Plans
        {198852, quest=70407, requires=ns.conditions.MajorFaction(ns.FACTION_DRAGONSCALE, 21)}, -- Bear Termination Orders
        -- the rest
        192055, -- Dragon Isles Artifact
        201390, -- Devastating Drakonid Waraxe
        201391, -- Drakonid Enforcer's Hidesplitter
        201396, -- Hidepiercing Claw Extensions
    },
    -- quest 72023 (after 70822 Lost Expedition Camp) at basecamp *says* it unlocks these, but I saw them before
    requires=ns.conditions.MajorFaction(ns.FACTION_DRAGONSCALE, 5), -- also 70813(Digging Up Treasure) / 72026
    texture=ns.atlas_texture("Professions_Tracking_Ore", {r=0.5, g=1, b=0.5, scale=0.9}),
    group="disturbeddirt", always=true,
    vignette=5466,
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [16079022] = {},
    [16819395] = {},
    [23709660] = {note="In cave"},
    [29079001] = {},
    [33918519] = {note="In cave"},
    [35388494] = {},
    [35548962] = {},
    [35858968] = {},
    [35938774] = {},
    [36358681] = {},
    [37798898] = {},
    [38259517] = {note="In cave"},
    [43134536] = {},
    [44289043] = {},
    [44799229] = {note="In cave"},
    [45597369] = {note="In cave"},
    [46288927] = {},
    [50767598] = {},
    [53464420] = {},
    [54795018] = {},
    [61974125] = {},
    [63706980] = {},
    [64853986] = {},
    [65006959] = {},
    [66347010] = {}, -- bugged?
    [69513968] = {},
    [71436627] = {},
    [72233891] = {},
    -- [75492173] = {note="In cave"},
}, dirt)
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [38706676] = {}, -- by an ancient stone
    [38825561] = {note="In cave"},
    [39555456] = {},
    [42325560] = {},
    [43326632] = {},
    [44686402] = {},
    [46345357] = {},
    [47296085] = {},
    [48857035] = {},
    [49716953] = {},
    [50164423] = {},
    [50184542] = {},
    [51946274] = {},
    [55207077] = {},
    [55568210] = {},
    [55944339] = {},
    [57544863] = {},
    [59922354] = {},
    [60452350] = {},
    [61064821] = {},
    [61245949] = {},
    [62222532] = {},
    [64321154] = {},
    [64501114] = {},
    [65991048] = {},
    [66034860] = {},
    [66285992] = {},
    [66815535] = {note="In cave"},
    [68892204] = {},
    [69077886] = {},
    [70244147] = {},
    [74838850] = {},
    [75492173] = {},
    [76365115] = {},
    [76485475] = {},
    [77664604] = {},
    [78544035] = {},
    [78923703] = {note="In cave"}, -- bugged?
    [79013698] = {},
    [79473665] = {},
    [80133864] = {note="In cave"}, -- bugged?
    [80823852] = {},
    [81103757] = {note="In cave"}, -- bugged?
    [81533246] = {},
    [82814024] = {},
    [83083330] = {},
    [83184162] = {},
    [83253607] = {},
    [83504117] = {},
    [83833290] = {},
    [83964545] = {},
    [84864042] = {},
    [90063505] = {},
    [90823584] = {},
}, dirt)
ns.RegisterPoints(ns.AZURESPAN, {
    [06174151] = {},
    [11413218] = {},
    [12143509] = {},
    [15422052] = {},
    [15922084] = {},
    [16323845] = {},
    [17293730] = {note="In cave"},
    [19235098] = {},
    [20052526] = {},
    [29872621] = {},
    [34754639] = {},
    [35153956] = {},
    [36264755] = {},
    [40325093] = {},
    [41984236] = {},
    [44153092] = {},
    [46862239] = {},
    [47192372] = {},
    [53883561] = {},
    [58272621] = {},
    [59361966] = {},
    [65163016] = {note="In cave"},
    [65193152] = {},
    [65911302] = {},
    [66101129] = {note="In cave"},
    [68301743] = {},
    [72344323] = {note="In cave"},
    [73384059] = {},
    [78923703] = {},
}, dirt)
ns.RegisterPoints(ns.THALDRASZUS, {
    [34556598] = {},
    [35718450] = {},
    [36478409] = {},
    [36547317] = {},
    [36828367] = {},
    [37607978] = {},
    [38198193] = {},
    [38758225] = {},
    [39018418] = {},
    [39768206] = {},
    [40738445] = {},
    [42616654] = {},
    [43728442] = {},
    [46377208] = {},
    [47917274] = {},
    [48495154] = {},
    [50006056] = {},
    [50278321] = {},
    [50397827] = {},
    [51115967] = {},
    [53327640] = {},
    [53495976] = {},
    [55227461] = {},
    [55598459] = {},
    [55918385] = {},
    [58748633] = {},
    [60507774] = {},
    [61057953] = {},
    [62296972] = {},
}, dirt)
ns.RegisterPoints(ns.VALDRAKKEN, {
    [13206380] = {parent=true,},
}, dirt)
