--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Alysrazor", 720, 194)
if not mod then return end
mod:RegisterEnableMob(52530, 53898, 54015, 53089) --Alysrazor, Voracious Hatchling, Majordomo Staghelm, Molten Feather

local woundTargets = mod:NewTargetList()
local meteorCount, moltCount, burnCount, initiateCount = 0, 0, 0, 0
local initiateTimes = {31, 31, 21, 21, 21}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.fullpower_soon_message = "Full power soon!"
	L.halfpower_soon_message = "Stage 4 soon!"
	L.encounter_restart = "Here we go again..."
	L.no_stacks_message = "Dunno if you care, but you have no feathers"
	L.moonkin_message = "Stop pretending and get some real feathers"
	L.molt_bar = "Molt"

	L.meteor = "Meteor"
	L.meteor_desc = "Warn when a Molten Meteor is summoned."
	L.meteor_icon = 100761
	L.meteor_message = "Meteor!"

	L.stage_message = "Stage %d"
	L.kill_message = "It's now or never - Kill her!"
	L.engage_message = "Alysrazor engaged - Stage 2 in ~%d min"

	L.worm_emote = "Fiery Lava Worms erupt from the ground!"
	L.phase2_soon_emote = "Alysrazor begins to fly in a rapid circle!"

	L.flight = "Flight Assist"
	L.flight_desc = "Show a bar with the duration of 'Wings of Flame' on you, ideally used with the Super Emphasize feature."
	L.flight_icon = 98619

	L.initiate = "Initiate Spawn"
	L.initiate_desc = "Show timer bars for initiate spawns."
	L.initiate_icon = 97062
	L.initiate_both = "Both Initiates"
	L.initiate_west = "West Initiate"
	L.initiate_east = "East Initiate"

	L.eggs = -2836 -- Voracious Hatchling
	L.eggs_icon = "inv_trinket_firelands_02"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		99362, 100024, 97128, 99464, "flight", "initiate", "eggs",
		99816,
		99432,
		99844, 99925,
		{100744, "FLASH"}, "meteor",
	}, {
		[99362] = -2820, --Stage 1: Flight
		[99816] = -2821, --Stage 2: Tornadoes
		[99432] = -2822, --Stage 3: Burnout
		[99844] = -2823, --Stage 4: Re-Ignite
		[100744] = "heroic",
	}
end

function mod:OnBossEnable()
	-- General
	self:Log("SPELL_AURA_APPLIED", "Molting", 99464, 99465)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BlazingClaw", 99844)
	self:Log("SPELL_AURA_APPLIED", "StartFlying", 98619)
	self:Log("SPELL_AURA_REMOVED", "StopFlying", 98619)

	-- Stage 1: Flight
	self:Log("SPELL_AURA_APPLIED", "Wound", 100024, 99308)
	self:Log("SPELL_AURA_APPLIED", "Tantrum", 99362)

	self:Emote("BuffCheck", L["worm_emote"])

	-- Stage 2: Tornadoes
	self:Emote("FieryTornado", L["phase2_soon_emote"])

	-- Stage 3: Burnout
	self:Log("SPELL_AURA_APPLIED", "Burnout", 99432)

	-- Stage 4: Re-Ignite
	self:Log("SPELL_AURA_REMOVED", "ReIgnite", 99432)

	-- Heroic only
	self:Log("SPELL_CAST_START", "Meteor", 100761, 102111)
	self:Log("SPELL_CAST_START", "Firestorm", 100744)
	self:Log("SPELL_AURA_REMOVED", "FirestormOver", 100744)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "Initiates")

	self:Death("Win", 52530)
end

