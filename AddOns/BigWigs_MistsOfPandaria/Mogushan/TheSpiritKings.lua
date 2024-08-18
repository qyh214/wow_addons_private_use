
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Spirit Kings", 1008, 687)
if not mod then return end
mod:RegisterEnableMob(
	60701, 61421, -- Zian of the Endless Shadows
	60708, 61429, -- Meng the Demented
	60709, 61423, -- Qiang the Merciless
	60710, 61427 -- Subetai the Swift
)
mod:SetEncounterID(1436)

--------------------------------------------------------------------------------
-- Locals
--

local spellReflect = mod:SpellName(69901)

local meng = mod:SpellName(-5835)
local qiang = mod:SpellName(-5841)
local subetai = mod:SpellName(-5846)
local zian = mod:SpellName(-5852)

local bossActivated = {}
local bossWarned = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.bosses = "Bosses"
	L.bosses_desc = "Warnings for when a boss becomes active."

	L.shield_removed = "Shield removed! (%s)"
	L.casting_shields = "Casting shields"
	L.casting_shields_desc = "Warnings for when shields are casted for all bosses."
	L.casting_shields_icon = 871

	L.cowardice = "{-5838} (".. spellReflect ..")"
	L.cowardice_desc = -5838
	L.cowardice_icon = 117756
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		117921, 119521, 117910, {117961, "FLASH"}, -- Qiang
		{118303, "SAY", "ICON"}, {117697, "FLASH"}, -- Zian
		118047, 118122, 118094, {118162, "FLASH"}, -- Subetai
		"cowardice", 117708, {117837, "DISPEL"}, -- Meng
		"bosses", "casting_shields", "berserk",
	}, {
		[117921] = -5841,
		[118303] = -5852,
		[118047] = -5846,
		cowardice = -5835,
		bosses = "general",
	}
end

function mod:OnBossEnable()
	-- Qiang
	self:Log("SPELL_CAST_START", "Annihilate", 119521, 117948) -- Heroic, Norm/LFR
	self:Log("SPELL_CAST_SUCCESS", "FlankingOrders", 117910)
	self:Log("SPELL_CAST_START", "ImperviousShield", 117961)
	self:Log("SPELL_AURA_REMOVED", "ShieldRemoved", 117961)
	self:Log("SPELL_DAMAGE", "MassiveAttack", 117921)
	self:Log("SPELL_MISSED", "MassiveAttack", 117921)

	-- Zian
	self:Log("SPELL_AURA_APPLIED", "Fixate", 118303)
	self:Log("SPELL_CAST_START", "ShieldofDarkness", 117697)
	self:Log("SPELL_AURA_REMOVED", "ShieldRemoved", 117697)

	-- Subetai
	self:Log("SPELL_CAST_SUCCESS", "Pillage", 118047)
	self:Log("SPELL_AURA_APPLIED", "PinnedDown", 118135)
	self:Log("SPELL_CAST_START", "SleightofHand", 118162)
	self:Log("SPELL_CAST_START", "Volley", 118094)

	-- Meng
	self:Log("SPELL_CAST_START", "MaddeningShout", 117708)
	self:Log("SPELL_AURA_APPLIED", "CowardiceApplied", 117756)
	self:Log("SPELL_AURA_REMOVED", "CowardiceRemoved", 117756)
	self:Log("SPELL_AURA_APPLIED", "Delirious", 117837)

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1", "boss2", "boss3", "boss4")
end

function mod:OnEngage()
	self:Berserk(600)
	bossActivated = {}
	if self:Heroic() then
		self:Bar(117961, 40) -- Impervious Shield
		self:RegisterUnitEvent("UNIT_HEALTH", "BossSwap", "boss1", "boss2", "boss3", "boss4")
		bossWarned = 0
	end
	self:Bar(119521, 10) -- Annihilate
	self:Bar(117910, 25) -- Flanking Orders
	self:MessageOld("bosses", "green", nil, qiang, 117920) -- Massive Attack icon
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "BossCheck")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

