local L = BigWigs:NewBossLocale("Halion", "zhTW")
if not L then return end
if L then
	L.twilight_cutter_emote_trigger = "這些環繞" -- 這些環繞的球體散發著黑暗能量!
end

L = BigWigs:NewBossLocale("The Ruby Sanctum Trash", "zhTW")
if L then
	--L.baltharus = "Baltharus the Warborn" -- NPC 39751
	--L.saviana = "Saviana Ragefire" -- NPC 39747
	--L.zarithrian = "General Zarithrian" -- NPC 39746

	L.adds_yell_trigger = "去吧!將他們挫骨揚灰!"
end
