local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local catID
if isBCC or isClassic then
	catID = 3
else--retail or wrath classic and later
	catID = 2
end
local mod	= DBM:NewMod("Kurinnaxx", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(15348)
mod:SetEncounterID(718)
mod:SetModelID(15742)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CREATE 25648",
	"SPELL_AURA_APPLIED 25646 26527",
	"SPELL_AURA_APPLIED_DOSE 25646",
	"SPELL_AURA_REMOVED 25646"
)

local warnWound			= mod:NewStackAnnounce(25646, 2, nil, "Tank")
local warnSandTrap		= mod:NewTargetNoFilterAnnounce(25656, 3)
local warnFrenzy		= mod:NewTargetNoFilterAnnounce(26527, 3)

local specWarnSandTrap	= mod:NewSpecialWarningYou(25656, nil, nil, nil, 1, 2)
local yellSandTrap		= mod:NewYell(25656)
local specWarnWound		= mod:NewSpecialWarningStack(25646, nil, 5, nil, nil, 1, 6)
local specWarnWoundTaunt= mod:NewSpecialWarningTaunt(25646, nil, nil, nil, 1, 2)

local timerWound		= mod:NewTargetTimer(15, 25646, nil, "Tank", nil, 5, nil, DBM_COMMON_L.TANK_ICON)
local timerSandTrapCD	= mod:NewCDTimer(8, 25656, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	timerSandTrapCD:Start(8-delay)
end

function mod:SPELL_CREATE(args)
	if args.spellId == 25648 then
		timerSandTrapCD:Start()
		if args:IsPlayerSource() then
			specWarnSandTrap:Show()
			specWarnSandTrap:Play("targetyou")
			yellSandTrap:Yell()
		else
			warnSandTrap:Show(args.sourceName)
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 25646 and not self:IsTrivial() then
		local amount = args.amount or 1
		timerWound:Start(args.destName)
		if amount >= 5 then
			if args:IsPlayer() then
				specWarnWound:Show(amount)
				specWarnWound:Play("stackhigh")
			elseif not DBM:UnitDebuff("player", args.spellName) and not UnitIsDeadOrGhost("player") then
				specWarnWoundTaunt:Show(args.destName)
				specWarnWoundTaunt:Play("tauntboss")
			else
				warnWound:Show(args.destName, amount)
			end
		else
			warnWound:Show(args.destName, amount)
		end
	elseif args.spellId == 26527 then
		warnFrenzy:Show(args.destName)
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 25646 then
		timerWound:Stop(args.destName)
	end
end
