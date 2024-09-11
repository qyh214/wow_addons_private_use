local myname, ns = ...

local boss = {
    group="worldboss",
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [50005880] = { -- Kordac
        quest=nil,
        worldquest=nil,
        npc=229334,
        loot={
            225730, -- Stone Gaze Ceinture
            225731, -- Lightseeker's Robes
            225732, -- Deep Dweller's Tabi
            225733, -- Abyssal Tendril Tights
            225734, -- Sturdy Chitinous Striders
            225735, -- Dornish Warden's Coat
            225745, -- Crystal Star Cuisses
            225746, -- Girdle of the Gleaming Dawn
            225748, -- Seal of the Silent Vigil
        },
    },
}, boss)

ns.RegisterPoints(ns.RINGINGDEEPS, {
    [65008760] = { -- Aggregation of Horrors
        quest=83466,
        worldquest=82653,
        npc=220999,
        loot={
            225730, -- Stone Gaze Ceinture
            225731, -- Lightseeker's Robes
            225732, -- Deep Dweller's Tabi
            225733, -- Abyssal Tendril Tights
            225734, -- Sturdy Chitinous Striders
            225735, -- Dornish Warden's Coat
            225745, -- Crystal Star Cuisses
            225746, -- Girdle of the Gleaming Dawn
            225749, -- Seal of the Void-Touched
        },
    },
}, boss)

ns.RegisterPoints(ns.HALLOWFALL, {
    [45401740] = { -- Shurrai
        quest=nil,
        worldquest=nil,
        npc=221224,
        loot={
            225730, -- Stone Gaze Ceinture
            225731, -- Lightseeker's Robes
            225732, -- Deep Dweller's Tabi
            225733, -- Abyssal Tendril Tights
            225734, -- Sturdy Chitinous Striders
            225735, -- Dornish Warden's Coat
            225745, -- Crystal Star Cuisses
            225746, -- Girdle of the Gleaming Dawn
            225750, -- Seal of the Abyssal Terror
        },
    },
}, boss)

ns.RegisterPoints(ns.CITYOFTHREADS, {
    [17103340] = { -- Orta
        quest=nil,
        worldquest=nil,
        npc=221067,
        loot={
            225730, -- Stone Gaze Ceinture
            225731, -- Lightseeker's Robes
            225732, -- Deep Dweller's Tabi
            225733, -- Abyssal Tendril Tights
            225734, -- Sturdy Chitinous Striders
            225735, -- Dornish Warden's Coat
            225745, -- Crystal Star Cuisses
            225746, -- Girdle of the Gleaming Dawn
            225751, -- Seal of the Broken Mountain
        },
    },
}, boss)
