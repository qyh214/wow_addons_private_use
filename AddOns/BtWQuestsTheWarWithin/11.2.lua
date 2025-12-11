if select(4, GetBuildInfo()) < 110200  then
    return
end

local BtWQuests = BtWQuests
local Database = BtWQuests.Database
local L = BtWQuests.L
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin.Karesh
local CATEGORY_ID = BtWQuests.Constant.Category.TheWarWithin.Karesh
local ACHIEVEMENT_ID_1 = 41970
local ACHIEVEMENT_ID_2 = 42739
local ACHIEVEMENT_ID_3 = 41808
local MAP_ID = 2371
local LEVEL_RANGE = {80, 80}

Chain.AShadowyInvitation = 110701
Chain.VoidAlliance = 110702
Chain.DesertPower = 110703
Chain.ShadowsEnGarde = 110704
Chain.TheLightOfKaresh = 110705

Chain.OfBoughAandBonds = 110711
Chain.OnATechnicality = 110712
Chain.InSearchOfDarkness = 110713
Chain.UntetheredPotential = 110714
Chain.ChasingEchoes = 110715
Chain.AvoidingTheVoid = 110716
Chain.PriestOfTheOldWays = 110717
Chain.ThatTazaveshTaste = 110718
Chain.LostAndFoundStorage = 110719
Chain.AnywayHeresFirewall = 110720
Chain.AStrangersGift = 110721

Chain.TheOasis = 110722
Chain.TheBeesKnees = 110723
Chain.RoamingFree = 110724
Chain.Foxstrut = 110725
Chain.LilLapbugs = 110726
Chain.RaysOfSunshine = 110727
Chain.NesingwaryNecessities = 110728
Chain.HardKarroc = 110729
Chain.ASlitherOfSnakes = 110730

Chain.WrappedUp = 110731

