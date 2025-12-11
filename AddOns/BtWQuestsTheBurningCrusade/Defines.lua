local BtWQuests = BtWQuests;
BtWQuests.Constant.Expansions.TheBurningCrusade = LE_EXPANSION_BURNING_CRUSADE or 1;
BtWQuests.Constant.Category.TheBurningCrusade = BtWQuests.Constant.Category.TheBurningCrusade or {};
BtWQuests.Constant.Chain.TheBurningCrusade = BtWQuests.Constant.Chain.TheBurningCrusade or {};
local Category = BtWQuests.Constant.Category.TheBurningCrusade;
local Chain = BtWQuests.Constant.Chain.TheBurningCrusade;

Category.HellfirePeninsula = 201
Category.Zangarmarsh = 202
Category.TerokkarForest = 203
Category.Nagrand = 204
Category.BladesEdgeMountains = 205
Category.Netherstorm = 206
Category.ShadowmoonValley = 207
Category.Attunements = 208

Chain.HellfirePeninsula = {}
Chain.Zangarmarsh = {}
Chain.TerokkarForest = {}
Chain.Nagrand = {}
Chain.BladesEdgeMountains = {}
Chain.Netherstorm = {}
Chain.ShadowmoonValley = {}
Chain.Attunements = {}

BtWQuestsDatabase:AddExpansion(BtWQuests.Constant.Expansions.TheBurningCrusade, {
    background = {
        texture = "Interface\\EncounterJournal\\UI-EJ-BurningCrusade"
    },
    image = {
        texture = "Interface\\AddOns\\BtWQuestsTheBurningCrusade\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})