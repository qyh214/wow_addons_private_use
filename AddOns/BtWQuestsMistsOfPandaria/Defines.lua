local BtWQuests = BtWQuests;
BtWQuests.Constant.Expansions.MistsOfPandaria = LE_EXPANSION_MISTS_OF_PANDARIA or 4;
BtWQuests.Constant.Category.MistsOfPandaria = BtWQuests.Constant.Category.MistsOfPandaria or {};
BtWQuests.Constant.Chain.MistsOfPandaria = BtWQuests.Constant.Chain.MistsOfPandaria or {};
local Category = BtWQuests.Constant.Category.MistsOfPandaria;
local Chain = BtWQuests.Constant.Chain.MistsOfPandaria;

Category.TheJadeForest = 501
Category.ValleyOfTheFourWinds = 502
Category.KrasarangWilds = 503
Category.KunLaiSummit = 504
Category.TownlongSteppes = 505
Category.DreadWastes = 506
Category.ValeOfEternalBlossom = 507
Category.IsleOfThunder = 508

Chain.TheJadeForest = {}
Chain.ValleyOfTheFourWinds = {}
Chain.KrasarangWilds = {}
Chain.KunLaiSummit = {}
Chain.TownlongSteppes = {}
Chain.DreadWastes = {}
Chain.ValeOfEternalBlossom = {}
Chain.IsleOfThunder = {}

BtWQuests.Database:AddExpansion(BtWQuests.Constant.Expansions.MistsOfPandaria, {
    background = {
        texture = "Interface\\EncounterJournal\\UI-EJ-MistsofPandaria"
    },
    image = {
        texture = "Interface\\AddOns\\BtWQuestsMistsOfPandaria\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})