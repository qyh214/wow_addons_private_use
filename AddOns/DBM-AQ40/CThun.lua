local mod	= DBM:NewMod("CThun", "DBM-AQ40", 1)
local L		= mod:GetLocalizedStrings()

mod:SetRevision("20200806150215")
mod:SetCreatureID(15589, 15727)
mod:SetEncounterID(717)
mod:RegisterCombat("combat")
mod:SetWipeTime(25)

mod:RegisterEventsInCombat(
	"CHAT_MSG_MONSTER_EMOTE",
	"UNIT_DIED"
)

local warnEyeTentacle		= mod:NewAnnounce("WarnEyeTentacle", 2, 126)
--local warnClawTentacle		= mod:NewAnnounce("WarnClawTentacle", 2, 26391)
--local warnGiantEyeTentacle	= mod:NewAnnounce("WarnGiantEyeTentacle", 3, 26391)
--local warnGiantClawTentacle	= mod:NewAnnounce("WarnGiantClawTentacle", 3, 26391)
local warnPhase2			= mod:NewPhaseAnnounce(2)

local specWarnDarkGlare		= mod:NewSpecialWarningDodge(26029, nil, nil, nil, 3, 2)
local specWarnWeakened		= mod:NewSpecialWarning("SpecWarnWeakened", nil, nil, nil, 2, 2, nil, 28598)

local timerDarkGlareCD		= mod:NewNextTimer(86, 26029)
local timerDarkGlare		= mod:NewBuffActiveTimer(39, 26029)
local timerEyeTentacle		= mod:NewTimer(45, "TimerEyeTentacle", 126, nil, nil, 1)
--local timerGiantEyeTentacle	= mod:NewTimer(60, "TimerGiantEyeTentacle", 26391, nil, nil, 1)
--local timerClawTentacle		= mod:NewTimer(11, "TimerClawTentacle", 26391, nil, nil, 1)
--local timerGiantClawTentacle = mod:NewTimer(60, "TimerGiantClawTentacle", 26391, nil, nil, 1)
local timerWeakened			= mod:NewTimer(45, "TimerWeakened", 28598)

mod:AddRangeFrameOption("10")

mod.vb.phase = 1
local firstBossMod = DBM:GetModByName("AQ40Trash")

function mod:OnCombatStart(delay)
	self.vb.phase = 1
	--timerClawTentacle:Start(-delay)
	timerEyeTentacle:Start(45-delay)
	timerDarkGlareCD:Start(48-delay)
	self:ScheduleMethod(45-delay, "EyeTentacle")
	self:ScheduleMethod(48-delay, "DarkGlare")
	if self.Options.RangeFrame then
		DBM.RangeCheck:Show(10)
	end
end

function mod:OnCombatEnd(wipe, isSecondRun)
	if self.Options.RangeFrame then
		DBM.RangeCheck:Hide()
	end
	--Only run on second run, to ensure trash mod has had enough time to update requiredBosses
	if not wipe and isSecondRun and firstBossMod.vb.firstEngageTime and firstBossMod.Options.SpeedClearTimer then
		if firstBossMod.vb.requiredBosses < 5 then
			DBM:AddMsg(L.NotValid:format(5 - firstBossMod.vb.requiredBosses .. "/4"))
		end
	end
end

function mod:EyeTentacle()
	warnEyeTentacle:Show()
	timerEyeTentacle:Start()
	self:ScheduleMethod(45, "EyeTentacle")
end

function mod:DarkGlare()
	specWarnDarkGlare:Show()
	specWarnDarkGlare:Play("laserrun")--Or "watchstep" ?
	timerDarkGlare:Start()
	timerDarkGlareCD:Start()
	self:ScheduleMethod(86, "DarkGlare")
end

function mod:CHAT_MSG_MONSTER_EMOTE(msg)
	if msg == L.Weakened or msg:find(L.Weakened) then
		specWarnWeakened:Show()
		specWarnWeakened:Play("targetchange")
		timerWeakened:Start()
	end
end

function mod:UNIT_DIED(args)
	local cid = self:GetCIDFromGUID(args.destGUID)
	if cid == 15589 then
		self.vb.phase = 2
		warnPhase2:Show()
		timerEyeTentacle:Stop()
		self:UnscheduleMethod("EyeTentacle")
		self:UnscheduleMethod("DarkGlare")
	end
end