local function isBossActiveById(bossId, bossIdTwo)
	for i=1, 5 do
		local unitId = ("boss%d"):format(i)
		if UnitExists(unitId) then
			local id = mod:MobId(mod:UnitGUID(unitId))
			if id == bossId or id == bossIdTwo then
				return true
			end
		end
	end
	return false
end

-- Meng
do
	local prevPower = 0
	function mod:CowardiceApplied()
		prevPower = 0
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "SpellReflectWarn", "boss1", "boss2", "boss3", "boss4")
	end
	function mod:CowardiceRemoved(args)
		self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss1", "boss2", "boss3", "boss4")
		prevPower = 0
		self:MessageOld("cowardice", "green", nil, CL["over"]:format(spellReflect), L.cowardice_icon)
	end
	function mod:SpellReflectWarn(_, unitId)
		local id = self:MobId(self:UnitGUID(unitId))
		if id == 60708 or id == 61429 then
			local power = UnitPower(unitId)
			if power > 74 and prevPower == 0 then
				prevPower = 75
				self:MessageOld("cowardice", "yellow", nil, ("%s (%d%%)"):format(spellReflect, power), L.cowardice_icon)
			elseif power > 84 and prevPower == 75 then
				prevPower = 85
				self:MessageOld("cowardice", "orange", nil, ("%s (%d%%)"):format(spellReflect, power), L.cowardice_icon)
			elseif power > 89 and prevPower == 85 then
				prevPower = 90
				self:MessageOld("cowardice", "blue", nil, ("%s (%d%%)"):format(spellReflect, power), L.cowardice_icon)
			elseif power > 92 and prevPower == 90 then
				prevPower = 93
				self:MessageOld("cowardice", "blue", nil, ("%s (%d%%)"):format(spellReflect, power), L.cowardice_icon)
			elseif power > 96 and prevPower == 93 then
				prevPower = 97
				self:MessageOld("cowardice", "blue", nil, ("%s (%d%%)"):format(spellReflect, power), L.cowardice_icon)
			end
		end
	end
end

function mod:MaddeningShout(args)
	self:MessageOld(args.spellId, "orange", "alarm")
	self:Bar(args.spellId, isBossActiveById(60708, 61429) and 46.7 or 76)
end

function mod:Delirious(args)
	if self:Dispeller("enrage", true, args.spellId) then
		self:MessageOld(args.spellId, "orange", "alert")
		self:Bar(args.spellId, 20)
	end
end

