if GetLocale() ~= "ruRU" then
	return
end
local L

-------------------------
-- Supreme Lord Kazzak --
-------------------------
L = DBM:GetModLocalization(1452)

L:SetMiscLocalization({
	Pull	= "Вы познаете мощь Легиона!"
})
