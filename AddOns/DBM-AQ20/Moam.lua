local mod	= DBM:NewMod("Moam", "DBM-AQ20", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 596 $"):sub(12, -3))
mod:SetCreatureID(15340)
mod:SetEncounterID(720)
mod:SetModelID(15392)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED 25685",
	"SPELL_AURA_REMOVED 25685"
)

local warnStoneform		= mod:NewSpellAnnounce(25685, 3)

local timerStoneform	= mod:NewNextTimer(90, 25685)
local timerStoneformDur	= mod:NewBuffActiveTimer(90, 25685)

function mod:OnCombatStart(delay)
	timerStoneform:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 25685 then
		warnStoneform:Show()
		timerStoneformDur:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 25685 then
		timerStoneformDur:Cancel()
		timerStoneform:Start()
	end
end