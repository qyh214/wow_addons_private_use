local L = BigWigs:NewBossLocale("Grubbis Discovery", "zhCN")
if not L then return end
if L then
	L.bossName = "格鲁比斯"
	L.aoe = "近战AOE"
	L.cloud = "一团毒云接近了首领"
	L.cone = "辐射？" -- "Frontal" Cone, it's a rear cone (he's farting) 还是使用技能名称（诡异的技能）
	L.warmup_say_chat_trigger = "诺莫瑞根" -- 在诺莫瑞根各地，还有一些会喷出辐射性物质的通风井。
end

L = BigWigs:NewBossLocale("Viscous Fallout Discovery", "zhCN")
if L then
	L.bossName = "粘性辐射尘"
	L.desiccated_fallout = "干燥辐射尘" -- NPC ID 216810
end

L = BigWigs:NewBossLocale("Crowd Pummeler 9-60 Discovery", "zhCN")
if L then
	L.bossName = "群体打击者9-60"
end

L = BigWigs:NewBossLocale("Electrocutioner 6000 Discovery", "zhCN")
if L then
	L.bossName = "电刑器6000型"
end

L = BigWigs:NewBossLocale("Mechanical Menagerie Discovery", "zhCN")
if L then
	L.bossName = "机械博览馆"
	L.attack_buff = "+50% 攻击速度"
	--L.boss_at_hp = "%s at %d%%" -- BOSS_NAME at 50%
	L.red_button = "红色按钮"

	L[218242] = "|T134153:0:0:0:0:64:64:4:60:4:60|t龙"
	L[218243] = "|T136071:0:0:0:0:64:64:4:60:4:60|t羊"
	L[218244] = "|T133944:0:0:0:0:64:64:4:60:4:60|t松鼠"
	L[218245] = "|T135996:0:0:0:0:64:64:4:60:4:60|t鸡"

	L.run = "远离中场"
	L.run_desc = "当你击败首领时，会显示一条信息，让你远离中场跑到门口。这样做的目的是帮助你避免引起与新出现的首领开战。"
end

L = BigWigs:NewBossLocale("Mekgineer Thermaplugg Discovery", "zhCN")
if L then
	L.bossName = "机械师瑟玛普拉格"
	L.red_button = "红色按钮"
	L.position = "位置 %d" -- Position 5
end