Database:AddChain(Chain.AShadowyInvitation, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 1),
    questline = 5690,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            }
        },
    },
    active = {
        type = "quest",
        id = 84956,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84967,
    },
    items = {
        {
            type = "npc",
            id = 227758,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Shadowy Invitation
            type = "quest",
            id = 84956,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Return to the Veiled Market
            type = "quest",
            id = 84957,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Restoring Operational Efficiency
            type = "quest",
            id = 85003,
            completed = { -- Restoring Operational Efficiency
                type = "quest",
                id = 85003,
                status = { "active", "completed", },
            },
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Compromised Containment
            type = "quest",
            id = 85039,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- Beasts Unbound
            type = "quest",
            id = 84958,
            connections = {
                2, 
            },
        },
        { -- Lost Lines of Defense
            type = "quest",
            id = 84959,
            connections = {
                1, 
            },
        },
        { -- Restoring Operational Efficiency
            type = "quest",
            id = 85003,
            active = {
                type = "quest",
                ids = {
                    85039, 84958, 84959, 
                },
                count = 3,
            },
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Darkness Among Us
            type = "quest",
            id = 84960,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Barriers to Entry
            type = "quest",
            id = 84961,
            x = -2,
            connections = {
                4, 
            },
        },
        { -- Sealing the Shadows
            type = "quest",
            id = 84963,
            connections = {
                2, 
            },
        },
        { -- Heroes Among Shadow
            type = "quest",
            id = 84964,
            connections = {
                2, 
            },
        },
        { -- Core Contributions
            type = "quest",
            id = 84965,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Regroup!
            type = "quest",
            id = 86835,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Shadowguard Shattered
            type = "quest",
            id = 84967,
            x = 0,
        },
    }
})
Database:AddChain(Chain.VoidAlliance, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 2),
    questline = 5733,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
        },
    },
    active = {
        type = "quest",
        id = 85032,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 90517,
    },
    items = {
        {
            type = "npc",
            id = 231128,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- What Is Left of Home
            type = "quest",
            id = 85032,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Moving the Pawns
            type = "quest",
            id = 85961,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Dead Silence
            type = "quest",
            id = 84855,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Reshii Ribbon
            type = "quest",
            id = 86495,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Where the Void Gathers
            type = "quest",
            id = 84856,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Eco-Dome: Primus
            type = "quest",
            id = 84857,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- System Restart
            type = "quest",
            id = 84858,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Damage Report 101
            type = "quest",
            id = 84859,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- Eco-Stabilizing
            type = "quest",
            id = 84860,
            connections = {
                1, 2, 
            },
        },
        { -- This Is Our Dome!
            type = "quest",
            id = 84861,
            x = -1,
            connections = {
                2, 3, 4, 
            },
        },
        { -- Void Alliance
            type = "quest",
            id = 84862,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Counter Measures
            type = "quest",
            id = 84863,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- Her Dark Side
            type = "quest",
            id = 84864,
            connections = {
                2, 
            },
        },
        { -- Divide and Conquer
            type = "quest",
            id = 84865,
            connections = {
                1, 
            },
        },
        { -- To Purchase Safety
            type = "quest",
            id = 84866,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Unwrapped and Unraveled
            type = "quest",
            id = 86946,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- My Part of the Deal
            type = "quest",
            id = 90517,
            x = 0,
        },
    }
})
Database:AddChain(Chain.DesertPower, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 3),
    questline = 5717,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
        },
    },
    active = {
        type = "quest",
        id = 84826,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84910,
    },
    items = {
        {
            type = "npc",
            id = 230811,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Eco-Dome: Rhovan
            type = "quest",
            id = 84826,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- The Shattered Dome
            type = "quest",
            id = 84827,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- The Rhovan Infestation
            type = "quest",
            id = 84831,
            connections = {
                1, 
            },
        },
        { -- Salvaging What's Left
            type = "quest",
            id = 85730,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Tempest Fields
            type = "quest",
            id = 86327,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Tempest Clefts
            type = "quest",
            id = 84834,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Hunting on Glass
            type = "quest",
            id = 84869,
            connections = {
                1, 
            },
        },
        { -- Enemies of Enemies
            type = "quest",
            id = 84838,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Before the Void
            type = "quest",
            id = 84848,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Stalking Stalkers
            type = "quest",
            id = 84867,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Distribution of Power
            type = "quest",
            id = 86332,
            connections = {
                1, 
            },
        },
        { -- The Oasis
            type = "quest",
            id = 84876,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Restoring Hope
            type = "quest",
            id = 84879,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- K'aresh That Was
            type = "quest",
            id = 84883,
            connections = {
                1, 
            },
        },
        { -- The Tabiqa
            type = "quest",
            id = 84910,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ShadowsEnGarde, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 4),
    questline = 5696,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
        },
    },
    active = {
        type = "quest",
        id = 84896,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85037,
    },
    items = {
        {
            type = "npc",
            id = 230786,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Next Dimension
            type = "quest",
            id = 84896,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Calm Before We Storm
            type = "quest",
            id = 84897,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- The Sands of K'aresh
            type = "quest",
            id = 84898,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Shadowguard Diffusion
            type = "quest",
            id = 84899,
            connections = {
                1, 
            },
        },
        { -- Like a Knife Through Aether
            type = "quest",
            id = 84900,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Adverse Instantiation
            type = "quest",
            id = 84902,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- Until the Sands Bleed Void
            type = "quest",
            id = 84903,
            connections = {
                2, 
            },
        },
        { -- And We Will Answer
            type = "quest",
            id = 84904,
            connections = {
                1, 
            },
        },
        { -- To Walk Among Shadow
            type = "quest",
            id = 84905,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Nexus Regicide
            type = "quest",
            id = 84906,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- That's a Wrap
            type = "quest",
            id = 85037,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Manaforge Omega: Dimensius Looms
            type = "quest",
            id = 86820,
            aside = true,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheLightOfKaresh, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_1, 5),
    questline = 5734,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    major = true,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
        },
    },
    active = {
        type = "quest",
        id = 86820,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86820,
    },
    items = {
    }
})

