local BtWQuests = BtWQuests;
local Database = BtWQuests.Database;
local L = BtWQuests.L;
local EXPANSION_ID = BtWQuests.Constant.Expansions.TheBurningCrusade;
local CATEGORY_ID = BtWQuests.Constant.Category.TheBurningCrusade.Zangarmarsh;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade.Zangarmarsh;
local ALLIANCE_RESTRICTIONS, HORDE_RESTRICTIONS = BtWQuests.Constant.Restrictions.Alliance, BtWQuests.Constant.Restrictions.Horde;
local MAP_ID = 102
local ACHIEVEMENT_ID = 1190
local CONTINENT_ID = 101
local LEVEL_RANGE = {10, 30}
local LEVEL_PREREQUISITES = {
    {
        type = "level",
        level = 10,
    },
}

Chain.DraeneiDiplomacy = 20201
Chain.SwampratPost = 20202
Chain.Telredor = 20203
Chain.Zabrajin = 20204
Chain.OreborHarborage = 20205
Chain.TheDefenseOfZabrajin = 20206
Chain.DontEatThoseMushrooms = 20207
Chain.DrainingTheMarsh = 20208
Chain.SavingTheSporeloks = 20209
Chain.ATripWithTheSporelings = 20210
Chain.EmbedChain01 = 20211
Chain.EmbedChain02 = 20212
Chain.EmbedChain03 = 20213
Chain.EmbedChain04 = 20214
Chain.EmbedChain05 = 20215
Chain.EmbedChain06 = 20216
Chain.EmbedChain07 = 20217
Chain.EmbedChain08 = 20218
Chain.EmbedChain09 = 20219
Chain.EmbedChain10 = 20220
Chain.EmbedChain11 = 20221
Chain.EmbedChain12 = 20222
Chain.EmbedChain13 = 20223
Chain.EmbedChain14 = 20224
Chain.EmbedChain15 = 20225

Chain.Chain01 = 20226

Chain.EmbedChain16 = 20227
Chain.EmbedChain17 = 20228
Chain.EmbedChain18 = 20229
Chain.EmbedChain19 = 20230
Chain.EmbedChain20 = 20231
Chain.EmbedChain21 = 20232
Chain.EmbedChain22 = 20233
Chain.EmbedChain23 = 20234
Chain.EmbedChain24 = 20235
Chain.EmbedChain25 = 20236
Chain.EmbedChain26 = 20237
Chain.EmbedChain27 = 20238

Chain.OtherChain = 20239

