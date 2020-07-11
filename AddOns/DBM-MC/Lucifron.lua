local mod	= DBM:NewMod("Lucifron", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200524145731")
mod:SetCreatureID(12118)--, 12119
mod:SetEncounterID(663)
mod:SetModelID(13031)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 19702 19703",
	"SPELL_AURA_APPLIED 20604"
)

--[[
(ability.id = 19702 or ability.id = 19703 or ability.id = 20604) and type = "cast"
--]]
local warnDoom		= mod:NewSpellAnnounce(19702, 2)
local warnCurse		= mod:NewSpellAnnounce(19703, 3)
local warnMC		= mod:NewTargetNoFilterAnnounce(20604, 4)

local timerCurseCD	= mod:NewCDTimer(20.5, 19703, nil, nil, nil, 3, nil, DBM_CORE_L.CURSE_ICON)--20-25
local timerDoomCD	= mod:NewCDTimer(20, 19702, nil, nil, nil, 3, nil, DBM_CORE_L.MAGIC_ICON)--20-25
--local timerDoom		= mod:NewCastTimer(10, 19702, nil, nil, nil, 3, nil, DBM_CORE_L.MAGIC_ICON)

function mod:OnCombatStart(delay)
	timerDoomCD:Start(7-delay)--7-8
	timerCurseCD:Start(12-delay)--12-15
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 19702 then
		warnDoom:Show()
--		timerDoom:Start()
		timerDoomCD:Start()
	elseif spellId == 19703 then
		warnCurse:Show()
		timerCurseCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 20604 then
		warnMC:CombinedShow(1, args.destName)
	end
end
