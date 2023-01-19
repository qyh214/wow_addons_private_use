local myname, ns = ...

-- Framing A New Perspective
local framing = {
    achievement=16634,
    atlas="Vehicle-TempleofKotmogu-PurpleBall",
    minimap=true,
    note="Use the {item:122674} and take a picture while standing in the purple glowing area only visible through the camera",
}
ns.RegisterPoints(ns.THALDRASZUS, {
    [38987042] = {criteria=55995, quest=72143}, -- The Cascades
    [55737321] = {criteria=55996, quest=72144, note="On the arch"}, -- Passage of Time
    [68245834] = {criteria=55997, quest=72145}, -- Vault of the Incarnates
    [57195871] = {criteria=55998, quest=72146}, -- Tyrhold
    [50254027] = {criteria=55999, quest=72147, note="Top of the tower"}, -- Algeth'era Court
    [63431348] = {criteria=56000, quest=72148}, -- Veiled Ossuary
    [39414688] = {criteria=56001, quest=72149, note="On floating island"}, -- Serene Dreams Spa
    [48276683] = {criteria=56002, quest=72150}, -- Shadow Ledge
    [46945949] = {criteria=56004, quest=72152}, -- Tyrhold Reservoir
}, framing)
ns.RegisterPoints(ns.VALDRAKKEN, {
    [56244442] = {criteria=55994, quest=72142, note="Top of the tower", parent=true}, -- The Seat of the Aspects
    [56654315] = {criteria=56003, quest=72151, note="On ground floor", parent=true}, -- Valdrakken's Portal Room
}, framing)

-- That's Pretty Neat! (16446)
local neat = {
    achievement=16446,
    atlas="Vehicle-TempleofKotmogu-CyanBall", minimap=true,
    note="Use the {item:122674} and take a picture of this bird",
}
ns.RegisterPoints(ns.WAKINGSHORES, {
    [33117630] = {criteria=55394,}, -- Forgotten Gryphon (npc=197634)
    [42616941] = {criteria=55391,}, -- Territorial Axebeak (npc=197619)
    [49816961] = {criteria=55387,}, -- Drakewing (npc=197613)
    [51411822] = {criteria=55383,}, -- Halia Cloudfeather (npc=193354)
    [51411841] = {criteria=55384,}, -- Avis Gryphonheart (npc=193356)
    [51411842] = {criteria=55385,}, -- Palla of the Wing (npc=193357)
}, neat)
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    -- [] = {criteria=55396,}, -- Quackers the Terrible (npc=197639)
    [31456392] = {criteria=55395,}, -- Zenet Avis (npc=197638)
    [57593191] = {criteria=55386,}, -- Ohn'ahra (npc=197612)
    [59017520] = {criteria=55400,}, -- Nergazurai (npc=197653)
    [62645507] = {criteria=55402,}, -- Glade Ohuna (npc=197658)
    [75814061] = {criteria=55401,}, -- Feasting Buzzard (npc=197655)
}, neat)
ns.RegisterPoints(ns.AZURESPAN, {
    [16412781] = {criteria=55397,}, -- Blue Terror (npc=197646)
    [36813660] = {criteria=55393,}, -- Horned Filcher (npc=197622)
    [66561339] = {criteria=55390,}, -- Pine Flicker (npc=197618)
}, neat)
ns.RegisterPoints(ns.THALDRASZUS, {
    [36617301] = {criteria=55399,}, -- Liskron the Dazzling (npc=197649)
    [43627201] = {criteria=55388,}, -- Chef Fry-Aerie (npc=197614)
    [48405200] = {criteria=55398,}, -- Eldoren the Reborn (npc=197648)
    [53235342] = {criteria=55389,}, -- Iridescent Peafowl (npc=197616)
}, neat)
ns.RegisterPoints(2080, { -- Neltharus
    [52307090] = {criteria=55392,}, -- Apex Blazewing (npc=197621)
}, neat)
