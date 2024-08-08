--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Spine of Deathwing", 967, 318)
if not mod then return end
-- Deathwing, Burning Tendons, Burning Tendons, Corruption, Corruption, Corruption
mod:RegisterEnableMob(53879, 56575, 56341, 53891, 56161, 56162)
mod.engageId = 1291

--------------------------------------------------------------------------------
-- Locales
--

local gripTargets = mod:NewTargetList()
local bloodCount = 0
local bloodTimers = {}

-- Locals for Fiery Grip, described in comments below
local corruptionStatus, lastBar, nextGrip = {}, true, 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "The plates! He's coming apart! Tear up the plates and we've got a shot at bringing him down!"

	L.roll = -4050 -- Roll
	L.roll_icon = "achievement_bg_returnxflags_def_wsg"

	L.about_to_roll = "about to roll"
	L.rolling = "rolls"
	L.not_hooked = "YOU are >NOT< hooked!"
	L.roll_message = "He's rolling, rolling, rolling!"
	L.level_trigger = "levels out"
	L.level_message = "Nevermind, he leveled out!"

	L.exposed = "Armor Exposed"

	L.residue = "Unabsorbed Residue"
	L.residue_desc = "Messages informing you of how much blood residue is remaining on the floor, waiting to be absorbed."
	L.residue_icon = "Spell_Fire_Fire"
	L.residue_message = "Residue: %d"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		105248, "residue", 105490, {105845, "FLASH"}, {"roll", "FLASH"},
		105848
	}
end

function mod:OnBossEnable()
	self:Emote("AboutToRoll", L["about_to_roll"])
	self:Emote("Rolls", L["rolling"])
	self:Emote("Level", L["level_trigger"])

	self:Log("SPELL_AURA_APPLIED_DOSE", "AbsorbedBlood", 105248)
	self:Log("SPELL_CAST_SUCCESS", "FieryGripCast", 105490)
	self:Log("SPELL_CAST_START", "SearingPlasmaCast", 109379) -- Only one id in both modes
	self:Death("CorruptionDeath", 56161, 56162, 53891)

	self:Log("SPELL_AURA_APPLIED", "FieryGripApplied", 105490)
	self:Log("SPELL_CAST_SUCCESS", "ResidueChange", 105248, 105219) -- Absorbed Blood/Burst
	self:Log("SPELL_AURA_APPLIED", "BloodCheckDest", 6343, 77758, 55095, 26017) -- Thunder Clap, Thrash, Frost Fever, Vindication
	self:Log("SWING_DAMAGE", "BloodCheckSource", "*")
	self:Log("SWING_MISSED", "BloodCheckSource", "*")
	self:Log("SPELL_CAST_START", "Nuclear", 105845)
	self:Log("SPELL_CAST_START", "Seal", 105847, 105848) -- Left, Right

	self:BossYell("Engage", L["engage_trigger"])

	self:Death("BurningTendonDeaths", 56575, 56341) -- Burning Tendons
end

-- Note: Engage is not called as early as you may expect. It is about 4s from the start of combat
function mod:OnEngage(diff)
	corruptionStatus = {}
	bloodTimers = {}
	lastBar = true
	bloodCount = 0

	if not self:LFR() then
		-- Initial bars for grip since we cannot trigger off of it (pad by -5s)
		if diff % 2 == 0 then
			-- 25 man has 2 casts of 8s
			self:CDBar(105490, 11)
		else
			-- 10 man has 4 casts of 8s
			self:CDBar(105490, 27)
		end
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local tendrils = mod:SpellName(105563)
	local timer = nil
	local function graspCheck(self)
		if not self.isEngaged then
			-- Timer should not be spamming
			self:CancelTimer(timer)
		end
		if not self:UnitDebuff("player", tendrils, 105563) and not UnitIsDead("player") then -- Grasping Tendrils
			self:MessageOld("roll", "blue", not self:Solo() and "alert", L.not_hooked, 105563)
		end
	end

	function mod:AboutToRoll()
		local solo = self:Solo()
		local rollTime = self:Solo() and 20 or 5
		local rollMsg = self:SpellName(L.roll)
		self:Bar("roll", rollTime, rollMsg, L.roll_icon)
		self:MessageOld("roll", "yellow", not solo and "long", CL.custom_sec:format(rollMsg, rollTime), L.roll_icon)
		if not solo then
			self:Flash("roll", L.roll_icon)
		end
		if timer then self:CancelTimer(timer) end
		timer = self:ScheduleRepeatingTimer(graspCheck, 2, self)
	end
	function mod:Rolls()
		self:MessageOld("roll", "green", nil, L.roll_message, L.roll_icon)
		self:Bar("roll", 5, CL.cast:format(self:SpellName(L.roll)), L.roll_icon)
		self:CancelTimer(timer)
		timer = nil
	end
	function mod:Level()
		self:MessageOld("roll", "green", nil, L.level_message, L.roll_icon)
		self:StopBar(self:SpellName(L.roll))
		self:CancelTimer(timer)
		timer = nil
	end
end

