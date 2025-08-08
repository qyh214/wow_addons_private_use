--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Lich King", 631, 1636)
if not mod then return end
mod:RegisterEnableMob(36597, 38995) -- The Lich King, Highlord Tirion Fordring
-- mod:SetEncounterID(1106)
-- mod:SetRespawnTime(30)
mod.toggleOptions = {72143, 70541, {70337, "ICON", "FLASH"}, 70372, {72762, "SAY", "ICON", "FLASH"}, 69409, 69037, "custom_on_valkyr_marker", {68980, "ICON", "FLASH"}, 70498, 68981, 69200, 72262, 72350, {73529, "SAY", "FLASH", "ICON"}, "warmup", "berserk"}
mod.optionHeaders = {
	[72143] = CL.phase:format(1),
	[72762] = CL.phase:format(2),
	[68980] = CL.phase:format(3),
	[68981] = "Transition",
	[73529] = "heroic",
	warmup = "general",
}
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local phase = 0
local frenzied = {}
local plagueTicks = {}
local valkyrs = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.warmup_trigger = "So the Light's vaunted justice has finally arrived"
	L.engage_trigger = "I'll keep you alive to witness the end, Fordring."

	L.horror_message = "Shambling Horror"
	L.horror_bar = "Next Horror"

	L.valkyr_message = "Val'kyr"
	L.valkyr_bar = "Next Val'kyr"
	L.valkyrhug_message = "Val'kyrs Hugged"

	L.cave_phase = "Cave Phase"
	L.last_phase_bar = "Last Phase"

	L.frenzy_bar = "%s frenzies!"
	L.frenzy_survive_message = "%s will survive after plague"
	L.frenzy_message = "Add frenzied!"
	L.frenzy_soon_message = "5sec to frenzy!"

	L.custom_on_valkyr_marker = "Val'kyr marker"
	L.custom_on_valkyr_marker_desc = "Mark the Val'kyr with {rt8}{rt7}{rt6}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over the Val'kyr is the fastest way to mark them.|r"
	L.custom_on_valkyr_marker_icon = 8
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	-- Phase 1
	self:Log("SPELL_CAST_START", "Infest", 70541)
	self:Log("SPELL_CAST_SUCCESS", "NecroticPlague", 70337, 70338)
	self:Log("SPELL_DISPEL", "PlagueScan", "*")
	self:Log("SPELL_SUMMON", "Horror", 70372)
	self:Log("SPELL_CAST_START", "Enrage", 72143)
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 28747)
	self:Log("SPELL_PERIODIC_DAMAGE", "PlagueTick", 70337, 70338)

	-- Phase 2
	self:Log("SPELL_CAST_SUCCESS", "SoulReaper", 69409)
	self:Log("SPELL_CAST_START", "DefileCast", 72762)
	self:Log("SPELL_DAMAGE", "DefileRun", 72754)
	self:Log("SPELL_MISSED", "DefileRun", 72754)
	self:Log("SPELL_SUMMON", "Valkyr", 69037)

	-- Phase 3
	self:Log("SPELL_CAST_SUCCESS", "HarvestSoul", 68980)
	self:Log("SPELL_AURA_REMOVED", "HSRemove", 68980)
	self:Log("SPELL_CAST_START", "VileSpirits", 70498)

	-- Transition phases
	self:Log("SPELL_CAST_START", "RemorselessWinter", 68981, 72259)
	self:Log("SPELL_CAST_SUCCESS", "RagingSpirit", 69200)
	self:Log("SPELL_CAST_START", "Quake", 72262)

	self:Log("SPELL_CAST_START", "FuryofFrostmourne", 72350)

	-- Hard Mode
	self:Log("SPELL_CAST_START", "ShadowTrap", 73539)

	self:Death("Win", 36597)

	self:BossYell("Warmup", L["warmup_trigger"])
	self:BossYell("Engage", L["engage_trigger"])
end

function mod:Warmup()
	self:Bar("warmup", 53, self.displayName, "achievement_boss_lichking")
end

