local mod	= DBM:NewMod("NexusLegendary", "DBM-Raids-Cata", 2)
local L		= mod:GetLocalizedStrings()

if not mod:IsClassic() then--Future planning, so cata classic uses regular rules defined in toc and not timewalker rules for this zone
	mod.statTypes = "normal"
else
	mod.statTypes = "normal,normal25"
end

mod:SetRevision("20230526085458")
mod:SetCreatureID(53472)
mod:SetModelID(32230)
mod:SetZone(951)--Scoped to Nexus only

mod:RegisterCombat("combat")

mod:RegisterEvents(
	"SPELL_CAST_START 99502 99392",
	"SPELL_AURA_APPLIED 99392",
	"SPELL_AURA_REMOVED 99392"
)
mod.noStatistics = true

local specwarnBreath			= mod:NewSpecialWarningSpell(99502, nil, nil, nil, 1, 2)
local specwarnHealInterrupt		= mod:NewSpecialWarningInterrupt(99392, "HasInterrupt", nil, 2, 1, 2)
local specwarnHealDispel		= mod:NewSpecialWarningDispel(99392, "MagicDispeller", nil, 2, 1, 2)

local timerBreath				= mod:NewBuffActiveTimer(14, 99502, nil, nil, nil, 3)
local timerHeal					= mod:NewTargetTimer(16, 99392, nil, nil, nil, 5, nil, DBM_COMMON_L.MAGIC_ICON)

function mod:OnCombatStart(delay)
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 99502 then
		specwarnBreath:Show()
		specwarnBreath:Play("breathsoon")
		timerBreath:Start()
	elseif spellId == 99392 and self:CheckInterruptFilter(args.sourceGUID, false, true) then
		specwarnHealInterrupt:Show(args.sourceName)
		specwarnHealInterrupt:Play("kickcast")
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 99392 and not args:IsPlayer() then
		specwarnHealDispel:Show(args.destName)
		specwarnHealDispel:Play("dispelboss")
		timerHeal:Start(args.destName)
	end
end

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 99392 then
		timerHeal:Cancel(args.destName)
	end
end