do
	local function printStacks(self, spellId, spellName, amount, destGUID)
		self:MessageOld(spellId, amount < 9 and "orange" or "red", nil, CL.count:format(spellName, amount))
		bloodTimers[destGUID] = nil
	end

	function mod:AbsorbedBlood(args)
		-- Cancel old timer
		if bloodTimers[args.destGUID] then
			self:CancelTimer(bloodTimers[args.destGUID])
			bloodTimers[args.destGUID] = nil
		end

		-- Throttle message by 0.5s, or print immediately if we hit 9+ stacks
		if args.amount < 9 then
			bloodTimers[args.destGUID] = self:ScheduleTimer(printStacks, 0.5, self, args.spellId, args.spellName, args.amount, args.destGUID)
		else
			printStacks(self, args.spellId, args.spellName, args.amount, args.destGUID)
		end
	end
end

--[[
	Notes on Fiery Grip:
	* corruptionStatus is a map from Corruption GUID to a number. We set the
	  number to 0 initially and increment it with each cast until it is reset
	  at the grip. A timer is shown (or readjusted) at every cast.
	* lastBar holds the GUID of the Corruption that triggered the bar. This
	  way, if it dies, we can kill the bar. This also serves as a throttle so
	  that we have at most one bar up at any time, which should be good enough.
	  We set it to true initially because we miss the first plasma cast for some
	  reason (likely because of the zone change).
]]
function mod:FieryGripCast(args)
	-- Reset flag
	corruptionStatus[args.sourceGUID] = nil
	if lastBar == args.sourceGUID or lastBar == true then
		lastBar = nil
		self:StopBar(105490) -- Fiery Grip
	end
end

function mod:SearingPlasmaCast(args)
	-- Set flag and maybe show bar, ignore if already set
	if not corruptionStatus[args.sourceGUID] then
		corruptionStatus[args.sourceGUID] = 0
	else
		corruptionStatus[args.sourceGUID] = corruptionStatus[args.sourceGUID] + 1
	end

	local gripTime
	if self:Difficulty() % 2 == 0 then
		-- 25 man has 2 casts of 8s
		gripTime = 16
	else
		-- 10 man has 4 casts of 8s
		gripTime = 32
	end
	gripTime = gripTime - corruptionStatus[args.sourceGUID] * 8
	local nextGripNew = gripTime + GetTime()

	-- Only showing the bar if one isn't already up or if we need to recalibrate (error > 0.5s)
	if not lastBar or (lastBar == args.sourceGUID and math.abs(nextGrip - nextGripNew) > 0.5) then
		lastBar = args.sourceGUID
		nextGrip = nextGripNew
		self:Bar(105490, gripTime)
	end
end

function mod:CorruptionDeath(args)
	if lastBar == args.destGUID then
		-- Cancel bar
		corruptionStatus[args.destGUID] = nil
		lastBar = nil
		self:StopBar(105490) -- Fiery Grip
	end
end

do
	-- Residue reporting will wait one full second after changes to report how
	-- many are up to prevent spamming when the mob picks up a bunch
	local scheduled = nil
	local function reportBloods()
		mod:MessageOld("residue", "yellow", nil, L["residue_message"]:format(bloodCount), 105223)
		scheduled = nil
	end
	local haltPrinting = true
	local deadBlood = {}
	local function residuePrint()
		-- start printing if we're over 3
		if bloodCount > 3 then
			haltPrinting = false
		end

		-- We are only printing if the haltPrinting flag has been turned off
		if not haltPrinting then
			if scheduled then
				mod:CancelTimer(scheduled)
			end
			scheduled = mod:ScheduleTimer(reportBloods, 1)
		end

		-- once we reach 0, we will hold until we pass the threshold again
		-- this must be after the print so we print the (0) warning
		if bloodCount == 0 then
			haltPrinting = true
		end
	end
	local function residueDecrease(GUID)
		bloodCount = bloodCount - 1
		deadBlood[GUID] = nil
	end
	function mod:ResidueChange(args)
		if args.spellId == 105219 then
			-- Burst (+1)
			bloodCount = bloodCount + 1
			-- Mark this blood as dead so we know if he revives
			deadBlood[args.sourceGUID] = GetTime()
		elseif args.spellId == 105248 then
			residueDecrease(args.sourceGUID)
		end

		residuePrint()
	end
	-- Here we're using the four common tank AoE threat auras: Thunder Clap,
	-- Thrash, Frost Fever, and Vindication. At some point one of these should
	-- be applied to a blood, and if it is at least 5s after death, we know that
	-- it revived.
	local function bloodCheck(GUID)
		if deadBlood[GUID] and GetTime() - deadBlood[GUID] > 5 then
			residueDecrease(GUID)
			residuePrint()
		end
	end
	function mod:BloodCheckDest(args)
		bloodCheck(args.destGUID)
	end
	function mod:BloodCheckSource(args)
		bloodCheck(args.sourceGUID)
	end
end

function mod:Nuclear(args)
	self:MessageOld(args.spellId, "red", "info")
	self:Bar(args.spellId, 5)
	self:Flash(args.spellId)
end

function mod:Seal(args)
	self:MessageOld(105848, "red", nil, L["exposed"])
	self:Bar(105848, self:LFR() and 33 or 23, L["exposed"]) -- 33 is a guess
end

do
	local scheduled = nil
	local function grip(spellId)
		mod:TargetMessageOld(spellId, gripTargets, "orange")
		scheduled = nil
	end
	function mod:FieryGripApplied(args)
		gripTargets[#gripTargets + 1] = args.destName
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(grip, 0.2, args.spellId)
		end
	end
end

function mod:BurningTendonDeaths()
	self:StopBar(L["exposed"])
end

