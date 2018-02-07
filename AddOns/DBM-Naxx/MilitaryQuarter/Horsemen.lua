local mod	= DBM:NewMod("Horsemen", "DBM-Naxx", 4)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 258 $"):sub(12, -3))
mod:SetCreatureID(16063, 16064, 16065, 30549)
mod:SetEncounterID(1121)
mod:SetModelID(10729)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
--	"SPELL_CAST_SUCCESS",
	"SPELL_AURA_APPLIED_DOSE 28832 28833 28834 28835"
)

-- local warnMarkSoon			= mod:NewAnnounce("WarningMarkSoon", 1, 28835, false)
-- local warnMarkNow			= mod:NewAnnounce("WarningMarkNow", 2, 28835)

local specWarnMarkOnPlayer		= mod:NewSpecialWarning("SpecialWarningMarkOnPlayer", nil, nil, nil, 1, 6)

--mod.vb.markCounter = 0

--[[
function mod:OnCombatStart(delay)
--	self.vb.markCounter = 0
--	warnMarkSoon:Schedule(12, markCounter + 1)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args:IsSpellID(28832, 28833, 28834, 28835) and self:AntiSpam(5) then
		--self.vb.markCounter = self.vb.markCounter + 1
--		warnMarkNow:Show(markCounter)
--		warnMarkSoon:Schedule(5, markCounter + 1)
	end
end
--]]

function mod:SPELL_AURA_APPLIED_DOSE(args)
	if args:IsSpellID(28832, 28833, 28834, 28835) and args:IsPlayer() then
		if args.amount >= 4 then
			specWarnMarkOnPlayer:Show(args.spellName, args.amount)
			specWarnMarkOnPlayer:Play("stackhigh")
		end
	end
end

