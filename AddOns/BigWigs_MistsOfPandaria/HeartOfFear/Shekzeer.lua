
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Grand Empress Shek'zeer", 1009, 743)
if not mod then return end
mod:RegisterEnableMob(62837)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Death to all who dare challenge my empire!"

	L.phases = "Phases"
	L.phases_desc = "Warning for phase changes."
	L.phases_icon = "achievement_raid_mantidraid07"

	L.eyes = "Eyes of the Empress"
	L.eyes_desc = "Count the stacks and show a duration bar for Eyes of the Empress."
	L.eyes_icon = 123707
	L.eyes_message = "Eyes"

	L.visions_message = "Visions"
	L.visions_dispel = "Players have been feared!"
	L.fumes_bar = "Your fumes buff"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{123845, "FLASH", "ICON", "SAY"},
		-6325, {"eyes", "TANK"}, {123788, "FLASH", "ICON"}, {123735, "HEALER"}, "proximity",
		{125390, "FLASH"}, 124097, 125826, 124827, {124077, "FLASH"},
		{124862, "FLASH", "PROXIMITY", "SAY"}, { 124849, "FLASH" },
		"phases", "berserk",
	}, {
		[123845] = "heroic",
		[-6325] = -6336,
		[125390] = -6340,
		[124862] = -6341,
		phases = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Eyes", 123707)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Eyes", 123707)
	self:Log("SPELL_CAST_SUCCESS", "DreadScreech", 123735)
	self:Log("SPELL_AURA_APPLIED", "CryOfTerror", 123788)
	self:Log("SPELL_AURA_REMOVED", "CryOfTerrorRemoved", 123788)

	self:Log("SPELL_AURA_APPLIED", "Poison", 124827)
	self:Log("SPELL_AURA_REFRESH", "Poison", 124827)
	self:Log("SPELL_AURA_APPLIED", "Fixate", 125390)
	self:Log("SPELL_AURA_REMOVED", "FixateRemoved", 125390)
	self:Log("SPELL_AURA_APPLIED", "Dispatch", 124077)
	self:Log("SPELL_AURA_APPLIED", "Resin", 124097)
	self:Log("SPELL_AURA_APPLIED_DOSE", "AmberTrap", 124748)

	self:Log("SPELL_AURA_APPLIED", "UltimateCorruption", 125451)
	self:Log("SPELL_AURA_REMOVED", "VisionsRemoved", 124862)
	self:Log("SPELL_AURA_APPLIED", "VisionsDispel", 124868)
	self:Log("SPELL_AURA_APPLIED", "Visions", 124862)
	self:Log("SPELL_CAST_START", "ConsumingTerror", 124849)

	self:Log("SPELL_AURA_APPLIED", "HeartOfFearApplied", 123845)
	self:Log("SPELL_AURA_REMOVED", "HeartOfFearRemoved", 123845)

	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "PoorMansDissonanceTimers", "boss1")
	self:RegisterUnitEvent("UNIT_HEALTH", "Phase3Warn", "boss1")

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")
	self:Death("Win", 62837)
end

function mod:OnEngage(diff)
	self:OpenProximity("proximity", 5)
	self:Berserk(900)
	self:Bar(-6325, 20) --Dissonance Field
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:HeartOfFearRemoved(args)
	self:PrimaryIcon(args.spellId)
end

function mod:HeartOfFearApplied(args)
	self:TargetMessageOld(args.spellId, args.destName, "red", "info")
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
		self:Say(args.spellId, nil, nil, "Heart of Fear")
	end
end

function mod:Dispatch(args)
	local diff = self:Difficulty()
	self:Bar(124077, (diff == 3 or diff == 5) and 22 or 12)
	self:MessageOld(args.spellId, "orange", "long")
	if self:UnitGUID("target") == args.sourceGUID or self:UnitGUID("focus") == args.sourceGUID then
		self:Flash(args.spellId)
	end
end

function mod:Poison(args)
	if self:Me(args.destGUID) then
		self:Bar(args.spellId, 30, L["fumes_bar"])
	end
