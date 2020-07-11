local mod	= DBM:NewMod("Ouro", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200524145731")
mod:SetCreatureID(15517)
mod:SetEncounterID(716)
mod:SetModelID(15509)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 26615",
	"SPELL_CAST_START 26102 26103",
	"SPELL_SUMMON 26058",
	"UNIT_HEALTH boss1"
)

local warnSubmerge		= mod:NewAnnounce("WarnSubmerge", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp")
local warnEmerge		= mod:NewAnnounce("WarnEmerge", 3, "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp")
local warnSweep			= mod:NewSpellAnnounce(26103, 2, nil, "Tank", 2)
local warnEnrage		= mod:NewSpellAnnounce(26615, 3)
local warnEnrageSoon	= mod:NewSoonAnnounce(26615, 2)

local specWarnBlast		= mod:NewSpecialWarningSpell(26102, nil, nil, nil, 2, 2)

--local timerSubmerge		= mod:NewTimer(30, "TimerSubmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendBurrow.blp", nil, nil, nil, 6)
local timerEmerge		= mod:NewTimer(30, "TimerEmerge", "Interface\\AddOns\\DBM-Core\\textures\\CryptFiendUnBurrow.blp", nil, nil, 6)
local timerSweepCD		= mod:NewNextTimer(20.5, 26103, nil, "Tank", 2, 5, nil, DBM_CORE_L.TANK_ICON)
local timerBlastCD		= mod:NewNextTimer(23, 26102, nil, nil, nil, 2)

mod.vb.prewarn_enrage = false
mod.vb.enraged = false

function mod:OnCombatStart(delay)
	self.vb.prewarn_enrage = false
	self.vb.enraged = false
end

function mod:Emerge()
	warnEmerge:Show()
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 26615 then
		self.vb.enraged = true
		warnEnrage:Show()
	end
end

function mod:SPELL_CAST_START(args)
	if args.spellId == 26102 then
		specWarnBlast:Show()
		specWarnBlast:Play("stunsoon")
		timerBlastCD:Start()
	elseif args.spellId == 26103 then
		warnSweep:Show()
		timerSweepCD:Start()
	end
end

function mod:SPELL_SUMMON(args)
	if args.spellId == 26058 and self:AntiSpam(3) and not self.vb.enraged then
		timerBlastCD:Stop()
		timerSweepCD:Stop()
		warnSubmerge:Show()
		timerEmerge:Start()
		self:ScheduleMethod(30, "Emerge")
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.23 and self:GetUnitCreatureId(uId) == 15517 and not self.vb.prewarn_enrage then
		self.vb.prewarn_enrage = true
		warnEnrageSoon:Show()
	end
end
