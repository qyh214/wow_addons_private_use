local mod	= DBM:NewMod("Magmadar", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 645 $"):sub(12, -3))
mod:SetCreatureID(11982)
mod:SetEncounterID(664)
mod:SetModelID(10193)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 19451",
	"SPELL_AURA_REMOVED 19451",
	"SPELL_CAST_SUCCESS 19408"
)

local warnPanic			= mod:NewSpellAnnounce(19408, 2)
local warnEnrage		= mod:NewTargetAnnounce(19451, 3, nil , "Healer|Tank|RemoveEnrage")

local specWarnEnrage	= mod:NewSpecialWarningDispel(19451, "RemoveEnrage")

--local timerPanicCD	= mod:NewCDTimer(30, 19408)
local timerPanic		= mod:NewBuffActiveTimer(8, 19408, nil, nil, nil, 3)
local timerEnrage		= mod:NewBuffActiveTimer(8, 19451, nil, nil, nil, 5, nil, DBM_CORE_ENRAGE_ICON)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 19451 then
		if self.Options.SpecWarn19451dispel then
			specWarnEnrage:Show(args.destName)
			specWarnEnrage:Play("trannow")
		else
			warnEnrage:Show(args.destName)
		end
		timerEnrage:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 19451 then
		timerEnrage:Stop()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19408 then
		warnPanic:Show()
		timerPanic:Start()
--		timerPanicCD:Start()
	end
end