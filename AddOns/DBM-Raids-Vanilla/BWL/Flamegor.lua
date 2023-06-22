local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local isWrath = WOW_PROJECT_ID == (WOW_PROJECT_WRATH_CLASSIC or 11)
local catID
if isWrath then
	catID = 4
elseif isBCC or isClassic then
	catID = 5
else--retail or cataclysm classic and later
	catID = 3
end
local mod	= DBM:NewMod("Flamegor", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525045438")
mod:SetCreatureID(11981)
mod:SetEncounterID(615)
if not mod:IsClassic() then
	mod:SetModelID(6377)
end
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 23339 22539",
	"SPELL_CAST_SUCCESS 23342",
	"SPELL_AURA_APPLIED 23342",
	"SPELL_AURA_REMOVED 23342"
)

--(ability.id = 23339 or ability.id = 22539) and type = "begincast" or ability.id = 23342 and type = "cast"
local warnWingBuffet		= mod:NewCastAnnounce(23339, 2)
local warnShadowFlame		= mod:NewCastAnnounce(22539, 2)
local warnFrenzy			= mod:NewSpellAnnounce(23342, 3, nil, "Tank|RemoveEnrage|Healer", 4)

local specWarnFrenzy		= mod:NewSpecialWarningDispel(23342, "RemoveEnrage", nil, nil, 1, 6)

local timerWingBuffet		= mod:NewCDTimer(31, 23339, nil, nil, nil, 2)
local timerShadowFlameCD	= mod:NewCDTimer(14, 22539, nil, false)--14-21
local timerFrenzy	 		= mod:NewBuffActiveTimer(10, 23342, nil, "Tank|RemoveEnrage|Healer", 4, 5, nil, DBM_COMMON_L.ENRAGE_ICON)

function mod:OnCombatStart(delay)
	timerShadowFlameCD:Start(18-delay)
	timerWingBuffet:Start(30-delay)
end

function mod:SPELL_CAST_START(args)--did not see ebon use any of these abilities
	if args.spellId == 23339 then
		warnWingBuffet:Show()
		timerWingBuffet:Start()
	elseif args.spellId == 22539 then
		warnShadowFlame:Show()
		timerShadowFlameCD:Start()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 23342 and args:IsSrcTypeHostile() then
		if self.Options.SpecWarn23342dispel then
			specWarnFrenzy:Show(args.sourceName)
			specWarnFrenzy:Play("enrage")
		else
			warnFrenzy:Show()
		end
	end
end

function mod:SPELL_AURA_APPLIED(args)--did not see ebon use any of these abilities
	if args.spellId == 23342 then
		timerFrenzy:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)--did not see ebon use any of these abilities
	if args.spellId == 23342 then
		timerFrenzy:Stop()
	end
end
