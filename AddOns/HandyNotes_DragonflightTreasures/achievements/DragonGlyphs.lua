local myname, ns = ...

-- Dragon Glyphs
local GLYPH = ns.nodeMaker{
	atlas="Warfront-AllianceHero-Silver",
	scale=1.4,
    minimap=true,
    requires=ns.DRAGONRIDING,
    group="glyphs",
}

ns.RegisterPoints(ns.WAKINGSHORES, {
    [75005700] = {criteria=55782}, -- Skytop Observatory Tower
    [74345754] = {criteria=56131}, -- Skytop Observatory Rostrum
    [58097858] = {criteria=56132}, -- Flashfrost Enclave
    [54467421] = {criteria=55785}, -- Ruby Life Pools Peaks
    [73082051] = {criteria=55790}, -- Wingrest Embassy
    [40957193] = {criteria=55784}, -- Obsidian Bulwark
    [46405214] = {criteria=55786}, -- The Overflowing Spring
    [52601721] = {criteria=55787}, -- Life-Binder Observatory
    [57705491] = {criteria=55788}, -- Crumbling Life Archway
    [69274623] = {criteria=55789}, -- Dragonheart Outpost
    [74873733] = {criteria=55783}, -- Scalecracker Peak
    [21765140] = {criteria=55791}, -- Obsidian Throne
}, GLYPH{achievement=16575})

ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [57793081] = {criteria=55792}, -- Ohn'ahra's Roost
    [30393607] = {criteria=55793}, -- Nokhudon Hold
    [30156156] = {criteria=55794}, -- Emerald Gardens
    [29547543] = {criteria=55795}, -- The Eternal Kurgans
    [44736457] = {criteria=55796}, -- Szar Skeleth
    [47327216] = {criteria=55797}, -- Mirror of the Sky
    [57138010] = {criteria=55798}, -- Ohn'iri Springs
    [84077727] = {criteria=55799}, -- Dragonsprings Summit
    [86543932] = {criteria=55800}, -- Rusza'thar Reach
    [61376423] = {criteria=55801}, -- Windsong Rise
    [80001300] = {criteria=56134}, -- Rubyscale Outpost
    [78422117] = {criteria=56139}, -- Mirewood Fen
}, GLYPH{achievement=16576})
ns.RegisterPoints(ns.WAKINGSHORES, {
    [48828664] = {criteria=56134}, -- Rubyscale Outpost
}, GLYPH{achievement=16576})

ns.RegisterPoints(ns.AZURESPAN, {
    [45772569] = {criteria=55802}, -- Cobalt Assembly
    [39206301] = {criteria=55803}, -- Azure Archives
    [68656035] = {criteria=55804}, -- Ruins of Karnthar
    [70584626] = {criteria=55805}, -- Lost Ruins
    [10393582] = {criteria=55806}, -- Brackenhide Hollow
    [26733168] = {criteria=55807}, -- Creektooth Den
    [60626999] = {criteria=55808}, -- Imbu
    [52974904] = {criteria=55809}, -- Zelthrak Outpost
    [67642911] = {criteria=55810}, -- Rhonin's Shield
    [72593986] = {criteria=55811}, -- Vakthros Range
    [36552815] = {criteria=56143}, -- Forkriver Crossing
    [56811603] = {criteria=56145}, -- The Fallen Course
}, GLYPH{achievement=16577})
ns.RegisterPoints(ns.OHNAHRANPLAINS, {
    [70118660] = {criteria=56143}, -- Forkriver Crossing
}, GLYPH{achievement=16577})

ns.RegisterPoints(ns.THALDRASZUS, {
    [66018234] = {criteria=55812}, -- Temporal Conflux
    [46097388] = {criteria=55813}, -- Stormshroud Peak
    [35568556] = {criteria=55814}, -- South Hold Gate
    [41265827] = {criteria=55815}, -- Valdrakken
    [49854023] = {criteria=55816}, -- Algeth'era
    [61575661] = {criteria=55817}, -- Tyrhold
    [62414046] = {criteria=55818}, -- Algeth'ar Academy
    [67091176] = {criteria=55819}, -- Veiled Ossuary
    [72405171] = {criteria=55820}, -- Vault of the Incarnates
    [72966914] = {criteria=55821}, -- Thaldraszus Apex
    [52656743] = {criteria=56159}, -- Gelikyr Overlook
    [55767233] = {criteria=56160}, -- Passage of Time
}, GLYPH{achievement=16578})
ns.RegisterPoints(ns.VALDRAKKEN, {
    [59183784] = {criteria=55815}, -- Valdrakken
}, GLYPH{achievement=16578})

ns.RegisterPoints(ns.FORBIDDENREACH, {
    [18381320] = {criteria=58238, --[[achievement=17398--]]}, -- Winglord's Perch
    [20569140] = {criteria=58239, --[[achievement=17399--]]}, -- Talon's Watch
    [62543238] = {criteria=58240, --[[achievement=17400--]]}, -- Froststone Peak
    [79553264] = {criteria=58241, --[[achievement=17401--]]}, -- Dragonskull Island
    [77295510] = {criteria=58242, --[[achievement=17402--]]}, -- Stormsunder Mountain
    [48516897] = {criteria=58243, --[[achievement=17403--]]}, -- The Frosted Spine
    [59056508] = {criteria=58244, --[[achievement=17404--]]}, -- Talonlords' Perch
    [37693069] = {criteria=58245, --[[achievement=17405--]]}, -- Caldera of the Menders
}, GLYPH{achievement=17411})

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [41608030] = {criteria=59544, --[[achievement=17510--]]}, -- Dragon Glyphs: Glimmerogg
    [62707030] = {criteria=59545, --[[achievement=17511--]]}, -- Dragon Glyphs: Nal ks'kol
    [54705480] = {criteria=59546, --[[achievement=17512--]]}, -- Dragon Glyphs: Loamm
    [30404520] = {criteria=59547, --[[achievement=17513--]]}, -- Dragon Glyphs: Zaqali Caldera
    [55202780] = {criteria=59548, --[[achievement=17514--]]}, -- Dragon Glyphs: Slitherdrake Roost
    [72004830] = {criteria=59549, --[[achievement=17515--]]}, -- Dragon Glyphs: The Throughway
    [46503620] = {criteria=59550, --[[achievement=17516--]]}, -- Dragon Glyphs: Acidbite Ravine
    [48000440] = {criteria=59551, --[[achievement=17517--]]}, -- Dragon Glyphs: Aberrus Approach
}, GLYPH{achievement=18150})
