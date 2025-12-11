local BtWQuests = BtWQuests;
BtWQuests.Constant.Expansions.WarlordsOfDraenor = LE_EXPANSION_WARLORDS_OF_DRAENOR or 5;
BtWQuests.Constant.Category.WarlordsOfDraenor = BtWQuests.Constant.Category.WarlordsOfDraenor or {};
BtWQuests.Constant.Chain.WarlordsOfDraenor = BtWQuests.Constant.Chain.WarlordsOfDraenor or {};
local Category = BtWQuests.Constant.Category.WarlordsOfDraenor;
local Chain = BtWQuests.Constant.Chain.WarlordsOfDraenor;

Category.FrostfireRidge = 601
Category.ShadowmoonValley = 602
Category.Gorgrond = 603
Category.Talador = 604
Category.SpiresOfArak = 605
Category.Nagrand = 606
Category.TanaanJungle = 607

Chain.FrostfireRidge = {}
Chain.ShadowmoonValley = {}
Chain.Gorgrond = {}
Chain.Talador = {}
Chain.SpiresOfArak = {}
Chain.Nagrand = {}
Chain.TanaanJungle = {}

Chain.Introduction = 60001

BtWQuestsDatabase:AddExpansion(BtWQuests.Constant.Expansions.WarlordsOfDraenor, {
    background = {
        texture = "Interface\\EncounterJournal\\UI-EJ-WarlordsOfDraenor"
    },
    image = {
        texture = "Interface\\AddOns\\BtWQuestsWarlordsOfDraenor\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})