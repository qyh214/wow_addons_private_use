local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
BtWQuests.Constant.Expansions.Dragonflight = LE_EXPANSION_DRAGONFLIGHT or 9
BtWQuests.Constant.Category.Dragonflight = BtWQuests.Constant.Category.Dragonflight or {}
BtWQuests.Constant.Chain.Dragonflight = BtWQuests.Constant.Chain.Dragonflight or {}
local Category = BtWQuests.Constant.Category.Dragonflight
local Chain = BtWQuests.Constant.Chain.Dragonflight

Database:AddExpansion(BtWQuests.Constant.Expansions.Dragonflight, {
    image = {
        texture = "Interface\\AddOns\\BtWQuestsDragonflightPrologue\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})
