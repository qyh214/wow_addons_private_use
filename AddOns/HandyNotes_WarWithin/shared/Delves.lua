local myname, ns = ...
local _, myfullname = C_AddOns.GetAddOnInfo(myname)

local STURDY = ns.nodeMaker{
    lable="Sturdy Chest",
    group="delves",
    minimap=true,
}

local CRYSTAL = {ns.rewards.Currency(ns.CURRENCY_RESONANCE, 250)}

ns.RegisterPoints(2269, { -- Earthcrawl Mines
    [45341512] = {quest=83440, loot=CRYSTAL}, -- Resonance Crystals
    [43522692] = {quest=83438, loot={226002}}, -- Expensive-Looking Find
    [32824004] = {quest=83451, loot={221756}}, -- Vial of Kaheti Oils
    [36293302] = {quest=83441, loot={211062, 211033}, note="Jump down from above, onto the crane"}, -- Treasure-Seeker's Shawl, Secret-Dredger's Legguards
    [53158208] = {quest=83439, loot={226109, 226107}}, -- Squirming Swarm Sac, Homebrewed Blink Vial
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
    [40706135] = {quest=83672, loot=CRYSTAL, note="Jump down"}, -- Resonance Crystals
}, STURDY{
    achievement=40808, -- Discoveries
})

ns.RegisterPoints(2249, { -- Fungal Folly
    [32737407] = {quest=83671, loot=CRYSTAL}, -- Resonance Crystals
    [58644691] = { -- Secret-Dredger's Gauntlets
        quest=83702, loot={211032}, note="May need to jump down to this",
        path={55844465, 53394431, 54175113}
    },
    [53324147] = { -- Snake Oil, Ancient Tool
        quest=83690, loot={226003, 226005}, note="Bounce up",
        path={55744326, 55844465},
    },
    [49563598] = {quest=83452, loot={{225556, toy=true}}}, -- Ancient Construct
    [34406546] = {quest=83689, loot={226003, 226001}, note="Under the waterfall"}, -- Snake Oil, Pure Gold Stein
}, STURDY{
    achievement=40803, -- Discoveries
})

ns.RegisterPoints(2250, { -- Kriegval's Rest
    [46241972] = {quest=83665, loot=CRYSTAL}, -- Resonance Crystals
    [62155287] = {quest=83698, loot={211029, 211062}, path={62185467, 63965416,}, note="Jump up the junk"}, -- Secret-Dredger's Helm, Treasure-Seeker's Shawl
    [74487010] = {quest=83683, loot={226005, 226003}}, -- Ancient Tool, Snake Oil
    [69968521] = {quest=83666, loot=CRYSTAL}, -- Resonance Crystals
}, STURDY{
    achievement=40807, -- Discoveries
})

ns.RegisterPoints(2277, { -- Nightfall Sanctum
    [77783613] = {quest=83688, loot={226005}}, -- Ancient Tool
    [70914449] = {quest=83670, loot=CRYSTAL, note="Jump down to this (or use the double-jump power)", path=70834054}, -- Resonance Crystals
    [39147434] = {quest=83454, loot={221758}}, -- Profaned Tinderbox
    [40043669] = {quest=83701, loot={219354}, note="Jump down from the ship", path={38654083, 38424814},}, -- Mountain Shaper's Greataxe
}, STURDY{
    achievement=40809, -- Discoveries
})

ns.RegisterPoints(2310, { -- Skittering Breach
    [50796572] = {quest=83679, loot={226001}}, -- Pure Gold Stein
    [27362648] = {quest=83660, loot=CRYSTAL}, -- Resonance Crystals
    [56112421] = {quest=83696, loot={211031}}, -- Secret-Dredger's Sabatons
    [66761466] = {quest=83680, loot={226004}}, -- Olden Text
}, STURDY{
    achievement=40810, -- Discoveries
})

ns.RegisterPoints(2259, { -- Tak-Rethan Abyss
    [59752480] = {quest=83651, loot={226109}, note="Above the pool"}, -- Squirming Swarm Sac
    [64744931] = {quest=83686, loot={226004}, note="Climb the coral"}, -- Olden Text
    [44794979] = {quest=83687, loot={226003}}, -- Snake Oil
    [35115861] = {quest=83669, loot=CRYSTAL}, -- Resonance Crystals
}, STURDY{
    achievement=40811, -- Discoveries
})

ns.RegisterPoints(2302, { -- The Dread Pit
    [41124548] = {quest=83677, loot={226001, 226003}, note="Behind rocks"}, -- Pure Gold Stein, Snake Oil
    [57465613] = {quest=83658, loot=CRYSTAL}, -- Resonance Crystals
    [57852763] = {quest=83678, loot={226005}}, -- Ancient Tool
    [36291664] = {quest=83659, loot=CRYSTAL}, -- Resonance Crystals
}, STURDY{
    achievement=40812, -- Discoveries
})

