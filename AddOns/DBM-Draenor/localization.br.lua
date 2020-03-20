if GetLocale() ~= "ptBR" then
	return
end

local L

-------------------------
-- Supreme Lord Kazzak --
-------------------------
L = DBM:GetModLocalization(1452)

L:SetMiscLocalization({
	Pull = "You face the might of the Burning Legion!"--Translate
})
