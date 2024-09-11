local L = BigWigs:NewBossLocale("Ragnaros Classic", "zhCN")
if not L then return end
if L then
	L.submerge_trigger = "出现吧，我的奴仆"
	L.son = "烈焰之子" -- NPC ID 12143
end

L = BigWigs:NewBossLocale("The Molten Core", "zhCN")
if L then
	L.bossName = "熔火之心"
end