Database:AddChain(Chain.DraeneiDiplomacy, {
    name = L["DRAENEI_DIPLOMACY"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.SwampratPost,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9786,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9803,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        5950, 6600, 7200, 7700, 8300, 8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 18050, 18700, 19150, 19750, 20400, 21000, 21500, 22100, 22700, 23200, 23800, 24400, 24900, 25500, 26150, 26750, 27200, 27850, 28450, 3600, 3600, 2875, 2125, 1440, 720, 365, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        5950, 6600, 7200, 7700, 8300, 8900, 9550, 10000, 10600, 11250, 11700, 12350, 12950, 13400, 14050, 14650, 15250, 15750, 16350, 17000, 17450, 17450, 14000, 10450, 7000, 3525, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 1755, 190, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 445920, 471840, 497760, 523680, 549600, 575520, 601440, 627360, 653280, 679200, 705120, 731040, 756960, 782880, 808800, 834240, 859680, 885120, 910560, 936000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        8000, 28600, 49200, 69800, 90400, 111000, 131600, 152200, 172800, 193400, 214000, 234600, 255200, 275800, 296400, 317000, 337600, 358200, 378800, 399400, 420000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 930,
            amount = 1000,
        },
    },
    items = {
        {
            type = "npc",
            id = 18003,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9786,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9787,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9801,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9803,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SwampratPost, {
    name = L["SWAMPRAT_POST"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.DraeneiDiplomacy,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9769, 9770, 9773, 9774, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {9899, 9898, 9772},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 38250, 39600, 40500, 41850, 43200, 44550, 45450, 46800, 48150, 49050, 50400, 51750, 52650, 54000, 55350, 56700, 57600, 58950, 60300, 7650, 7650, 6075, 4500, 3060, 1530, 765, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 36900, 29700, 22050, 14850, 7425, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 405, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 891840, 943680, 995520, 1047360, 1099200, 1151040, 1202880, 1254720, 1306560, 1358400, 1410240, 1462080, 1513920, 1565760, 1617600, 1668480, 1719360, 1770240, 1821120, 1872000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        16000, 57200, 98400, 139600, 180800, 222000, 263200, 304400, 345600, 386800, 428000, 469200, 510400, 551600, 592800, 634000, 675200, 716400, 757600, 798800, 840000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 530,
            amount = 2250,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain01,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
            embed = true,
            x = -1,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
            embed = true,
            x = 2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
            aside = true,
            embed = true,
            x = -1,
        },
    },
})
Database:AddChain(Chain.Telredor, {
    name = L["TELREDOR"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Zabrajin,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9791, 9781, 9782, 9901
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9790, 9780, 9896, 9783},
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        15400, 17050, 18700, 19800, 21450, 23100, 24750, 25850, 27500, 29150, 30250, 31900, 33550, 34650, 36300, 37950, 39600, 40700, 42350, 44000, 45100, 46750, 48400, 49500, 51150, 52800, 54450, 55550, 57200, 58850, 59950, 61600, 63250, 64350, 66000, 67650, 69300, 70400, 72050, 73700, 9350, 9350, 7425, 5500, 3740, 1870, 935, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        15400, 17050, 18700, 19800, 21450, 23100, 24750, 25850, 27500, 29150, 30250, 31900, 33550, 34650, 36300, 37950, 39600, 40700, 42350, 44000, 45100, 45100, 36300, 26950, 18150, 9075, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 4510, 495, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 47,
            amount = 500,
        },
        {
            type = "reputation",
            id = 930,
            amount = 2250,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain04,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain16,
            aside = true,
            embed = true,
            x = 2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
            aside = true,
            embed = true,
        },
    },
})
Database:AddChain(Chain.Zabrajin, {
    name = L["ZABRAJIN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.Telredor,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9814, 9841, 9846, 9845
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9847, 9842, 9816, 9904},
        count = 4,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 38250, 39600, 40500, 41850, 43200, 44550, 45450, 46800, 48150, 49050, 50400, 51750, 52650, 54000, 55350, 56700, 57600, 58950, 60300, 7650, 7650, 6075, 4500, 3060, 1530, 765, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12600, 13950, 15300, 16200, 17550, 18900, 20250, 21150, 22500, 23850, 24750, 26100, 27450, 28350, 29700, 31050, 32400, 33300, 34650, 36000, 36900, 36900, 29700, 22050, 14850, 7425, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 3690, 405, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 1003320, 1061640, 1119960, 1178280, 1236600, 1294920, 1353240, 1411560, 1469880, 1528200, 1586520, 1644840, 1703160, 1761480, 1819800, 1877040, 1934280, 1991520, 2048760, 2106000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        18000, 64350, 110700, 157050, 203400, 249750, 296100, 342450, 388800, 435150, 481500, 527850, 574200, 620550, 666900, 713250, 759600, 805950, 852300, 898650, 945000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 530,
            amount = 2250,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain08,
            embed = true,
            x = -2,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
            embed = true,
            x = 0,
        },
    },
})
Database:AddChain(Chain.OreborHarborage, {
    name = L["OREBOR_HARBORAGE"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.TheDefenseOfZabrajin,
    },
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9848, 9835, 10115, 9830, 9833, 9902, 9834
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9839, 10115, 9848, 9905, 9830, 9833, 9902},
        count = 7,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        14350, 15900, 17400, 18500, 20000, 21500, 23050, 24100, 25600, 27150, 28200, 29750, 31250, 32300, 33850, 35350, 36850, 37950, 39450, 41000, 42050, 43550, 45100, 46150, 47650, 49200, 50700, 51800, 53300, 54800, 55900, 57400, 58900, 60000, 61500, 63050, 64550, 65600, 67150, 68650, 8700, 8700, 6925, 5125, 3480, 1740, 875, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14350, 15900, 17400, 18500, 20000, 21500, 23050, 24100, 25600, 27150, 28200, 29750, 31250, 32300, 33850, 35350, 36850, 37950, 39450, 41000, 42050, 42050, 33800, 25150, 16900, 8475, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 4215, 460, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 1226280, 1297560, 1368840, 1440120, 1511400, 1582680, 1653960, 1725240, 1796520, 1867800, 1939080, 2010360, 2081640, 2152920, 2224200, 2294160, 2364120, 2434080, 2504040, 2574000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        22000, 78650, 135300, 191950, 248600, 305250, 361900, 418550, 475200, 531850, 588500, 645150, 701800, 758450, 815100, 871750, 928400, 985050, 1041700, 1098350, 1155000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 72,
            amount = 250,
        },
        {
            type = "reputation",
            id = 978,
            amount = 2250,
            restrictions = 924,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain12,
            embed = true,
            x = -3,
            y = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
            embed = true,
            x = 0,
            y = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
            aside = true,
            embed = true,
            x = 3,
            y = 0,
        },
        {
            type = "reputation",
            id = 978,
            x = 0,
            y = 3,
            connections = {
                1, 2, 
            },
            standing = 4,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
            embed = true,
            x = -1,
            y = 4,
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
            embed = true,
            x = 3,
        },
    },
})
Database:AddChain(Chain.TheDefenseOfZabrajin, {
    name = L["THE_DEFENSE_OF_ZABRAJIN"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    alternatives = {
        Chain.OreborHarborage,
    },
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9820,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {9823, 10118},
        count = 2,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7700, 8550, 9300, 10000, 10750, 11500, 12350, 12950, 13700, 14550, 15150, 16000, 16750, 17350, 18200, 18950, 19700, 20400, 21150, 22000, 22600, 23350, 24200, 24800, 25550, 26400, 27150, 27850, 28600, 29350, 30050, 30800, 31550, 32250, 33000, 33850, 34600, 35200, 36050, 36800, 4650, 4650, 3725, 2750, 1860, 930, 475, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7700, 8550, 9300, 10000, 10750, 11500, 12350, 12950, 13700, 14550, 15150, 16000, 16750, 17350, 18200, 18950, 19700, 20400, 21150, 22000, 22600, 22600, 18100, 13550, 9050, 4575, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 2280, 245, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 780360, 825720, 871080, 916440, 961800, 1007160, 1052520, 1097880, 1143240, 1188600, 1233960, 1279320, 1324680, 1370040, 1415400, 1459920, 1504440, 1548960, 1593480, 1638000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        14000, 50050, 86100, 122150, 158200, 194250, 230300, 266350, 302400, 338450, 374500, 410550, 446600, 482650, 518700, 554750, 590800, 626850, 662900, 698950, 735000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 530,
            amount = 1000,
        },
    },
    items = {
        {
            type = "object",
            id = 182165,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9820,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9822,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9823,
            x = -1,
        },
        {
            type = "quest",
            id = 10118,
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
            embed = true,
            aside = true,
            x = 2,
            y = 0,
        }
    },
})
Database:AddChain(Chain.DontEatThoseMushrooms, {
    name = L["DONT_EAT_THOSE_MUSHROOMS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9697, 9701
        },
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        id = 9709,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7350, 8150, 8900, 9500, 10250, 11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 22300, 23100, 23650, 24400, 25200, 25950, 26550, 27300, 28050, 28650, 29400, 30150, 30750, 31500, 32300, 33050, 33600, 34400, 35150, 4450, 4450, 3550, 2625, 1780, 890, 450, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7350, 8150, 8900, 9500, 10250, 11000, 11800, 12350, 13100, 13900, 14450, 15250, 16000, 16550, 17350, 18100, 18850, 19450, 20200, 21000, 21550, 21550, 17300, 12900, 8650, 4350, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 2165, 235, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 1350,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9697,
                    restrictions = {
                        type = "quest",
                        id = 9697,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 17831,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9701,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9702,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9708,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9709,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
            embed = true,
            aside = true,
            x = 2,
            y = 1,
        },
        {
            visible = false,
            x = -2,
            y = 1,
        },
    },
})
Database:AddChain(Chain.DrainingTheMarsh, {
    name = L["DRAINING_THE_MARSH"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9716, 9731, 9912, 39180, 39181, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9732,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7700, 8525, 9300, 9950, 10725, 11500, 12300, 12950, 13700, 14550, 15200, 16000, 16750, 17400, 18200, 18950, 19750, 20400, 21200, 22000, 22600, 23400, 24200, 24800, 25600, 26400, 27150, 27850, 28600, 29350, 30050, 30800, 31550, 32250, 33000, 33800, 34600, 35200, 36050, 36800, 4645, 4645, 3715, 2755, 1860, 935, 470, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7700, 8525, 9300, 9950, 10725, 11500, 12300, 12950, 13700, 14550, 15200, 16000, 16750, 17400, 18200, 18950, 19750, 20400, 21200, 22000, 22600, 22600, 18100, 13550, 9075, 4560, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 2275, 250, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        7000, 25025, 43050, 61075, 79100, 97125, 115150, 133175, 151200, 169225, 187250, 205275, 223300, 241325, 259350, 277375, 295400, 313425, 331450, 349475, 367500, 390180, 412860, 435540, 458220, 480900, 503580, 526260, 548940, 571620, 594300, 616980, 639660, 662340, 685020, 707700, 729960, 752220, 774480, 796740, 819000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7000, 25025, 43050, 61075, 79100, 97125, 115150, 133175, 151200, 169225, 187250, 205275, 223300, 241325, 259350, 277375, 295400, 313425, 331450, 349475, 367500, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 1325,
        },
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 39180,
                    restrictions = {
                        type = "quest",
                        id = 39180,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 39181,
                    restrictions = {
                        type = "quest",
                        id = 39181,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "quest",
                    id = 9912,
                    restrictions = {
                        type = "quest",
                        id = 9912,
                        status = {
                            "active",
                            "completed",
                        },
                    },
                },
                {
                    type = "npc",
                    id = 17841,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9716,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9718,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9720,
            aside = true,
            x = -1,
        },
        {
            type = "kill",
            id = 18340,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9731,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9724,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9732,
            x = 0,
        },
    },
})
Database:AddChain(Chain.SavingTheSporeloks, {
    name = L["SAVING_THE_SPORELOKS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9747,
        status = {'active', 'completed'},
    },
    completed = {
        type = "quest",
        ids = {10096, 9894, 9788},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        7000, 7750, 8500, 9000, 9750, 10500, 11250, 11750, 12500, 13250, 13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 21250, 22000, 22500, 23250, 24000, 24750, 25250, 26000, 26750, 27250, 28000, 28750, 29250, 30000, 30750, 31500, 32000, 32750, 33500, 4250, 4250, 3375, 2500, 1700, 850, 425, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        7000, 7750, 8500, 9000, 9750, 10500, 11250, 11750, 12500, 13250, 13750, 14500, 15250, 15750, 16500, 17250, 18000, 18500, 19250, 20000, 20500, 20500, 16500, 12250, 8250, 4125, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 2050, 225, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 557400, 589800, 622200, 654600, 687000, 719400, 751800, 784200, 816600, 849000, 881400, 913800, 946200, 978600, 1011000, 1042800, 1074600, 1106400, 1138200, 1170000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10000, 35750, 61500, 87250, 113000, 138750, 164500, 190250, 216000, 241750, 267500, 293250, 319000, 344750, 370500, 396250, 422000, 447750, 473500, 499250, 525000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 1250,
        },
    },
    items = {
        {
            type = "npc",
            id = 17956,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9747,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 9788,
            x = -2,
        },
        {
            type = "quest",
            id = 9894,
        },
        {
            type = "quest",
            id = 10096,
        },
        {
            type = "chain",
            id = Chain.EmbedChain20,
            aside = true,
            embed = true,
            x = 2,
            y = 0,
        },
    },
})
Database:AddChain(Chain.ATripWithTheSporelings, {
    name = L["A_TRIP_WITH_THE_SPORELINGS"],
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    major = true,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9726, 9729, 9739, 9743, 9806, 9808, 9919, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {9729, 9919, 9726},
        count = 3,
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        10510, 11650, 12720, 13560, 14650, 15720, 16860, 17650, 18720, 19860, 20650, 21790, 22860, 23650, 24790, 25860, 26950, 27790, 28860, 30000, 30800, 31850, 33000, 33800, 34850, 36000, 37100, 37900, 39000, 40100, 40900, 42000, 43100, 43900, 45000, 46150, 47200, 48000, 49150, 50200, 6370, 6370, 5070, 3755, 2540, 1270, 640, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        10510, 11650, 12720, 13560, 14650, 15720, 16860, 17650, 18720, 19860, 20650, 21790, 22860, 23650, 24790, 25860, 26950, 27790, 28860, 30000, 30800, 30800, 24720, 18420, 12370, 6200, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 3085, 335, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "reputation",
            id = 970,
            amount = 3100,
        },
    },
    items = {
        {
            type = "reputation",
            id = 970,
            x = 0,
            connections = {
                1,
            },
            standing = 3,
        },
        {
            type = "npc",
            id = 17923,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 9739,
            aside = true,
            x = -1,
            connections = {
                2, 3
            },
        },
        {
            type = "quest",
            id = 9743,
            aside = true,
            connections = {
                2, 3,
            },
        },
        {
            type = "quest",
            id = 9742,
            aside = true,
            x = -2,
            active = {
                type = "quest",
                id = 9739,
            },
            completed = {
                type = "reputation",
                id = 970,
                standing = 5,
            },
        },
        {
            type = "quest",
            id = 50131,
            aside = true,
            completed = {
                type = "reputation",
                id = 970,
                standing = 4,
                restrictions = {
                    type = "quest",
                    id = 50131,
                    status = {'pending'}
                }
            },
        },
        {
            type = "quest",
            id = 9744,
            aside = true,
            active = {
                type = "quest",
                id = 9743,
            },
            completed = {
                type = "reputation",
                id = 970,
                standing = 5,
            },
        },


        
        {
            type = "reputation",
            id = 970,
            x = 0,
            connections = {
                1, 2, 3
            },
            standing = 4,
        },
        {
            type = "npc",
            id = 17923,
            x = -2,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 17924,
            connections = {
                3, 
            },
        },
        {
            type = "npc",
            id = 17925,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 9919,
            x = -2,
            connections = {
                3, 
            },
        },
        { -- This quest becomes unavailable after hitting friendly,
          -- marking it as a breadcrumb will show it as completed at that time
            type = "quest",
            id = 9808,
            breadcrumb = true,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 9806,
            aside = true,
            connections = {
                3, 
            },
        },
        {
            type = "quest",
            id = 50130,
            aside = true,
            x = -2,
            completed = {
                type = "reputation",
                id = 970,
                standing = 5,
                restrictions = {
                    type = "quest",
                    id = 50130,
                    status = {'pending'}
                }
            },
        },
        {
            type = "quest",
            id = 9809,
            aside = true,
            active = {
                type = "quest",
                id = 9808,
            },
            completed = {
                type = "reputation",
                id = 970,
                standing = 5,
            },
        },
        {
            type = "quest",
            id = 9807,
            aside = true,
            active = {
                type = "quest",
                id = 9806,
            },
            completed = {
                type = "reputation",
                id = 970,
                standing = 7,
            },
        },


        {
            type = "reputation",
            id = 970,
            x = 0,
            connections = {
                1, 2
            },
            standing = 5,
        },
        {
            type = "npc",
            id = 17856,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "npc",
            id = 17877,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9726,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9729,
        },
        {
            type = "quest",
            id = 9727,
            x = -1,
            aside = true,
        },
    },
})
Database:AddChain(Chain.EmbedChain01, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9774,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9772,
    },
    items = {
        {
            type = "npc",
            id = 18011,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9774,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9771,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9772,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain02, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9770,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9898,
    },
    items = {
        {
            type = "npc",
            id = 18012,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9770,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9898,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain03, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9769, 9773, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9899,
    },
    items = {
        {
            type = "npc",
            id = 18016,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9773,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 9769,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9899,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain04, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9791,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9780,
    },
    items = {
        {
            type = "npc",
            id = 18006,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9791,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9780,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain05, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9781,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9790,
    },
    items = {
        {
            type = "npc",
            id = 18005,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9781,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9790,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain06, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9782,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9783,
    },
    items = {
        {
            type = "npc",
            id = 18004,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9782,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9783,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain07, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9901,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9896,
    },
    items = {
        {
            type = "npc",
            id = 18295,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9901,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9896,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain08, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9814,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9816,
    },
    items = {
        {
            type = "npc",
            id = 18014,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9814,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9816,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain09, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9841,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9842,
    },
    items = {
        {
            type = "npc",
            id = 18015,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9841,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9842,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain10, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9846,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9847,
    },
    items = {
        {
            type = "npc",
            id = 18017,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9846,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9847,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain11, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = HORDE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9845,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9904,
    },
    items = {
        {
            type = "npc",
            id = 18018,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9845,
            x = 0,
            connections = {
                1, 2
            },
        },
        {
            type = "quest",
            id = 9904,
            x = -1,
        },
        {
            type = "quest",
            id = 9903,
            aside = true,
        },
    },
})
Database:AddChain(Chain.EmbedChain12, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9848,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9848,
    },
    items = {
        {
            type = "npc",
            id = 18019,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9848,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain13, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9835, 10115, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            9839, 10115, 
        },
        count = 2,
    },
    items = {
        {
            type = "npc",
            id = 18008,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9835,
            x = -1,
            connections = {
                2, 
            },
        },
        {
            type = "quest",
            id = 10115,
        },
        {
            type = "quest",
            id = 9839,
            x = -1,
        },
    },
})
Database:AddChain(Chain.EmbedChain14, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "reputation",
            id = 978,
            standing = 4,
        }
    },
    active = {
        type = "quest",
        ids = {
            9830, 9833, 9902, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            9830, 9833, 9902, 
        },
        count = 3,
    },
    items = {
        {
            type = "npc",
            id = 18009,
            x = 0,
            connections = {
                1, 2, 3, 
            },
        },
        {
            type = "quest",
            id = 9830,
            x = -2,
        },
        {
            type = "quest",
            id = 9833,
        },
        {
            type = "quest",
            id = 9902,
        },
    },
})
Database:AddChain(Chain.EmbedChain15, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = {
        {
            type = "level",
            level = 10,
        },
        {
            type = "reputation",
            id = 978,
            standing = 4,
        }
    },
    active = {
        type = "quest",
        id = 9834,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9905,
    },
    items = {
        {
            type = "npc",
            id = 18010,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9834,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9905,
            x = 0,
        },
    },
})

Database:AddChain(Chain.Chain01, {
    name = BtWQuests_GetAreaName(3565), -- Cenarion Refuge
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {9778, 9728, 9730, 9817, 9895, 9802, 9785},
        status = {'active', 'completed'}
    },
    completed = {
        type = "quest",
        ids = {9728, 9730, 9817, 9895, 9802, 9785},
        count = 6
    },
    rewards = {
        {
            type = "experience",
            variations = {
                {
                    amounts = {
                        9100, 10125, 10950, 11900, 12725, 13550, 14550, 15350, 16150, 17150, 17950, 18950, 19750, 20550, 21550, 22350, 23200, 24150, 25000, 26000, 26750, 27600, 28600, 29350, 30200, 31200, 32000, 33000, 33800, 34600, 35600, 36400, 37200, 38200, 39000, 40000, 40850, 41600, 42650, 43450, 5470, 5470, 4415, 3250, 2190, 1095, 565, 
                    },
                    minLevel = 10,
                    maxLevel = 56,
                    restrictions = -1,
                },
                {
                    amounts = {
                        9100, 10125, 10950, 11900, 12725, 13550, 14550, 15350, 16150, 17150, 17950, 18950, 19750, 20550, 21550, 22350, 23200, 24150, 25000, 26000, 26750, 26750, 21350, 16100, 10675, 5435, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 2720, 290, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                },
            },
        },
        {
            type = "money",
            variations = {
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 668880, 707760, 746640, 785520, 824400, 863280, 902160, 941040, 979920, 1018800, 1057680, 1096560, 1135440, 1174320, 1213200, 1251360, 1289520, 1327680, 1365840, 1404000, 
                    },
                    minLevel = 10,
                    maxLevel = 50,
                    restrictions = -1,
                },
                {
                    amounts = {
                        12000, 42900, 73800, 104700, 135600, 166500, 197400, 228300, 259200, 290100, 321000, 351900, 382800, 413700, 444600, 475500, 506400, 537300, 568200, 599100, 630000, 
                    },
                    minLevel = 10,
                    maxLevel = 30,
                },
            },
        },
        {
            type = "reputation",
            id = 942,
            amount = 2375,
        },
    },
    items = {
        {
            type = "chain",
            id = Chain.EmbedChain21,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
            embed = true,
            x = 0,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
            embed = true,
            x = -3,
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
            embed = true,
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
            embed = true,
        },
    },
})

