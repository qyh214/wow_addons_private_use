--[[
    Currently I'm not sure how best to determine which character completed
    the Main Character version of the Oribos intro
    When the alt experiance is enabled an achievement (14529) and quest (59880)
    are flagged as completed. When an alt gets to oribos and relogs both of these
    are marked as complete on that character too, the first 2 quests in the alt
    chain appear to be flagged as completed on main, although they appear to have
    been added later so maybe they wouldnt be under normal circumstances.
    Orignally there was a different quest (62166) at the start of the alt version
    not sure if it was changed or why its different now

    When leaving The Maw quests for the main character oribos chain are flagged
    as completed, along with quest 62537, this doesnt seem to be flagged as completed
    on the main though, so maybe it can be used to test for alts

    Maybe the solution is:
    if achievement 14529 isnt complete on any character then we are the main
    if quest 59770 is complete and quest 62537 is not complete you are the main
    if quest 59770 is not complete and achievement 14529 is complete you are an alt
    if quest 62537 is complete you are an alt (only happens after finishing the maw)

As of Build 35854:
    New alt handling, when first arriving in oribos after doing The Maw you get the
    quest [62704] The Threads of Fate, if selecting to do the campaign...
    otherwise you get a couple of intro quests as before and can select a zone
    or fly directly to the zone to auto accept the quest

    When selecting the new leveling the quest 62713 is flagged as completed, this is also checked by the player condition
    and should be useable to detect if the player is on the alt progress

    alt tracking is now if we should show quest 62704 (The Threads of Fate) at the start of the main progress
    and then checking if the player selected the main version of leveling

    achievement 14807 flags alt progress being available, its account wide
    completing The Maw flags quest 62706 as completed if the achievement is complete(?)

    To show the alt leveling we check if quest 62713 is complete
    To show the initial quest on main progress we check if achievement 14807 is complete and if either
        The Maw isnt complete or
        quest 62704 is active/completed
]]
local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
local EXPANSION_ID = BtWQuests.Constant.Expansions.Shadowlands
local Category = BtWQuests.Constant.Category.Shadowlands
local Chain = BtWQuests.Constant.Chain.Shadowlands
local LEVEL_RANGE = {50, 50}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 50,
    },
}