ns.RegisterPoints(2301, { -- The Sinkhole
    [52291335] = {quest=83453, loot={221757}, note="At the bottom of the pool"}, -- Gloomfathom Hide
    [43446070] = {quest=83668, loot=CRYSTAL}, -- Resonance Crystals
    [72566119] = {quest=83700, loot={211063}}, -- Long-Lost Choker
    [48436926] = {quest=83685, loot={226001}}, -- Pure Gold Stein
}, STURDY{
    achievement=40813, -- Discoveries
})

ns.RegisterPoints(2347, { -- The Spiral Weave
    [50164325] = {quest=83649, loot={226107}, note="Under the {npc:227747:Crawler Eggs}"}, -- Homebrewed Blink Vial
    [36381082] = {quest=83661, loot={}, note="Up on the beam; only reachable during the {achievement:40536.68787:From The Weaver With Love} variant"}, --
    [46014630] = {quest=83681, loot={226005}, note="Jump down from the bridge, onto the pillar"}, -- Ancient Tool
    [42324780] = {quest=83662, loot=CRYSTAL, note="Jump down from the bridge, onto the beam", route={47004651, 46034617, 42324780}}, --
}, STURDY{
    achievement=40814, -- Discoveries
})

ns.RegisterPoints(2299, { -- The Underkeep
    [35913464] = {quest=83664, loot=CRYSTAL}, -- Resonance Crystals
    [63613256] = {quest=83682, loot={226003}, note="Reachable during the {achievement:40534.68779:Torture Victims} variant"}, -- Snake Oil
    [72118902] = {quest=83697, loot={211036}}, -- Secret-Dredger's Armplates
    [38946882] = {quest=83663, loot={}, note="Reachable during the {achievement:40534.68780:Weaver Rescue} variant"}, --
}, STURDY{
    achievement=40815, -- Discoveries
})

ns.RegisterPoints(2251, { -- The Waterworks
    [49902459] = {quest=83684, loot={226002, 226005}}, -- Expensive-Looking Find, Ancient Tool
    [44383823] = {quest=83650, loot={226131, 223287}}, -- Deployable Wind-Wrangling Spire, Atomized Salien Slime
    [47925350] = {quest=83667, loot=CRYSTAL}, -- Resonance Crystals
    [49577916] = {quest=83456, loot={221754}}, -- Ringing Deeps Ingot
}, STURDY{
    achievement=40816, -- Discoveries
})

----

EventUtil.ContinueOnAddOnLoaded("Blizzard_WorldMap", function()
    local delves = {
        --[areaPoiID] = {stories, discoveries, other...}
        [7863] = {40527, 40806, 40453}, -- Earthcrawl Mines (Nerubian)
        [7864] = {40525, 40803, 40445}, -- Fungal Folly (Fungal)
        [7865] = {40526, 40807, 40446}, -- Kriegval's Rest (Kobold)
        [7866] = {40528, 40816, 40446}, -- The Waterworks (Kobold)
        [7867] = {40529, 40812, 40453}, -- The Dread Pit (Nerubian)
        [7868] = {40530, 40809, 40454}, -- Nightfall Sanctum (Order of Night)
        [7869] = {40531, 40808, 40445}, -- Mycomancer Cavern (Fungal)
        [7870] = {40532, 40813, 40452}, -- The Sinkhole (Kobyss)
        [7871] = {40533, 40810, 40453}, -- Skittering Breach (Nerubian)
        [7872] = {40534, 40815, 40453}, -- The Underkeep (Nerubian)
        [7873] = {40535, 40811, 40452}, -- Tak-Rethan Abyss (Kobyss)
        [7874] = {40536, 40814, 40453}, -- The Spiral Weave (Nerubian)
    }
    EventRegistry:RegisterCallback("AreaPOIPin.MouseOver", function(_, pin, tooltipShown, areaPoiID, name)
        -- print("AreaPOIPin.MouseOver", pin, tooltipShown, areaPoiID, name)
        if ns.db.groupsHidden.delves then
            return
        end
        if tooltipShown and delves[areaPoiID] then
            local tooltip = GetAppropriateTooltip()
            for i, achievement in ipairs(delves[areaPoiID]) do
                -- we want to show the full criteria list for the first one (stories), and just the summary for the second
                ns.tooltipHelpers.achievement(tooltip, achievement, i == 1)
            end
            tooltip:AddDoubleLine(" ", myfullname:gsub("HandyNotes: ", ""), 0, 1, 1, 0, 1, 1)
            tooltip:Show()
        end
    end)
end)
