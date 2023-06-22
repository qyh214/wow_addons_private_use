local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local catID
if isBCC or isClassic then
	catID = 3
else--retail or wrath classic and later
	catID = 2
end
local mod	= DBM:NewMod("Ossirian", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(15339)
mod:SetEncounterID(723)
mod:SetModelID(15432)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 25176 25189 25177 25178 25180 25181 25183",
	"SPELL_AURA_REMOVED 25189"
)

local warnSupreme		= mod:NewSpellAnnounce(25176, 3)
local warnCyclone		= mod:NewTargetAnnounce(25189, 4)
local warnVulnerable	= mod:NewAnnounce("WarnVulnerable", 3, "132866")

local timerCyclone		= mod:NewTargetTimer(10, 25189, nil, nil, nil, 3)
local timerVulnerable	= mod:NewTimer(45, "TimerVulnerable", "132866", nil, nil, 6)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 25176 then
		warnSupreme:Show()
	elseif args.spellId == 25189 then
		warnCyclone:Show(args.destName)
		timerCyclone:Start(args.destName)
	elseif args:IsSpellID(25177, 25178, 25180, 25181, 25183) then
		warnVulnerable:Show(args.spellName)
		timerVulnerable:Show(args.spellName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 25189 then
		timerCyclone:Stop(args.destName)
	end
end
