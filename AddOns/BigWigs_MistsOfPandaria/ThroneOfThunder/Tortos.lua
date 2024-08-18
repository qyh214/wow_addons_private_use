--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Tortos", 1098, 825)
if not mod then return end
mod:RegisterEnableMob(67977)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.bats = -7140
	L.bats_desc = "Many bats. Handle it."
	L.bats_icon = 136686

	L.kick = "Kick"
	L.kick_desc = "Keep track of how many turtles can be kicked."
	L.kick_icon = 1766
	L.kick_message = "Kickable turtles: %d"
	L.kicked_message = "%s kicked! (%d remaining)"

	L.custom_off_turtlemarker = "Turtle Marker"
	L.custom_off_turtlemarker_desc = "Marks turtles using all raid icons, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r\n|cFFADFF2FTIP: If the raid has chosen you to turn this on, quickly mousing over all the turtles is the fastest way to mark them.|r"
	L.custom_off_turtlemarker_icon = 8

	L.no_crystal_shell = "NO Crystal Shell!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Locals
--

local quakeCounter = 0
local kickable = 0
local crystalTimer = nil

-- marking
local markableMobs = {}
local marksUsed = {}
local markTimer = nil

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{137633, "FLASH"},
		"custom_off_turtlemarker",
		136294, -7134, 133939, {136010, "TANK"}, 134920, {135251, "TANK"}, "bats",
		"kick", "berserk",
	}, {
		[137633] = "heroic",
		custom_off_turtlemarker = L.custom_off_turtlemarker,
		[136294] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	-- Heroic
	self:Log("SPELL_AURA_REMOVED", "CrystalShellRemoved", 137633)
	-- Normal
	self:Log("SPELL_CAST_START", "SnappingBite", 135251)
	self:Log("SPELL_CAST_START", "QuakeStomp", 134920)
	self:Log("SPELL_CAST_START", "FuriousStoneBreath", 133939)
	self:Log("SPELL_CAST_SUCCESS", "GrowingFury", 136010)
	self:Log("SPELL_AURA_APPLIED", "AddMarkedMob", 133974) -- spawn
	self:Log("SPELL_AURA_APPLIED", "ShellBlock", 133971) -- death
	self:Log("SPELL_AURA_REMOVED", "ShellBlockRemoved", 133971) -- kicked
	self:Log("SPELL_CAST_SUCCESS", "KickShell", 134031)
	self:Log("SPELL_CAST_START", "CallOfTortos", 136294)

	self:RegisterUnitEvent("UNIT_AURA", "ShellConcussionCheck", "boss1")
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "SummonBats", "boss1")

	self:Death("Win", 67977)
end

function mod:OnEngage()
	kickable = 0
	quakeCounter = 0
	self:Berserk(600)
	self:Bar("bats", 46, 136686) -- Summon Bats
	self:Bar(133939, 46) -- Furious Stone Breath
	self:Bar(136294, 21) -- Call of Tortos
	self:Bar(134920, 28, CL["count"]:format(self:SpellName(134920), 1)) -- Quake Stomp
	if self:Heroic() then
		crystalTimer = self:ScheduleRepeatingTimer("CrystalShell", 3, self:SpellName(137633))
	end
	-- marking
	if self.db.profile.custom_off_turtlemarker then
		self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	end
	markableMobs = {}
	marksUsed = {}
	markTimer = nil
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BreathUpdate(unit)
	local power = UnitPower(unit)
	if power == 50 then
		self:Bar(133939, 23)
	elseif power == 60 then
		self:Bar(133939, 18.4)
	elseif power == 70 then
		self:Bar(133939, 13.8)
	elseif power == 80 then
		self:Bar(133939, 9.2)
	end
end

function mod:CrystalShell(spellName)
	if self:UnitDebuff("player", spellName, 137633) or not UnitAffectingCombat("player") then -- diff 5
		mod:CancelTimer(crystalTimer)
		crystalTimer = nil
	else
		mod:MessageOld(137633, "blue", "info", L["no_crystal_shell"])
	end
end

function mod:CrystalShellRemoved(args)
	if not self:Me(args.destGUID) or not self.isEngaged then return end
	self:MessageOld(args.spellId, "blue", "alarm", CL["removed"]:format(args.spellName))
	if not self:Tank() then
		self:Flash(args.spellId)
		crystalTimer = self:ScheduleRepeatingTimer("CrystalShell", 3, args.spellName)
	end
end

function mod:SnappingBite(args)
	if self:Me(self:UnitGUID("boss1target")) then
		self:MessageOld(args.spellId, "yellow", self:Heroic() and "warning")
	end
	self:Bar(args.spellId, 7)
end

function mod:SummonBats(_, _, _, spellId)
	if spellId == 136685 then -- Summon Bats
		self:MessageOld("bats", "orange", self:Tank() and not UnitIsUnit("boss1target", "player") and "warning", 136686)
		self:Bar("bats", 46, 136686)
	end
end

function mod:QuakeStomp(args)
	quakeCounter = quakeCounter + 1
	self:MessageOld(args.spellId, "red", "alert", CL["count"]:format(args.spellName, quakeCounter))
	self:Bar(args.spellId, 47, CL["count"]:format(args.spellName, quakeCounter+1))
end

function mod:FuriousStoneBreath(args)
	self:MessageOld(args.spellId, "red", "long")
	self:Bar(args.spellId, 46) -- 45.8-48.2
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "BreathUpdate", "boss1") -- First is generally fine, register after
end

function mod:GrowingFury(args)
	self:MessageOld(args.spellId, "red", "alarm")
end

do
	local kicked = {}
	function mod:KickShell(args)
		if kicked[args.destGUID] then return end -- prevent multiple people kicking the same turtle from messing up the count
		kicked[args.destGUID] = true

		kickable = kickable - 1
		self:MessageOld("kick", "yellow", nil, L["kicked_message"]:format(self:ColorName(args.sourceName), kickable), args.spellId)
	end

	function mod:ShellBlockRemoved(args)
		kicked[args.destGUID] = nil
	end
end

do
	local scheduled = nil
	local function announceKickable()
		mod:MessageOld("kick", "yellow", nil, L["kick_message"]:format(kickable), 1766)
		scheduled = nil
	end
	function mod:ShellBlock(args)
		kickable = kickable + 1
		if not scheduled then
			scheduled = self:ScheduleTimer(announceKickable, 2)
		end

		markableMobs[args.destGUID] = nil
		for i=8, 1, -1 do
			if marksUsed[i] == args.destGUID then
				marksUsed[i] = nil
				break
			end
		end
	end
end

do
	local concussion = mod:SpellName(136431)
	local prev = 0
	function mod:ShellConcussionCheck(_, unit)
		local _, _, _, expires = self:UnitDebuff(unit, concussion, 136431) -- diff 5
		if expires and expires ~= prev then
			local t = GetTime()
			if prev < t then -- buff fell off
				self:MessageOld(-7134, "green", "info")
			end
			local duration = expires-t
			self:Bar(-7134, duration)
			prev = expires
		end
	end
end

function mod:CallOfTortos(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 60)
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
		if not continue or not mod.db.profile.custom_off_turtlemarker then
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
			if self.db.profile.custom_off_turtlemarker and not markTimer then
				markTimer = self:ScheduleRepeatingTimer(markMobs, 0.2)
			end
		end
	end
end

