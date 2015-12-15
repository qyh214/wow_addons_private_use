local mod	= DBM:NewMod("Sulfuron", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 576 $"):sub(12, -3))
mod:SetCreatureID(12098)--, 11662
--mod:SetEncounterID(669)
mod:SetModelID(13030)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED 19779 19780 19776 20294",
	"SPELL_CAST_START 19775"
)

local warnInspire		= mod:NewTargetAnnounce(19779, 2, nil, "Tank|Healer")
local warnHandRagnaros	= mod:NewTargetAnnounce(19780, 2, nil, false, 2)
local warnShadowPain	= mod:NewTargetAnnounce(19776, 2, nil, false, 2)
local warnHeal			= mod:NewCastAnnounce(19775, 3, nil, nil, false)--this may be spammy now that spellid is fixed
local warnImmolate		= mod:NewTargetAnnounce(20294, 2, nil, false, 2)

local specWarnHeal		= mod:NewSpecialWarningInterrupt(19775)

local timerInspireCD	= mod:NewCDTimer(16, 19779, nil, "Tank|Healer")--16-20
local timerInspire		= mod:NewTargetTimer(10, 19779, nil, "Tank|Healer")
local timerHeal			= mod:NewCastTimer(2, 19775, nil, false)--this may be spammy now that spellid is fixed

function mod:OnCombatStart(delay)
	timerInspireCD:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 19779 then
		warnInspire:Show(args.destName)
		timerInspire:Start(args.destName)
		timerInspireCD:Start()
	elseif args.spellId == 19780 and args:IsDestTypePlayer() then
		warnHandRagnaros:CombinedShow(0.3, args.destName)
	elseif args.spellId == 19776 then
		warnShadowPain:CombinedShow(0.3, args.destName)
	elseif args.spellId == 20294 then
		warnImmolate:CombinedShow(0.3, args.destName)
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 19775 then
		warnHeal:Show()
		timerHeal:Start()
		if args.sourceGUID == UnitGUID("target") or args.sourceGUID == UnitGUID("focus") then--Only show warning/timer for your own target.
			specWarnHeal:Show(args.sourceName)
		end
	end
end