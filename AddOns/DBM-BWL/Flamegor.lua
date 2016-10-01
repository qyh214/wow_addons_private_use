local mod	= DBM:NewMod("Flamegor", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 597 $"):sub(12, -3))
mod:SetCreatureID(11981)
mod:SetEncounterID(615)
mod:SetModelID(6377)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 23339 22539",
	"SPELL_CAST_SUCCESS 23342"
)

local warnWingBuffet	= mod:NewCastAnnounce(23339)
local warnShadowFlame	= mod:NewCastAnnounce(22539)
local warnEnrage		= mod:NewSpellAnnounce(23342)

local timerWingBuffet	= mod:NewNextTimer(31, 23339)
local timerShadowFlame	= mod:NewCastTimer(2, 22539)
local timerEnrageNext 	= mod:NewNextTimer(10, 23342)

function mod:OnCombatStart(delay)
	timerWingBuffet:Start(-delay)
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 23339 then
		warnWingBuffet:Show()
		timerWingBuffet:Start()
	elseif args.spellId == 22539 then
		timerShadowFlame:Start()
		warnShadowFlame:Show()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 23342 then
		warnEnrage:Show()
		timerEnrageNext:Start()
	end
end