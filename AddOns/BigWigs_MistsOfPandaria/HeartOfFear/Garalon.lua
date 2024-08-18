
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Garalon", 1009, 713)
if not mod then return end
mod:RegisterEnableMob(63191, 63053) -- Garalon, Garalon's Leg

-----------------------------------------------------------------------------------------
-- Locals
--

local legCounter, crushCounter = 4, 0
local mendLegTimerRunning = nil
local pheromonesOnMe = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.phase2_trigger = "Garalon's massive armor plating begins to crack and split!"

	L.removed = "%s removed!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-6294,
		122735, 122754,
		122774, 123495, {122835, "ICON"}, 123120, 123081, "berserk",
	}, {
		[-6294] = "heroic",
		[122735] = INLINE_TANK_ICON..TANK,
		[122774] = "general",
	}
end

function mod:OnBossEnable()
	self:Emote("Crush", "spell:122774")
	self:Emote("Phase2", L["phase2_trigger"])

	self:Log("SPELL_AURA_APPLIED", "PheromonesApplied", 122835)
	self:Log("SPELL_AURA_REMOVED", "PheromonesRemoved", 122835)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Pungency", 123081)
	self:Log("SPELL_CAST_SUCCESS", "MendLeg", 123495)
	self:Log("SPELL_CAST_SUCCESS", "BrokenLeg", 122786)
	self:Log("SPELL_CAST_START", "FuriousSwipe", 122735)
	self:Log("SPELL_AURA_APPLIED", "Fury", 122754)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Fury", 122754)

	self:Log("SPELL_DAMAGE", "PheromoneTrail", 123120)
	self:Log("SPELL_MISSED", "PheromoneTrail", 123120)

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 62164, 63191)
end

function mod:OnEngage(diff)
	legCounter, crushCounter = 4, 0
	mendLegTimerRunning = nil
	pheromonesOnMe = false

	self:Berserk(self:Heroic() and 420 or 720)
	self:Bar(122735, 11) -- Furious Swipe
	if self:Heroic() then
		self:RegisterUnitEvent("UNIT_HEALTH", "PrePhase2", "boss1", "boss2", "boss3", "boss4", "boss5")
		self:Bar(122774, 28, CL["count"]:format(self:SpellName(122774), 1), 122082) -- Crush
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:PheromoneTrail(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", not pheromonesOnMe and "alert", CL["underyou"]:format(args.spellName)) -- even tho we usually use Alarm, Alarm has been used too much in the module
		end
	end
end

function mod:Crush(message, sender, _, _, target)
	if self:Heroic() and sender ~= target then -- someone running underneath (don't start new bars in heroic)
		self:MessageOld(122774, "red", "alarm", CL["soon"]:format(self:SpellName(122774))) -- Crush
		self:Bar(122774, 3.6, CL["cast"]:format(self:SpellName(122774))) -- Crush
	else
		crushCounter = crushCounter + 1
		self:MessageOld(122774, "red", "alarm", CL["soon"]:format(CL["count"]:format(self:SpellName(122774), crushCounter))) -- Crush
		self:Bar(122774, 3.6, CL["cast"]:format(self:SpellName(122774))) -- Crush
		if self:Heroic() then
			self:Bar(122774, 36, CL["count"]:format(self:SpellName(122774), crushCounter+1), 122082) -- Crush
		end
	end
	self:Bar(122735, 9) --Furious Swipe
end

function mod:Fury(args)
	if self:MobId(args.destGUID) == 63191 then -- only fire once
		self:Bar(args.spellId, self:LFR() and 15 or 30, nil, 119622) -- Rage like icon (swipe and fury have the same)
		self:MessageOld(args.spellId, "orange", nil, CL["count"]:format(args.spellName, args.amount or 1), 119622)
	end
end

function mod:PheromonesApplied(args)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		pheromonesOnMe = true
		self:MessageOld(args.spellId, "blue", "info", CL["you"]:format(args.spellName))
	elseif self:Healer() then
		self:TargetMessageOld(args.spellId, args.destName, "yellow", nil, nil, nil, true)
	end
end

function mod:PheromonesRemoved(args)
	if self:Me(args.destGUID) then
		pheromonesOnMe = false
		self:MessageOld(args.spellId, "red", "alarm", L["removed"]:format(args.spellName))
	end
end

function mod:Pungency(args)
	if args.amount % 2 == 0 and args.amount > ((self:LFR() and 13) or (self:Heroic() and 3) or 7) then
		self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow")
	end
end

function mod:MendLeg(args)
	legCounter = legCounter + 1
	if legCounter < 4 then -- don't start a timer if it has all 4 legs
		self:MessageOld(args.spellId, "orange")
		self:Bar(args.spellId, 30)
	else
		-- all legs grew back, no need to start a bar, :BrokenLeg will start it
		mendLegTimerRunning = nil
	end
end

function mod:BrokenLeg()
	legCounter = legCounter - 1
	-- this is just a way to start the bar after 1st legs death
	if not mendLegTimerRunning then
		self:Bar(123495, 30) -- Mend Leg
		mendLegTimerRunning = true
	end
end

function mod:FuriousSwipe(args)
	-- delay the bar so it ends when the damage occurs
	-- Furious Swipe's cast time is 2.5ish seconds, with 8s between SPELL_CAST_STARTs
	self:ScheduleTimer("Bar", 2.5, args.spellId, 8)
end

function mod:PrePhase2(event, unit)
	local id = self:MobId(self:UnitGUID(unit))
	if id == 62164 or id == 63191 then
		local hp = self:GetHealth(unit)
		if hp < 38 then -- phase starts at 33
			self:MessageOld(-6294, "green", "long", CL["soon"]:format(CL["phase"]:format(2)), false)
			self:UnregisterUnitEvent(event, "boss1", "boss2", "boss3", "boss4", "boss5")
		end
	end
end

function mod:Phase2()
	self:MessageOld(-6294, "green", "info", "33% - "..CL["phase"]:format(2))
end

