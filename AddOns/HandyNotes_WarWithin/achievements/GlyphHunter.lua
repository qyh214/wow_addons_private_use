local myname, ns = ...

-- Skyriding Glyphs
local GLYPH = ns.nodeMaker{
    atlas="Warfront-AllianceHero-Silver",
    scale=1.4,
    minimap=true,
    requires=ns.DRAGONRIDING,
    group="glyphs",
    -- loot={{223267, mount=2181}}, -- Swarmite Skyhunter
    note="Collect all the glyphs for the {item:223267:Swarmite Skyhunter}",
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [75722213] = {criteria=67178,}, -- Skyriding Glyphs: The Three Shields
    [23055860] = {criteria=69237,}, -- Skyriding Glyphs: Dhar Oztan
    [37854094] = {criteria=69238,}, -- Storm's Watch, Isle of Dorn
    [44517973] = {criteria=69239,}, -- Dhar Durgaz, Isle of Dorn
    [68287183] = {criteria=69240,}, -- Sunken Shield, Isle of Dorn
    [47762674] = {criteria=69241,}, -- Thul Medran, Isle of Dorn
    [56191779] = {criteria=69242,}, -- Thunderhead Peak, Isle of Dorn
    [78234264] = {criteria=69243,}, -- Cinderbrew Meadery, Isle of Dorn
    [62104486] = {criteria=69244,}, -- Mourning Rise, Isle of Dorn
    [71914719] = {criteria=69245,}, -- Ironwold, Isle of Dorn
}, GLYPH{achievement=40166})

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [45903161] = {criteria=69246,}, -- Gundargaz, The Ringing Deeps
    [43871019] = {criteria=69247,}, -- The Stonevault Exterior, The Ringing Deeps
    [53623159] = {criteria=69248,}, -- The Lost Mines, The Ringing Deeps
    [65003445] = {criteria=69249,}, -- Chittering Den, The Ringing Deeps
    [52685607] = {criteria=69250,}, -- The Rumbling Wastes, The Ringing Deeps
    [46196613] = {criteria=69251,}, -- The Living Grotto, The Ringing Deeps
    [59839493] = {criteria=69252,}, -- Abyssal Excavation, The Ringing Deeps
    [58896610] = {criteria=69253,}, -- Taelloch Mine, The Ringing Deeps
    [43475157] = {criteria=69254,}, -- The Waterworks, The Ringing Deeps
}, GLYPH{achievement=40703})

ns.RegisterPoints(ns.HALLOWFALL, {
    [62965184] = {criteria=69255, note="Quite high up"}, -- The Fangs, Hallowfall
    [57173259] = {criteria=69256,}, -- Sina's Yearning, Hallowfall
    [63656535] = {criteria=69257,}, -- Sanguine Grasps, Hallowfall
    [69944420] = {criteria=69258,}, -- Dunelle's Kindness, Hallowfall
    [62760721] = {criteria=69259,}, -- Bleak Sand, Hallowfall
    [43325275] = {criteria=69260,}, -- Mereldar, Hallowfall
    [35403385] = {criteria=69261,}, -- Priory of the Sacred Flame, Hallowfall
    [30795156] = {criteria=69262,}, -- Fortune's Fall, Hallowfall
    [45691230] = {criteria=69263,}, -- Velhan's Claim, Hallowfall
    [57686460] = {criteria=69264, note="Down between the ship and the dock"}, -- Tenir's Ascent, Hallowfall
}, GLYPH{achievement=40704})

ns.RegisterPoints(ns.AZJKAHET, {
    [63311399] = {criteria=69265,}, -- Arathi's End, Azj-Kahet
    [46692129] = {criteria=69266, note="On ledge very high above"}, -- Siegehold, Azj-Kahet
    [25144058] = {criteria=69267, note="Up in the canopy"}, -- Ruptured Lake, Azj-Kahet
    [43125702] = {criteria=69268,}, -- Eye of Ansurek, Azj-Kahet
    [58628980] = {criteria=69270,}, -- Deepwalker Pass, Azj-Kahet
    [66298505] = {criteria=69271,}, -- The Maddening Deep, Azj-Kahet
    [73218411] = {criteria=69272,}, -- Rak-Ush, Azj-Kahet
    [57615755] = {criteria=69273,}, -- Silken Ward, Azj-Kahet
    [70582519] = {criteria=69274,}, -- Trickling Abyss, Azj-Kahet
    [65435176] = {criteria=69275,}, -- Untamed Valley, Azj-Kahet
}, GLYPH{achievement=40705})
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [13323352] = {criteria=69269,}, -- Old Sacrificial Pit, Azj-Kahet
}, GLYPH{achievement=40705, parent=true})

ns.RegisterPoints(ns.KARESH, {
    [60983883] = {criteria=106183}, -- Castigaar, K'aresh
    [46495839] = {criteria=106184}, -- Eco-Dome: Primus, K'aresh
    [54702338] = {criteria=106185}, -- Fracture of Laacuna, K'aresh
    [76474629] = {criteria=106186}, -- North Sufaad, K'aresh
    [54735317] = {criteria=106187}, -- Serrated Peaks, K'aresh
    [43931704] = {criteria=106188}, -- Shadow Point, K'aresh
    [74073252] = {criteria=106190}, -- The Oasis, K'aresh
}, GLYPH{achievement=42727})
ns.RegisterPoints(ns.KARESH_TAZAVESH, {
    [55126762] = {criteria=106189}, -- Tazavesh, the Veiled Market, K'aresh
}, GLYPH{achievement=42727, parent=true})