-- Subetai
do
	local pinnedTargets, scheduled = mod:NewTargetList(), nil
	local function warnPinned(spellName)
		mod:TargetMessageOld(118122, pinnedTargets, "red", "alarm", spellName)
		scheduled = nil
	end
	function mod:PinnedDown(args)
		pinnedTargets[#pinnedTargets + 1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(warnPinned, 0.1, args.spellName)
		end
	end
end

function mod:Pillage(args)
	self:MessageOld(args.spellId, "orange", "alarm")
	if isBossActiveById(60710, 61427) then
		self:Bar(args.spellId, 40)
	else
		self:Bar(args.spellId, 75.5)
	end
end

function mod:Volley(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 41)
end

function mod:SleightofHand(args)
	self:MessageOld(args.spellId, "red", "alert")
	self:Bar(args.spellId, 42)
	self:Flash(args.spellId)
end

-- Zian
function mod:Fixate(args)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", "info")
		self:Say(args.spellId, args.spellName, nil, "Fixate")
	end
end

function mod:ShieldofDarkness(args)
	self:MessageOld(args.spellId, "red", "alert")
	self:Bar(args.spellId, 42)
	self:Bar("casting_shields", 2, CL["cast"]:format(args.spellName), args.spellId)
	self:Flash(args.spellId)
end

-- Qiang
function mod:FlankingOrders(args)
	self:MessageOld(args.spellId, "yellow", "long")
	if isBossActiveById(60709, 61423) then
		self:Bar(args.spellId, self:Heroic() and 45.7 or 41)
	else
		self:Bar(args.spellId, 75)
	end
end

function mod:Annihilate(args)
	self:MessageOld(119521, "orange", "alarm")
	self:Bar(119521, self:Difficulty() == 6 and 32 or 39)
	self:Bar(117921, 8) -- Massive Attack
end

function mod:MassiveAttack(args)
	self:Bar(args.spellId, 5)
end

function mod:ImperviousShield(args)
	self:MessageOld(args.spellId, "red", "alert")
	self:Bar(args.spellId, self:Difficulty() == 5 and 62 or 42)
	self:Bar("casting_shields", 2, CL["cast"]:format(args.spellName), args.spellId)
	self:Flash(args.spellId)
end

function mod:ShieldRemoved(args)
	self:MessageOld(args.spellId, "green", "info", L["shield_removed"]:format(args.spellName))
end

function mod:BossCheck()
	for i=1, 5 do
		local unitId = ("boss%d"):format(i)
		if UnitExists(unitId) then
			local id = self:MobId(self:UnitGUID(unitId))
			-- this is needed because of heroic
			if (id == 60701 or id == 61421) and not bossActivated[60701] then -- Zian
				bossActivated[60701] = true
				if self:Heroic() then
					self:Bar(117697, 40) -- Shield of Darkness
				end
				self:MessageOld("bosses", "green", nil, zian, 117628) -- Shadow Blast icon
			elseif (id == 60710 or id == 61427) and not bossActivated[60710] then -- Subetai
				bossActivated[60710] = true
				if self:Heroic() then
					self:Bar(118162, 15) -- Sleight of Hand
				end
				self:Bar(118094, 5) -- Volley
				self:Bar(118047, 26) -- Pillage
				self:Bar(118122, self:Heroic() and 40 or 15) -- Rain of Arrows
				self:MessageOld("bosses", "green", nil, subetai, 118122) -- Rain of Arrows icon
			elseif (id == 60708 or id == 61429) and not bossActivated[60708] then -- Meng
				bossActivated[60708] = true
				self:Bar(117708, self:Heroic() and 40 or 21) -- Maddening Shout
				if self:Heroic() then
					self:Bar(117837, 20) -- Delirious
				end
				self:MessageOld("bosses", "green", nil, meng, 117833) -- Crazy Thought icon
			end
		end
	end
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, unitId, _, spellId)
	if spellId == 118205 then -- Inactive Visual
		local id = self:MobId(self:UnitGUID(unitId))
		if (id == 60709 or id == 61423) then -- Qiang
			self:StopBar(119521) -- Annihilate
			self:StopBar(117961) -- Impervious Shield
			self:StopBar(117921) -- Massive Attack
			self:Bar(117910, 30) -- Flanking Orders
		elseif (id == 60701 or id == 61421) then -- Zian
			self:StopBar(117697) -- Shield of Darkness
		elseif (id == 60710 or id == 61427) then -- Subetai
			self:StopBar(118162) -- Sleight of Hand
			self:StopBar(118094) -- Volley
			self:StopBar(118122) -- Rain of Arrows
			self:StopBar(118047) -- Pillage
			self:Bar(118047, 30) -- Pillage
		elseif (id == 60708 or id == 61429) then -- Meng
			self:StopBar(117837)
			self:Bar(117708, 30) -- Maddening Shout
		end
	elseif spellId == 118121 then -- Rain of Arrows for Pinned Down
		if self:Heroic() then
			self:Bar(118122, 41) -- Rain of Arrows
		else
			self:Bar(118122, 51) -- Rain of Arrows
		end
	end
end

function mod:BossSwap(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 38 then -- next boss at 30% (Qiang -> Subetai -> Zian -> Meng)
		local id = self:MobId(self:UnitGUID(unit))
		if bossWarned == 0 and (id == 60709 or id == 61423) then -- Qiang
			self:MessageOld("bosses", "green", "info", CL["soon"]:format(subetai), false)
			bossWarned = 1
		elseif bossWarned == 1 and (id == 60710 or id == 61427) then -- Subetai
			self:MessageOld("bosses", "green", "info", CL["soon"]:format(zian), false)
			bossWarned = 2
		elseif bossWarned == 2 and (id == 60701 or id == 61421) then -- Zian
			self:MessageOld("bosses", "green", "info", CL["soon"]:format(meng), false)
			bossWarned = 3
			self:UnregisterUnitEvent(event, "boss1", "boss2", "boss3", "boss4")
		end
	end
end

