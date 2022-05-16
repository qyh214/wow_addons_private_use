local myname, ns = ...

local icon = "poi-islands-table"

ns.RegisterPoints(1525, { -- Revendreth
    [72896582] = {criteria=48556,}, --  Caretaker's Manor
    [61237429] = {criteria=48558,}, --  Witherfall Ruin
    [65953242] = {criteria=48560,}, --  Catacombs of Regret
    [51087841] = {criteria=48562,}, --  The Night Market
    [46575951] = {criteria=48564,}, --  Stalker's Lodge
    [55083633] = {criteria=48566,}, --  Redelav District
    [29175002] = {criteria=48568,}, --  Ember Ward
    [45204559] = {criteria=48570,}, --  Court of the Harvesters
    [21605517] = {criteria=48572,}, --  The Shrouded Asylum
    [75263741] = {criteria=48557,}, -- Archivam
    [66985880] = {criteria=48559,}, -- The Endmire
    [61133879] = {criteria=48561,}, -- Old Gate
    [43027136] = {criteria=48563,}, -- The Banewood
    [49295058] = {criteria=48565,}, -- Chalice District
    [40948022] = {criteria=48567,}, -- Dredhollow
    [45875086] = {criteria=48569,}, -- Darkwall Tower
    [43543423] = {criteria=48571,}, -- Dominance Gate
    [25992886] = {criteria=48573,}, -- Dominance Keep
}, {
    achievement=14306, -- Explore Revendreth
    atlas=icon, scale=1.2,
})

ns.RegisterPoints(1536, { -- Maldraxxus
    [49774613] = {criteria=50085,}, -- Theater of Pain
    [39165540] = {criteria=50087,}, -- The Spearhead
    [50466782] = {criteria=50089,}, -- Seat of the Primus
    [59687193] = {criteria=50091,}, -- House of Plagues
    [63613619] = {criteria=50093,}, -- House of Rituals
    [30022836] = {criteria=50095,}, -- House of Constructs
    [54673240] = {criteria=50097,}, -- Forgotten Wounds
    [27993688] = {criteria=50086,}, -- The Stitchyard
    [43312904] = {criteria=50088,}, -- Sepulcher of Knowledge
    [34547728] = {criteria=50092,}, -- House of the Chosen
    [54611638] = {criteria=50094,}, -- House of Eyes
    [65044842] = {criteria=50096,}, -- Glutharn's Decay
    [29695934] = {criteria=50098,}, -- Burning Thicket
}, {
    achievement=14305, -- Explore Maldraxxus
    atlas=icon, scale=1.2,
})

ns.RegisterPoints(1533, { -- Bastion
    [45847954] = {criteria=48532,}, -- Vestibule of Eternity
    [62157360] = {criteria=48534,}, -- Purity's Pinnacle
    [49885752] = {criteria=48536,}, -- The Mnemonic Locus
    [58282882] = {criteria=48538,}, -- Elysian Hold
    [38005919] = {criteria=48540,}, -- Temple of Courage
    [46916346] = {criteria=48542,}, -- Agthia's Repose
    [61224387] = {criteria=48533,}, -- Temple of Humility
    [51414947] = {criteria=48535,}, -- Firstborne's Bounty
    [50792101] = {criteria=48537,}, -- The Eternal Forge
    [27592836] = {criteria=48539,}, -- Citadel of Loyalty
    [54908232] = {criteria=48541,}, -- Aspirant's Crucible
}, {
    achievement=14303, -- Explore Bastion
    atlas=icon, scale=1.2,
})

