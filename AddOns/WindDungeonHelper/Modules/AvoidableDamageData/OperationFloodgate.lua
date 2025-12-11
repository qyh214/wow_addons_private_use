local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 飛艇彈幕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1213704,
	},
	{
		-- 電能水池
		type = AD.MISTAKE.AURA,
		aura = 1215089,
	},
	{
		-- 高速衝鋒 (布隆特)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 460965,
	},
	{
		-- R.P.G.G. (暗融爆破兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 461793,
	},
	{
		-- 武器儲物箱爆炸
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 464294,
	},
	{
		-- 上緊發條 (裝貨機器人)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 465128,
	},
	{
		-- 電池箭 (暗融起跳者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 465604,
	},
	{
		-- 突襲檢查 (暗融巡官)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 465682,
	},
	{
		-- 渦輪箭 (基澤‧巨電)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 465982,
	},
	{
		-- 水壩碎石 (基澤‧巨電)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 468604,
	},
	{
		-- 跳躍火花 (基澤‧巨電, 跳躍火花)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 468647,
	},
	{
		-- 流水電擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 468723,
	},
	{
		-- 爆鹽炸藥 (風險投資公司潛水員)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 468727,
	},
	{
		-- 流水電擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 468741,
	},
	{
		-- 勘查地面 (風險投資公司勘測員)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 472338,
	},
	{
		-- 末日風暴 (暗融機甲飛機)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 472454,
	},
	{
		-- 破片 (姬薩‧迅融)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 472755,
	},
	{
		-- 串插根鬚 (沼臉)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473046,
	},
	{
		-- 洶湧浪潮
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473051,
	},
	{
		-- 土石流 (沼臉)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473126,
	},
	{
		-- 音速波 (巨型M.O.M.M.A.)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473224,
	},
	{
		-- 音速波 (巨型M.O.M.M.A.)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473240,
	},
	{
		-- 過度電化 (巨型M.O.M.M.A.)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473287,
	},
	{
		-- 超級大爆炸！ (滴答作響的定時炸彈, 姬薩‧迅融)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 473526,
	},
	{
		-- 粉碎鋸刃 (伐木器械3000型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 474350,
	},
	{
		-- 火焰噴射器 (伐木器械3000型)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 474388,
	},
	{
		-- 飛艇彈幕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1213790,
	},
	{
		-- 炸彈堆爆炸
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1214341,
	},
	{
		-- 電能水池
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1215071,
	},
	{
		-- B.B.B.F.G. (姬薩‧迅融)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 1217751,
	},
}

local mapIds = { 2387, 2388 }

AD:AddData("Operation: Floodgate", mistakes, mapIds)