Database:AddChain(Chain.OfBoughAandBonds, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 1),
    questline = 5683,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        ids = { 84740, 84915, },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 84765,
    },
    items = {
        {
            type = "npc",
            id = 230159,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Bridge to Nowhere
            type = "quest",
            id = 84740,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Clearing the Dunes
            type = "quest",
            id = 84915,
            connections = {
                1, 
            },
        },
        { -- Signs in the Sands
            type = "quest",
            id = 84741,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Ill-met in Starlight
            type = "quest",
            id = 84759,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- A Friendly Warning
            type = "quest",
            id = 84760,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Toil and Trespass
            type = "quest",
            id = 84761,
            connections = {
                1, 
            },
        },
        { -- We Are Our Words
            type = "quest",
            id = 84762,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- By Oath and Blood
            type = "quest",
            id = 84820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Of Bonds and Boughs
            type = "quest",
            id = 84765,
            x = 0,
        },
    }
})
Database:AddChain(Chain.OnATechnicality, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 2),
    questline = 5703,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
        },
    },
    active = {
        type = "quest",
        ids = { 85429, 85430 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85434,
    },
    items = {
        {
            type = "npc",
            id = 232498,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Overwhelm Them
            type = "quest",
            id = 85429,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- Mandatory Time Off
            type = "quest",
            id = 85430,
            connections = {
                1, 2, 
            },
        },
        { -- Drain Their Resources
            type = "quest",
            id = 85431,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Confuse Their Contacts
            type = "quest",
            id = 85432,
            connections = {
                1, 
            },
        },
        { -- Eyes on Us
            type = "quest",
            id = 85433,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- On a Technicality
            type = "quest",
            id = 85434,
            x = 0,
        },
    }
})
Database:AddChain(Chain.InSearchOfDarkness, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 3),
    questline = 5770,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 90972,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 91044,
    },
    items = {
        {
            type = "npc",
            id = 248153,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Common Cause
            type = "quest",
            id = 90972,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Void Hunter
            type = "quest",
            id = 86786,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Wasted Lands
            type = "quest",
            id = 89323,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Piece of Something Greater
            type = "quest",
            id = 89324,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Void Confluence
            type = "quest",
            id = 89325,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Distilled Darkness
            type = "quest",
            id = 89326,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Chaos
            type = "quest",
            id = 89327,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Hunger of the Void
            type = "quest",
            id = 91044,
            x = 0,
        },
    }
})
Database:AddChain(Chain.UntetheredPotential, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 4),
    questline = 5953,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = { -- Requires the wraps equipped which has different prerequisites for first character. Might be possible to use the account bound quest to track which prerequisites to show
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
            restrictions = {
                type = "quest",
                id = 90938,
                status = {"pending"},
            }
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
            restrictions = {
                type = "quest",
                id = 90938,
                status = {"pending"},
            }
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
            restrictions = {
                type = "quest",
                id = 90938,
                status = {"pending"},
            }
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            restrictions = {
                type = "quest",
                id = 90938,
                status = {"pending"},
            }
        },
        {
            variations = {
                {
                    type = "quest",
                    id = 90938,
                    restrictions = {
                        type = "quest",
                        id = 90938,
                        status = {"active", "completed"},
                    },
                },
                {
                    type = "quest",
                    id = 89344,
                },
            },
            status = {'active', 'completed'},
        },
        {
            type = "equipped",
            id = 235499,
        }
    },
    active = {
        type = "quest",
        id = 91454,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 91454,
    },
    items = {
        {
            type = "npc",
            id = 246601,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        {
            type = "kill",
            id = 246608,
            connections = {
                2, 
            },
        },
        { -- Untethered Potential
            type = "quest",
            id = 91314,
            aside = true,
            x = -1,
        },
        { -- Phase-Lost Adventurer
            type = "quest",
            id = 91454,
        },
    }
})
Database:AddChain(Chain.ChasingEchoes, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 5),
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = { -- no requirements on second character
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        ids = { 85006, 85007 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85009,
    },
    items = {
        {
            type = "npc",
            id = 231314,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Those We Have Lost
            type = "quest",
            id = 85006,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Extended Reach
            type = "quest",
            id = 85007,
            connections = {
                1, 
            },
        },
        { -- Machinations of Memory
            type = "quest",
            id = 85008,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Those We Have Yet to Save
            type = "quest",
            id = 85009,
            x = 0,
        },
    }
})
Database:AddChain(Chain.AvoidingTheVoid, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 6),
    questline = 5906,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 84972,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85018,
    },
    items = {
        {
            type = "npc",
            id = 231162,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Chipping the Void
            type = "quest",
            id = 84972,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Of Motes and Husks
            type = "quest",
            id = 84973,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Shards of Hope
            type = "quest",
            id = 84974,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Packets of Promises
            type = "quest",
            id = 85018,
            x = 0,
        },
    }
})
Database:AddChain(Chain.PriestOfTheOldWays, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 7),
    questline = 5970,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
        },
    },
    active = {
        type = "quest",
        id = 85019,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85022,
    },
    items = {
        {
            type = "npc",
            id = 231422,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- An Outcast's Request
            type = "quest",
            id = 85019,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Blood of K'aresh
            type = "quest",
            id = 85020,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Cleansing the Void
            type = "quest",
            id = 85021,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Priest of the Old Ways
            type = "quest",
            id = 85022,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ThatTazaveshTaste, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 8),
    questline = 5699,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
        },
    },
    active = {
        type = "quest",
            id = 85383,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85394,
    },
    items = {
        {
            type = "npc",
            id = 232351,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Applied Mixology
            type = "quest",
            id = 85383,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Market Research
            type = "quest",
            id = 85384,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- An Eye for Trouble
            type = "quest",
            id = 85394,
            x = 0,
        },
    }
})
Database:AddChain(Chain.LostAndFoundStorage, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 9),
    questline = 5695,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
        },
    },
    active = {
        type = "quest",
        id = 85052,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85055,
    },
    items = {
        {
            type = "npc",
            id = 231674,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Lucrative Opportunity
            type = "quest",
            id = 85052,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Obtaining Permits
            type = "quest",
            id = 85053,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Articles of Acquisition
            type = "quest",
            id = 85054,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Expired Goods
            type = "quest",
            id = 85055,
            x = 0,
        },
    }
})
Database:AddChain(Chain.AnywayHeresFirewall, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 10),
    questline = 5735,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 86196,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86201,
    },
    items = {
        {
            type = "npc",
            id = 234216,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Give me Fuel
            type = "quest",
            id = 86196,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Give me Fire
            type = "quest",
            id = 86200,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Watch me Make These Bugs Expire
            type = "quest",
            id = 86201,
            x = 0,
        },
    }
})
Database:AddChain(Chain.AStrangersGift, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_2, 11),
    questline = 5715,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
    },
    active = {
        type = "quest",
        id = 85238,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86193,
    },
    items = {
        {
            type = "npc",
            id = 233500,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Stranger on the Steps
            type = "quest",
            id = 85238,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- A New Devouring
            type = "quest",
            id = 85239,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Only Hunger Remains
            type = "quest",
            id = 85240,
            connections = {
                1, 
            },
        },
        { -- A Once-Proud Priest
            type = "quest",
            id = 85241,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Life for Life
            type = "quest",
            id = 86193,
            x = 0,
        },
    }
})