function mod:OnEngage()
	meteorCount, moltCount, burnCount, initiateCount = 0, 0, 0, 0
	if self:Heroic() then
		initiateTimes = {22, 63, 21, 21, 40}
		self:MessageOld(99816, "yellow", nil, L["engage_message"]:format(4), "inv_misc_pheonixpet_01")
		self:Bar(99816, 250, L["stage_message"]:format(2))
		self:Bar(100744, 95) -- Firestorm
		self:CDBar("meteor", 30, L["meteor"], 100761)
		self:CDBar("eggs", 42, 58542, L["eggs_icon"]) -- Hatch Eggs
		self:DelayedMessage("eggs", 41.5, "green", 58542, L["eggs_icon"]) -- Hatch Eggs
	else
		initiateTimes = {31, 31, 21, 21, 21}
		self:MessageOld(99816, "yellow", nil, L["engage_message"]:format(3), "inv_misc_pheonixpet_01")
		self:Bar(99816, 188.5, L["stage_message"]:format(2))
		self:Bar(99464, 12.5, L["molt_bar"])
		--self:Bar("eggs", "~"..self:SpellName(58542), 42, L["eggs_icon"]) -- Hatch Eggs
		--self:DelayedMessage("eggs", 41.5, 58542, "green", L["eggs_icon"]) -- Hatch Eggs
	end
	self:Bar("initiate", 27, L["initiate_both"], 97062)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local lastCheck = 0
	function mod:FlightCheck(_, unit)
		local _, _, _, expires = self:UnitBuff(unit, self:SpellName(98619), 98619) -- Wings of Flame
		if expires ~= lastCheck then
			lastCheck = expires
			self:Bar("flight", expires-GetTime(), 98619)
		end
	end
	function mod:StartFlying(args)
		if self:Me(args.destGUID) then
			self:Bar("flight", 30, 98619)
			self:RegisterUnitEvent("UNIT_AURA", "FlightCheck", "player")
		end
	end
	function mod:StopFlying(args)
		if self:Me(args.destGUID) then
			self:UnregisterUnitEvent("UNIT_AURA", "player")
		end
	end
end

do
	local initiateLocation = {L["initiate_both"], L["initiate_east"], L["initiate_west"], L["initiate_east"], L["initiate_west"]}
	function mod:Initiates(_, _, unit)
		if unit == self:SpellName(-2834) then -- Blazing Talon Initiate
			initiateCount = initiateCount + 1
			if initiateCount > 5 then return end
			self:Bar("initiate", initiateTimes[initiateCount], initiateLocation[initiateCount], 97062) --Night Elf head
		end
	end
end

do
	local feather = mod:SpellName(97128)
	local moonkin = mod:SpellName(24858)
	function mod:BuffCheck()
		local name = self:UnitBuff("player", feather, 97128)
		if not name then
			if self:UnitBuff("player", moonkin) then
				self:MessageOld(97128, "blue", nil, L["moonkin_message"])
			else
				self:MessageOld(97128, "blue", nil, L["no_stacks_message"])
			end
		end
	end
end

