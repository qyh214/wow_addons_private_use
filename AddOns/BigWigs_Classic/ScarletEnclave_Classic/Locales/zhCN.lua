local L = BigWigs:NewBossLocale("Balnazzar Scarlet Enclave", "zhCN")
if not L then return end
if L then
	L.bossName = "巴纳扎尔"
end

L = BigWigs:NewBossLocale("High Commander Beatrix", "zhCN")
if L then
	L.bossName = "高阶指挥官碧阿崔克丝"
	--L.meteor_yell_trigger = "如您所愿" -- 如您所愿，高阶指挥官！
	--L.waves_footmen_yell_trigger = "列队防守" -- 列队防守！
	--L.waves_cavalry_yell_trigger = "举起长矛" -- 明白！举起长矛！
	--L.arrows_yell_trigger = "Archers," -- Archers, unleash hell!
	--L.bombing_yell_trigger = "At once," -- At once, Beatrix!
end

L = BigWigs:NewBossLocale("Solistrasza", "zhCN")
if L then
	L.bossName = "瑟莉斯塔萨"
end

L = BigWigs:NewBossLocale("Alexei the Beastlord", "zhCN")
if L then
	L.bossName = "兽王阿莱克谢"
end

L = BigWigs:NewBossLocale("Mason the Echo", "zhCN")
if L then
	L.bossName = "回响者梅森"
end

L = BigWigs:NewBossLocale("Reborn Council", "zhCN")
if L then
	L.bossName = "复生议会"
	L[240795] = "赫洛德"
	L[240809] = "韦沙斯"
	L[240810] = "杜安"
end

L = BigWigs:NewBossLocale("Lillian Voss", "zhCN")
if L then
	L.bossName = "莉莉安·沃斯"
end

L = BigWigs:NewBossLocale("Grand Crusader Caldoran", "zhCN")
if L then
	L.bossName = "大十字军战士凯尔多兰"
end
