local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local catID
if isBCC or isClassic then
	catID = 2
else--retail or wrath classic and later
	catID = 1
end
local mod	= DBM:NewMod("Sartura", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(15516)
mod:SetEncounterID(711)
mod:SetModelID(15583)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 26083 8269"
)

--Add sundering cleave?
local warnEnrageSoon	= mod:NewSoonAnnounce(8269, 2)
local warnEnrage		= mod:NewSpellAnnounce(8269, 4)
local warnWhirlwind		= mod:NewSpellAnnounce(26083, 3)

local specWarnWhirlwind	= mod:NewSpecialWarningRun(26083, nil, nil, 2, 4, 2)

mod.vb.prewarn_enrage = false

function mod:OnCombatStart(delay)
	self.vb.prewarn_enrage = false
	self:RegisterShortTermEvents(
		"UNIT_HEALTH"
	)
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 26083 and args:IsSrcTypeHostile() and self:AntiSpam(4, 1) then
		if self:CheckInterruptFilter(args.sourceGUID, true) and self.Options.SpecWarn26083run then
			specWarnWhirlwind:Show()
			specWarnWhirlwind:Play("justrun")
		else
			warnWhirlwind:Show()
		end
	elseif args.spellId == 8269 and args:IsSrcTypeHostile() then
		warnEnrage:Show()
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 and self:GetUnitCreatureId(uId) == 15516 and not self.vb.prewarn_enrage then
		warnEnrageSoon:Show()
		self.vb.prewarn_enrage = true
		self:UnregisterShortTermEvents()
	end
end
