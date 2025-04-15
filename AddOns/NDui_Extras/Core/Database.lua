local _, ns = ...
local B, C, L, DB = unpack(ns)

-- Other
DB.margin = 3
DB.alpha = .75

-- Item Stats
DB.ItemStats = {
	--["ITEM_MOD_CRIT_RATING_SHORT"] = true,    -- 爆击
	--["ITEM_MOD_HASTE_RATING_SHORT"] = true,   -- 急速
	--["ITEM_MOD_MASTERY_RATING_SHORT"] = true, -- 精通
	--["ITEM_MOD_VERSATILITY"] = true,          -- 全能

	["ITEM_MOD_CR_AVOIDANCE_SHORT"] = true,     -- 闪避
	["ITEM_MOD_CR_LIFESTEAL_SHORT"] = true,     -- 吸血
	["ITEM_MOD_CR_SPEED_SHORT"] = true,         -- 加速
	["ITEM_MOD_CR_STURDINESS_SHORT"] = true,    -- 永不磨损
}

-- Item IDs
DB.MiscellaneousIDs = {
	[Enum.ItemClass.Miscellaneous] = true,
}

DB.CollectionIDs = {
	[Enum.ItemMiscellaneousSubclass.CompanionPet] = true,
	[Enum.ItemMiscellaneousSubclass.Mount] = true,
}

DB.EquipmentIDs = {
	[Enum.ItemClass.Weapon] = true,
	[Enum.ItemClass.Armor] = true,
}

DB.OutmodedIDs = {
	[Enum.ItemClass.Consumable] = true,
	[Enum.ItemClass.Gem] = true,
	[Enum.ItemClass.Reagent] = true,
	[Enum.ItemClass.Tradegoods] = true,
	[Enum.ItemClass.ItemEnhancement] = true,
}

DB.ExcludeIDs = {
	[Enum.ItemConsumableSubclass.Generic] = Enum.ItemClass.Consumable,
	[Enum.ItemConsumableSubclass.Elixir] = Enum.ItemClass.Consumable,
	[Enum.ItemConsumableSubclass.Other] = Enum.ItemClass.Consumable,
}

-- Item Types
DB.ConduitTypes = {
	[CONDUIT_TYPE_ENDURANCE] = "耐久",
	[CONDUIT_TYPE_FINESSE] = "灵巧",
	[CONDUIT_TYPE_POTENCY] = "效能",
}

DB.CurioTypes = {
	[DELVES_CONFIG_SLOT_COMBAT_CURIO] = "战斗",
	[DELVES_CONFIG_SLOT_UTILITY_CURIO] = "效能",
}

DB.BindTypes = {
	[ITEM_ACCOUNTBOUND] = "BoA",
	[ITEM_BNETACCOUNTBOUND] = "BoA",
	[ITEM_BIND_ON_EQUIP] = "BoE",
	[ITEM_BIND_ON_USE] = "BoU",
	[ITEM_BIND_TO_ACCOUNT] = "BoA",
	[ITEM_BIND_TO_BNETACCOUNT] = "BoA",
	--[ITEM_ACCOUNTBOUND_UNTIL_EQUIP] = "EoA",
	--[ITEM_BIND_TO_ACCOUNT_UNTIL_EQUIP] = "EoA",
}

DB.EquipmentTypes = {
	["INVTYPE_HOLDABLE"] = SECONDARYHANDSLOT,
	["INVTYPE_SHIELD"] = SHIELDSLOT,
}

DB.ContainerTypes = {
	[0] = "背包",
	[1] = "灵魂",
	[2] = "草药",
	[3] = "附魔",
	[4] = "工程",
	[5] = "珠宝",
	[6] = "采矿",
	[7] = "制皮",
	[8] = "铭文",
	[9] = "工具",
	[10] = "烹饪",
	[11] = "材料",
}

DB.ItemEnhancementTypes = {
	[0] = INVTYPE_HEAD,
	[1] = INVTYPE_NECK,
	[2] = INVTYPE_SHOULDER,
	[3] = INVTYPE_CLOAK,
	[4] = INVTYPE_CHEST,
	[5] = INVTYPE_WRIST,
	[6] = INVTYPE_HAND,
	[7] = INVTYPE_WAIST,
	[8] = INVTYPE_LEGS,
	[9] = INVTYPE_FEET,
	[10] = INVTYPE_FINGER,
	[11] = INVTYPE_WEAPON,
	[12] = INVTYPE_2HWEAPON,
	[13] = INVTYPE_WEAPONOFFHAND,
	[14] = AUCTION_SUBCATEGORY_OTHER,
}

DB.RecipeTypes = {
	[0] = "书籍",
	[1] = "制皮",
	[2] = "裁缝",
	[3] = "工程",
	[4] = "锻造",
	[5] = "烹饪",
	[6] = "炼金",
	[7] = "急救",
	[8] = "附魔",
	[9] = "钓鱼",
	[10] = "珠宝",
	[11] = "铭文",
}

DB.KeyTypes = {
	[0] = "钥匙",
	[1] = "开锁",
}