end

function mod:DreadScreech(args)
	self:Bar(args.spellId, 6)
end

function mod:ConsumingTerror(args)
	self:MessageOld(args.spellId, "red", "alert")
	self:Bar(args.spellId, 31)
	self:Flash(args.spellId)
end

function mod:CryOfTerror(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow", "long")
	self:PrimaryIcon(args.spellId, args.destName)
	self:Bar(args.spellId, 25)
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
end

function mod:CryOfTerrorRemoved(args)
	self:PrimaryIcon(args.spellId)
end

do
	local prev = 0
	function mod:VisionsDispel(args)
		local _, class = UnitClass("player")
		if self:Dispeller("magic") or class == "SHAMAN" then -- shamans too because of tremor totem
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				self:MessageOld(124862, "yellow", "alert", L["visions_dispel"], args.spellId)
			end
		end
	end
end

function mod:VisionsRemoved(args)
	self:CloseProximity(args.spellId)
end

do
	local visionsList, scheduled = mod:NewTargetList(), nil
	local function warnVisions(spellId)
		mod:TargetMessageOld(spellId, visionsList, "red", "alarm", L["visions_message"])
		scheduled = nil
	end
	function mod:Visions(args)
		visionsList[#visionsList + 1] = args.destName
		if self:Me(args.destGUID) then
			self:Say(args.spellId, L["visions_message"], nil, "Visions")
			self:Flash(args.spellId)
			self:OpenProximity(args.spellId, 8)
		end
		if not scheduled then
			scheduled = self:ScheduleTimer(warnVisions, 0.1, args.spellId)
		end
	end
end

function mod:Fixate(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow", "info")
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
		self:MessageOld(args.spellId, "blue", "info", CL["you"]:format(args.spellName))
		self:TargetBar(args.spellId, 20, args.destName)
	end
end

function mod:FixateRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(args.spellName, args.destName)
	end
end

function mod:Resin(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", "info", CL["you"]:format(args.spellName))
	end
end

function mod:AmberTrap(args)
	local buffStack = args.amount or 1
	if buffStack < 5 then
		self:MessageOld(125826, "yellow", nil, CL["count"]:format(args.spellName, buffStack)) --Sticky Resin (124748)
	else
		self:MessageOld(125826, "yellow") --Amber Trap
	end
end

do
	local warned = 0
	function mod:PoorMansDissonanceTimers(_, unitId)
		local power = UnitPower(unitId)
		if warned == power then return end
		warned = power
		if power == 149 then
			self:OpenProximity("proximity", 5)
			self:Bar(-6325, 19) --Dissonance Field
			self:Bar("phases", 149, CL["phase"]:format(2), L.phases_icon)
			self:StopBar(CL["phase"]:format(1))
			self:StopBar(124077)
		elseif power == 130 then
			self:Bar(-6325, 65)
			self:MessageOld(-6325, "yellow")
		elseif power == 65 then
			self:MessageOld(-6325, "yellow")
		elseif power == 2 then
			self:CloseProximity()
			self:Bar("phases", 158, CL["phase"]:format(1), L.phases_icon)
			self:StopBar(123735)
		end
	end
end

function mod:Eyes(args)
	local buffStack = args.amount or 1
	self:Bar("eyes", 10.5, L["eyes_message"], args.spellId)
	self:StackMessageOld("eyes", args.destName, buffStack, "orange", buffStack > 2 and "info", L["eyes_message"], args.spellId)
end

function mod:UltimateCorruption(args)
	self:MessageOld("phases", "green", "info", "30% - "..CL["phase"]:format(3), args.spellId)
	self:StopBar(CL["phase"]:format(2))
	self:StopBar(123627) -- Dissonance Field
	self:CloseProximity()
	self:Bar(124849, 10) -- Consuming Terror
end

function mod:Phase3Warn(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 35 then -- phase starts at 30
		self:MessageOld("phases", "green", "info", CL["soon"]:format(CL["phase"]:format(3)), L.phases_icon)
		self:UnregisterUnitEvent(event, unit)
	end
end

