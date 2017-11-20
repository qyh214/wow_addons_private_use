local mod	= DBM:NewMod("Majordomo", "DBM-MC", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 637 $"):sub(12, -3))
mod:SetCreatureID(12018, 11663, 11664)
mod:SetEncounterID(671)
mod:SetModelID(12029)
mod:RegisterCombat("combat")
--mod:RegisterKill("yell", L.Kill)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 20619 21075 20534"
)

--TODO, if BOSS isn't available in classic, common local it in core
local warnTeleport			= mod:NewTargetAnnounce(20534)

local specWarnMagicReflect	= mod:NewSpecialWarningReflect(20619, "-Melee")
local specWarnDamageShield	= mod:NewSpecialWarningReflect(21075, "Melee")

local timerMagicReflect		= mod:NewBuffActiveTimer(10, 20619, nil, nil, nil, 5, nil, DBM_CORE_DAMAGE_ICON)
local timerDamageShield		= mod:NewBuffActiveTimer(10, 21075, nil, nil, nil, 5, nil, DBM_CORE_DAMAGE_ICON)

local voiceMagicReflect		= mod:NewVoice(20619, "-Melee")--stopattack
local voiceDamageShield		= mod:NewVoice(21075, "Melee")--stopattack

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 20619 then
		specWarnMagicReflect:Show(BOSS)--Always a threat to casters
		voiceMagicReflect:Play("stopattack")
		timerMagicReflect:Start()
	elseif spellId == 21075 then
		if self:IsDifficulty("event40") or not self:IsTrivial(75) then--Not a threat to high level melee
			specWarnDamageShield:Show(BOSS)
			voiceDamageShield:Play("stopattack")
		end
		timerDamageShield:Start()
	elseif spellId == 20534 then
		warnTeleport:Show(args.destName)
	end
end