function mod:OnEngage()
	self:SetStage(1)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	frenzied = {}
	plagueTicks = {}
	valkyrs = {}

	self:Berserk(900)
	self:Bar(70337, 31) -- Necrotic Plague
	self:CDBar(70372, 22, L["horror_bar"])
	phase = 1
	if self:Heroic() then
		self:Bar(73529, 16)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:PlagueTick(args)
	if not self:Heroic() then return end -- Doesn't apply on normal diff.
	-- Not ticking on a Shambling Horror, so bail early
	if self:MobId(args.destGUID) ~= 37698 then return end

	plagueTicks[args.destGUID] = (plagueTicks[args.destGUID] or 0) + 1
	if plagueTicks[args.destGUID] == 3 then
		plagueTicks[args.destGUID] = nil
		return
	end

	-- Search by full GUID, so we don't mistake one shambler for another
	local unitId = self:GetUnitIdByGUID(args.destGUID)
	if not unitId then return end

	-- Shambler is already frenzied, will it die from the plague or endure
	-- for a longer period?
	if frenzied[args.destGUID] then
		local damageLeft = (3 - plagueTicks[args.destGUID]) * args.extraSpellId
		local hp = UnitHealth(unitId)
		if hp > damageLeft then
			self:MessageOld(70372, "yellow", nil, L["frenzy_survive_message"]:format(args.destName), 72143)
		end
	else
		local hp, max = UnitHealth(unitId), UnitHealthMax(unitId)
		if not max or max == 0 then return end
		local nextTickHP = hp - args.extraSpellId
		-- Will the shambler die from the next tick?
		if nextTickHP <= 0 then return end
		local percentHp = (nextTickHP / max) * 100
		-- This sucker will frenzy in 5 seconds
		if percentHp < 21 then
			self:MessageOld(70372, "red", "info", L["frenzy_soon_message"], 72143)
			self:Bar(70372, 5, L["frenzy_bar"]:format(args.destName), 72143)
		end
	end
end

function mod:Frenzy(args)
	frenzied[args.destGUID] = true
	self:MessageOld(70372, "red", "long", L["frenzy_message"], 72143)
end

function mod:Horror(args)
	self:MessageOld(70372, "yellow", nil, L["horror_message"])
	self:CDBar(70372, 60, L["horror_bar"])
end

function mod:FuryofFrostmourne()
	self:StopBar(72762) -- Defile
	self:StopBar(69409) -- Soul Reaper
	self:StopBar(70498) -- Vile Spirits
	self:StopBar(68980) -- Harvest Soul
	self:Bar(72350, 160, L["last_phase_bar"])
end

function mod:Infest(args)
	self:MessageOld(70541, "orange")
	self:CDBar(70541, 22)
end

function mod:VileSpirits(args)
	self:MessageOld(70498, "orange")
	self:CDBar(70498, 30.5)
end

function mod:SoulReaper(args)
	self:TargetMessageOld(69409, args.destName, "blue", "alert")
	self:CDBar(69409, 30)
end

function mod:NecroticPlague(args)
	if self:Me(args.destGUID) then
		self:Flash(70337)
	end
	self:TargetMessageOld(70337, args.destName, "blue", "alert")
	self:Bar(70337, 30)
	self:SecondaryIcon(70337, args.destName)
end

do
	local function scanRaid()
		for unit in mod:IterateGroup() do
			local debuffed, _, _, expire = mod:UnitDebuff(unit, mod:SpellName(70337), 70337, 70338) -- Necrotic Plague, both were on 25N
			if debuffed and (expire - GetTime()) > 13 then
				if UnitIsUnit(unit, "player") then
					mod:Flash(70337)
				end
				local player = mod:UnitName(unit)
				mod:TargetMessageOld(70337, player, "blue", "alert")
				mod:SecondaryIcon(70337, player)
			end
		end
	end
	function mod:PlagueScan()
		self:ScheduleTimer(scanRaid, 0.8)
	end
end

function mod:Enrage(args)
	if self:Dispeller("enrage", true) then
		self:MessageOld(72143, "yellow", "alert")
		self:CDBar(72143, 21)
	else
		self:MessageOld(72143, "yellow")
	end
end

function mod:RagingSpirit(args)
	self:TargetMessageOld(69200, args.destName, "blue", "alert")
	self:Bar(69200, 23) -- Raging Spirit
end

do
	local prev = 0
	function mod:DefileRun(args)
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			if self:Me(args.destGUID) then
				self:MessageOld(72762, "blue", "info", CL["you"]:format(args.spellName))
				self:Flash(72762)
			end
		end
	end
end

