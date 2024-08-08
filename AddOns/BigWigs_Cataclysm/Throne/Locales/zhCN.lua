
local L = BigWigs:NewBossLocale("Al'Akir", "zhCN")
if not L then return end
if L then
	L.stormling = "风暴火花"
	L.stormling_desc = "当召唤风暴火花时发出警报。"

	L.acid_rain = "酸雨：>%d<！"

	L.feedback_message = "%dx 回馈！"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "zhCN")
if L then
	L.gather_strength = "%s即将获得全部力量！"

	L["93059_desc"] = "当风暴护盾吸收伤害时发出警报。"

	L.full_power = "全部能量"
	L.full_power_desc = "当首领获得全部能量并开始施放特殊技能时发出警报。"
	L.gather_strength_emote = "%s开始从剩下的风领主身上获得力量！"
end

