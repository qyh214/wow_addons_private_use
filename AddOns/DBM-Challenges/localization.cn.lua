if GetLocale() ~= "zhCN" then return end
local L

------------------------
-- White TIger Temple --
------------------------
L= DBM:GetModLocalization("d640")

L:SetMiscLocalization({
	Endless				= "无尽",--Could not find a global for this one.
	ReplyWhisper		= "<Deadly Boss Mods> %s正在试炼场试炼中(模式:%s 波数:%d)"
})