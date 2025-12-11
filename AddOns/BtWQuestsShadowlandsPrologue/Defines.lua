local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
BtWQuests.Constant.Expansions.Shadowlands = LE_EXPANSION_SHADOWLANDS or 8
BtWQuests.Constant.Category.Shadowlands = BtWQuests.Constant.Category.Shadowlands or {}
BtWQuests.Constant.Chain.Shadowlands = BtWQuests.Constant.Chain.Shadowlands or {}
local Category = BtWQuests.Constant.Category.Shadowlands
local Chain = BtWQuests.Constant.Chain.Shadowlands

Database:AddExpansion(BtWQuests.Constant.Expansions.Shadowlands, {
    image = {
        texture = "Interface\\AddOns\\BtWQuestsShadowlandsPrologue\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})