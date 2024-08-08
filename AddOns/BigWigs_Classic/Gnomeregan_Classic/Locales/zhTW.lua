local L = BigWigs:NewBossLocale("Grubbis Discovery", "zhTW")
if not L then return end
if L then
	L.bossName = "格魯比斯"
	L.aoe = "近戰AOE"
	L.cloud = "一團毒雲接近了首領"
	--L.cone = "\"Frontal\" cone" -- "Frontal" Cone, it's a rear cone (he's farting)
	--L.warmup_say_chat_trigger = "Gnomeregan" -- There are still ventilation shafts actively spewing radioactive material throughout Gnomeregan.
end

L = BigWigs:NewBossLocale("Viscous Fallout Discovery", "zhTW")
if L then
	L.bossName = "粘性輻射塵"
	L.desiccated_fallout = "乾燥的輻射塵" -- NPC ID 216810
end

L = BigWigs:NewBossLocale("Crowd Pummeler 9-60 Discovery", "zhTW")
if L then
	L.bossName = "群體打擊者9-60"
end

L = BigWigs:NewBossLocale("Electrocutioner 6000 Discovery", "zhTW")
if L then
	L.bossName = "電刑器6000型"
end

L = BigWigs:NewBossLocale("Mechanical Menagerie Discovery", "zhTW")
if L then
	L.bossName = "機械展示廳"
	L.attack_buff = "+50% 攻擊速度"
	--L.boss_at_hp = "%s at %d%%" -- BOSS_NAME at 50%
	--L.red_button = "Red Button"

	L[218242] = "|T134153:0:0:0:0:64:64:4:60:4:60|t龍"
	L[218243] = "|T136071:0:0:0:0:64:64:4:60:4:60|t羊"
	L[218244] = "|T133944:0:0:0:0:64:64:4:60:4:60|t松鼠"
	L[218245] = "|T135996:0:0:0:0:64:64:4:60:4:60|t雞"

	--L.run = "Run to the door"
	--L.run_desc = "Show a message when you defeat this boss to run to the door. This is intended to help you avoid accidentally engaging the next boss."
end

L = BigWigs:NewBossLocale("Mekgineer Thermaplugg Discovery", "zhTW")
if L then
	L.bossName = "機電師瑟瑪普拉格"
	--L.red_button = "Red Button"
	--L.position = "Position %d" -- Position 5
end
