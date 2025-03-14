local myname, ns = ...

local LORE = {
    achievement=40762,
    texture=ns.atlas_texture("profession", {r=1, g=1, b=0}),
    -- minimap=true,
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [37305250] = {criteria=69369, quest=82038, vignette=6182}, -- Galan's Edict
    [44083014] = {criteria=69371, quest=82046, vignette=6188}, -- Stone of The Unbound
    [78132784] = {criteria=69370, quest=82045, vignette=6187}, -- Titan Console
    [57222001] = {criteria=69372, quest=82047, vignette=6189}, -- Watcher of the North
    [42128025] = {criteria=69373, quest=82048, vignette=6190}, -- Watcher of the South
}, LORE)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [36811739] = {criteria=69374, quest=82049, vignette=6191}, -- A Skull on a Sign
    [60815613] = {criteria=69378, quest=82054, vignette=6195}, -- Kobold Warning Sign
    [48187243] = {criteria=69376, quest=82052, vignette=6193}, -- Submerged Sign
    [66824240] = {criteria=69375, quest=82051, vignette=6192}, -- Warning: Collapsed Tunnel
    [47015826] = {criteria=69377, quest=82053, vignette=6194}, -- Wax-Drenched Sign
}, LORE)

ns.RegisterPoints(ns.HALLOWFALL, {
    [62214557] = {criteria=69383, quest=82066, vignette=6200}, -- A Scout's Journal
    [71423667] = {criteria=69382, quest=82065, vignette=6199}, -- A Tattered Note
    [78244042] = {criteria=69381, quest=82064, vignette=6198}, -- A Weathered Tome
    [25085372] = {criteria=69380, quest=82063, vignette=6197}, -- A Worn Down Book
    [25733844] = {criteria=69379, quest=82061, vignette=6196}, -- Captain's Chest (Last Flight of the Soundness)
}, LORE)

ns.RegisterPoints(ns.AZJKAHET, {
    [75443324] = {criteria=69387, quest=82069, vignette=6202}, -- Kah'teht
    [54071888] = {criteria=69388, quest=82067, vignette=6201}, -- Mad Nerubian
    [71126233] = {criteria=69384, quest=82082, vignette=6206}, -- Weathered Shadecaster
}, LORE)
ns.RegisterPoints(ns.CITYOFTHREADS, {
    [77557019] = {criteria=69385, quest=82079, vignette=6205, parent=true}, -- Forgotten Shadecaster
    [08543058] = {criteria=69386, quest=82085, vignette=6207, note="Above the city", parent=true}, -- Neglected Shadecaster
}, LORE)
