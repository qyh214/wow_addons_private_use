
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Iron Maidens", 1205, 1203)
if not mod then return end
mod:RegisterEnableMob(77477, 77557, 77231) -- Marak the Blooded, Admiral Gar'an, Enforcer Sorka
mod.engageId = 1695
mod.respawnTime = 29.5

--------------------------------------------------------------------------------
-- Locals
--

local shipCount = 0
local barrierCount = 0
local boatTimers = {} -- don't announce while on the boat, but track the cd times

local function isOnABoat()
	--local _, pos = UnitPosition("player")
	--return pos > 3200
end

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.ship_trigger = "prepares to man the Dreadnaught's Main Cannon!"

	L.ship = "Jump to Ship" -- XXX Check if 137266 is translated in wowNext
	L.ship_desc = -10019 -- The Dreadnaught
	L.ship_icon = "ability_vehicle_siegeenginecannon"

	L.warming_up = 158849
	L.warming_up_desc = 158849
	L.warming_up_icon = "spell_fire_selfdestruct" -- 158849 doesn't have an icon

	L.bombardment = 147135 -- Bombardment
	L.bombardment_desc = -10854 -- Bombardment Pattern
	L.bombardment_icon = "ability_ironmaidens_bombardment"

	L.custom_off_heartseeker_marker = "Bloodsoaked Heartseeker marker"
	L.custom_off_heartseeker_marker_desc = "Marks Heartseeker targets with {rt1}{rt2}{rt3}, requires promoted or leader."
	L.custom_off_heartseeker_marker_icon = 1

	L.power_message = "%d Iron Fury!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		--[[ Dreadnaught ]]--
		"ship",
		"warming_up",
		"bombardment",
		{158683, "FLASH"}, -- Corrupted Blood
		158708, -- Earthen Barrier
		158692, -- Deadly Throw
		--[[ Gar'an ]]--
		{156631, "ICON", "SAY", "FLASH"}, -- Rapid Fire
		{164271, "ICON", "SAY", "FLASH"}, -- Penetrating Shot
		158599, -- Deploy Turret
		--[[ Sorka ]]--
		155794, -- Blade Dash
		{156109, "FLASH", "DISPEL"}, -- Convulsive Shadows
		158315, -- Dark Hunt
		--[[ Marak ]]--
		{159724, "ICON", "SAY", "FLASH"}, -- Blood Ritual
		{158010, "SAY", "FLASH"}, -- Heartseeker
		"custom_off_heartseeker_marker",
		156601, -- Sanguine Strikes
		-- [[ General ]]--
		159336, -- Iron Will
	}, {
		["ship"] = -10019, -- Dreadnaught
		[156631] = -10025, -- Gar'an
		[155794] = -10030, -- Sorka
		[159724] = -10033, -- Marak
		[159336] = "general"
	}
end

function mod:OnBossEnable()
	self:Death("Deaths", 77477, 77557, 77231)

	self:Log("SPELL_AURA_APPLIED", "IronWill", 159336)
	-- Gar'an
	self:RegisterEvent("RAID_BOSS_WHISPER")
	self:Log("SPELL_AURA_APPLIED", "RapidFire", 156631)
	self:Log("SPELL_AURA_REMOVED", "RapidFireRemoved", 156631)
	self:Log("SPELL_AURA_APPLIED", "PenetratingShot", 164271)
	self:Log("SPELL_AURA_REMOVED", "PenetratingShotRemoved", 164271)
	self:Log("SPELL_CAST_START", "DeployTurret", 158599)
	-- Sorka
	self:Log("SPELL_CAST_SUCCESS", "BladeDash", 155794)
	self:Log("SPELL_CAST_START", "ConvulsiveShadows", 156109)
	self:Log("SPELL_AURA_APPLIED", "DarkHunt", 158315)
	-- Marak
	self:Log("SPELL_AURA_APPLIED", "BloodRitual", 159724)
	self:Log("SPELL_AURA_REMOVED", "BloodRitualRemoved", 159724)
	self:Log("SPELL_AURA_APPLIED", "HeartseekerApplied", 158010)
	self:Log("SPELL_AURA_REMOVED", "HeartseekerRemoved", 158010)
	self:Log("SPELL_AURA_APPLIED", "SanguineStrikes", 156601)
	-- Ship
	self:Emote("ShipPhase", L.ship_trigger) -- 10/40/70 power
	--self:Log("SPELL_CAST_SUCCESS", "ShipPhase", 181089) -- XXX 6.1
	self:Log("SPELL_CAST_SUCCESS", "BombardmentAlpha", 157854)
	self:Log("SPELL_CAST_SUCCESS", "BombardmentOmega", 157886)
	self:Log("SPELL_PERIODIC_DAMAGE", "CorruptedBloodDamage", 158683)
	self:Log("SPELL_PERIODIC_MISSED", "CorruptedBloodDamage", 158683)
	self:Log("SPELL_CAST_START", "EarthenBarrier", 158708)
	self:Log("SPELL_CAST_START", "DeadlyThrow", 158692)
end

function mod:OnEngage()
	shipCount = 0
	barrierCount = 0
	boatTimers = {}
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", nil, "boss1", "boss2", "boss3")

	self:Bar(159724, 5) -- Blood Ritual
	self:Bar(155794, 11) -- Blade Dash
	self:Bar(156631, 19) -- Rapid Fire
	self:Bar("ship", 60, L.ship, L.ship_icon) -- Jump to Ship
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:UNIT_POWER_FREQUENT(_, unit, powerType)
		if powerType == "ALTERNATE" then
			local power = UnitPower(unit, 10) -- Enum.PowerType.Alternate = 10
			if power == 1 then
				self:Bar("warming_up", 88, L.warming_up, L.warming_up_icon)
			elseif power == 0 then
				self:StopBar(L.warming_up)
				self:StopBar(L.bombardment)
				-- restart timers
				-- local t = GetTime()
				-- for spellId, nextTime in next, boatTimers do
				-- 	if nextTime > t then
				-- 		self:CDBar(spellId, nextTime-t)
				-- 	end
				-- end
				-- boatTimers = {}
			end
		else
			local power = UnitPower(unit)
			if power == prev then return end
			if power == 27 then
				if self:Dispeller("magic", nil, 156109) then
					self:CDBar(156109, 22) -- Convulsive Shadows
				end
				self:CDBar(164271, 21) -- Penetrating Shot
				self:CDBar(158010, 32) -- Bloodsoaked Heartseeker 32-35
			elseif power == 30 or power == 100 then
				self:MessageOld(159336, "cyan", "long", L.power_message:format(power), false)
			end
			prev = power
		end
	end
end

do
	local prev = 0
	function mod:IronWill(args)
		local t = GetTime()
		if t-prev > 5 then
			prev = t
			self:MessageOld(args.spellId, "red", "long")
			self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss1", "boss2", "boss3")
			self:StopBar(L.ship) -- Jump to Ship
		end
	end
end

-- Ship

local function stopBars(mobId)
	if mobId == 77477 or mobId == true then -- Marak
		mod:StopBar(159724) -- Blood Ritual
		mod:StopBar(158010) -- Heartseeker
		mod:StopBar(156601) -- Sanguine Strikes
	end
	if mobId == 77557 or mobId == true then -- Gar'an
		mod:StopBar(156631) -- Rapid Fire
		mod:StopBar(164271) -- Penetrating Shot
		mod:StopBar(158599) -- Deploy Turret
	end
	if mobId == 77231 or mobId == true then -- Sorka
		mod:StopBar(155794) -- Blade Dash
		mod:StopBar(156109) -- Convulsive Shadows
	end
end

local function checkBoat()
	if isOnABoat() then
		stopBars(true)
	end
end

-- XXX 6.1
--function mod:ShipPhase(args)
--	shipCount = shipCount + 1
--	self:MessageOld("ship", "cyan", "info", CL.other:format(L.ship, args.sourceName), false)
--	stopBars(self:MobId(args.sourceGUID))
--	if shipCount < 3 then
--		self:Bar("ship", 198, L.ship, L.ship_icon)
--	end
--	self:ScheduleTimer(checkBoat, 6)
--end

function mod:ShipPhase(_, sender)
	shipCount = shipCount + 1
	self:MessageOld("ship", "cyan", "info", CL.other:format(L.ship, sender), false)
	if sender == self:SpellName(-10025) then -- Gar'an
		stopBars(77557)
	elseif sender == self:SpellName(-10030) then -- Sorka
		stopBars(77231)
	elseif sender == self:SpellName(-10033) then -- Marak
		stopBars(77477)
	end
	if shipCount < 3 then
		self:Bar("ship", 198, L.ship, L.ship_icon)
	end
	self:ScheduleTimer(checkBoat, 6)
end

function mod:BombardmentAlpha(args)
	if isOnABoat() then
		self:Bar("bombardment", 11, CL.count:format(self:SpellName(157884), 1), "ability_ironmaidens_incindiarydevice") -- Detonation Sequence (1)
	else
		self:MessageOld("bombardment", "cyan", nil, args.spellId)
		self:CDBar("bombardment", 18, L.bombardment, L.bombardment_icon)
	end
end

function mod:BombardmentOmega(args)
	if isOnABoat() then
		self:Bar("bombardment", 11, CL.count:format(self:SpellName(157884), 2), "ability_ironmaidens_incindiarydevice") -- Detonation Sequence (2)
	else
		self:MessageOld("bombardment", "cyan", nil, args.spellId)
	end
end

do
	local prev = 0
	function mod:CorruptedBloodDamage(args)
		local t = GetTime()
		if self:Me(args.destGUID) and t-prev > 1 then
			prev = t
			self:MessageOld(args.spellId, "blue", "alarm", CL.underyou:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:EarthenBarrier(args)
	barrierCount = barrierCount + 1
	if isOnABoat() then
		self:MessageOld(args.spellId, "orange", "alert", CL.count:format(args.spellName, barrierCount))
		self:CDBar(args.spellId, 10)
	end
end

do
	local function printTarget(self, name)
		self:TargetMessageOld(158692, name, "orange", "alert", nil, nil, self:Tank())
	end
	function mod:DeadlyThrow(args)
		if isOnABoat() then
			self:GetUnitTarget(printTarget, 0.2, args.sourceGUID)
			self:Bar(args.spellId, 13)
		end
	end
end

-- Gar'an

function mod:RAID_BOSS_WHISPER(_, msg)
	if msg:find("156626", nil, true) then -- Rapid Fire
		local text = CL.you:format(self:SpellName(156631))
		self:MessageOld(156631, "blue", "alarm", text)
		self:Bar(156631, 10.5, text)
		self:Flash(156631)
		self:Say(156631, nil, nil, "Rapid Fire")
	end
end

do
	function mod:RapidFire(args)
		if not self:LFR() then
			self:PrimaryIcon(args.spellId, args.destName)
		end
		if isOnABoat() then
			boatTimers[args.spellId] = GetTime() + 31.6
			return
		end
		if not self:Me(args.destGUID) then
			self:TargetMessageOld(args.spellId, args.destName, "orange")
		end
		self:Bar(args.spellId, 31.6)
	end

	function mod:RapidFireRemoved(args)
		if not self:LFR() then
			self:PrimaryIcon(args.spellId)
		end
	end
end

-- XXX lacks a :Log method
--function mod:IncendiaryDevice(args)
--	if isOnABoat() then
--		return
--	end
--	self:MessageOld(args.spellId, "red")
--end

do
	function mod:PenetratingShot(args)
		if not self:LFR() then
			self:PrimaryIcon(args.spellId, args.destName)
		end
		if isOnABoat() then
			boatTimers[args.spellId] = GetTime() + 30
			return
		end
		if self:Me(args.destGUID) then
			self:MessageOld(args.spellId, "blue", "alarm", CL.you:format(args.spellName))
			self:Flash(args.spellId)
			self:Say(args.spellId, nil, nil, "Penetrating Shot")
		else
			self:TargetMessageOld(args.spellId, args.destName, "red", "warning", nil, nil, true)
		end
		self:TargetBar(args.spellId, self:Normal() and 8 or 6, args.destName)
		self:Bar(args.spellId, 30)
	end

	function mod:PenetratingShotRemoved(args)
		if not self:LFR() then
			self:PrimaryIcon(args.spellId)
		end
	end
end

function mod:DeployTurret(args)
	self:MessageOld(args.spellId, "yellow")
	--self:CDBar(args.spellId, 20) -- 19.8-22.6
end

-- Sorka

function mod:BladeDash(args)
	if isOnABoat() then
		boatTimers[args.spellId] = GetTime() + 18
		return
	end
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
	self:Bar(args.spellId, 18)
end

do
	local dispeller = nil
	local function printTarget(self, name, guid)
		if dispeller or self:Me(guid) then
			self:TargetMessageOld(156109, name, "orange", "info")
		end
		if self:Me(guid) then
			self:Flash(156109)
		end
	end

	function mod:ConvulsiveShadows(args)
		dispeller = self:Dispeller("magic", nil, args.spellId)
		if dispeller and isOnABoat() then
			boatTimers[args.spellId] = GetTime() + 56
			return
		end
		self:GetBossTarget(printTarget, 0.2, args.sourceGUID)
		if dispeller then
			self:Bar(args.spellId, 56)
		end
	end
end

function mod:DarkHunt(args)
	self:TargetMessageOld(args.spellId, args.destName, "yellow")
	self:TargetBar(args.spellId, 8, args.destName)
	--self:CDBar(args.spellId, 13) -- 13.39-15.89
end

-- Marak

do
	function mod:BloodRitual(args)
		if not self:LFR() then
			self:SecondaryIcon(args.spellId, args.destName)
		end
		if isOnABoat() then
			boatTimers[args.spellId] = GetTime() + 20
			return
		end
		self:TargetMessageOld(args.spellId, args.destName, "yellow", "alert", nil, nil, self:Tank())
		self:Bar(args.spellId, 20)
		if self:Me(args.destGUID) then
			self:TargetBar(args.spellId, 5, args.destName)
			self:Flash(args.spellId)
			self:Say(args.spellId, nil, nil, "Blood Ritual")
		end
	end

	function mod:BloodRitualRemoved(args)
		if not self:LFR() then
			self:SecondaryIcon(args.spellId)
		end
	end
end

do
	local targets = mod:NewTargetList()
	function mod:HeartseekerApplied(args)
		targets[#targets+1] = args.destName
		if self:Me(args.destGUID) then
			self:TargetBar(args.spellId, 5, args.destName)
			self:Flash(args.spellId)
			self:Say(args.spellId, nil, nil, "Heartseeker")
		end
		if self.db.profile.custom_off_heartseeker_marker then
			self:CustomIcon(false, args.destName, #targets)
		end
		if #targets == 1 then
			if isOnABoat() then
				boatTimers[args.spellId] = GetTime() + 70
			else
				self:CDBar(args.spellId, 70)
				self:ScheduleTimer("TargetMessageOld", 0.2, args.spellId, targets, "orange", "alert")
			end
		end
	end
	function mod:HeartseekerRemoved(args)
		if self.db.profile.custom_off_heartseeker_marker then
			self:CustomIcon(false, args.destName)
		end
	end
end

function mod:SanguineStrikes(args)
	self:MessageOld(args.spellId, "red")
end

function mod:Deaths(args)
	stopBars(args.mobId)
end

