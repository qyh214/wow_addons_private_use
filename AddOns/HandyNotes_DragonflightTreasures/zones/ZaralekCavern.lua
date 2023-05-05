local myname, ns = ...

-- Zone added in 10.1.0

-- Zaralek Cavern (2133)
ns.RegisterPoints(ns.ZARALEKCAVERN, {
    --[[
    [0] = { -- Alcanon
        criteria=59188,
        quest=nil,
        npc=203515,
    },
    [0] = { -- Lavermix
        criteria=59201,
        quest=nil,
        npc=203630,
    },
    [0] = { -- Shadowforge Mole Machine
        criteria=59211,
        quest=nil,
        npc=204096,
    },
    [0] = { -- Hadexia
        criteria=59197,
        quest=nil,
        npc=203611,
    },
    [0] = { -- Kronkapace
        criteria=59204,
        quest=75342,
        npc=203642,
    },
    --]]
    [48367509] = { -- Aquifon
        criteria=59185,
        quest=75270, -- 75271
        npc=203468,
        loot={205295}, -- Sediment Sifters
        vignette=5640,
    },
    [57786911] = { -- Underlight Queen
        criteria=59191,
        quest=nil,
        npc=203593,
        vignette=5646,
    },
    [41518613] = { -- Brullo the Strong (Brulsef the Stronk?)
        criteria=59202,
        quest=75325, -- 75326
        npc=203621,
        vignette=5652,
    },
    [55841899] = { -- Professor Gastrinax
        criteria=59189,
        quest=nil,
        npc=203521,
        vignette=5644,
    },
    [46103346] = { -- Invoq (Invohq?)
        criteria=59200,
        quest=nil,
        npc=203627,
        vignette=5654,
    },
    [28875085] = { -- Dinn (Jrumm?)
        criteria=59206,
        quest=nil,
        npc=203646,
        vignette=5660,
    },
    [36324481] = { -- Flowfy
        criteria=59207,
        quest=nil,
        npc=203660,
        vignette=5661,
    },
    [47822342] = { -- Colossian
        criteria=59212,
        quest=nil,
        npc=204093,
        vignette=5674,
    },
    [39407061] = { -- Viridian King
        criteria=59210,
        quest=75366,
        npc=201029,
        vignette=5664,
    },
    [60293933] = { -- Kapraku (Kaprachu?)
        criteria=59184,
        quest=75269,
        npc=203466,
        loot={
            205319, -- Deepflayer Shoulderguards
            205310, -- Legguards of Kaprachu
        },
        vignette=5639,
    },
    [42521879] = { -- General Zskorro
        criteria=59190,
        quest=75296,
        npc=203592,
        loot={205321}, -- Brimstone Bracers
        vignette=5645,
    },
    [32445127] = { -- Emberdusk
        criteria=59209,
        quest=75364,
        npc=203664,
        loot={205335}, -- Talisman of the Dusk
        vignette=5663,
    },
    [65435587] = { -- Kob'rok
        criteria=59183,
        quest=75267,
        npc=203462,
        loot={
            {206021, pet=3545}, -- Kob'rok's Luminescent Scale
            {205152, pet=3546}, -- Skaarn
            {205147, pet=3541}, -- Ridged Shalewing
            205307, -- Kob'rok's Scale Sabatons
        },
        vignette=5638,
    },
    [68734593] = { -- Goopal
        criteria=59186,
        quest=75273, -- 75274
        npc=203477,
        vignette=5641,
    },
    [42176584] = { -- Karokta
        criteria=59199,
        quest=75334,
        npc=203625,
        vignette=5653,
    },
    [53604120] = { -- Klakatak
        criteria=59198,
        quest=75322,
        npc=203618,
        loot={205686}, -- Clacking Claw
        vignette=5651,
    },
    [36425329] = { -- Skornak
        criteria=59205,
        quest=nil,
        npc=203643,
        vignette=5659,
    },
    [53106421] = { -- Spinmarrow
        criteria=59187,
        quest=nil,
        npc=203480,
        path=54986573,
    },
    [37954642] = { -- Subterrax
        criteria=59208,
        quest=75360,
        npc=203662,
        vignette=5662,
    },
    [41383744] = { -- Magtembo (magmanesha?)
        criteria=59203,
        quest=75339, -- 75340
        npc=200111,
        vignette=5656,
    },
}, {
    achievement=17783, -- Adventurer of Zaralek Cavern
})

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [54205180] = { -- Bogg
        quest=nil,
        npc=201747,
    },
    [58205580] = { -- Jalgon Stoutburn
        quest=nil,
        npc=204426,
    },
    --[[
    [0] = { -- Elusive Magma Cobra
        quest=nil,
        npc=204831,
    },
    [0] = { -- Elusive Crystalscale Stonecleaver
        quest=nil,
        npc=204821,
    },
    [0] = { -- Captain Reykal
        quest=nil,
        npc=203355,
    },
    [0] = { -- Lost Lunker
        quest=nil,
        npc=205630,
    },
    [0] = { -- Crimson Oldblood
        quest=nil,
        npc=201054,
    },
    [0] = { -- Rampant Shadowflame
        quest=nil,
        npc=203698,
    },
    [0] = { -- Banechitter
        quest=nil,
        npc=203869,
    },
    [0] = { -- Banechitter
        quest=nil,
        npc=203870,
    },
    [0] = { -- Calibrating Scent Matrix
        quest=nil,
        npc=203606,
    },
    [0] = { -- Dreadswoop
        quest=nil,
        npc=203868,
    },
    [0] = { -- Escaped Elderwing
        quest=nil,
        npc=203326,
    },
    [0] = { -- Flamebringer Rageblood
        quest=nil,
        npc=203703,
    },
    [0] = { -- Happy Child
        quest=nil,
        npc=203871,
    },
    [0] = { -- Treasure Goblin
        quest=nil,
        npc=205490,
    },
    [0] = { -- Vinyeti
        quest=nil,
        npc=202932,
    },
    [0] = { -- Animated Contaminant
        quest=nil,
        npc=202270,
    },
    [0] = { -- Cavern Flayer Matriarch
        quest=nil,
        npc=202309,
    },
    [0] = { -- Contaminated Titan Watcher
        quest=nil,
        npc=203834,
    },
    [0] = { -- Elder Magma Serpent
        quest=nil,
        npc=203846,
    },
    [0] = { -- Flamebringer Cauterizer
        quest=nil,
        npc=203707,
    },
    [0] = { -- Flamebringer Elementalist
        quest=nil,
        npc=203705,
    },
    [0] = { -- Flamebringer Shaman
        quest=nil,
        npc=203700,
    },
    [0] = { -- Half-bound Rageflame
        quest=nil,
        npc=203699,
    },
    [0] = { -- Monstrous Magmaclaw Snapper
        quest=nil,
        npc=202874,
    },
    [0] = { -- Pahi'rys
        quest=nil,
        npc=205540,
    },
    [0] = { -- Response Team Watcher
        quest=nil,
        npc=202318,
    },
    [0] = { -- Rupturing Earth
        quest=nil,
        npc=205791,
    },
    --]]
})

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [36634881] = {criteria=59222, quest=73697, vignette=5534, nearby={36454821, label="Magma Bottle"}}, -- Ancient Zaqali Chest
    [28524794] = {criteria=59220, quest=72986, vignette=5523, note="Equip your {item:15138:Onyxia Scale Cloak} to loot this (really)"}, -- Blazing Shadowflame Chest
    -- [] = {criteria=59225, quest=75232}, -- Bloody Body
    [30054193] = {criteria=59226, quest=73706, vignette=5539, note="On the high ledge"}, -- Charred Egg
    -- [] = {criteria=59224, quest=75187}, -- Chest of the Flights
    -- [] = {criteria=59228, quest=74986}, -- Crystal-Encased Chest
    [62705377] = {criteria=59223, quest=75019, vignette=5593, note="Underwater"}, -- Long-Lost Cache
    [43068257] = { -- Old Trunk
        criteria=59227, quest=74995,
        loot={204810}, -- Drogbar Rocks
        related={
            [42988255] = {label="{npc:204277:Thieving Rock Mouse}", quest=75526, minimap=true,},
            [42148014] = {label="{npc:204277:Thieving Rock Mouse}", quest=75527, hide_before=ns.conditions.QuestComplete(75526), minimap=true,},
            [41728145] = {label="{npc:204277:Thieving Rock Mouse}", quest=75534, hide_before=ns.conditions.QuestComplete(75527), minimap=true,},
            [42758221] = {label="{npc:204277:Thieving Rock Mouse}", quest=75535, hide_before=ns.conditions.QuestComplete(75534), minimap=true,},
            [43728386] = {label="{npc:204277:Thieving Rock Mouse}", hide_before=ns.conditions.QuestComplete(75535), minimap=true,},
        },
        note="Find the {npc:204277:Thieving Rock Mouse} 5x nearby",
    },
    -- [] = {criteria=59221, quest=73410}, -- Seething Cache
    [29764055] = {criteria=59219, quest=73395, vignette=5522, path=30394148, nearby={30124074}, note="Get the key from the bear"}, -- Well-Chewed Chest
}, {
    achievement=17786, -- Treasures of Zaralek Cavern
})

ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [56684936] = {
        label="Moth-Pilfered Pouch",
        quest=75320,
        -- npc=203225, -- Struggling mothling
        loot={205191}, -- Underlight Globe
        note="Stand under {npc:203225:Struggling Mothling} it as it bounces on you",
        vignette=5658, -- 5650 once dropped
    },
    [57956632] = {
        label="Dreamer's Bounty",
        quest=75762,
        loot={205194}, -- Fractured Crystalspine Quill
        note="Get a {npc:201068:Preying Duskmoth} to use {spell:400066:Drowsy Dust} on you, quickly kill it, then open the chest",
        vignette=5712,
    },
    [48451083] = {
        label="Fealty's Reward",
        quest=75514,
        loot={205195}, -- Drakeforged Magma Charm
        note="/kneel by the nearby statue",
        related={
            [43572302] = {label="Statue", note="/kneel", minimap=true,},
        },
    },
    [48421636] = {
        label="Molten Hoard",
        quest=75515,
        loot={205981}, -- Molten Primal Fang
        vignette=5686,
        note="Underground, where the magma is coming from",
        path=48531838,
    },
    [62065534] = { -- Waterlogged Bundle
        label="Waterlogged Bundle",
        quest=75015, -- 75814? probably one is a barter-brick
        -- loot={},
        note="Underwater",
        vignette=5592,
    },
})

local STASH = {
    label="Stolen Stash",
    texture=ns.atlas_texture("VignetteLoot", {r=0.5, g=1, b=0.5, scale=0.9}),
}
ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [60664621] = {quest=75302, vignette=5647},
    [63203710] = {quest=75303, vignette=5648, note="In cave", path=59903660},
}, STASH)
ns.RegisterPoints(2184, { -- starting cave
    [63688296] = {quest=75303, vignette=5648},
}, STASH)

local RITUAL = {
    label="Ritual Offerings",
    texture=ns.atlas_texture("VignetteLoot", {r=1, g=0.5, b=0.5, scale=0.9}),
}
ns.RegisterPoints(ns.ZARALEKCAVERN, {
    [27344217] = {quest=73553, vignette=5531},
    [32634418] = {quest=73551, vignette=5529},
}, RITUAL)
