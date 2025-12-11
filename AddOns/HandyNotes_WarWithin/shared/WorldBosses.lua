local myname, ns = ...

local boss = {
    group="worldboss",
}

ns.RegisterPoints(ns.ISLEOFDORN, {
    [50005880] = { -- Kordac
        quest=81630, -- This is the world quest
        worldquest=81630,
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
    [60868760] = { -- Aggregation of Horrors
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
    [45401740] = { -- Shurrai, Atrocity of the Undersea
        quest=83467,
        worldquest=81653,
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
        quest=81624, -- this is the worldquest; a separate one didn't trip
        worldquest=81624,
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

ns.RegisterPoints(ns.UNDERMINE, {
    [49601720] = { -- The Gobfather
        quest=85088, -- 89401 is the account-loot weekly, I think?
        worldquest=85088, -- The Main Event, also
        npc=231821,
        loot={
            232725, -- Pilot's Oiled Trousers
            232726, -- Well-Trodden Mechanic's Shoes
            232727, -- Cavern Stalker's Trophy Girdle
            232728, -- Darkfuse Dinner Jacket
            232729, -- Horn-Adorned Chausses
            232730, -- Cauldron Master Cleats
            232731, -- Steadfast Contender's Breastplate
            232732, -- Champion's Gilded Stompers
            232733, -- Gobfather's Gold Medal
        },
    },
})

ns.RegisterPoints(ns.KARESH, {
    [71854851] = { -- Reshanor
        quest=90783, -- 87352 tripped as well, account-wide, then 87354 on next kill
        worldquest=87354,
        npc=238319,
        loot={
            243038, -- Gaze of the Untethered Doom
            243039, -- Devoured Magi's Cinch
            243040, -- Crystalblight Legguards
            243041, -- Umbral Stalker's Footpads
            243042, -- Void-Bound Hauberk
            243043, -- Shadowguard's Rift Wrap
            243044, -- Feasting Fiend's Barbute
            243045, -- Bygone Wastelander's Girdle
            243046, -- Band of Boundless Hunger
        },
    },
})
