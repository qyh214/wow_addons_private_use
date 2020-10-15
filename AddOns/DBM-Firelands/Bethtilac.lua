local mod	= DBM:NewMod(192, "DBM-Firelands", nil, 78)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200918204324")
mod:SetCreatureID(52498)
mod:SetEncounterID(1197)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"SPELL_CAST_START 99052",
	"SPELL_CAST_SUCCESS 99476 98934 99859",
	"SPELL_AURA_APPLIED 99506 99526",
	"SPELL_DAMAGE 99278",
	"SPELL_MISSED 99278",
	"CHAT_MSG_RAID_BOSS_EMOTE"
)

--[[
ability.id = 99052 and type = "begincast"
 or (ability.id = 99476 or ability.id = 98934 or ability.id = 99859) and type = "cast"
--]]
--TODO, VERIFY TIMER UPDATES OFF BOSS POWER (and not just it avoiding timere refresh errors, but actual accuracy feels. Make sure timer doesn't have too much jitter)
local warnSmolderingDevastation		= mod:NewCountAnnounce(99052, 4)--Use count announce, cast time is pretty obvious from the bar, but it's useful to keep track how many of these have been cast.
local warnPhase2Soon				= mod:NewPrePhaseAnnounce(2, 3)
local warnFixate					= mod:NewTargetAnnounce(99526, 4)--Heroic ability

local specWarnFixate				= mod:NewSpecialWarningYou(99526, nil, nil, nil, 1, 2)
local specWarnTouchWidowKiss		= mod:NewSpecialWarningYou(99476, nil, nil, nil, 1, 2)
local specWarnSmolderingDevastation	= mod:NewSpecialWarningCount(99052, nil, nil, nil, 3, 2)
local specWarnVolatilePoison		= mod:NewSpecialWarningMove(99278, nil, nil, nil, 1, 2)--Heroic ability
local specWarnTouchWidowKissOther	= mod:NewSpecialWarningTarget(99476, "Tank", nil, nil, 1, 2)

local timerSpinners 				= mod:NewNextTimer(15, "ej2770", nil, nil, nil, 1, 97370) -- 15secs after Smoldering cast start
local timerSpiderlings				= mod:NewNextTimer(30, "ej2778", nil, nil, nil, 1, 72106)
local timerDrone					= mod:NewNextTimer(60, "ej2773", nil, nil, nil, 1, 28866)
local timerSmolderingDevastationCD	= mod:NewCDCountTimer(85, 99052, nil, nil, nil, 2, nil, DBM_CORE_L.DEADLY_ICON)
local timerEmberFlareCD				= mod:NewNextTimer(6, 98934, nil, nil, nil, 2)
local timerSmolderingDevastation	= mod:NewCastTimer(8, 99052, nil, nil, nil, 2, nil, DBM_CORE_L.DEADLY_ICON)
local timerFixate					= mod:NewTargetTimer(10, 99526, nil, false)
local timerWidowsKissCD				= mod:NewCDTimer(32, 99476, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_L.TANK_ICON)
local timerWidowKiss				= mod:NewTargetTimer(23, 99476, nil, "Tank|Healer", nil, 5, nil, DBM_CORE_L.TANK_ICON)

local berserkTimer					= mod:NewBerserkTimer(600)

mod.vb.smolderingCount = 0
mod.vb.phase = 1

mod:AddRangeFrameOption(10, 99476)

function mod:repeatDrone()
	timerDrone:Start()
	self:ScheduleMethod(60, "repeatDrone")
end

function mod:OnCombatStart(delay)
	self.vb.smolderingCount = 0
	self.vb.phase = 1
	timerSpiderlings:Start(11.1-delay)
	timerSpinners:Start(12-delay)
	timerDrone:Start(45-delay)
	self:ScheduleMethod(45-delay, "repeatDrone")
	timerSmolderingDevastationCD:Update(10+delay, 85, 1)--First one is 75, boss doesn't start full mana, or rather uses a bunch on pull?
	berserkTimer:Start(600-delay)
	self:RegisterShortTermEvents(
		"UNIT_POWER_UPDATE boss1"
	)
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
end

function mod:SPELL_CAST_START(args)
	local spellId = args.spellId
	if spellId == 99052 then
		self.vb.smolderingCount = self.vb.smolderingCount + 1
		if self:GetUnitCreatureId("target") == 52498 or self:GetBossTarget(52498) == DBM:GetUnitFullName("target") then--If spider is you're target or it's tank is, you're up top.
			specWarnSmolderingDevastation:Show(self.vb.smolderingCount)
			specWarnSmolderingDevastation:Play("aesoon")
		else
			warnSmolderingDevastation:Show(self.vb.smolderingCount)
		end
		timerSmolderingDevastation:Start()
		timerEmberFlareCD:Cancel()--Cast immediately after Devastation, so don't need to really need to update timer, just cancel last one since it won't be cast during dev
		if self.vb.smolderingCount == 3 then	-- 3rd cast = start P2
			self:UnregisterShortTermEvents()
			timerSmolderingDevastationCD:Stop()--Stop just in case energy event started it as events were unregistering
			self.vb.phase = 2
			warnPhase2Soon:Show()
			self:UnscheduleMethod("repeatDrone")
			timerSpiderlings:Stop()
			timerDrone:Stop()
			timerWidowsKissCD:Start(47)--47-50sec variation for first, probably based on her movement into position.
		else
			timerSmolderingDevastationCD:Start(69.1, self.vb.smolderingCount+1)--It's technically 85-90 if adds handled correctly, this assumes they aren't
			timerSpinners:Start()
		end
	end
end

function mod:SPELL_CAST_SUCCESS(args)
	local spellId = args.spellId
	if spellId == 99476 then--Cast debuff only, don't add other spellid. (99476 spellid uses on SPELL_CAST_START, NOT SPELL_AURA_APPLIED),
		timerWidowsKissCD:Start()
		if self.Options.RangeFrame and self:IsTank() then
			DBM.RangeCheck:Show(10)
		end
		if args:IsPlayer() then
			specWarnTouchWidowKiss:Show()
			specWarnTouchWidowKiss:Play("defensive")
		else
			specWarnTouchWidowKissOther:Show(args.destName)
			specWarnTouchWidowKissOther:Play("watchstep")
		end
	--Phase 1 ember flares. Only show for people who are actually up top.
	elseif spellId == 98934 and (self:GetUnitCreatureId("target") == 52498 or self:GetBossTarget(52498) == DBM:GetUnitFullName("target")) then
		timerEmberFlareCD:Start()
	--Phase 2 ember flares. Show for everyone
	elseif spellId == 99859 then
		timerEmberFlareCD:Start()
	end
end

function mod:SPELL_AURA_APPLIED(args)
	local spellId = args.spellId
	if spellId == 99506 then--Applied debuff after cast. Used to announce special warnings and start target timer, only after application confirmed and not missed.
		timerWidowKiss:Start(args.destName)
	elseif spellId == 99526 then--99526 is on player, 99559 is on drone
		timerFixate:Start(args.destName)
		if args:IsPlayer() then
			specWarnFixate:Show()
			specWarnFixate:Play("justrun")
		else
			warnFixate:Show(args.destName)
		end
	end
end

function mod:SPELL_AURA_REMOVED(args)
	local spellId = args.spellId
	if spellId == 99506 then
		timerWidowKiss:Stop(args.destName)
		if args:IsPlayer() then
			if self.Options.RangeFrame then
				DBM.RangeCheck:Hide()
			end
		end
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 99278 and destGUID == UnitGUID("player") and self:AntiSpam(3) then
		specWarnVolatilePoison:Show()
		specWarnVolatilePoison:Play("watchfeet")
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:CHAT_MSG_RAID_BOSS_EMOTE(msg)
	if msg == L.EmoteSpiderlings or msg:find(L.EmoteSpiderlings) then
		timerSpiderlings:Start()
	end
end

--Adds draw energy off boss through "Leaech Venom" (99411). This causes bosses energy to deplete faster if adds are up longer
--This code force updates timer as adds siphon off the boss energy
function mod:UNIT_POWER_UPDATE(uId, powerType)
	local bossMana = UnitPower(uId) / UnitPowerMax(uId) * 100
	local bossRemaining = bossMana * 1.176--Calculating based on 85 seconds to fully deplete energy with no drains, is 1.176 energy per second
	local timeRemaining = timerSmolderingDevastationCD:GetRemaining(self.vb.smolderingCount+1)
	if (bossRemaining - timeRemaining) > 1 or (bossRemaining - timeRemaining) < -1 then--Off by more than one second
		timerSmolderingDevastationCD:Update(85-bossRemaining, 85, self.vb.smolderingCount+1)--Update method uses Elapsed and total
	end
end