Database:AddChain(Chain.TheOasis, {
    name = { -- The Oasis
        type = "quest",
        id = 87290,
    },
    questline = 5780,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
        },
    },
    active = {
        type = "quest",
        id = 87290,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 87340,
    },
    items = {
        {
            type = "npc",
            id = 238212,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Oasis
            type = "quest",
            id = 87290,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Custodian Duties
            type = "quest",
            id = 87337,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Ongoing Activities
            type = "quest",
            id = 87339,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Day One Orientation
            type = "quest",
            id = 87338,
            connections = {
                1, 
            },
        },
        { -- Junk Mail
            type = "quest",
            id = 87340,
            x = 0,
        },
    }
})
Database:AddChain(Chain.TheBeesKnees, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 1),
    questline = 5693,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        -- Changes on second character, available from at latest the [What Is Left of Home] quest (85032)
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
        },
    },
    active = {
        type = "quest",
        id = 85075,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 85262,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- To Stormsong
            type = "quest",
            id = 85075,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Don't Bee Crazy
            type = "quest",
            id = 85076,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- Sticky Fingers
            type = "quest",
            id = 85077,
            connections = {
                1, 2, 
            },
        },
        { -- Bee in the Bonnet
            type = "quest",
            id = 85078,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- Such a Sleebee-head
            type = "quest",
            id = 85079,
            connections = {
                1, 2, 
            },
        },
        { -- An Un-Bee-lievable Solution
            type = "quest",
            id = 85080,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Beehemian Rhapsody
            type = "quest",
            id = 85081,
            connections = {
                1, 
            },
        },
        { -- To K'aresh
            type = "quest",
            id = 85082,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Bee Test
            type = "quest",
            id = 85249,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Bee Strong
            type = "quest",
            id = 85084,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Photogra-Bee
            type = "quest",
            id = 85083,
            connections = {
                1, 
            },
        },
        { -- Primus Buzzness
            type = "quest",
            id = 85257,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Tranquila-Bee
            type = "quest",
            id = 85255,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Botany, Finally
            type = "quest",
            id = 85256,
            connections = {
                1, 
            },
        },
        { -- Let There Bee Love
            type = "quest",
            id = 89348,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Oh Honey Honey
            type = "quest",
            id = 85258,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Waggle Dance
            type = "quest",
            id = 85259,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Hiving a Hard Day
            type = "quest",
            id = 85260,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Bee Roll
            type = "quest",
            id = 85261,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Royal Procession
            type = "quest",
            id = 85262,
            x = 0,
        },
    }
})
Database:AddChain(Chain.RoamingFree, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 2),
    questline = 5705,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NesingwaryNecessities,
        },
    },
    active = {
        type = "quest",
        id = 86182,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86195,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Ghost Buster
            type = "quest",
            id = 86182,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Power of Gods
            type = "quest",
            id = 86183,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Diminishing Returns
            type = "quest",
            id = 86184,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Running Free
            type = "quest",
            id = 86185,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Super Sniffer
            type = "quest",
            id = 86186,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- The Smallest Possible Effort
            type = "quest",
            id = 86187,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- More-shrooms
            type = "quest",
            id = 86188,
            connections = {
                1, 2, 
            },
        },
        { -- Fungal Invasion
            type = "quest",
            id = 86189,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- One Mushroom to Rule Them All
            type = "quest",
            id = 86190,
            connections = {
                1, 
            },
        },
        { -- Smell Ya Later
            type = "quest",
            id = 86191,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Scent of Love
            type = "quest",
            id = 86194,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- On a Bed of Bones They Lie
            type = "quest",
            id = 86192,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Slateback Soccer
            type = "quest",
            id = 86195,
            x = 0,
        },
    }
})
Database:AddChain(Chain.Foxstrut, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 3),
    questline = 5742,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NesingwaryNecessities,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.RoamingFree,
        },
    },
    active = {
        type = "quest",
        id = 86348,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86392,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Fox Bane
            type = "quest",
            id = 86348,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Eau de Foxy
            type = "quest",
            id = 86350,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- What Does the Fox Dream?
            type = "quest",
            id = 86362,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Strike a Pose
            type = "quest",
            id = 86351,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Fantastic Ms. Fox
            type = "quest",
            id = 86360,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Are You Kitting Me?
            type = "quest",
            id = 86361,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Foxy Footwork
            type = "quest",
            id = 86392,
            x = 0,
        },
    }
})
Database:AddChain(Chain.LilLapbugs, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 4),
    questline = 5779,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NesingwaryNecessities,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.RoamingFree,
        },
    },
    active = {
        type = "quest",
        id = 86349,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 87294,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Lapbug Essence Hunter
            type = "quest",
            id = 86349,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Rooting for Trouble
            type = "quest",
            id = 87292,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Salad Bar
            type = "quest",
            id = 87291,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Shameless Hawking
            type = "quest",
            id = 87293,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- A Truth Universally Acknowledged
            type = "quest",
            id = 87294,
            x = 0,
        },
    }
})
Database:AddChain(Chain.RaysOfSunshine, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 5),
    questline = 5763,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NesingwaryNecessities,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.RoamingFree,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Foxstrut,
        },
        {
            type = "chain",
            id = Chain.LilLapbugs,
        },
    },
    active = {
        type = "quest",
        id = 86587,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86607,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- To Maldraxxus
            type = "quest",
            id = 86587,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        { -- Ritualistic Murder
            type = "quest",
            id = 86588,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- A Plague a Day Keeps the Doctor Away
            type = "quest",
            id = 86589,
            connections = {
                2, 
            },
        },
        { -- I Don't Even Work Here
            type = "quest",
            id = 86590,
            connections = {
                1, 
            },
        },
        { -- A Poor Imitation
            type = "quest",
            id = 86591,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Get Your Jabs
            type = "quest",
            id = 86592,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- To the Oasis
            type = "quest",
            id = 86593,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Atrium Hospital
            type = "quest",
            id = 86782,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- A Cultured Palette
            type = "quest",
            id = 86594,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Custodial Duties
            type = "quest",
            id = 86595,
            connections = {
                1, 
            },
        },
        { -- Rays of Sunshine
            type = "quest",
            id = 86783,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Triple Twenty
            type = "quest",
            id = 86601,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Medical Checkup
            type = "quest",
            id = 86602,
            connections = {
                1, 
            },
        },
        {
            type = "npc",
            id = 230736,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Ray-ket Ball
            type = "quest",
            id = 86603,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Dubious Intent
            type = "quest",
            id = 86604,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Booster Shots
            type = "quest",
            id = 86605,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Golden Ooze
            type = "quest",
            id = 86606,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Freedom of Ray-cing
            type = "quest",
            id = 86607,
            x = 0,
        },
    }
})
Database:AddChain(Chain.NesingwaryNecessities, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 6),
    questline = 5744,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
        },
    },
    active = {
        type = "quest",
        id = 86352,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 86359,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Hunting for a Good Author
            type = "quest",
            id = 86352,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- A Percussive Antidote
            type = "quest",
            id = 86354,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Protecting the Young
            type = "quest",
            id = 86353,
            connections = {
                1, 
            },
        },
        { -- To Iskaara
            type = "quest",
            id = 84822,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        { -- Using the Whole Animal
            type = "quest",
            id = 86355,
            x = -1,
            connections = {
                2, 3, 
            },
        },
        { -- Sustainable Harvesting
            type = "quest",
            id = 86356,
            connections = {
                1, 2, 
            },
        },
        { -- Time for Noms
            type = "quest",
            id = 86357,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Any Old Excuse
            type = "quest",
            id = 86358,
            connections = {
                1, 
            },
        },
        { -- Return to K'aresh
            type = "quest",
            id = 86359,
            x = 0,
        },
    }
})
Database:AddChain(Chain.HardKarroc, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 7),
    questline = 5782,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.NesingwaryNecessities,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.RoamingFree,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.Foxstrut,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.LilLapbugs,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.RaysOfSunshine,
        },
    },
    active = {
        type = "quest",
        id = 87408,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        id = 87415,
    },
    items = {
        {
            type = "npc",
            id = 231820,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Being Spiritual
            type = "quest",
            id = 87408,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- From Death, Life
            type = "quest",
            id = 87409,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Percussive Negotiation
            type = "quest",
            id = 87410,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Making Stuff to Look Tough
            type = "quest",
            id = 87411,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- K'arrocing Photos
            type = "quest",
            id = 87412,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Bird Bath
            type = "quest",
            id = 87413,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Medical Maneuvers
            type = "quest",
            id = 87414,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Skies of K'aresh
            type = "quest",
            id = 87415,
            x = 0,
        },
    }
})
Database:AddChain(Chain.ASlitherOfSnakes, {
    name = BtWQuests_GetAchievementCriteriaNameDelayed(ACHIEVEMENT_ID_3, 8),
    questline = 5791,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
        },
    },
    active = {
        type = "quest",
        id = 87290,
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 84891, 84892, 84893, },
        count = 3,
    },
    items = {
    }
})

