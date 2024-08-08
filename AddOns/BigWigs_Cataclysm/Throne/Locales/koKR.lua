
local L = BigWigs:NewBossLocale("Al'Akir", "koKR")
if not L then return end
if L then
	L.stormling = "작은 폭풍 정령"
	L.stormling_desc = "작은 폭풍 정령 소환을 알립니다."

	L.acid_rain = "산성 비 (%d)"

	L.feedback_message = "역순환 x%d"
end

L = BigWigs:NewBossLocale("Conclave of Wind", "koKR")
if L then
	L.gather_strength = "힘 모으기: %s"

	L["93059_desc"] = "폭풍 방패"

	L.full_power = "극의 힘"
	L.full_power_desc = "힘이 극에 달했을시 특별한 능력에 대해 알립니다.(현재 3가지중 미풍에 대해서만 알립니다.)" --check
	L.gather_strength_emote = "%s의 힘이 극" --check
end

