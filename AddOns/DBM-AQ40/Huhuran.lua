local mod	= DBM:NewMod("Huhuran", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20190417010011")
mod:SetCreatureID(15509)
mod:SetEncounterID(714)
mod:SetModelID(15739)
mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_AURA_APPLIED 26180 26053 26051 26068 26050",
	"SPELL_AURA_APPLIED_DOSE 26050",
	"SPELL_AURA_REMOVED 26180 26053 26050",
	"SPELL_CAST_SUCCESS 26053",
	"UNIT_HEALTH boss1"
)

local warnSting			= mod:NewTargetAnnounce(26180, 2)
local warnAcid			= mod:NewStackAnnounce(26050, 3, nil, "Tank", 2)
local warnPoison		= mod:NewSpellAnnounce(26053, 3)
local warnEnrage		= mod:NewSpellAnnounce(26051, 2, nil, "Tank", 2)
local warnBerserkSoon	= mod:NewSoonAnnounce(26068, 2)
local warnBerserk		= mod:NewSpellAnnounce(26068, 2)

local specWarnAcid		= mod:NewSpecialWarningStack(26050, nil, 10, nil, nil, 1, 6)
local specWarnAcidTaunt	= mod:NewSpecialWarningTaunt(26050, nil, nil, nil, 1, 2)

local timerSting		= mod:NewBuffFadesTimer(12, 26180, nil, nil, nil, 3, nil, DBM_CORE_POISON_ICON..DBM_CORE_DEADLY_ICON)
local timerStingCD		= mod:NewCDTimer(25, 26180, nil, nil, nil, 3, nil, DBM_CORE_POISON_ICON..DBM_CORE_DEADLY_ICON)
local timerPoisonCD		= mod:NewCDTimer(11, 26053, nil, nil, nil, 3)
local timerPoison		= mod:NewBuffFadesTimer(8, 26053)
local timerEnrageCD		= mod:NewCDTimer(11.8, 26051, nil, false, 3, 5, nil, DBM_CORE_TANK_ICON..DBM_CORE_HEALER_ICON)--Off by default do to ridiculous variation
local timerEnrage		= mod:NewBuffActiveTimer(8, 26051, nil, "Tank|Healer", 2, 5, nil, DBM_CORE_TANK_ICON..DBM_CORE_HEALER_ICON)
local timerAcid			= mod:NewTargetTimer(30, 26050, nil, "Tank", 2, 5, nil, DBM_CORE_TANK_ICON)

mod.vb.prewarn_berserk = false
local StingTargets = {}

function mod:OnCombatStart(delay)
	self.vb.prewarn_berserk = false
	table.wipe(StingTargets)
	timerEnrageCD:Start(9.6-delay)
	timerPoisonCD:Start(11-delay)
	timerStingCD:Start(24.4-delay)
end

local function warnStingTargets()
	warnSting:Show(table.concat(StingTargets, "<, >"))
	timerStingCD:Start()
	table.wipe(StingTargets)
end

function mod:SPELL_CAST_SUCCESS(args)
	if args.spellId == 26053 then
		warnPoison:Show()
		timerPoisonCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	if args.spellId == 26180 then
		StingTargets[#StingTargets + 1] = args.destName
		self:Unschedule(warnStingTargets)
		self:Schedule(1, warnStingTargets)
		if args:IsPlayer() then
			timerSting:Start()
		end
	elseif args.spellId == 26053 and args:IsPlayer() then
		timerPoison:Start()
	elseif args.spellId == 26051 then
		warnEnrage:Show()
		timerEnrage:Start()
		timerEnrageCD:Start()
	elseif args.spellId == 26068 then
		warnBerserk:Show()
		timerStingCD:Stop()
		timerEnrageCD:Stop()
		timerPoisonCD:Stop()
	elseif args.spellId == 26050 and not self:IsTrivial(80) then
		local amount = args.amount or 1
		timerAcid:Start(args.destName)
		if amount >= 10 then
			if args:IsPlayer() then
				specWarnAcid:Show(amount)
				specWarnAcid:Play("stackhigh")
			elseif not DBM:UnitDebuff("player", args.spellName) and not UnitIsDeadOrGhost("player") then
				specWarnAcidTaunt:Show(args.destName)
				specWarnAcidTaunt:Play("tauntboss")
			else
				warnAcid:Show(args.destName, amount)
			end
		else
			warnAcid:Show(args.destName, amount)
		end
	end
end
mod.SPELL_AURA_APPLIED_DOSE = mod.SPELL_AURA_APPLIED

function mod:SPELL_AURA_REMOVED(args)
	if args.spellId == 26180 and args:IsPlayer() then
		timerSting:Stop()
	elseif args.spellId == 26053 and args:IsPlayer() then
		timerPoison:Stop()
	elseif args.spellId == 26050 then
		timerAcid:Stop(args.destName)
	end
end

function mod:UNIT_HEALTH(uId)
	if UnitHealth(uId) / UnitHealthMax(uId) <= 0.35 and self:GetUnitCreatureId(uId) == 15509 and not self.vb.prewarn_berserk then
		warnBerserkSoon:Show()
		self.vb.prewarn_berserk = true
	end
end