do
	local scheduled = nil
	local function woundWarn()
		mod:TargetMessageOld(100024, woundTargets, "blue")
		scheduled = nil
	end
	function mod:Wound(args)
		if not UnitIsPlayer(args.destName) then return end --Avoid those shadowfiends
		woundTargets[#woundTargets + 1] = args.destName
		if not scheduled then
			scheduled = true
			self:ScheduleTimer(woundWarn, 0.5)
		end
	end
end

function mod:Tantrum(args)
	local target = self:UnitGUID("target")
	if not target or args.sourceGUID ~= target then return end
	-- Just warn for the tank
	self:MessageOld(args.spellId, "red")
end

-- don't need molting warning for heroic because molting happens at every firestorm
function mod:Molting(args)
	if not self:Heroic() then
		moltCount = moltCount + 1
		self:MessageOld(99464, "green", nil, args.spellId)
		if moltCount < 3 then
			self:Bar(99464, 60, L["molt_bar"], args.spellId)
		end
	end
end

function mod:Firestorm(args)
	self:Flash(args.spellId)
	self:MessageOld(args.spellId, "orange", "alert")
	self:Bar(args.spellId, 10, CL["cast"]:format(args.spellName))
end

function mod:FirestormOver(args)
	-- Only show a bar for next if we have seen less than 3 meteors
	if meteorCount < 3 then
		self:CDBar(args.spellId, 72)
	end
	self:Bar("meteor", meteorCount == 2 and 11.5 or 21.5,  L["meteor"], 100761)
	self:CDBar("eggs", 22.5, 58542, L["eggs_icon"]) -- Hatch Eggs
	self:DelayedMessage("eggs", 22, "green", 58542, L["eggs_icon"]) -- Hatch Eggs
end

function mod:Meteor(args)
	self:MessageOld("meteor", "yellow", "alarm", L["meteor_message"], args.spellId)
	-- Only show a bar if this is the first or third meteor this phase
	meteorCount = meteorCount + 1
	if meteorCount == 1 or meteorCount == 3 then
		self:Bar("meteor", 32, L["meteor"], args.spellId)
	end
end

function mod:FieryTornado()
	self:BuffCheck()
	self:StopBar(100744) -- Firestorm
	self:Bar(99816, 35) -- Fiery Tornado
	self:MessageOld(99816, "red", "alarm", (L["stage_message"]:format(2))..": "..self:SpellName(99816))
end

function mod:BlazingClaw(args)
	if args.amount > 4 then -- 50% extra fire and physical damage taken on tank
		self:StackMessageOld(args.spellId, args.destName, args.amount, "orange", "info", 16827, args.spellId) -- 16827 = "Claw"
	end
end

do
	local halfWarned = false
	local fullWarned = false

	-- Alysrazor crashes to the ground
	function mod:Burnout(args)
		self:MessageOld(args.spellId, "green", "alert", (L["stage_message"]:format(3))..": "..args.spellName)
		self:CDBar(args.spellId, 33)
		halfWarned, fullWarned = false, false
		burnCount = burnCount + 1
		if burnCount < 3 then
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", nil, "boss1")
		end
	end

	function mod:UNIT_POWER_FREQUENT(event, unit)
		local power = UnitPower(unit, 0)
		if power > 40 and not halfWarned then
			self:MessageOld(99925, "orange", nil, L["halfpower_soon_message"])
			halfWarned = true
		elseif power > 80 and not fullWarned then
			self:MessageOld(99925, "yellow", nil, L["fullpower_soon_message"])
			fullWarned = true
		elseif power == 100 then
			self:MessageOld(99925, "green", "alert", (L["stage_message"]:format(1))..": "..(L["encounter_restart"]))
			self:UnregisterUnitEvent(event, unit)
			initiateCount = 0
			self:Bar("initiate", 13.5, L["initiate_both"], 97062)
			if self:Heroic() then
				meteorCount = 0
				self:Bar("meteor", 19, L["meteor"], 100761)
				self:Bar(100744, 72) -- Firestorm
				self:Bar(99816, 225, L["stage_message"]:format(2)) -- Just adding 60s like OnEngage
				self:CDBar("eggs", 30, 58542, L["eggs_icon"]) -- Hatch Eggs
				self:DelayedMessage("eggs", 29.5, "green", L["eggs_icon"], 58542) -- Hatch Eggs
			else
				self:Bar(99816, 165, L["stage_message"]:format(2))
				moltCount = 1
				self:Bar(99464, 55, L["molt_bar"])
				--self:Bar("eggs", "~"..self:SpellName(58542), 22.5, L["eggs_icon"]) -- Hatch Eggs
				--self:DelayedMessage("eggs", 22, 58542, "green", L["eggs_icon"]) -- Hatch Eggs
			end
		end
	end

	function mod:ReIgnite()
		if burnCount < 3 then
			self:MessageOld(99925, "green", "alert", (L["stage_message"]:format(4))..": "..self:SpellName(99922))
			self:Bar(99925, 25) -- Full Power
		else
			self:MessageOld(99925, "green", "alert", L["kill_message"], 99922)
		end
		self:StopBar(99432) -- Burnout
	end
end

