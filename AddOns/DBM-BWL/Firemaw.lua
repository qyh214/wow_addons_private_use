local mod	= DBM:NewMod("Firemaw", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("2019041710011")
mod:SetCreatureID(11983)
mod:SetEncounterID(613)
mod:SetModelID(6377)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 23339 22539"
)

local warnWingBuffet	= mod:NewCastAnnounce(23339, 2)
local warnShadowFlame	= mod:NewCastAnnounce(22539, 2)
--local warnFlameBuffet	= mod:NewSpellAnnounce(23341)

local timerWingBuffet	= mod:NewNextTimer(31, 23339, nil, nil, nil, 2)
--local timerFlameBuffetCD = mod:NewCDTimer(10, 23341)

function mod:OnCombatStart(delay)
	timerWingBuffet:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 23339 then
		warnWingBuffet:Show()
		timerWingBuffet:Start()
	elseif args.spellId == 22539 then
		warnShadowFlame:Show()
	end
end

--[[
function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 23341 then
		warnFlameBuffet:Show()
	end
end--]]
