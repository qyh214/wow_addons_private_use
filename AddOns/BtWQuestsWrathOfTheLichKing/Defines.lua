local BtWQuests = BtWQuests;
BtWQuests.Constant.Expansions.WrathOfTheLichKing = LE_EXPANSION_WRATH_OF_THE_LICH_KING or 2;
BtWQuests.Constant.Category.WrathOfTheLichKing = BtWQuests.Constant.Category.WrathOfTheLichKing or {};
BtWQuests.Constant.Chain.WrathOfTheLichKing = BtWQuests.Constant.Chain.WrathOfTheLichKing or {};
local Category = BtWQuests.Constant.Category.WrathOfTheLichKing;
local Chain = BtWQuests.Constant.Chain.WrathOfTheLichKing;

Category.BoreanTundra = 301
Category.HowlingFjord = 302
Category.Dragonblight = 303
Category.GrizzlyHills = 304
Category.ZulDrak = 305
Category.SholazarBasin = 306
Category.TheStormPeaks = 307
Category.Icecrown = 308
Category.Wintergrasp = 309
Category.CrystalsongForest = 310

Chain.BoreanTundra = {}
Chain.HowlingFjord = {}
Chain.Dragonblight = {}
Chain.GrizzlyHills = {}
Chain.ZulDrak = {}
Chain.SholazarBasin = {}
Chain.TheStormPeaks = {}
Chain.Icecrown = {}
Chain.Wintergrasp = {}
Chain.CrystalsongForest = {}

BtWQuestsDatabase:AddExpansion(BtWQuests.Constant.Expansions.WrathOfTheLichKing, {
    background = {
        texture = "Interface\\EncounterJournal\\UI-EJ-WrathoftheLichKing"
    },
    image = {
        texture = "Interface\\AddOns\\BtWQuestsWrath\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})