
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lei Shi", 996, 729)
if not mod then return end
mod:RegisterEnableMob(62983, 63275) -- Lei Shi, Corrupted Protector

--------------------------------------------------------------------------------
-- Locals
--

local hiding = nil
local nextProtectWarning = 85
local nextSpecial = 0

-- marking
local markableMobs = {}
local marksUsed = {}
local markTimer = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.hp_to_go = "%d%% to go"

	L.special = "Next special ability"
	L.special_desc = "Warning for next special ability"
	L.special_icon = 123263 -- I know it is icon for "Afraid", but since we don't warn for that, might as well use it

	L.custom_off_addmarker = "Protector Marker"
	L.custom_off_addmarker_desc = "Marks Animated Protectors during Lei Shi's Protect, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over all of the Protectors is the fastest way to mark them.|r"
	L.custom_off_addmarker_icon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{123705, "PROXIMITY"},
		"custom_off_addmarker",
		{123121, "PROXIMITY", "TANK"}, 123461, 123250, 123244, "special", "berserk",
	}, {
		[123705] = "heroic",
		custom_off_addmarker = L.custom_off_addmarker,
		[123121] = "general",
	}
end

function mod:VerifyEnable(unit)
	local hp = self:GetHealth(unit)
	if hp > 8 and UnitCanAttack("player", unit) then
		return true
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "GetAwayApplied", 123461)
	self:Log("SPELL_AURA_REMOVED", "GetAwayRemoved", 123461)
	self:Log("SPELL_AURA_APPLIED", "Protect", 123250)
	self:Log("SPELL_AURA_REMOVED", "ProtectRemoved", 123250)
	self:Log("SPELL_CAST_START", "Hide", 123244)
	self:Log("SPELL_AURA_APPLIED", "Spray", 123121)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Spray", 123121)
	self:Log("SPELL_AURA_APPLIED", "ScaryFog", 123705)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ScaryFog", 123705)
	self:Log("SPELL_AURA_REMOVED", "ScaryFogRemoved", 123705)
	self:Log("SPELL_AURA_APPLIED", "AddMarkedMob", 123505) -- Protect

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "EngageCheck") -- to detect her coming out of hide
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "Kill", "boss1")
end

function mod:OnEngage(diff)
	hiding = nil
	nextProtectWarning = 85
	markableMobs = {}
	marksUsed = {}
	markTimer = nil
	self:Bar("special", 32, L["special"], L.special_icon)
	self:RegisterUnitEvent("UNIT_HEALTH", "HealthCheck", "boss1")
	self:Berserk(self:Heroic() and 420 or 600)
	self:OpenProximity(123121, 4)
	-- marking
	if self.db.profile.custom_off_addmarker then
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:EngageCheck()
	self:CheckBossStatus()
	if hiding then
		hiding = nil
		self:MessageOld(123244, "yellow", nil, CL["over"]:format(self:SpellName(123244))) -- Hide
		self:Bar("special", 32, L["special"], L.special_icon)
		nextSpecial = GetTime() + 32
	end
end

do
	local scheduled = nil
	local function reportFog(spellName)
		local highestStack, highestStackPlayer = 0
		for unit in mod:IterateGroup() do
			local _, stack, duration = mod:UnitDebuff(unit, 123705)
			if stack and stack > highestStack and duration > 0 then
				highestStack = stack
				highestStackPlayer = unit
			end
		end
		local player = mod:UnitName(highestStackPlayer)
		mod:StackMessageOld(123705, player, highestStack, "yellow")
		scheduled = nil
	end

	function mod:ScaryFog(args)
		if self:Me(args.destGUID) and not self:Tank() then
			self:OpenProximity(args.spellId, 4)
		end
		if not scheduled then
			self:Bar(args.spellId, 19)
			scheduled = self:ScheduleTimer(reportFog, 0.2, args.spellName)
		end
	end
end

function mod:ScaryFogRemoved(args)
	if self:Me(args.destGUID) and not self:Tank() then
		self:CloseProximity(123705)
	end
end

function mod:Spray(args)
	local amount = args.amount or 1
	if UnitIsPlayer(args.destName) and amount > (self:LFR() and 11 or 5) and amount % 2 == 0 then
		self:StackMessageOld(args.spellId, args.destName, amount, "orange", "info")
	end
end

function mod:Hide(args)
	hiding = true
	self:MessageOld(args.spellId, "yellow")
end

do
	local getAwayStartHP
	function mod:GetAwayApplied(args)
		if UnitHealthMax("boss1") > 0 then
			getAwayStartHP = self:GetHealth("boss1")
			self:MessageOld(args.spellId, "red", "alarm")
		end
	end
	function mod:GetAwayRemoved()
		getAwayStartHP = nil
		self:Bar("special", 32, L["special"], L.special_icon)
		nextSpecial = GetTime() + 32
	end

	local prev = 0
	local lastHpToGo
	function mod:HealthCheck(_, unit)
		local hp = self:GetHealth(unit)
		if hp < nextProtectWarning then
			self:MessageOld(123250, "green", nil, CL["soon"]:format(self:SpellName(123250))) -- Protect
			nextProtectWarning = hp - 20
			if nextProtectWarning < 20 then
				nextProtectWarning = 0
			end
		end
		if getAwayStartHP then
			local t = GetTime()
			if t-prev > 3 then -- warn max once every 3 sec
				prev = t
				local hpToGo = math.ceil(4 - (getAwayStartHP - hp))
				if lastHpToGo ~= hpToGo and hpToGo > 0 then
					lastHpToGo = hpToGo
					self:MessageOld(123461, "green", nil, L["hp_to_go"]:format(hpToGo))
				end
			end
		end
	end
end

function mod:Protect(args)
	self:MessageOld(args.spellId, "red", "alarm")
	self:StopBar(L["special"]) --stop the bar since it's pretty likely the cd will expire during protect
end

function mod:ProtectRemoved()
	-- marking
	markableMobs = {}
	marksUsed = {}

	local left = nextSpecial - GetTime()
	if left > 4 then -- restart the bar if there are more than a few seconds left on the special's cd
		self:Bar("special", left, L["special"], L.special_icon)
	else
		self:MessageOld("special", "yellow", nil, CL["soon"]:format(L["special"]), L.special_icon)
	end
end

function mod:Kill(_, _, _, spellId)
	if spellId == 127524 then -- Transform
		self:Win()
	end
end


-- marking
do
	local function setMark(unit, guid)
		for mark=8, 1, -1 do
			if not marksUsed[mark] then
				mod:CustomIcon(false, unit, mark)
				markableMobs[guid] = "marked"
				marksUsed[mark] = guid
				return
			end
		end
	end

	local function markMobs()
		local continue
		for guid in next, markableMobs do
			if markableMobs[guid] == true then
				local unit = mod:GetUnitIdByGUID(guid)
				if unit then
					setMark(unit, guid)
				else
					continue = true
				end
			end
		end
		if not continue or not mod.db.profile.custom_off_addmarker then
			mod:CancelTimer(markTimer)
			markTimer = nil
		end
	end

	function mod:UPDATE_MOUSEOVER_UNIT()
		local guid = self:UnitGUID("mouseover")
		if guid and markableMobs[guid] == true then
			setMark("mouseover", guid)
		end
	end

	function mod:AddMarkedMob(args)
		if not markableMobs[args.destGUID] then
			markableMobs[args.destGUID] = true
			if self.db.profile.custom_off_addmarker and not markTimer then
				markTimer = self:ScheduleRepeatingTimer(markMobs, 0.2)
			end
		end
	end
end