Database:AddChain(Chain.IntoTheMaw, {
    name = BtWQuests_GetAchievementName(14334),
    questline = 1108,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                },
            },
        },
    },
    active = {
        type = "quest",
        ids = {
            59751, 60545, 61874, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 59770,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        25030, 27725, 30360, 32230, 34875, 37510, 40080, 42150, 44660, 47230, 49300, 51870, 54380, 56450, 59020, 61530, 64300, 66170, 68930, 71500, 73325, 76075, 78650, 80475, 83225, 85800, 88325, 90425, 92950, 95475, 97575, 100100, 102625, 104725, 107250, 109825, 112575, 114400, 117225, 119725, 121550, 124375, 126875, 128750, 131525, 134025, 136600, 138675, 141175, 143750, 145800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        121550, 97525, 73250, 48990, 24145, 12085, 
                    },
                    minLevel = 51,
                    maxLevel = 56,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        37200, 132990, 228780, 324570, 420360, 516150, 611940, 707730, 803520, 899310, 995100, 1090890, 1186680, 1282470, 1378260, 1474050, 1569840, 1665630, 1761420, 1857210, 1953000, 2073530, 2194055, 2314585, 2435110, 2555640, 2676170, 2796695, 2917225, 3037750, 3158280, 3278810, 3399335, 3519865, 3640390, 3760920, 3879215, 3997510, 4115810, 4234105, 4352400, 4395925, 4439450, 4482970, 4526495, 4570020, 4613545, 4657070, 4700590, 4744115, 4787640, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amount = 4352400,
                },
            },
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 60545,
                    restrictions = {
                        type = "faction",
                        id = BtWQuests.Constant.Faction.Alliance,
                    },
                },
                {
                    type = "quest",
                    id = 61874,
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59751,
            x = 0,
            connections = {
                1, 2, 3,
            },
        },
        {
            type = "quest",
            id = 59752,
            x = -2,
            connections = {
                3,
            },
        },
        {
            type = "quest",
            id = 59907,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59753,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59914,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59754,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59755,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59756,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59757,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59758,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59915,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59759,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 59760,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59761,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59776,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59762,
            x = 0,
            connections = {
                1, 2,
            },
        },
        {
            type = "quest",
            id = 59765,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 59766,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60644,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59767,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 59770,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = 90002,
            aside = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ArrivalInTheShadowlandsMain, {
    name = L["ARRIVAL_IN_THE_SHADOWLANDS"],
    questline = 1135,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.ArrivalInTheShadowlandsAlt
    },
    restrictions = {
        type = "quest",
        id = 62713,
        status = {'pending'}
    },
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                },
            },
        },
        {
            type = "chain",
            id = Chain.IntoTheMaw,
        },
    },
    active = {
        type = "quest",
        ids = {62704, 60129},
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60156,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5780, 6400, 7010, 7430, 8050, 8660, 9080, 9900, 10310, 10730, 11550, 11970, 12380, 13200, 13620, 14030, 14850, 15270, 16080, 16500, 16925, 17725, 18150, 18575, 19375, 19800, 20225, 21025, 21450, 21875, 22675, 23100, 23525, 24325, 24750, 25175, 25975, 26400, 27225, 27625, 28050, 28875, 29275, 29700, 30525, 30925, 31350, 32175, 32575, 33000, 33800, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        28050, 28875, 29275, 29700, 30525, 30925, 31350, 32175, 32575, 33000, 33800, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8200, 29315, 50430, 71545, 92660, 113775, 134890, 156005, 177120, 198235, 219350, 240465, 261580, 282695, 303810, 324925, 346040, 367155, 388270, 409385, 430500, 457070, 483635, 510205, 536770, 563340, 589910, 616475, 643045, 669610, 696180, 722750, 749315, 775885, 802450, 829020, 855095, 881170, 907250, 933325, 959400, 968995, 978590, 988180, 997775, 1007370, 1016965, 1026560, 1036150, 1045745, 1055340, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        959400, 968995, 978590, 988180, 997775, 1007370, 1016965, 1026560, 1036150, 1045745, 1055340, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 174871,
            restrictions = {
                {
                    type = "achievement",
                    id = 14807,
                },
                {
                    type = "quest",
                    id = 62704,
                    restrictions = {
                        type = "quest",
                        id = 60129,
                        status = {'active', 'completed'}
                    }
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62704,
            restrictions = {
                {
                    type = "achievement",
                    id = 14807,
                },
                {
                    type = "quest",
                    id = 62704,
                    restrictions = {
                        type = "quest",
                        id = 60129,
                        status = {'active', 'completed'}
                    }
                },
            },
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60129,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60148,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60149,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60150,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60151,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60152,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60154,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60156,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "chain",
            id = 90101,
            x = 0,
        },
    },
})
Database:AddChain(Chain.ArrivalInTheShadowlandsAlt, {
    name = L["ARRIVAL_IN_THE_SHADOWLANDS"],
    questline = 1175,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.ArrivalInTheShadowlandsMain
    },
    restrictions = {
        type = "quest",
        id = 62713,
    },
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                },
            },
        },
        {
            type = "chain",
            id = Chain.IntoTheMaw,
        },
    },
    active = {
        type = "quest",
        id = 62704,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 62159,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        2480, 2750, 2960, 3180, 3450, 3660, 3880, 4200, 4360, 4580, 4900, 5120, 5280, 5600, 5820, 5980, 6300, 6520, 6780, 7000, 7250, 7450, 7700, 7950, 8150, 8400, 8650, 8850, 9100, 9350, 9550, 9800, 10050, 10250, 10500, 10750, 10950, 11200, 11550, 11650, 11900, 12250, 12350, 12600, 12950, 13050, 13300, 13650, 13750, 14000, 14200, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        11900, 12250, 12350, 12600, 12950, 13050, 13300, 13650, 13750, 14000, 14200, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        3200, 11440, 19680, 27920, 36160, 44400, 52640, 60880, 69120, 77360, 85600, 93840, 102080, 110320, 118560, 126800, 135040, 143280, 151520, 159760, 168000, 178380, 188730, 199110, 209460, 219840, 230220, 240570, 250950, 261300, 271680, 282060, 292410, 302790, 313140, 323520, 333690, 343860, 354060, 364230, 374400, 378150, 381900, 385620, 389370, 393120, 396870, 400620, 404340, 408090, 411840, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        374400, 378150, 381900, 385620, 389370, 393120, 396870, 400620, 404340, 408090, 411840, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                },
            },
        },
    },
    items = {
        {
            type = "npc",
            id = 174871,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62704,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62716,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62000,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62159,
            x = 0,
            connections = {
                1, 2, 3, 4,
            },
        },
        {
            type = "quest",
            id = 62275,
            aside = true,
            x = -3,
            -- connections = {
            --     4,
            -- },
        },
        {
            type = "quest",
            id = 62278,
            aside = true,
            -- connections = {
            --     4,
            -- },
        },
        {
            type = "quest",
            id = 62277,
            aside = true,
            -- connections = {
            --     4,
            -- },
        },
        {
            type = "quest",
            id = 62279,
            aside = true,
            -- connections = {
            --     4,
            -- },
        },
        -- {
        --     type = "chain",
        --     id = 90141,
        --     aside = true,
        --     x = -3,
        -- },
        -- {
        --     type = "chain",
        --     id = 90241,
        --     aside = true,
        -- },
        -- {
        --     type = "chain",
        --     id = 90341,
        --     aside = true,
        -- },
        -- {
        --     type = "chain",
        --     id = 90441,
        --     aside = true,
        -- },
    },
})
Database:AddChain(Chain.TheMawEmbed, {
    name = L["RETURN_TO_THE_MAW"],
    questline = 1123,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 53,
                },
            },
        },
    },
    active = {
        type = "quest",
        id = 62882,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 62837,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        4730, 5250, 5710, 6130, 6600, 7060, 7530, 8000, 8410, 8880, 9350, 9820, 10230, 10700, 11170, 11580, 12100, 12520, 13030, 13500, 13875, 14375, 14850, 15225, 15725, 16200, 16625, 17125, 17550, 17975, 18475, 18900, 19325, 19825, 20250, 20725, 21225, 21600, 22175, 22575, 22950, 23525, 23925, 24350, 24875, 25275, 25750, 26225, 26625, 27100, 27550, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        25200, 25225, 25225, 25250, 25275, 25275, 25750, 26225, 26625, 27100, 27550, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        25350, 25800, 26250, 26650, 27100, 27550, 
                    },
                    minLevel = 55,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8200, 29315, 50430, 71545, 92660, 113775, 134890, 156005, 177120, 198235, 219350, 240465, 261580, 282695, 303810, 324925, 346040, 367155, 388270, 409385, 430500, 457070, 483635, 510205, 536770, 563340, 589910, 616475, 643045, 669610, 696180, 722750, 749315, 775885, 802450, 829020, 855095, 881170, 907250, 933325, 959400, 968995, 978590, 988180, 997775, 1007370, 1016965, 1026560, 1036150, 1045745, 1055340, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1006200, 1006435, 1006670, 1006900, 1007135, 1007370, 1016965, 1026560, 1036150, 1045745, 1055340, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amounts = {
                        1008540, 1017900, 1027260, 1036620, 1045980, 1055340, 
                    },
                    minLevel = 55,
                    maxLevel = 60,
                },
            },
        },
        {
            type = "reputation",
            id = 2432,
            amount = 20,
        },
    },
    items = {
        {
            type = "quest",
            id = 62882,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60287,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 61355,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60289,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62837,
            x = 0,
        },
    },
})
Database:AddChain(Chain.Torghast, {
    name = BtWQuests_GetMapName(1762),
    questline = {1136, 1210, 1242, 1243, 1244, 1245},
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    buttonImage = "Interface\\AddOns\\BtWQuestsShadowlands\\UI-Chain-Torghast",
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 60,
                },
            },
        },
        {
            type = "chain",
            id = Chain.Kyrian.AmongTheKyrian or 90601,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = Chain.Venthyr.Sinfall or 90901,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = Chain.NightFae.ForQueenAndGrove or 90801,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = Chain.Necrolord.LoyalToThePrimus or 90701,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
    },
    active = {
        type = "quest",
        ids = {
            60136, 63029, 63030, 63032, 63033, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {62719, 61730},
        count = 2,
    },
    rewards = {
        {
            name = L["ACCESS_TO_TORGHAST"],
            type = "spell",
            id = 334746,
        },
        {
            name = L["ACCESS_TO_TORGHAST_TWISTING_CORRIDORS"],
            type = "spell",
            id = 346217,
        },
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        54250, 56725, 59200, 62050, 64525, 67450, 69900, 72350, 75250, 77700, 80600, 83050, 85500, 88400, 90850, 93750, 96250, 98650, 101600, 104050, 106900, 109400, 111850, 114700, 117200, 120100, 122550, 125000, 127900, 130350, 133250, 135700, 138150, 141050, 143500, 146400, 148900, 151300, 154250, 156700, 159550, 162050, 164500, 167350, 169850, 172750, 175200, 177650, 180550, 183000, 185900, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        159550, 162050, 164500, 167350, 169850, 172750, 175200, 177650, 180550, 183000, 185900, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 185900,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        331400, 521950, 712500, 903050, 1093600, 1284150, 1474700, 1665250, 1855800, 2046350, 2236900, 2427450, 2618000, 2808550, 2999100, 3189650, 3380200, 3570750, 3761300, 3951850, 4142400, 4382160, 4621920, 4861680, 5101440, 5341200, 5580960, 5820720, 6060480, 6300240, 6540000, 6779760, 7019520, 7259280, 7499040, 7738800, 7974120, 8209440, 8444760, 8680080, 8915400, 9001980, 9088560, 9175140, 9261720, 9348300, 9434880, 9521460, 9608040, 9694620, 9781200, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8915400, 9001980, 9088560, 9175140, 9261720, 9348300, 9434880, 9521460, 9608040, 9694620, 9781200, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 9781200,
                },
            },
        },
        {
            type = "currency",
            id = 1828,
            amount = 1150,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 63029,
                    restrictions = {
                        type = "covenant",
                        id = 1,
                    },
                },
                {
                    type = "quest",
                    id = 63033,
                    restrictions = {
                        type = "covenant",
                        id = 2,
                    },
                },
                {
                    type = "quest",
                    id = 63030,
                    restrictions = {
                        type = "covenant",
                        id = 3,
                    },
                },
                {
                    type = "quest",
                    id = 63032,
                    restrictions = {
                        type = "covenant",
                        id = 4,
                    },
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60136,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 61099,
            x = -1,
            connections = {
                2, 3
            },
        },
        {
            type = "kill",
            id = 175123,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62932,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            ids = {60267, 62967},
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62935,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60268,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62938,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60269,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60139,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60270,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 62966,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 60271,
            connections = {
                3, 
            },
        },
        {
            visible = false,
            x = -3,
        },
        {
            type = "quest",
            id = 62969,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60272,
            connections = {
                2, 3
            },
        },
        {
            type = "quest",
            id = 60146,
            x = -1,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 62700,
            aside = true,
        },
        {
            type = "quest",
            id = 62719,
        },
        {
            type = "quest",
            id = 62836,
            x = -1,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61730,
            x = -1,
        },
    },
})
Database:AddChain(Chain.NewRules, {
    name = L["NEW_RULES"],
    questline = 1200,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 60,
                },
            },
        },
        {
            type = "chain",
            id = Chain.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = Chain.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = Chain.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = Chain.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = Chain.Torghast,
            upto = 61099
        },
    },
    active = {
        type = "quest",
        id = 63051,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 60158,
    },
    rewards = {
        {
            name = L["ACCESS_TO_PERDITION_HOLD"],
            type = "spell",
            id = 340350,
        },
        {
            name = L["ACCESS_TO_THE_BEASTWARRENS"],
            type = "spell",
            id = 340351,
        },
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        11250, 12475, 13500, 14650, 15675, 16700, 17900, 18900, 19900, 21100, 22100, 23300, 24300, 25300, 26500, 27500, 28550, 29700, 30750, 31950, 32950, 34000, 35200, 36150, 37200, 38400, 39400, 40600, 41600, 42600, 43800, 44800, 45800, 47000, 48000, 49200, 50250, 51200, 52450, 53450, 54450, 55700, 56700, 57850, 58900, 59900, 61100, 62100, 63100, 64300, 65300, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        55800, 56900, 57750, 58800, 59700, 60550, 61600, 62500, 63350, 64400, 65300, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 65300,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        25000, 89375, 153750, 218125, 282500, 346875, 411250, 475625, 540000, 604375, 668750, 733125, 797500, 861875, 926250, 990625, 1055000, 1119375, 1183750, 1248125, 1312500, 1393500, 1474500, 1555500, 1636500, 1717500, 1798500, 1879500, 1960500, 2041500, 2122500, 2203500, 2284500, 2365500, 2446500, 2527500, 2607000, 2686500, 2766000, 2845500, 2925000, 2954250, 2983500, 3012750, 3042000, 3071250, 3100500, 3129750, 3159000, 3188250, 3217500, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        2948400, 2975310, 3002220, 3029130, 3056040, 3082950, 3109860, 3136770, 3163680, 3190590, 3217500, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 3217500,
                },
            },
        },
        {
            type = "currency",
            id = 1767,
            amount = 223,
        },
        {
            type = "reputation",
            id = 2432,
            amount = 380,
        },
    },
    items = {
        {
            type = "npc",
            id = 168432,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 63051,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60281,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 60284,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 60285,
            x = -1,
            connections = {
                2,
            },
        },
        {
            type = "quest",
            id = 63022,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 62461,
            x = 0,
            connections = {
                1,
            },
        },
        {
            type = "quest",
            id = 60158,
            x = 0,
        },
    },
})
Database:AddChain(Chain.PeeringIntoDarkness, {
    name = L["PEERING_INTO_DARKNESS"],
    questline = 1138,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = {
        {
            type = "level",
            variations = {
                {
                    level = 10,
                    restrictions = -1,
                },
                {
                    level = 48,
                    restrictions = 86994,
                },
                {
                    level = 60,
                },
            },
        },
        {
            type = "chain",
            id = Chain.Kyrian.AmongTheKyrian or 90601,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 1,
            },
        },
        {
            type = "chain",
            id = Chain.Venthyr.Sinfall or 90901,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 2,
            },
        },
        {
            type = "chain",
            id = Chain.NightFae.ForQueenAndGrove or 90801,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 3,
            },
        },
        {
            type = "chain",
            id = Chain.Necrolord.LoyalToThePrimus or 90701,
            lowPriority = true,
            restrictions = {
                type = "covenant",
                id = 4,
            },
        },
        {
            type = "chain",
            id = Chain.Torghast,
            upto = 62836,
        },
    },
    active = {
        type = "quest",
        ids = {60501, 61730},
        status = {'active', 'completed'},
        count = 2,
    },
    completed = {
        type = "quest",
        id = 62569,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5250, 5650, 6050, 6450, 6850, 7300, 7700, 8050, 8500, 8900, 9300, 9700, 10100, 10500, 10900, 11350, 11750, 12100, 12550, 12950, 13350, 13750, 14150, 14550, 14950, 15400, 15800, 16150, 16600, 17000, 17400, 17800, 18200, 18600, 19000, 19450, 19850, 20200, 20650, 21050, 21450, 21850, 22250, 22650, 23050, 23500, 23900, 24250, 24700, 25100, 25500, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        21450, 21850, 22250, 22650, 23050, 23500, 23900, 24250, 24700, 25100, 25500, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 25500,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        138700, 164450, 190200, 215950, 241700, 267450, 293200, 318950, 344700, 370450, 396200, 421950, 447700, 473450, 499200, 524950, 550700, 576450, 602200, 627950, 653700, 686100, 718500, 750900, 783300, 815700, 848100, 880500, 912900, 945300, 977700, 1010100, 1042500, 1074900, 1107300, 1139700, 1171500, 1203300, 1235100, 1266900, 1298700, 1310400, 1322100, 1333800, 1345500, 1357200, 1368900, 1380600, 1392300, 1404000, 1415700, 
                    },
                    minLevel = 10,
                    maxLevel = 60,
                    restrictions = -1,
                },
                {
                    amounts = {
                        1298700, 1310400, 1322100, 1333800, 1345500, 1357200, 1368900, 1380600, 1392300, 1404000, 1415700, 
                    },
                    minLevel = 50,
                    maxLevel = 60,
                    restrictions = 86994,
                },
                {
                    amount = 1415700,
                },
            },
        },
        {
            type = "currency",
            id = 1828,
            amount = 250,
        },
    },
    items = {
        {
            type = "kill",
            id = 167406,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "chain",
            id = Chain.Torghast,
            upto = 62836,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 60501,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 61730,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61557,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61558,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 61559,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 62569,
            x = 0,
        },
    },
})

