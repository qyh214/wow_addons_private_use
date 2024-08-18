local myname, ns = ...

local STURDY = ns.nodeMaker{
    lable="Sturdy Chest",
    group="delves",
}

ns.RegisterPoints(2269, { -- Earthcrawl Mines
    [45341512] = {quest=83440, currency=761},
    [43522692] = {quest=83438, loot={226002}}, -- Expensive-Looking Find
    [32824004] = {quest=83451, loot={221756}}, -- Vial of Kaheti Oils
    [36293302] = {quest=83441, loot={211062}, note="Jump down from above, onto the crane"}, -- Treasure-Seeker's Shawl
    [53158208] = {quest=83439, loot={226109}}, -- Squirming Swarm Sac
}, STURDY{
    achievement=40806, -- Discoveries
})

-- ns.RegisterPoints(2269, { -- Earthcrawl Mines
--     [42594115] = {
--         -- Reno Jackson (228044) and Sir Finley Mrrgglton (228030)
--         label="Strange Disturbance",
--         quest=nil,
--         vignette=6171,
--     },
-- })

ns.RegisterPoints(2312, { -- Mycomancer Cavern
    [49882164] = {quest=83652, loot={223287}}, -- Atomized Salien Slime
    [63304537] = {quest=83691, loot={226005}, note="Underwater"}, -- Ancient Tool
    [68724128] = {quest=83455, loot={221763}}, -- Viridian Charmcap
    [40706135] = {quest=83672, currency=2815, note="Jump down"}, -- Resonance Crystals
}, STURDY{
    achievement=40808, -- Discoveries
})

ns.RegisterPoints(2249, { -- Fungal Folly
    [32737407] = {quest=83671, currency=2815}, -- Resonance Crystals
    [58644691] = { -- Secret-Dredger's Gauntlets
        quest=83702, loot={211032}, note="May need to jump down to this",
        path={55844465, 53394431, 54175113}
    },
    [53324147] = { -- Snake Oil
        quest=83690, loot={226003}, note="Bounce up",
        path={55744326, 55844465},
    },
    [49563598] = {quest=83452, loot={{225556, toy=true}}}, -- Ancient Construct
    [34406546] = {quest=83689, loot={226003}, note="Under the waterfall"}, -- Snake Oil
}, STURDY{
    achievement=40803, -- Discoveries
})

ns.RegisterPoints(2250, { -- Kriegval's Rest
    [46241972] = {quest=83665, currency=2815}, -- Resonance Crystals
    [62155287] = {quest=83698, loot={211029}, path={62185467, 63965416,}, note="Jump up the junk"}, -- Secret-Dredger's Helm
    [77447010] = {quest=83683, loot={226005}}, -- Ancient Tool
    [69968521] = {quest=83666, currency=2815}, -- Resonance Crystals
}, STURDY{
    achievement=40807, -- Discoveries
})

-- ns.RegisterPoints(, { -- Nightfall Sanctum
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40809, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- Skittering Breach
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40810, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- Tak-Rethan Abyss
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40811, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- The Dread Pit
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40812, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- The Sinkhole
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40813, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- The Spiral Weave
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40814, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- The Underkeep
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40815, -- Discoveries
-- })

-- ns.RegisterPoints(, { -- The Waterworks
--     -- [] = {quest=, loot={}}, --
-- }, STURDY{
--     achievement=40816, -- Discoveries
-- })
