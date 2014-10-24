local mod	= DBM:NewMod("Shazzrah", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 539 $"):sub(12, -3))
mod:SetCreatureID(12264)
--mod:SetEncounterID(667)
mod:SetModelID(13032)
mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_AURA_APPLIED",
	"SPELL_AURA_REMOVED",
	"SPELL_CAST_SUCCESS"
)

local warnCurse			= mod:NewSpellAnnounce(19713)
local warnGrounding		= mod:NewSpellAnnounce(19714, 2, nil, false)
local warnCntrSpell		= mod:NewSpellAnnounce(19715)
local warnBlink			= mod:NewSpellAnnounce(21655)

local timerCurseCD		= mod:NewNextTimer(20, 19713)
local timerGrounding	= mod:NewBuffActiveTimer(30, 19714, nil, false)
local timerBlinkCD		= mod:NewNextTimer(30, 21655)

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 19714 and self:IsInCombat() and not args:IsDestTypePlayer() then
		warnGrounding:Show()
		timerGrounding:Start()
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 19714 then
		timerGrounding:Cancel()
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 19713 and self:IsInCombat() then
		warnCurse:Show()
		timerCurseCD:Start()
	elseif args.spellId == 19715 and self:IsInCombat() then
		warnCntrSpell:Show()
	elseif args.spellId == 21655 and self:IsInCombat() then
		warnBlink:Show()
		timerBlinkCD:Start()
	end
end