ns.RegisterPoints(1565, { -- Ardenweald
    [61263441] = {criteria=48543,}, -- Dusty Burrows
    [64811983] = {criteria=48545,}, -- Starlit Overlook
    [24946095] = {criteria=48547,}, -- Tirna Scithe
    [47985136] = {criteria=48549,}, -- Heart of the Forest
    [51193372] = {criteria=48551,}, -- Glitterfall Basin
    [35546643] = {criteria=48553,}, -- Darkreach
    [36612949] = {criteria=48555,}, -- Gossamer Cliffs
    [31003443] = {criteria=48544,}, -- The Stalks
    [52365972] = {criteria=48546,}, -- Shimmerbough
    [60235340] = {criteria=48548,}, -- Hibernal Hollow
    [53517442] = {criteria=48550,}, -- Gormhive
    [66375570] = {criteria=48552,}, -- Tirna Noch
    [72832756] = {criteria=48554,}, -- Crumbled Ridge
}, {
    achievement=14304, -- Explore Ardenweald
    atlas=icon, scale=1.2,
})

ns.RegisterPoints(1543, { -- The Maw
    [23853667] = {criteria=49501,}, -- Calcis
    [16914943] = {criteria=49503,}, -- Crucible of the Damned
    [31373372] = {criteria=49505,}, -- Gorgoa, River of Souls
    [32886654] = {criteria=49507,}, -- Perdition Hold
    [62506685] = {criteria=49509,}, -- Ravener's Lament
    [49576330] = {criteria=49511,}, -- The Beastwarrens
    [42864312] = {criteria=49502,}, -- Cocyrus
    [55196209] = {criteria=49504,}, -- Desmotaeron
    [47008086] = {criteria=49506,}, -- Marrow's Coppice
    [33242161] = {criteria=49508,}, -- Planes of Torment
    [23156838] = {criteria=49510,}, -- The Altar of Damnation
    [38784131] = {criteria=49512,}, -- Zovaal's Cauldron
}, {
    achievement=14663, -- Explore the Maw
    atlas=icon, scale=1.2,
})

ns.RegisterPoints(1961, { -- Korthia
    [40115298] = {criteria=52092,}, -- Estuary of Awakening
    [60812408] = {criteria=52094,}, -- Keeper's Respite
    [57272249] = {criteria=52096,}, -- Sanctuary of Guidance
    [54965391] = {criteria=52098,}, -- Seeker's Quorum
    [30215507] = {criteria=52100,}, -- Windswept Aerie
    [35053494] = {criteria=52093,}, -- Hope's Ascent
    [53513101] = {criteria=52095,}, -- Mauler's Outlook
    [61843097] = {criteria=52097,}, -- Scholar's Den
    [49666462] = {criteria=52099,}, -- Vault of Secrets
}, {
    achievement=15053, -- Explore Korthia
    atlas=icon, scale=1.2,
})

ns.RegisterPoints(1970, { -- Zereth Mortis
    [38006300] = {criteria=52855,}, -- The Great Veldt
    [40004100] = {criteria=52857,}, -- Terrace of Formation
    [57303150] = {criteria=52859,}, -- Deserted Overlook
    [59002200] = {criteria=52861,}, -- The Dread Portal
    [40007200] = {criteria=52863,}, -- Genesis Fields
    [59005100] = {criteria=52865,}, -- Pilgrim's Grace
    [66003600] = {criteria=52867,}, -- Arrangement Index
    [51002900] = {criteria=52869,}, -- Resonant Peaks
    [34006800] = {criteria=52854,}, -- Haven
    [36004300] = {criteria=52856,}, -- Faith's Repose
    [44008700] = {criteria=52858,}, -- Catalyst Gardens
    [52007200] = {criteria=52860,}, -- Dimensional Falls
    [46006400] = {criteria=52862,}, -- Provis Fauna
    [41003100] = {criteria=52864,}, -- Zovaal's Grasp
    [54004700] = {criteria=52866,}, -- Plain of Actualization
    [56008400] = {criteria=52868,}, -- Lexical Glade
    [27005300] = {criteria=52588,}, -- Path of Inception
}, {
    achievement=15224, -- Explore Zereth Mortis
    atlas=icon, scale=1.2,
})
