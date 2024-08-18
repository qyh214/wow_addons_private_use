--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Gothik the Harvester", 533, 1608)
if not mod then return end
mod:RegisterEnableMob(16060)
mod:SetEncounterID(1109)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locales
--

local wave = 0
local traineeCount = 1
local deathKnightCount = 1
local riderCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.phase1_trigger1 = "Foolishly you have sought your own demise."
	L.phase1_trigger2 = "Teamanare shi rikk mannor rikk lok karkun" -- Curse of Tongues
	L.phase2_trigger = "I have waited long enough. Now you face the harvester of souls."
	-- Why was there a demonic engage trigger, but not one for phasing?

	L.add = "Add Warnings"
	L.add_desc = "Warnings for add waves."
	L.add_icon = "spell_deathknight_summondeathcharger"

	L.add_death = "Add Death Alert"
	L.add_death_desc = "Alerts when an add dies."
	L.add_death_icon = "ability_whirlwind"

	L.riderdiewarn = "Rider dead!"
	L.dkdiewarn = "Death Knight dead!"

	L.wave = "%d/23: %s"

	L.trawarn = "Trainees in 3 sec"
	L.dkwarn = "Death Knights in 3 sec"
	L.riderwarn = "Rider in 3 sec"

	L.trabar = "Trainee (%d)"
	L.dkbar = "Death Knight (%d)"
	L.riderbar = "Rider (%d)"

	L.gate = "Gate Open!"
	L.gatebar = "Gate opens"

	L.phase_soon = "Gothik Incoming in 10 sec"

	L.engage_message = "Gothik the Harvester engaged!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		"add",
		"add_death",
	}
end

function mod:OnBossEnable()
	-- Most fights where the boss comes later don't have an initial ENCOUNTER_START
	-- leaving the the strings for this in just in case Classic needs them.
	-- self:BossYell("Engage", L.phase1_trigger1, L.phase1_trigger2)
	self:BossYell("Phase2", L.phase2_trigger)
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE") -- Unlocalized phase2 trigger
	self:Death("DeathKnightDeath", 16125) -- Death Knight
	self:Death("RiderDeath", 16126) -- Rider

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

function mod:OnEngage()
	wave = 0
	traineeCount = 1
	deathKnightCount = 1
	riderCount = 1
	self:SetStage(1)

	self:Message("stages", "yellow", L.engage_message, false)

	self:Bar("stages", 156, L.gatebar, "inv_misc_key_11")
	self:DelayedMessage("stages", 156, "cyan", L.gate, false, "info")
	self:Bar("stages", 270, CL.phase:format(2), "Spell_Magic_LesserInvisibilty")
	self:DelayedMessage("stages", 260, "cyan", L.phase_soon, false, "alarm")

	self:NewTrainee(27)
	self:NewDeathKnight(77)
	self:NewRider(137)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DeathKnightDeath(args)
	self:Message("add_death", "red", L.dkdiewarn, "ability_whirlwind")
	self:PlaySound("add_death", "info")
end

function mod:RiderDeath(args)
	self:Message("add_death", "red", L.riderdiewarn, "ability_warstomp")
	self:PlaySound("add_death", "alert")
end

function mod:Phase2()
	self:SetStage(2)
	self:Message("stages", "cyan", CL.phase:format(2), false)
	self:PlaySound("stages", "long")
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(event, msg, sender)
	if sender ~= self.displayName then return end
	self:UnregisterEvent(event)
	if self:GetStage() ~= 2 then
		self:Phase2()
	end
end

-- Wave timers

local colors = {
	[L.trawarn] = "yellow",
	[L.dkwarn] = "orange",
	[L.riderwarn] = "red",
}
local function waveWarn(message)
	wave = wave + 1
	if wave < 24 then
		mod:Message("add", colors[message], L.wave:format(wave, message), false) -- SetOption::yellow,orange,red::
	end
	if wave == 23 then
		mod:StopBar(L.trabar:format(traineeCount - 1))
		mod:StopBar(L.dkbar:format(deathKnightCount - 1))
		mod:StopBar(L.riderbar:format(riderCount - 1))
		mod:CancelAllTimers()
	end
end

function mod:NewTrainee(t)
	self:Bar("add", t, L.trabar:format(traineeCount), "ability_creature_disease_03")
	self:ScheduleTimer(waveWarn, t - 3, L.trawarn)
	self:ScheduleTimer("NewTrainee", t, 20)
	traineeCount = traineeCount + 1
end

function mod:NewDeathKnight(t)
	self:Bar("add", t, L.dkbar:format(deathKnightCount), "spell_shadow_shadowward")
	self:ScheduleTimer(waveWarn, t - 3, L.dkwarn)
	self:ScheduleTimer("NewDeathKnight", t, 25)
	deathKnightCount = deathKnightCount + 1
end

function mod:NewRider(t)
	self:Bar("add", t, L.riderbar:format(riderCount), "spell_deathknight_summondeathcharger")
	self:ScheduleTimer(waveWarn, t - 3, L.riderwarn)
	self:ScheduleTimer("NewRider", t, 30)
	riderCount = riderCount + 1
end
