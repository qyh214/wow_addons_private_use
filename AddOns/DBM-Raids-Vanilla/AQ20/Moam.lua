local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local catID
if isBCC or isClassic then
	catID = 3
else--retail or wrath classic and later
	catID = 2
end
local mod	= DBM:NewMod("Moam", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(15340)
mod:SetEncounterID(720)
mod:SetModelID(15392)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 25685",
	"SPELL_AURA_REMOVED 25685"
)

--Energize is mode boss goes in during Summon Mana Fiend Phase
--TODO, update timrs on mana drains/etc
--TODO, verify if arcane eruption wll always be the same
--"Arcane Eruption-25672-npc:15340 = pull:325.8", -- [1]
local warnStoneform		= mod:NewSpellAnnounce(25685, 3)

local timerStoneform	= mod:NewNextTimer(90, 25685, nil, nil, nil, 6)
local timerStoneformDur	= mod:NewBuffActiveTimer(90, 25685, nil, nil, nil, 6)

function mod:OnCombatStart(delay)
	timerStoneform:Start(-delay)
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 25685 then
		warnStoneform:Show()
		timerStoneformDur:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 25685 then
		timerStoneformDur:Stop()
		timerStoneform:Start()
	end
end
