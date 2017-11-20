local mod	= DBM:NewMod("Gehennas", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 637 $"):sub(12, -3))
mod:SetCreatureID(12259)--, 11661
mod:SetEncounterID(665)
mod:SetModelID(13030)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 19716 19717",
	"SPELL_AURA_APPLIED 20277"
)

local warnRainFire	= mod:NewSpellAnnounce(19717, 2, nil, false)
local warnCurse		= mod:NewSpellAnnounce(19716, 3)
local warnFist		= mod:NewTargetAnnounce(20277, 2, nil, false, 2)

local specWarnRoF	= mod:NewSpecialWarningMove(19717, nil, nil, nil, 1, 2)

local timerRoF		= mod:NewCDTimer(6, 19717, nil, false, nil, 3)
local timerCurse	= mod:NewNextTimer(30, 19716, nil, nil, nil, 3, nil, DBM_CORE_HEALER_ICON..DBM_CORE_CURSE_ICON)
local timerFist		= mod:NewBuffActiveTimer(4, 20277, nil, false, 2, 3)

local voiceRoF		= mod:NewVoice(19717)--runaway

function mod:OnCombatStart(delay)
	timerCurse:Start(6-delay)
	if self:IsDifficulty("event40") or not self:IsTrivial(75) then--Only want to warn if it's a threat
		self:RegisterShortTermEvents(
			"SPELL_PERIODIC_DAMAGE 19717",
			"SPELL_PERIODIC_MISSED 19717"
		)
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19716 then
		timerCurse:Start()
		warnCurse:Show()
	elseif args.spellId == 19717 and self:IsInCombat() then
		warnRainFire:Show()
		timerRoF:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 20277 and args:IsDestTypePlayer() then
		warnFist:CombinedShow(0.3, args.destName)
	end
end

function mod:SPELL_PERIODIC_DAMAGE(_, _, _, _, destGUID, destName, _, _, spellId)
	if spellId == 19717 and destGUID == UnitGUID("player") and self:AntiSpam() then
		specWarnRoF:Show()
		voiceRoF:Play("runaway")
	end
end
mod.SPELL_PERIODIC_MISSED = mod.SPELL_PERIODIC_DAMAGE
