--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Blood-Queen Lana'thel", 631, 1633)
if not mod then return end
mod:RegisterEnableMob(37955)
-- mod:SetEncounterID(1103)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {{71340, "FLASH"}, {71265, "FLASH"}, 70877, 71772, 71623, "proximity", "berserk"}
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local pactTargets = mod:NewTargetList()
local airPhaseTimers = {
	{},
	{},
	{124, 120}, -- 10man Normal
	{127, 100}, -- 25man Normal
	{124, 120}, -- 10man Heroic
	{127, 100}, -- 25man Heroic
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "You have made an... unwise... decision."

	L.shadow = "Shadows"
	L.shadow_message = "Shadows"
	L.shadow_bar = "Next Shadows"

	L.feed_message = "Time to feed soon!"

	L.pact_message = "Pact"
	L.pact_bar = "Next Pact"

	L.phase_message = "Air phase incoming!"
	L.phase1_bar = "Back on floor"
	L.phase2_bar = "Air phase"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Pact", 71340)
	self:Log("SPELL_AURA_APPLIED", "Feed", 70877)
	self:Log("SPELL_CAST_SUCCESS", "AirPhase", 73070)
	-- 71623. 72264 are 10 man (and so on)
	self:Log("SPELL_AURA_APPLIED", "Slash", 71623, 72264)

	self:BossYell("Engage", L["engage_trigger"])
	self:Emote("Shadows", L["shadow"])

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Death("Win", 37955)
end

function mod:OnEngage(diff)
	self:SetStage(1)
	self:Berserk(320, true)
	self:OpenProximity("proximity", 6)
	self:Bar(71772, airPhaseTimers[diff][1], L["phase2_bar"])
	self:Bar(71340, 16, L["pact_bar"])
	self:Bar(71265, 30, L["shadow_bar"])
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local scheduled = nil
	local function pact()
		mod:TargetMessageOld(71340, pactTargets, "red", nil, L["pact_message"])
		scheduled = nil
	end
	function mod:Pact(args)
		if self:Me(args.destGUID) then
			self:Flash(71340)
		end
		pactTargets[#pactTargets + 1] = args.destName
		if not scheduled then
			self:Bar(71340, 30, L["pact_bar"])
			scheduled = self:ScheduleTimer(pact, 0.3)
		end
	end
end

function mod:Shadows(msg, _, _, _, player)
	if UnitIsUnit(player, "player") then
		self:Flash(71265)
	end
	self:TargetMessageOld(71265, player, "yellow", nil, L["shadow_message"])
	self:Bar(71265, 30, L["shadow_bar"])
end

function mod:Feed(args)
	if self:Me(args.destGUID) then
		self:MessageOld(70877, "orange", "alert", L["feed_message"])
		self:Bar(70877, 15, L["feed_message"])
	end
end

function mod:AirPhase(args)
	self:SetStage(2)
	self:MessageOld(71772, "red", "alarm", L["phase_message"])
	self:Bar(71772, 12, L["phase1_bar"])
	self:Bar(71772, airPhaseTimers[self:Difficulty()][2], L["phase2_bar"])
	self:ScheduleTimer("GroundPhase", airPhaseTimers[self:Difficulty()][2])
end

function mod:GroundPhase()
	self:SetStage(1)
end

function mod:Slash(args)
	self:TargetMessageOld(71623, args.destName, "yellow")
end

