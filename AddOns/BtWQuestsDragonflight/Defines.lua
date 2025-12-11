--[[
    Tracking quest 67030, may be related to unlocking the level scaling for all zones.
      Not flagged as completed on live, is flagged on beta, already had max level character
]]
local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
BtWQuests.Constant.Expansions.Dragonflight = LE_EXPANSION_DRAGONFLIGHT or 9

if BtWQuests.Characters.AddCurrency then
    BtWQuests.Characters:AddCurrency(2002);
    BtWQuests.Characters:AddCurrency(2021);
    BtWQuests.Characters:AddCurrency(2087);
    BtWQuests.Characters:AddCurrency(2088);
end

BtWQuests.Constant.Category.Dragonflight = {
    TheWakingShores = 1001,
    OhnahranPlains = 1002,
    TheAzureSpan = 1003,
    Thaldraszus = 1004,
    Dragonflight = 1005,
    EmbersOfNeltharion = 1006,
    GuardiansOfTheDream = 1007,
}
BtWQuests.Constant.Chain.Dragonflight = {
    DracthyrAwaken = 100001,
    DragonIslesEmissary = 100002,
    TheMotherOathstone = 100003,
    TheSparkOfIngenuity = 100004,
    DragonShardOfKnowledge = 100005,

    OldHatreds = 100006,
    ReturnToTheReach = 100007,
    ZskeraVaults = 100008,
    AcademicAcquisitions = 100009,

    TheWakingShores = {},
    OhnahranPlains = {},
    TheAzureSpan = {},
    Thaldraszus = {
        ValdrakkenCityOfDragons = 100401,
        TimeManagement = 100402,
        BigTimeAdventurer = 100403,
        TempChain01 = 100411,
        TempChain02 = 100412,
        TempChain03 = 100413,
        TempChain04 = 100414,
        TempChain05 = 100415,
        TempChain06 = 100416,
        TempChain07 = 100417,
        TempChain08 = 100418,
        TempChain09 = 100419,
        TempChain10 = 100420,
        TempChain11 = 100421,
        TempChain12 = 100422,
        TempChain13 = 100423,
        TempChain14 = 100424,
        TempChain15 = 100425,
        TempChain16 = 100426,
        OtherAlliance = 100497,
        OtherHorde = 100498,
        OtherBoth = 100499,
    },
    Dragonflight = {
        TheChieftainsDuty = 100501,
        AMysterySealed = 100502,
        TheSilverPurpose = 100503,
        InTheHallsOfTitans = 100504,
        GardenOfSecrets = 100505,
        TheDreamer = 100506,
        EmbedChain01 = 100511,
    },
    EmbersOfNeltharion = {},
    GuardiansOfTheDream = {},
}

BtWQuests.Constant.Restrictions.DragonflightToF = -100001;
BtWQuests.Constant.Restrictions.NOTDragonflightToF = -100002;
Database:AddCondition(BtWQuests.Constant.Restrictions.DragonflightToF, { type = "quest", id = 67030 }) -- "Threads of Fate"
Database:AddCondition(BtWQuests.Constant.Restrictions.NOTDragonflightToF, { type = "quest", id = 67030, status = { "pending" } }) -- "Threads of Fate"

Database:AddExpansion(BtWQuests.Constant.Expansions.Dragonflight, {
    image = {
        texture = "Interface\\AddOns\\BtWQuestsDragonflight\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})

Database:AddMapRecursive(1670, {
    type = "expansion",
    id = BtWQuests.Constant.Expansions.Dragonflight,
})
