if GetLocale() ~= "zhCN" then
	return
end
local L

-------------------------
-- Supreme Lord Kazzak --
-------------------------
L = DBM:GetModLocalization(1452)

L:SetMiscLocalization({
	Pull	= "你将面对燃烧军团的力量！"
})
