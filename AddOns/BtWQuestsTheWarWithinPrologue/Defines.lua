local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
BtWQuests.Constant.Expansions.TheWarWithin = LE_EXPANSION_THE_WAR_WITHIN or 10
BtWQuests.Constant.Category.TheWarWithin = BtWQuests.Constant.Category.TheWarWithin or {}
BtWQuests.Constant.Chain.TheWarWithin = BtWQuests.Constant.Chain.TheWarWithin or {}
local Category = BtWQuests.Constant.Category.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin

Database:AddExpansion(BtWQuests.Constant.Expansions.TheWarWithin, {
    image = {
        texture = "Interface\\AddOns\\BtWQuestsTheWarWithinPrologue\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})
