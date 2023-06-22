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
local mod	= DBM:NewMod("Majordomo", "DBM-Raids-Vanilla", catID)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20230525041212")
mod:SetCreatureID(12018, 11663, 11664)
mod:SetEncounterID(671)
mod:SetModelID(12029)
mod:SetHotfixNoticeRev(20191122000000)--2019, 11, 22

mod:RegisterCombat("combat")
--mod:RegisterKill("yell", L.Kill)

mod:RegisterEventsInCombat(
	"SPELL_CAST_SUCCESS 20619 21075 20534"
)

--[[
(ability.id = 20619 or ability.id = 21075 or ability.id = 20534) and type = "cast"
--]]
local warnTeleport			= mod:NewTargetNoFilterAnnounce(20534)
local warnDamageShield		= mod:NewSpellAnnounce(21075, 2)

local specWarnMagicReflect	= mod:NewSpecialWarningReflect(20619, "-Melee", nil, nil, 1, 2)
local specWarnDamageShield	= mod:NewSpecialWarningReflect(21075, "Melee", nil, nil, 1, 2)

local timerMagicReflect		= mod:NewBuffActiveTimer(10, 20619, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerDamageShield		= mod:NewBuffActiveTimer(10, 21075, nil, nil, nil, 5, nil, DBM_COMMON_L.DAMAGE_ICON)
local timerTeleportCD		= mod:NewCDTimer(25, 20534, nil, nil, nil, 5, nil, DBM_COMMON_L.TANK_ICON)--25-30
local timerShieldCD			= mod:NewTimer(30.3, "timerShieldCD", nil, nil, nil, 6, nil, DBM_COMMON_L.DAMAGE_ICON)

function mod:OnCombatStart(delay)
	timerTeleportCD:Start(19.4-delay)
	timerShieldCD:Start(27.8-delay)--27-30
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 20619 then
		specWarnMagicReflect:Show(BOSS)--Always a threat to casters
		specWarnMagicReflect:Play("stopattack")
		timerMagicReflect:Start()
		timerShieldCD:Start()
	elseif spellId == 21075 then
		if self.Options.SpecWarn21075reflect and (self:IsEvent() or not self:IsTrivial()) then--Not a threat to high level melee
			specWarnDamageShield:Show(BOSS)
			specWarnDamageShield:Play("stopattack")
		else
			warnDamageShield:Show()
		end
		timerDamageShield:Start()
		timerShieldCD:Start()
	elseif spellId == 20534 then
		warnTeleport:Show(args.destName)
		timerTeleportCD:Start()
	end
end