DB.ProfessionTypes = {
	[0] = "锻造",
	[1] = "制皮",
	[2] = "炼金",
	[3] = "草药",
	[4] = "烹饪",
	[5] = "采矿",
	[6] = "裁缝",
	[7] = "工程",
	[8] = "附魔",
	[9] = "钓鱼",
	[10] = "剥皮",
	[11] = "珠宝",
	[12] = "铭文",
	[13] = "考古",
}

DB.MiscellaneousTypes = {
	[2] = PETS,
	[5] = MOUNTS,
	[6] = EQUIPSET_EQUIP,
}

DB.DeliverRelic = {
	[356931] = true,
	[356933] = true,
	[356934] = true,
	[356935] = true,
	[356936] = true,
	[356937] = true,
	[356938] = true,
	[356939] = true,
	[356940] = true,
}

DB.AncientMana = {
	[192922] = true,
	[193080] = true,
	[193081] = true,
	[211161] = true,
	[211171] = true,
	[216918] = true,
	[222333] = true,
	[222334] = true,
	[222335] = true,
	[222336] = true,
	[222929] = true,
	[222942] = true,
	[222945] = true,
	[222947] = true,
	[222950] = true,
	[223677] = true,
	[224379] = true,
	[224380] = true,
	[224381] = true,
	[224382] = true,
	[227729] = true,
	[233126] = true,
	[233232] = true,
}

DB.Experience = {
	[180419] = true,
	[225517] = true,
	[255249] = true,
	[347495] = true,
	[347496] = true,
	[347497] = true,
	[347498] = true,
	[347499] = true,
	[353852] = true,
	[357445] = true,
	[357447] = true,
	[357448] = true,
	[362986] = true,
}

DB.Studying = {
	[450698] = true,
	[450793] = true,
	[450818] = true,
	[450819] = true,
	[450821] = true,
	[450824] = true,
	[450827] = true,
	[450828] = true,
	[450835] = true,
	[450836] = true,
	[450840] = true,
	[452259] = true,
	[452260] = true,
	[453371] = true,
	[453372] = true,
	[453440] = true,
	[453443] = true,
	[453444] = true,
	[453447] = true,
	[453448] = true,
	[453450] = true,
	[453452] = true,
	[453453] = true,
	[453454] = true,
	[453455] = true,
	[453456] = true,
	[453880] = true,
	[454023] = true,
	[454355] = true,
	[454358] = true,
	[457715] = true,
	[457717] = true,
	[457718] = true,
	[457719] = true,
	[457720] = true,
	[457721] = true,
	[457722] = true,
	[457723] = true,
	[457724] = true,
	[457725] = true,
	[457726] = true,
	[458432] = true,
	[458477] = true,
	[458681] = true,
	[458690] = true,
	[458719] = true,
	[458722] = true,
	[458726] = true,
	[458728] = true,
	[458729] = true,
	[458731] = true,
	[458733] = true,
	[458734] = true,
	[458738] = true,
	[459885] = true,
	[459886] = true,
	[459887] = true,
	[459888] = true,
	[459889] = true,
	[459890] = true,
	[459891] = true,
	[459892] = true,
	[459893] = true,
	[459894] = true,
	[459895] = true,
	[459896] = true,
	[459897] = true,
	[459898] = true,
	[459899] = true,
	[459900] = true,
	[459901] = true,
	[459902] = true,
	[459903] = true,
	[459904] = true,
	[459905] = true,
	[459906] = true,
	[459907] = true,
	[459908] = true,
	[459909] = true,
	[459910] = true,
	[459911] = true,
	[459912] = true,
	[459913] = true,
	[459914] = true,
	[459915] = true,
	[459916] = true,
	[459917] = true,
	[460234] = true,
	[460240] = true,
	[460258] = true,
	[462138] = true,
	[462141] = true,
	[462142] = true,
	[462143] = true,
	[462144] = true,
	[462146] = true,
	[462902] = true,
	[462903] = true,
	[462904] = true,
	[462905] = true,
	[462906] = true,
	[462907] = true,
	[462908] = true,
	[462909] = true,
	[462910] = true,
	[462911] = true,
	[462912] = true,
	[462913] = true,
	[462914] = true,
	[462915] = true,
	[462916] = true,
	[462917] = true,
	[463199] = true,
	[463200] = true,
	[463201] = true,
	[463202] = true,
	[463203] = true,
	[463204] = true,
	[463205] = true,
}

DB.SpecialJunk = {
	[3300] = true, -- 幸运兔脚
	[3670] = true, -- 带粘液的骨头
	[6150] = true, -- 绳结
	[11406] = true, -- 腐烂的熊肉
	[11944] = true, -- 黑铁幼婴鞋
	[25402] = true, -- 有坚不摧之力
	[36812] = true, -- 基础零件
	[62072] = true, -- 罗波的摇头杖
	[67410] = true, -- 极其不祥的石头
	[221550] = true, -- 薮根伞菇
}

DB.PrimordialStone = {}
for id = 204000, 204030 do
	DB.PrimordialStone[id] = true
end
for id = 204573, 204579 do
	DB.PrimordialStone[id] = true
end
DB.PrimordialStone[203703] = true -- 棱光碎片