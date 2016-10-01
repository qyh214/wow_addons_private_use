local mod	= DBM:NewMod("Broodlord", "DBM-BWL", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 597 $"):sub(12, -3))
mod:SetCreatureID(12017)
mod:SetEncounterID(612)
mod:SetModelID(14308)
mod:RegisterCombat("combat")--Leave this combat, so pull still works for non localized if user manages to leave combat before pull

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 23331 18670",
	"SPELL_AURA_APPLIED 24573"
)

local warnBlastWave	= mod:NewSpellAnnounce(23331)
local warnKnockAway	= mod:NewSpellAnnounce(18670)
local warnMortal	= mod:NewTargetAnnounce(24573)

local timerMortal	= mod:NewTargetTimer(5, 24573)

function mod:OnCombatStart(delay)
end

--It's unfortunate this is a shared spellid.
--cause you are almost always in combat before pulling this boss which breaks "IsInCombat" detection
--these 2 of these warnings will never work.

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 23331 then
		warnBlastWave:Show()
	elseif args.spellId == 18670 then
		warnKnockAway:Show()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 24573 then
		warnMortal:Show(args.destName)
		timerMortal:Start(args.destName)
	end
end
