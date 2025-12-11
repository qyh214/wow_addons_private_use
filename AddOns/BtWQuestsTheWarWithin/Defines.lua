local BtWQuests = BtWQuests
local L = BtWQuests.L
local Database = BtWQuests.Database
BtWQuests.Constant.Expansions.TheWarWithin = LE_EXPANSION_THE_WAR_WITHIN or 10
BtWQuests.Constant.Category.TheWarWithin = BtWQuests.Constant.Category.TheWarWithin or {}
BtWQuests.Constant.Chain.TheWarWithin = BtWQuests.Constant.Chain.TheWarWithin or {}
local Category = BtWQuests.Constant.Category.TheWarWithin
local Chain = BtWQuests.Constant.Chain.TheWarWithin

BtWQuests.Constant.Category.TheWarWithin = {
    IsleOfDorn = 1101,
    TheRingingDeeps = 1102,
    Hallowfall = 1103,
    AzjKahet = 1104,
    SirenIsle = 1105,
    Undermined = 1106,
    Karesh = 1107,
}
BtWQuests.Constant.Chain.TheWarWithin = {
    IsleOfDorn = {},
    TheRingingDeeps = {},
    Hallowfall = {},
    AzjKahet = {},
    SirenIsle = {},
    Undermined = {},
    Karesh = {},
}

BtWQuests.Constant.Restrictions.TheWarWithinToF = -110001;
BtWQuests.Constant.Restrictions.NOTTheWarWithinToF = -110002;
Database:AddCondition(BtWQuests.Constant.Restrictions.TheWarWithinToF, { type = "quest", id = 79573 }) -- "Threads of Fate"
Database:AddCondition(BtWQuests.Constant.Restrictions.NOTTheWarWithinToF, { type = "quest", id = 79573, status = { "pending" } }) -- "Threads of Fate"

Database:AddExpansion(BtWQuests.Constant.Expansions.TheWarWithin, {
    image = {
        texture = "Interface\\AddOns\\BtWQuestsTheWarWithin\\UI-Expansion",
        texCoords = {0, 0.90625, 0, 0.8125}
    }
})
