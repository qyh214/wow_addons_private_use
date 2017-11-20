local mod	= DBM:NewMod("VoidReaver", "DBM-TheEye")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 631 $"):sub(12, -3))
mod:SetCreatureID(19516)
mod:SetEncounterID(731)
mod:SetModelID(18951)
mod:SetZone()

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 34172 34162 25778"
)

local warnOrb			= mod:NewTargetAnnounce(34172, 2)
local warnKnockBack		= mod:NewSpellAnnounce(25778, 4)
local warnPounding		= mod:NewSpellAnnounce(34162, 3)

local specWarnOrb		= mod:NewSpecialWarningDodge(34172, nil, nil, nil, 1, 2)
local yellOrb			= mod:NewYell(34172)

local timerKnockBack	= mod:NewCDTimer(20, 25778, nil, "Tank", 2, 5)
local timerPounding		= mod:NewCDTimer(13, 34162, nil, nil, nil, 2)

local berserkTimer		= mod:NewBerserkTimer(600)

local voiceOrb			= mod:NewVoice(34172)--watchorb

function mod:OnCombatStart(delay)
	timerPounding:Start()
	berserkTimer:Start(-delay)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 34172 then
		if args:IsPlayer() then
			specWarnOrb:Show()
			voiceOrb:Play("watchorb")
			yellOrb:Yell()
		else
			warnOrb:Show(args.destName)
		end
	elseif args.spellId == 34162 then
		warnPounding:Show()
		timerPounding:Start()
	elseif args.spellId == 25778 then
		warnKnockBack:Show()
		timerKnockBack:Start()
	end
end
