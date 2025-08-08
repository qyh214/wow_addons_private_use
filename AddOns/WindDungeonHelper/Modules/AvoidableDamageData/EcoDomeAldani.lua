local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 碎地者 (鑽地潛伏者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1213695,
	},
	{
		-- 噬食 (阿奇卡)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1217241,
	},
	{
		-- 消化唾沫 (阿奇卡)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1217446,
	},
	{
		-- 吞食潰擊 (饑渴吞食者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1221174,
	},
	{
		-- 秘法燃燒 (過載哨兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1222202,
	},
	{
		-- 扭曲傳送 (馴服的廢墟潛獵者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1222356,
	},
	{
		-- 鑽地爆發 (荒地潛伏者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1223008,
	},
	{
		-- 祭儀匕首 (靈魂雕銘師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1225179,
	},
	{
		-- 命運負傷
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1226444,
	},
	{
		-- 秘法斬擊 (過載哨兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		playerIsNotTank = true,
		spell = 1231224,
	},
	{
		-- 永恆編織 (靈魂雕銘師)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1236910,
	},
}

local mapIds = { 2449 }

AD:AddData("Eco-Dome Al'dani", mistakes, mapIds)
