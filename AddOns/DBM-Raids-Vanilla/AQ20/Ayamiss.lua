local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local catID
if isBCC or isClassic then
	catID = 3
else--retail or wrath classic and later
	catID = 2
end
local mod	= DBM:NewMod("Ayamiss", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(15369)
mod:SetEncounterID(722)
mod:SetModelID(15431)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 25725",
	"SPELL_AURA_REMOVED 25725"
)

local warnPhase2	= mod:NewPhaseAnnounce(2)
local warnParalyze	= mod:NewTargetAnnounce(25725, 3)

local timerParalyze	= mod:NewTargetTimer(10, 25725, nil, nil, nil, 3)

function mod:OnCombatStart(delay)
	self:SetStage(1)
	self:RegisterShortTermEvents(
		"UNIT_HEALTH"
	)
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 25725 then
		warnParalyze:Show(args.destName)
		timerParalyze:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 25725 then
		timerParalyze:Stop(args.destName)
	end
end

function mod:UNIT_HEALTH(uId)
	if self:GetStage(1) and self:GetUnitCreatureId(uId) == 15369 and UnitHealth(uId) / UnitHealthMax(uId) <= 0.70 then
		self:UnregisterShortTermEvents()
		self:SetStage(2)
		warnPhase2:Show()
	end
end