Database:AddChain(Chain.WrappedUp, {
    name = { -- Wrapped Up
        type = "quest",
        id = 89561,
    },
    questline = 5791,
    expansion = EXPANSION_ID,
    category = CATEGORY_ID,
    range = LEVEL_RANGE,
    prerequisites = {
        {
            type = "level",
            level = 80,
        },
        {
            type = "chain",
            id = BtWQuests.Constant.Chain.TheWarWithin.AgainstTheCurrent,
            upto = 79197,
            completed = {
                type = "quest",
                id = 79573,
            },
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
            lowPriority = true,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
        },
    },
    active = {
        type = "quest",
        ids = { 89380, 89561 },
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = { 89345,  89561 },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 241601,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 241588,
            connections = {
                2, 
            },
        },
        { -- Another World
            type = "quest",
            id = 89380,
            x = -1,
            connections = {
                2, 
            },
        },
        { -- Wrapped Up
            type = "quest",
            id = 89561,
        },
        { -- The Untethered Void
            type = "quest",
            id = 89343,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- What Doesn't See You
            type = "quest",
            id = 89344,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- The Untethered Horror
            type = "quest",
            id = 89345,
            x = 0,
        },
    }
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = 7050019,
    items = {
        {
            type = "chain",
            id = Chain.AShadowyInvitation,
        },
        {
            type = "chain",
            id = Chain.VoidAlliance,
        },
        {
            type = "chain",
            id = Chain.DesertPower,
        },
        {
            type = "chain",
            id = Chain.ShadowsEnGarde,
        },
        -- {
        --     type = "chain",
        --     id = Chain.TheLightOfKaresh,
        -- },
        
        {
            type = "chain",
            id = Chain.OfBoughAandBonds,
        },
        {
            type = "chain",
            id = Chain.OnATechnicality,
        },
        {
            type = "chain",
            id = Chain.InSearchOfDarkness,
        },
        {
            type = "chain",
            id = Chain.UntetheredPotential,
        },
        {
            type = "chain",
            id = Chain.ChasingEchoes,
        },
        {
            type = "chain",
            id = Chain.AvoidingTheVoid,
        },
        {
            type = "chain",
            id = Chain.PriestOfTheOldWays,
        },
        {
            type = "chain",
            id = Chain.ThatTazaveshTaste,
        },
        {
            type = "chain",
            id = Chain.LostAndFoundStorage,
        },
        {
            type = "chain",
            id = Chain.AnywayHeresFirewall,
        },
        {
            type = "chain",
            id = Chain.AStrangersGift,
        },
        {
            type = "chain",
            id = Chain.TheOasis,
        },
        {
            type = "chain",
            id = Chain.TheBeesKnees,
        },
        {
            type = "chain",
            id = Chain.NesingwaryNecessities,
        },
        {
            type = "chain",
            id = Chain.RoamingFree,
        },
        {
            type = "chain",
            id = Chain.Foxstrut,
        },
        {
            type = "chain",
            id = Chain.LilLapbugs,
        },
        {
            type = "chain",
            id = Chain.RaysOfSunshine,
        },
        {
            type = "chain",
            id = Chain.HardKarroc,
        },
        -- {
        --     type = "chain",
        --     id = Chain.ASlitherOfSnakes,
        -- },
        {
            type = "chain",
            id = Chain.WrappedUp,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "category",
        id = CATEGORY_ID,
    },
})

BtWQuestsDatabase:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
}, true, true)

BtWQuestsDatabase:AddQuestItemsForChain(Chain.AShadowyInvitation)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.VoidAlliance)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.DesertPower)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ShadowsEnGarde)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheLightOfKaresh)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.OfBoughAandBonds)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.OnATechnicality)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.InSearchOfDarkness)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.UntetheredPotential)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ChasingEchoes)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AvoidingTheVoid)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.PriestOfTheOldWays)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ThatTazaveshTaste)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.LostAndFoundStorage)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AnywayHeresFirewall)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.AStrangersGift)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheOasis)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.TheBeesKnees)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RoamingFree)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.Foxstrut)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.LilLapbugs)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.RaysOfSunshine)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.NesingwaryNecessities)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.HardKarroc)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.ASlitherOfSnakes)
BtWQuestsDatabase:AddQuestItemsForChain(Chain.WrappedUp)
