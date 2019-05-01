local mod	= DBM:NewMod("Shazzrah", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("2019041710011")
mod:SetCreatureID(12264)
mod:SetEncounterID(667)
mod:SetModelID(13032)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 19714",
	"SPELL_AURA_REMOVED 19714",
	"SPELL_CAST_SUCCESS 19713 19715 23138"
)

local warnCurse			= mod:NewSpellAnnounce(19713)
local warnGrounding		= mod:NewTargetNoFilterAnnounce(19714, 2, nil, "MagicDispeller")
local warnCntrSpell		= mod:NewSpellAnnounce(19715)

local specWarnGrounding	= mod:NewSpecialWarningDispel(19714, "MagicDispeller", nil, nil, 1, 2)
local specWarnGate		= mod:NewSpecialWarningTaunt(23138, "Tank", nil, nil, 1, 2)--aggro wipe, needs fresh taunt

local timerCurseCD		= mod:NewCDTimer(20, 19713, nil, nil, nil, 3, nil, DBM_CORE_CURSE_ICON)
local timerGrounding	= mod:NewBuffActiveTimer(30, 19714, nil, "MagicDispeller", 2, 5, nil, DBM_CORE_MAGIC_ICON)
local timerGateCD		= mod:NewNextTimer(50, 23138, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)

function mod:OnCombatStart(delay)
	--Bad pull, transcriptor started late, times may be off 1-2 seconds
	timerCurseCD:Start(10-delay)
	timerGateCD:Start(30-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 19714 and self:IsInCombat() and not args:IsDestTypePlayer() then
		if self.Options.SpecWarn19714dispel then
			specWarnGrounding:Show(args.destName)
			specWarnGrounding:Play("dispelboss")
		else
			warnGrounding:Show(args.destName)
		end
		timerGrounding:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 19714 then
		timerGrounding:Stop()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19713 and self:IsInCombat() then
		warnCurse:Show()
		timerCurseCD:Start()
	elseif args.spellId == 19715 and self:IsInCombat() then
		warnCntrSpell:Show()
	elseif args.spellId == 23138 then
		specWarnGate:Show(args.sourceName)
		specWarnGate:Play("tauntboss")
		timerGateCD:Start()
	end
end
