local mod	= DBM:NewMod("Shazzrah", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190904201124")
mod:SetCreatureID(12264)
mod:SetEncounterID(667)
mod:SetModelID(13032)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 19714",
	"SPELL_AURA_REMOVED 19714",
	"SPELL_CAST_SUCCESS 19713 19715 23138"
)

--TODO, classic is 40 for gate, is retail 50 or did I make a mistake? Coding classic timing in for now
local warnCurse				= mod:NewSpellAnnounce(19713, 4)
local warnDeadenMagic		= mod:NewTargetNoFilterAnnounce(19714, 2, nil, false, 2)
local warnCntrSpell			= mod:NewSpellAnnounce(19715, 3, nil, "SpellCaster", 2)

local specWarnDeadenMagic	= mod:NewSpecialWarningDispel(19714, false, nil, 2, 1, 2)
local specWarnGate			= mod:NewSpecialWarningTaunt(23138, "Tank", nil, nil, 1, 2)--aggro wipe, needs fresh taunt

local timerCurseCD			= mod:NewCDTimer(22, 19713, nil, nil, nil, 3, nil, DBM_CORE_CURSE_ICON)--22-25.5 (20-25?)
local timerDeadenMagic		= mod:NewBuffActiveTimer(30, 19714, nil, false, 3, 5, nil, DBM_CORE_MAGIC_ICON)
local timerGateCD			= mod:NewCDTimer(41.3, 23138, nil, "Tank", nil, 5, nil, DBM_CORE_TANK_ICON)--41-50
local timerCounterSpellCD	= mod:NewCDTimer(15, 19715, nil, "SpellCaster", nil, 3)--15-19

function mod:OnCombatStart(delay)
	timerCurseCD:Start(6-delay)--6-10
	timerCounterSpellCD:Start(9.6-delay)
	timerGateCD:Start(30-delay)--30-31
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 19714 and self:IsInCombat() and not args:IsDestTypePlayer() then
		if self.Options.SpecWarn19714dispel then
			specWarnDeadenMagic:Show(args.destName)
			specWarnDeadenMagic:Play("dispelboss")
		else
			warnDeadenMagic:Show(args.destName)
		end
		timerDeadenMagic:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 19714 then
		timerDeadenMagic:Stop()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19713 and self:IsInCombat() then
		warnCurse:Show()
		timerCurseCD:Start()
	elseif args.spellId == 19715 and self:IsInCombat() then
		warnCntrSpell:Show()
		timerCounterSpellCD:Start()
	elseif args.spellId == 23138 then
		specWarnGate:Show(args.sourceName)
		specWarnGate:Play("tauntboss")
		timerGateCD:Start()
	end
end
