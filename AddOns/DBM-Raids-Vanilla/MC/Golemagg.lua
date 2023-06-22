local isClassic = WOW_PROJECT_ID == (WOW_PROJECT_CLASSIC or 2)
local isBCC = WOW_PROJECT_ID == (WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5)
local isWrath = WOW_PROJECT_ID == (WOW_PROJECT_WRATH_CLASSIC or 11)
local catID
if isWrath then
	catID = 5
elseif isBCC or isClassic then
	catID = 6
else--retail or cataclysm classic and later
	catID = 4
end
local mod	= DBM:NewMod("Golemagg", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525045438")
mod:SetCreatureID(11988)--, 11672
mod:SetEncounterID(670)
if not mod:IsClassic() then
	mod:SetModelID(11986)--Totally fucked on classic
end
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 20553"
)

--TODO, verify spellId, it might be 19798
local warnQuake		= mod:NewSpellAnnounce(20553)

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 20553 then
		warnQuake:Show()
	end
end
