--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Professor Putricide", 631, 1631)
if not mod then return end
mod:RegisterEnableMob(36678, 37562, 37697) -- Putricide, Gas Cloud (Red Ooze), Volatile Ooze (Green Ooze)
-- mod:SetEncounterID(1102)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {{70447, "ICON"}, {70672, "FLASH"}, 70351, 71255, {72295, "SAY", "FLASH"}, 72451, {70911, "ICON", "FLASH"}, "phase", "berserk"}
mod.optionHeaders = {
	[70447] = CL.phase:format(1),
	[71255] = CL.phase:format(2),
	[72451] = CL.phase:format(3),
	[70911] = "heroic",
	phase = "general",
}
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local p2, first = nil, nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "I think I've perfected a plague"

	L.phase = "Phases"
	L.phase_desc = "Warn for phase changes."
	L.phase_warning = "Phase %d soon!"
	L.phase_bar = "Next Phase"

	L.ball_bar = "Next bouncing goo ball"
	L.ball_say = "Goo ball incoming!"

	L.experiment_message = "Ooze incoming!"
	L.experiment_heroic_message = "Oozes incoming!"
	L.experiment_bar = "Next ooze"
	L.blight_message = "Red ooze"
	L.violation_message = "Green ooze"

	L.gasbomb_bar = "More yellow gas bombs"
	L.gasbomb_message = "Yellow bombs!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "ChasedByRedOoze", 70672)
	self:Log("SPELL_AURA_APPLIED", "StunnedByGreenOoze", 70447)
	self:Log("SPELL_CAST_START", "Experiment", 70351)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Plague", 72451)
	self:Log("SPELL_CAST_SUCCESS", "GasBomb", 71255)
	self:Log("SPELL_CAST_SUCCESS", "BouncingGooBall", 72295)
	self:Log("SPELL_AURA_APPLIED", "TearGasStart", 71615)
	self:Log("SPELL_AURA_REMOVED", "TearGasOver", 71615)

	-- Heroic
	self:Log("SPELL_AURA_APPLIED", "UnboundPlague", 70911)
	self:Log("SPELL_CAST_START", "VolatileExperiment", 72840)

	self:BossYell("Engage", L["engage_trigger"])
	self:Death("RedOozeDeath", 37562)
	self:Death("Win", 36678)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Berserk(600)
	p2, first = nil, nil
	self:Bar(70351, 25, L["experiment_bar"])

	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function stopOldStuff()
		mod:StopBar(L["experiment_bar"])
	end
	local function newPhase()
		mod:Bar(71255, 14, L["gasbomb_bar"])
		mod:Bar(72295, 6, L["ball_bar"])
		if not first then
			mod:MessageOld("phase", "green", nil, CL.phase:format(2), false)
			mod:Bar(70351, 25, L["experiment_bar"])
			first = true
			p2 = true
			mod:SetStage(2)
		else
			mod:MessageOld("phase", "green", nil, CL.phase:format(3), false)
			first = nil
			mod:UnregisterEvent("UNIT_HEALTH")
			mod:SetStage(3)
		end
	end

	-- Heroic mode phase change
	function mod:VolatileExperiment()
		stopOldStuff()
		self:MessageOld("phase", "red", nil, L["experiment_heroic_message"], "achievement_boss_profputricide")
		if not first then
			self:Bar("phase", 45, L["phase_bar"], "achievement_boss_profputricide")
			self:ScheduleTimer(newPhase, 45)
		else
			self:Bar("phase", 37, L["phase_bar"], "achievement_boss_profputricide")
			self:ScheduleTimer(newPhase, 37)
		end
	end

	-- Normal mode phase change
	local stop = nil
	local function nextPhase()
		stop = nil
	end
	function mod:TearGasStart()
		if stop then return end
		stop = true
		self:Bar("phase", 18, L["phase_bar"], "achievement_boss_profputricide")
		self:ScheduleTimer(nextPhase, 3)
		stopOldStuff()
	end
	function mod:TearGasOver()
		if stop then return end
		stop = true
		self:ScheduleTimer(nextPhase, 13)
		newPhase()
	end
end

function mod:Plague(args)
	self:StackMessageOld(72451, args.destName, args.amount, "orange", "info")
	self:Bar(72451, 10)
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 36678 then
		local hp = self:GetHealth(unit)
		if hp < 84 and not p2 then
			self:MessageOld("phase", "green", nil, L["phase_warning"]:format(2), false)
			p2 = true
		elseif hp < 38 then
			self:MessageOld("phase", "green", nil, L["phase_warning"]:format(3), false)
			self:UnregisterEvent(event)
		end
	end
end

do
	local oldBlightBar = ""
	function mod:ChasedByRedOoze(args)
		if self:Me(args.destGUID) then
			self:Flash(70672)
		end
		self:StopBar(L["blight_message"], oldBlightBar)
		oldBlightBar = args.destName
		self:TargetBar(70672, 20, oldBlightBar, L["blight_message"])
		self:TargetMessageOld(70672, args.destName, "blue", nil, L["blight_message"], args.spellId)
	end
	function mod:RedOozeDeath()
		self:StopBar(L["blight_message"], oldBlightBar)
	end
end

function mod:StunnedByGreenOoze(args)
	self:TargetMessageOld(70447, args.destName, "blue", nil, L["violation_message"])
	self:PrimaryIcon(70447, args.destName)
end

function mod:Experiment(args)
	self:MessageOld(70351, "yellow", "alert", L["experiment_message"])
	self:Bar(70351, 38, L["experiment_bar"])
end

function mod:GasBomb(args)
	self:MessageOld(71255, "orange", nil, L["gasbomb_message"])
	self:Bar(71255, 35, L["gasbomb_bar"])
end

do
	local scheduled = nil
	local function scanTarget()
		scheduled = nil
		local bossId = mod:GetUnitIdByGUID(36678)
		if not bossId then return end
		local bossTarget = bossId.."target"
		if UnitExists(bossTarget) then
			if UnitIsUnit(bossTarget, "player") then
				mod:Flash(72295)
				mod:Say(72295, L["ball_say"], true)
			end
			mod:TargetMessageOld(72295, mod:UnitName(bossTarget), "yellow")
		end
	end
	function mod:BouncingGooBall(args)
		if not scheduled then
			scheduled = self:ScheduleTimer(scanTarget, 0.2)
			self:Bar(72295, self:Heroic() and 20 or 25, L["ball_bar"])
		end
	end
end

do
	local oldPlagueBar = ""
	function mod:UnboundPlague(args)
		--local _, _, _, expirationTime = self:UnitDebuff(args.destName, args.spellName, 70911)
		--if expirationTime then
		--	self:StopBar(70911, oldPlagueBar)
		--	oldPlagueBar = args.destName
		--	self:TargetBar(70911, expirationTime - GetTime(), args.destName)
		--end
		--self:SecondaryIcon(70911, args.destName)
		if self:Me(args.destGUID) then
			self:TargetMessageOld(70911, args.destName, "blue", "alert")
			self:Flash(70911)
		end
	end
end