do
	-- valkyr marking
	local count = 8
	function mod:UNIT_TARGET(_, firedUnit)
		local unit = firedUnit and firedUnit.."target" or "mouseover"
		local guid = self:UnitGUID(unit)
		if valkyrs[guid] then
			self:CustomIcon(false, unit, valkyrs[guid])
			valkyrs[guid] = nil
		end
		if not next(valkyrs) then
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:UnregisterEvent("UNIT_TARGET")
		end
	end

	local hugged, prev = mod:NewTargetList(), 0
	local function ValkyrHugCheck()
		count = 8
		for unit in mod:IterateGroup() do
			if UnitInVehicle(unit) then
				hugged[#hugged + 1] = mod:UnitName(unit)
			end
		end
		mod:TargetMessageOld(69037, hugged, "orange", nil, L["valkyrhug_message"], 71844)
	end

	function mod:Valkyr(args)
		valkyrs[args.destGUID] = count
		count = count - 1

		local t = GetTime()
		if t-prev > 4 then
			prev = t
			self:MessageOld(69037, "yellow", nil, L["valkyr_message"], 71844)
			self:Bar(69037, 46, L["valkyr_bar"], 71844)
			self:ScheduleTimer(ValkyrHugCheck, 6.1)
			if self.db.profile.custom_on_valkyr_marker then
				self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", "UNIT_TARGET")
				self:RegisterEvent("UNIT_TARGET")
			end
		end
	end
end

function mod:HarvestSoul(args)
	if self:Heroic() then
		self:StopBar(72762) -- Defile
		self:StopBar(69409) -- Soul Reaper
		self:StopBar(69200) -- Raging Spirit
		self:Bar(68980, 50, L["cave_phase"])
		self:Bar(68980, 105)
	else
		if self:Me(args.destGUID) then
			self:Flash(68980)
		end
		self:TargetMessageOld(68980, args.destName, "yellow")
		self:Bar(68980, 75)
		self:SecondaryIcon(68980, args.destName)
	end
end

function mod:HSRemove(args)
	self:SecondaryIcon(68980)
end

function mod:RemorselessWinter(args)
	phase = phase + 1
	self:SetStage(phase) -- Phase 2, and 4 is transition phases
	self:StopBar(L["valkyr_bar"])
	self:StopBar(L["horror_bar"])
	self:StopBar(70337) -- Necrotic Plague
	self:StopBar(70541) -- Infest
	self:StopBar(72762) -- Defile
	self:StopBar(69409) -- Soul Reaper
	self:StopBar(73529) -- Shadow Trap

	self:MessageOld(68981, "orange", "long", CL["cast"]:format(args.spellName))
	self:Bar(72262, 62) -- Quake
	self:Bar(69200, 15) -- Raging Spirit
end

function mod:Quake(args)
	phase = phase + 1
	self:SetStage(phase)
	self:StopBar(69200) -- Raging Spirit
	self:MessageOld(72262, "orange", "long", CL["cast"]:format(args.spellName))
	self:Bar(72762, 37) -- Defile
	self:CDBar(69409, 39) -- Soul Reaper
	if phase == 3 then
		self:CDBar(70541, 13) -- Infest
		self:Bar(69037, 24, L["valkyr_bar"], 71844)
	elseif phase == 5 then
		self:CDBar(70498, 21) -- Vile Spirits
		self:Bar(68980, 12) -- Harvest Soul
	end
end

do
	local handle = nil
	local function scanTarget()
		local bossId = mod:GetUnitIdByGUID(36597)
		if not bossId then return end
		local bossTarget = bossId.."target"
		if UnitExists(bossTarget) then
			if UnitIsUnit(bossTarget, "player") then
				mod:Flash(72762)
				mod:Say(72762, nil, nil, "Defile")
			end
			local target = mod:UnitName(bossTarget)
			mod:TargetMessageOld(72762, target, "red", "alert")
			mod:PrimaryIcon(72762, target)
		end
		handle = nil
	end
	function mod:DefileCast(args)
		self:CancelTimer(handle)
		self:Bar(72762, 32)
		handle = self:ScheduleTimer(scanTarget, 0.01, args.spellName)
	end
end

do
	local scheduled = nil
	local function trapTarget()
		scheduled = nil
		local bossId = mod:GetUnitIdByGUID(36597)
		if not bossId then return end
		local bossTarget = bossId.."target"
		if UnitExists(bossTarget) then
			if UnitIsUnit(bossTarget, "player") then
				mod:Flash(73529)
				mod:Say(73529, nil, nil, "Shadow Trap")
			end
			local target = mod:UnitName(bossTarget)
			mod:TargetMessageOld(73529, target, "yellow")
			mod:PrimaryIcon(73529, target)
		end
	end
	function mod:ShadowTrap(args)
		if not scheduled then
			scheduled = self:ScheduleTimer(trapTarget, 0.01)
			self:Bar(73529, 16)
		end
	end
end

