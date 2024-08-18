--[[
TODO:
	Focused Lightning CD might be reset by Ionization ( or maybe its thundering throw too if the CDs are close enough )
]]--

--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Jin'rokh the Breaker", 1098, 827)
if not mod then return end
mod:RegisterEnableMob(69465)

--------------------------------------------------------------------------------
-- Locals
--
local ionized = {}
local openedForMe = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.storm_duration = "Lightning Storm duration"
	L.storm_duration_desc = "A separate bar warning for the duration of the Lightning Storm cast."
	L.storm_duration_icon = 137313
	L.storm_short = "Storm"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{138732, "PROXIMITY"},
		137313, "storm_duration",
		{137162, "TANK"}, {138349, "TANK"},
		{137175, "PROXIMITY", "ICON"}, {139467, "FLASH"}, {-7741, "PROXIMITY", "ICON", "SAY"}, {138006, "FLASH"}, "berserk",
	}, {
		[138732] = "heroic",
		[137313] = 137313,
		[137162] = INLINE_TANK_ICON..TANK,
		[137175] = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_REMOVED", "IonizationRemoved", 138732)
	self:Log("SPELL_AURA_APPLIED", "PersonalIonization", 138732) -- This is needed for personal bar
	self:Log("SPELL_CAST_START", "Ionization", 138732)
	self:Log("SPELL_CAST_SUCCESS", "LightningStormDuration", 137313)
	self:Log("SPELL_CAST_START", "LightningStorm", 137313)
	self:Log("SPELL_AURA_APPLIED", "ThunderingThrowSafe", 137371)
	self:Log("SPELL_DAMAGE", "LightningFissure", 139467, 137485) -- 137485 is from 25H
	self:Log("SPELL_MISSED", "LightningFissure", 139467, 137485)
	self:Log("SPELL_AURA_REMOVED", "FocusedLightningRemoved", 137422)
	self:Log("SPELL_CAST_START", "FocusedLightning", 137399) -- SUCCESS has destName, but this is so much earlier, and "boss1target" should be reliable for it
	self:Log("SPELL_CAST_SUCCESS", "StaticBurst", 137162)
	self:Log("SPELL_AURA_APPLIED", "ElectrifiedWaters", 138006)
	self:Log("SPELL_MISSED", "ElectrifiedWaters", 138006)
	self:Log("SPELL_PERIODIC_DAMAGE", "ElectrifiedWaters", 138006)
	self:Log("SPELL_PERIODIC_MISSED", "ElectrifiedWaters", 138006)

	self:Log("SPELL_AURA_APPLIED", "StaticWound", 138349)
	self:Log("SPELL_AURA_APPLIED_DOSE", "StaticWound", 138349)

	self:Emote("ThunderingThrow", "137175") -- this seems to be the fastest way to determine which tank gets thrown, APPLIED is way too slow
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 69465)
end

function mod:OnEngage()
	self:Bar(137313, 93, L["storm_short"]) -- Lightning Storm
	self:Bar(137175, 30) -- Thundering Throw
	self:Bar(137162, 13) -- Static Burst
	self:Berserk(self:Heroic() and 360 or 540)
	if self:Heroic() then -- Ionization
		ionized = {}
		openedForMe = nil
		self:Bar(138732, 60) -- Ionization
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:IonizationRemoved(args)
	if self:Me(args.destGUID) then
		openedForMe = nil
		self:StopBar(CL["you"]:format(args.spellName))
		self:MessageOld(args.spellId, "green", "info", CL["removed"]:format(args.spellName))
	end
	for k, v in next, ionized do
		if v == args.destName then
			tremove(ionized, k)
			break
		end
	end
	if #ionized == 0 then
		self:CloseProximity(args.spellId)
		if self:UnitDebuff("player", self:SpellName(137422), 137422) then -- Focused Lightning
			self:OpenProximity(-7741, 8) -- reopen it if we have lightning chasing us too
		end
	elseif not openedForMe then
		self:OpenProximity(args.spellId, 8, ionized)
	end
end

function mod:PersonalIonization(args)
	if self:Me(args.destGUID) then
		openedForMe = true
		self:OpenProximity(args.spellId, 8)
		self:TargetBar(args.spellId, 24, args.destName)
	else
		ionized[#ionized+1] = args.destName
	end
	if not openedForMe then
		self:OpenProximity(args.spellId, 8, ionized)
	end
end

function mod:Ionization(args)
	self:Bar(-7741, 13) -- Focused Lightning
	self:MessageOld(args.spellId, "red", "long")
	self:Bar(args.spellId, 92)
end

function mod:LightningStormDuration(args)
	self:Bar("storm_duration", 15, CL["cast"]:format(L["storm_short"]), L.storm_duration_icon) -- help with organizing raid cooldowns
end

function mod:LightningStorm(args)
	self:MessageOld(args.spellId, "red", "long")
	self:Bar(args.spellId, 93, L["storm_short"])
	self:Bar(-7741, self:Heroic() and 20 or 26) -- Focused Lightning
	self:Bar(137162, 20) -- Static Burst
	self:Bar(137175, 30) -- Thundering Throw
end

function mod:ThunderingThrowSafe()
	self:SecondaryIcon(137175)
	self:CloseProximity(137175)
	if self:UnitDebuff("player", self:SpellName(137399)) then -- Focused Lightning
		self:OpenProximity(-7741, 5)
	end
end

function mod:ThunderingThrow(_, _, _, _, target)
	self:TargetMessageOld(137175, target, "red", "warning")
	self:SecondaryIcon(137175, target)
	if not UnitIsUnit(target, "player") then -- no point opening proximity for the thrown tank
		self:CloseProximity(-7741) -- close this before opening another ( in case it was open )
		self:OpenProximity(137175, 8, target)
	end
end

do
	local prev = 0
	function mod:LightningFissure(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(139467, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(139467)
		end
	end
end

function mod:FocusedLightningRemoved(args)
	self:PrimaryIcon(-7741)
	if self:Me(args.destGUID) then
		self:CloseProximity(-7741)
		if self:UnitDebuff("player", self:SpellName(138732), 138732) then -- Ionization
			self:OpenProximity(138732, 8)
		end
	end
end

do
	local function printTarget(self, player, guid)
		self:TargetMessageOld(-7741, player, "green", "alarm")
		self:PrimaryIcon(-7741, player)
		if self:Me(guid) then
			self:Say(-7741, nil, nil, "Focused Lightning")
			self:OpenProximity(-7741, 8)
		end
	end
	function mod:FocusedLightning(args)
		self:Bar(-7741, 11)
		self:GetBossTarget(printTarget, 0.5, args.sourceGUID)
	end
end

function mod:StaticBurst(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 23)
end

function mod:StaticWound(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange", "alert", nil, nil, true)
end


do
	local prev = 0
	function mod:ElectrifiedWaters(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

