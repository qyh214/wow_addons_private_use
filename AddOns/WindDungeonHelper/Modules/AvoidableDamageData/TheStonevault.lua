local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 水晶裂片 (斯卡莫拉克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 422261,
	},
	{
		-- 不穩定撞擊 (斯卡莫拉克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 423538,
	},
	{
		-- 震地波 (大地灌注魔像)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 425027,
	},
	{
		-- 不羈的虛無 (至高代言者埃里奇)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 427869,
	},
	{
		-- 廢料方塊 (廢料方塊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428547,
	},
	{
		-- 花崗岩爆發 (岩石粉碎者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428709,
	},
	{
		-- 排氣通風口 (通道潛獵者, 代言者布洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 428819,
	},
	{
		-- 燃焰碎塊 (通道潛獵者, 代言者布洛克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 429999,
	},
	{
		-- 動盪碎片 (斯卡莫拉克)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 443405,
	},
	{
		-- 粉碎猛撲 (再利用的裝貨機器人)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 447145,
	},
	{
		-- 持盾奔竄 (咒爐榮譽守衛)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 448975,
	},
	{
		-- 水晶齊射 (虛無之觸元素)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 449070,
	},
	{
		-- 熔岩火砲 (代言者朵利塔, 熔爐裝填工)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 449129,
	},
	{
		-- 熔岩火砲 (代言者朵利塔, 熔爐裝填工)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 449169,
	},
	{
		-- 無序 (至高代言者埃里奇)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 457465,
	},
	{
		-- 熔岩波 (廢料方塊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 463145,
	},
	{
		-- 熾炎破片 (廢料方塊)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 464392,
	},
}

local mapIds = { 2341 }

AD:AddData("The Stonevault", mistakes, mapIds)