Database:AddChain(Chain.EmbedChain16, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    restrictions = ALLIANCE_RESTRICTIONS,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9777,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9777,
    },
    items = {
        {
            type = "npc",
            id = 18007,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9777,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain17, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9827,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10355,
    },
    items = {
        {
            type = "kill",
            id = 18124,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9827,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10355,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain18, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10116,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10116,
    },
    items = {
        {
            type = "object",
            id = 183284,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 10116,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain19, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9911,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9911,
    },
    items = {
        {
            type = "kill",
            id = 18285,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9911,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain20, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9752,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9752,
    },
    items = {
        {
            type = "npc",
            id = 17969,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9752,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain21, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9728, 9778, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9728,
    },
    items = {
        {
            variations = {
                {
                    type = "quest",
                    id = 9778,
                    restrictions = {
                        type = "quest",
                        id = 9778,
                        status = { "active", "completed", },
                    },
                },
                {
                    type = "npc",
                    id = 17858,
                },
            },
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9728,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain22, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        ids = {
            9730, 9817, 
        },
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        ids = {
            9730, 9817, 
        },
        count = 2,
    },
    items = {
        {
            type = "object",
            id = 182115,
            x = 0,
            connections = {
                1, 2, 
            },
        },
        {
            type = "quest",
            id = 9730,
            x = -1,
        },
        {
            type = "quest",
            id = 9817,
        },
    },
})
Database:AddChain(Chain.EmbedChain23, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9895,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9895,
    },
    items = {
        {
            type = "npc",
            id = 17834,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9895,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain24, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9802,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9802,
    },
    items = {
        {
            type = "npc",
            id = 17909,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9802,
            x = 0,
            connections = {
                1, 
            },
        },
        { -- Available after doing previous quest and up until honored
            type = "quest",
            id = 9784,
            aside = true,
            completed = {
                {
                    type = "quest",
                    id = 9802,
                },
                {
                    type = "reputation",
                    id = 942,
                    standing = 6,
                },
            },
            x = 0,
            connections = {
                1, 
            },
            active = {
                type = "quest",
                id = 9802,
            },
        },
        { -- Can be looted from the bags rewarded by previous quests
            type = "quest",
            id = 9875,
            aside = true,
            completed = {
                --[[
                    We mark this as completed when:
                      Completed the Plants of Zangarmarsh quest,
                      and have reached Honored rep,
                      and have reached exalted rep IF we have more of the items that start this quest.
                    This is because those are BOP and only available from the previous quest which is
                    only up to honored rep
                ]]
                {
                    type = "quest",
                    id = 9802,
                },
                {
                    type = "reputation",
                    id = 942,
                    standing = 6,
                },
                {
                    type = "reputation",
                    id = 942,
                    standing = 8,
                    restrictions = {
                        type = "item",
                        id = 24407,
                    }
                },
            },
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain25, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9785,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9785,
    },
    items = {
        {
            type = "reputation",
            id = 942,
            x = 0,
            connections = {
                1, 
            },
            standing = 5,
        },
        {
            type = "npc",
            id = 18070,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9785,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain26, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 9828,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 9828,
    },
    items = {
        {
            type = "kill",
            id = 18124,
            x = 0,
            connections = {
                1, 
            },
        },
        {
            type = "quest",
            id = 9828,
            x = 0,
        },
    },
})
Database:AddChain(Chain.EmbedChain27, {
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    prerequisites = LEVEL_PREREQUISITES,
    active = {
        type = "quest",
        id = 10117,
        status = { "active", "completed", },
    },
    completed = {
        type = "quest",
        id = 10117,
    },
    items = {
        {
            type = "object",
            id = 182165,
            x = 0,
            connections = {
                1
            }
        },
        {
            type = "quest",
            id = 10117,
            x = 0,
        },
    },
})
Database:AddChain(Chain.OtherChain, {
    name = "Others",
    category = CATEGORY_ID,
    expansion = EXPANSION_ID,
    range = LEVEL_RANGE,
    items = {
        { -- Report to Shadow Hunter Denjai. Breadcrumb that doesnt block any quests so cant really fit it into a chain
            type = "quest",
            id = 9775,
        },
        { -- Report to Zurai. Breadcrumb that doesnt block any quests so cant really fit it into a chain
            type = "quest",
            id = 10103,
        },
        { -- The Orebor Harborage. Breadcrumb that doesnt block any quests so cant really fit it into a chain
            type = "quest",
            id = 9776,
        },
        {
            type = "quest",
            id = 10459,
        },
    },
})

Database:AddCategory(CATEGORY_ID, {
    name = BtWQuests.GetMapName(MAP_ID),
    expansion = EXPANSION_ID,
    buttonImage = {
        texture = [[Interface\AddOns\BtWQuestsTheBurningCrusade\UI-Category-Zangarmarsh]],
		texCoords = {0,1,0,1},
    },
    items = {
        {
            type = "chain",
            id = Chain.DraeneiDiplomacy,
        },
        {
            type = "chain",
            id = Chain.Telredor,
        },
        {
            type = "chain",
            id = Chain.OreborHarborage,
        },
        {
            type = "chain",
            id = Chain.DontEatThoseMushrooms,
        },
        {
            type = "chain",
            id = Chain.DrainingTheMarsh,
        },
        {
            type = "chain",
            id = Chain.SavingTheSporeloks,
        },
        {
            type = "chain",
            id = Chain.ATripWithTheSporelings,
        },
        {
            type = "chain",
            id = Chain.SwampratPost,
        },
        {
            type = "chain",
            id = Chain.Zabrajin,
        },
        {
            type = "chain",
            id = Chain.TheDefenseOfZabrajin,
        },
        {
            type = "chain",
            id = Chain.Chain01,
        },
    },
})

Database:AddExpansionItem(EXPANSION_ID, {
    type = "category",
    id = CATEGORY_ID,
})

Database:AddMapRecursive(MAP_ID, {
    type = "category",
    id = CATEGORY_ID,
})

if not C_QuestLine then
    Database:AddContinentItems(CONTINENT_ID, {
        {
            type = "chain",
            id = Chain.DraeneiDiplomacy,
        },
        {
            type = "chain",
            id = Chain.TheDefenseOfZabrajin,
        },
        {
            type = "chain",
            id = Chain.DontEatThoseMushrooms,
        },
        {
            type = "chain",
            id = Chain.DrainingTheMarsh,
        },
        {
            type = "chain",
            id = Chain.SavingTheSporeloks,
        },
        {
            type = "chain",
            id = Chain.ATripWithTheSporelings,
        },

        {
            type = "chain",
            id = Chain.EmbedChain01,
        },
        {
            type = "chain",
            id = Chain.EmbedChain02,
        },
        {
            type = "chain",
            id = Chain.EmbedChain03,
        },
        {
            type = "chain",
            id = Chain.EmbedChain04,
        },
        {
            type = "chain",
            id = Chain.EmbedChain05,
        },
        {
            type = "chain",
            id = Chain.EmbedChain06,
        },
        {
            type = "chain",
            id = Chain.EmbedChain07,
        },
        {
            type = "chain",
            id = Chain.EmbedChain08,
        },
        {
            type = "chain",
            id = Chain.EmbedChain09,
        },
        {
            type = "chain",
            id = Chain.EmbedChain10,
        },
        {
            type = "chain",
            id = Chain.EmbedChain11,
        },
        {
            type = "chain",
            id = Chain.EmbedChain12,
        },
        {
            type = "chain",
            id = Chain.EmbedChain13,
        },
        {
            type = "chain",
            id = Chain.EmbedChain14,
        },
        {
            type = "chain",
            id = Chain.EmbedChain15,
        },
        {
            type = "chain",
            id = Chain.EmbedChain16,
        },
        {
            type = "chain",
            id = Chain.EmbedChain17,
        },
        {
            type = "chain",
            id = Chain.EmbedChain18,
        },
        {
            type = "chain",
            id = Chain.EmbedChain19,
        },
        {
            type = "chain",
            id = Chain.EmbedChain20,
        },
        {
            type = "chain",
            id = Chain.EmbedChain21,
        },
        {
            type = "chain",
            id = Chain.EmbedChain22,
        },
        {
            type = "chain",
            id = Chain.EmbedChain23,
        },
        {
            type = "chain",
            id = Chain.EmbedChain24,
        },
        {
            type = "chain",
            id = Chain.EmbedChain25,
        },
        {
            type = "chain",
            id = Chain.EmbedChain26,
        },
        {
            type = "chain",
            id = Chain.EmbedChain27,
        },
    })
end