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
local mod	= DBM:NewMod("Magmadar", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(11982)
mod:SetEncounterID(664)
mod:SetModelID(10193)
mod:SetHotfixNoticeRev(20191205000000)--2019, 12, 05

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 19451 19428",
	"SPELL_AURA_REMOVED 19451",
	"SPELL_CAST_SUCCESS 19408"
)

--[[
(ability.id = 19408 or ability.id = 19451) and type = "cast"
 or ability.id = 19428 and type = "applydebuff"
--]]
local warnPanic			= mod:NewSpellAnnounce(19408, 2)
local warnEnrage		= mod:NewTargetNoFilterAnnounce(19451, 3, nil , "Healer|Tank|RemoveEnrage")
local warnConflagration	= mod:NewTargetNoFilterAnnounce(19428, 2, nil , false)

local specWarnEnrage	= mod:NewSpecialWarningDispel(19451, "RemoveEnrage", nil, nil, 1, 2)

local timerPanicCD		= mod:NewCDTimer(30, 19408)--30-40
local timerEnrage		= mod:NewBuffActiveTimer(8, 19451, nil, nil, nil, 5, nil, DBM_COMMON_L.ENRAGE_ICON)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 19451 and args:IsDestTypeHostile() then
		if self.Options.SpecWarn19451dispel then
			specWarnEnrage:Show(args.destName)
			specWarnEnrage:Play("enrage")
		else
			warnEnrage:Show(args.destName)
		end
		timerEnrage:Start()
	elseif args.spellId == 19428 and args:IsDestTypePlayer() then
		warnConflagration:CombinedShow(0.5, args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 19451 and args:IsDestTypeHostile() then
		timerEnrage:Stop()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19408 then
		warnPanic:Show()
		timerPanicCD:Start()
	end
end
