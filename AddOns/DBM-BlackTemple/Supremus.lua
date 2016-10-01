local mod	= DBM:NewMod("Supremus", "DBM-BlackTemple")
local L		= mod:GetLocalizedStrings()

mod:SetRevision(("$Revision: 594 $"):sub(12, -3))
mod:SetCreatureID(22898)
mod:SetEncounterID(602)
mod:SetModelID(21145)
mod:SetZone()
mod:SetUsedIcons(8)

mod:RegisterCombat("combat")

mod:RegisterEventsInCombat(
	"RAID_BOSS_EMOTE"
)

local warnPhase			= mod:NewAnnounce("WarnPhase", 4, 42052)
local warnKite			= mod:NewAnnounce("WarnKite", 3, 42052)

local specWarnMolten	= mod:NewSpecialWarningMove(40265)
local specWarnVolcano	= mod:NewSpecialWarningMove(42052)

local timerPhase		= mod:NewTimer(60, "TimerPhase", 42052, nil, nil, 6)

local berserkTimer		= mod:NewBerserkTimer(900)

mod:AddBoolOption("KiteIcon", true)

local phase2 = false
local lastTarget = false

function mod:ScanTarget()
	local target = self:GetBossTarget(22898)
	if target then
		if lastTarget ~= target then
			warnKite:Show(target)
			lastTarget = target
			if self.Options.KiteIcon then
				self:SetIcon(target, 8)
			end
		end
	end
end

function mod:OnCombatStart(delay)
	berserkTimer:Start(-delay)
	timerPhase:Start(-delay, L.Kite)
	phase2 = false
	lastTarget = false
	if not self:IsTrivial(85) then--Only warning that uses these events is remorseless winter and that warning is completely useless spam for level 90s.
		self:RegisterShortTermEvents(
			"SPELL_DAMAGE 40265 42052",
			"SPELL_MISSED 40265 42052"
		)
	end
end

function mod:OnCombatEnd()
	self:UnregisterShortTermEvents()
	if lastTarget then
		self:SetIcon(lastTarget, 0)
	end
end

function mod:SPELL_DAMAGE(_, _, _, _, destGUID, _, _, _, spellId)
	if spellId == 40265 and destGUID == UnitGUID("player") and self:AntiSpam(4, 1) and not self:IsTrivial(85) then
		specWarnMolten:Show()
	elseif spellId == 42052 and destGUID == UnitGUID("player") and self:AntiSpam(4, 2) and not self:IsTrivial(85) then
		specWarnVolcano:Show()
	end
end
mod.SPELL_MISSED = mod.SPELL_DAMAGE

function mod:RAID_BOSS_EMOTE(msg)
	if msg == L.PhaseKite or msg:find(L.PhaseKite) then
		phase2 = true
		warnPhase:Show(L.Kite)
		timerPhase:Start(L.Tank)
		self:ScheduleMethod(4, "ScanTarget")
		if lastTarget then
			self:SetIcon(lastTarget, 0)
		end
	elseif msg == L.PhaseTank or msg:find(L.PhaseTank) then
		phase2 = false
		warnPhase:Show(L.Tank)
		timerPhase:Start(L.Kite)
		if lastTarget then
			self:SetIcon(lastTarget, 0)
		end
	elseif msg == L.ChangeTarget or msg:find(L.ChangeTarget) then
		self:ScheduleMethod(0.5, "ScanTarget")
	end
end