BtWQuestsDatabase:AddExpansionItems(EXPANSION_ID, {
    {
        type = "chain",
        id = Chain.IntoTheMaw,
    },
    {
        type = "chain",
        id = Chain.ArrivalInTheShadowlandsMain,
    },
    {
        type = "chain",
        id = Chain.ArrivalInTheShadowlandsAlt,
    },
    {
        type = "category",
        variations = {
            {
                id = Category.Kyrian,
                restrictions = {
                    type = "covenant",
                    id = 1,
                },
            },
            {
                id = Category.Necrolord,
                restrictions = {
                    type = "covenant",
                    id = 4,
                },
            },
            {
                id = Category.NightFae,
                restrictions = {
                    type = "covenant",
                    id = 3,
                },
            },
            {
                id = Category.Venthyr,
                restrictions = {
                    type = "covenant",
                    id = 2,
                },
            },
        },
    },
    {
        type = "chain",
        id = Chain.Torghast,
    },
    {
        type = "chain",
        id = Chain.NewRules,
    },
    {
        type = "chain",
        id = Chain.PeeringIntoDarkness,
    },
})

Database:AddMapRecursive(1648, {
    type = "chain",
    id = Chain.IntoTheMaw,
})
Database:AddMapRecursive(1911, {
    type = "chain",
    id = Chain.Torghast,
})
Database:AddMapRecursive(1912, {
    type = "chain",
    id = Chain.Torghast,
})
Database:AddMap(1543, {
    type = "chain",
    id = Chain.NewRules,
})