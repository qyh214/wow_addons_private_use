
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Council of Elders", 1098, 816)
if not mod then return end
mod:RegisterEnableMob(69132, 69131, 69134, 69078) -- High Priestess Mar'li, Frost King Malakk, Kazra'jin, Sul the Sandcrawler

--------------------------------------------------------------------------------
-- Locals
--
local bossDead = 0
local posessHPStart = 0
local frostBiteStart, bitingColdStart = nil, nil
local sandGuyDead = nil
local fixated = mod:SpellName(40415)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.priestess_adds = "Priestess adds"
	L.priestess_adds_desc = "Warnings for when High Priestess Mar'li starts to summon adds."
	L.priestess_adds_icon = "inv_misc_tournaments_banner_troll"
	L.priestess_adds_message = "Priestess add"

	L.custom_on_markpossessed = "Mark Possessed Boss"
	L.custom_on_markpossessed_desc = "Mark the possessed boss with a skull, requires promoted or leader."
	L.custom_on_markpossessed_icon = 8

	L.priestess_heal = "%s was healed!"
	L.assault_stun = "Tank Stunned!"
	L.assault_message = "Assault"
	L.full_power = "Full power"
	L.hp_to_go_power = "%d%% HP to go! (Power: %d)"
	L.hp_to_go_fullpower = "%d%% HP to go! (Full power)"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"priestess_adds", 137203, {137350, "FLASH"}, -- High Priestess Mar'li
		{-7062, "FLASH"}, 136878, {136857, "FLASH", "DISPEL"}, 136894, -- Sul the Sandcrawler
		{137122, "FLASH"}, -- Kazra'jin
		{-7054, "TANK_HEALER"}, {136992, "ICON", "SAY", "PROXIMITY"}, 136990, 137084, {137085, "FLASH"}, -- Frost King Malakk
		136442, "custom_on_markpossessed", {137650, "FLASH"}, "proximity", "berserk",
	}, {
		["priestess_adds"] = -7050,
		[-7062] = -7049,
		[137122] = -7048,
		[-7054] = -7047,
		[136442] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	-- High Priestess Mar'li
	self:Log("SPELL_CAST_START", "PriestessAdds", 137203, 137350, 137891) -- Blessed, Shadowed, Twisted Fate
	self:Log("SPELL_CAST_SUCCESS", "BlessedLoaSpirit", 137203)
	self:Log("SPELL_CAST_SUCCESS", "BlessedGift", 137303) -- Spirit heals a boss
	self:Log("SPELL_AURA_APPLIED", "MarkedSoul", 137359)
	self:Log("SPELL_AURA_REMOVED", "MarkedSoulRemoved", 137359)
	-- Sul the Sandcrawler
	self:Log("SPELL_CAST_SUCCESS", "Quicksand", 136521)
	self:Log("SPELL_AURA_APPLIED", "QuicksandApplied", 136860)
	self:Log("SPELL_AURA_APPLIED", "Ensnared", 136878)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Ensnared", 136878)
	self:Log("SPELL_AURA_APPLIED", "Entrapped", 136857)
	self:Log("SPELL_CAST_START", "Sandstorm", 136894)
	-- Kazra'jin
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "RecklessCharge", "boss1", "boss2", "boss3", "boss4", "boss5")
	self:Log("SPELL_DAMAGE", "RecklessChargeDamage", 137133)
	--Frost King Malakk
	self:Log("SPELL_AURA_REMOVED", "FrostbiteRemoved", 136990, 136922)
	self:Log("SPELL_AURA_APPLIED", "FrostbiteApplied", 136990, 136922)
	self:Log("SPELL_AURA_APPLIED", "BitingColdApplied", 136992)
	self:Log("SPELL_AURA_REMOVED", "BitingColdRemoved", 136992)
	self:Log("SPELL_CAST_START", "FrigidAssaultStart", 136904)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FrigidAssault", 136903)
	self:Log("SPELL_AURA_APPLIED", "FrigidAssaultStun", 136910)
	-- General
	self:Log("SPELL_AURA_APPLIED_DOSE", "ShadowedSoul", 137650) -- Heroic
	self:Log("SPELL_AURA_APPLIED", "PossessedApplied", 136442)
	self:Log("SPELL_AURA_REMOVED", "PossessedRemoved", 136442)

	self:Death("BlessedLoaDeath", 69480) -- Blessed Loa Spirit
	self:Death("Deaths", 69132, 69131, 69134, 69078) -- Priestess, Frost King, Kazra'jin, Sandcrawler
end

function mod:OnEngage()
	self:Berserk(self:LFR() and 720 or 600) -- XXX assumed. 12 min or higher on LFR, prob 15
	bossDead = 0
	if not self:LFR() then
		self:OpenProximity("proximity", 7) -- for Quicksand
	end
	self:Bar("priestess_adds", 27, L["priestess_adds_message"], L.priestess_adds_icon)
	self:Bar(-7062, 7) -- Quicksand
	self:Bar(136990, 9.7) -- Frostbite -- might be 7.5?
	frostBiteStart, bitingColdStart = nil, nil
	sandGuyDead = nil
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- High Priestess Mar'li

function mod:MarkedSoul(args)
	self:TargetMessageOld(137350, args.destName, "orange", "alert", fixated)
	self:TargetBar(137350, 20, args.destName, fixated)
	if self:Me(args.destGUID) then
		self:Flash(137350)
	end
end

function mod:MarkedSoulRemoved(args)
	self:StopBar(fixated, args.destName)
end

function mod:BlessedLoaSpirit(args)
	local lowest, lowestHP = "", 1
	for i=1,5 do
		local boss = ("boss%d"):format(i)
		local mobId = self:MobId(self:UnitGUID(boss))
		if mobId == 69134 or mobId == 69078 or mobId == 69131 then -- Kazra'jin, Sandcrawler, Frost King
			local hp = UnitHealth(boss) / UnitHealthMax(boss)
			if hp > 0 and hp < lowestHP then
				lowest = boss
				lowestHP = hp
			end
		end
	end
	self:MessageOld(args.spellId, "yellow", nil, CL["other"]:format(fixated, self:UnitName(lowest) or "???"))
	self:Bar(args.spellId, 20, CL["other"]:format(fixated, args.spellName))
end

function mod:BlessedGift(args)
	if not self:LFR() then
		self:MessageOld("priestess_adds", "red", "alarm", L["priestess_heal"]:format(args.destName), args.spellId)
	end
	self:StopBar(CL["other"]:format(fixated, self:SpellName(137203)))
end

function mod:PriestessAdds(args)
	self:MessageOld("priestess_adds", "red", "alarm", args.spellId)
	self:Bar("priestess_adds", 33, L["priestess_adds_message"], L.priestess_adds_icon)
end

-- Sul the Sandcrawler

function mod:Sandstorm(args)
	self:Bar(args.spellId, 38)
	self:MessageOld(args.spellId, "orange", "alert")
end

function mod:Entrapped(args)
	if self:Me(args.destGUID) then
		self:Flash(136857)
		self:MessageOld(136857, "blue", "info")
	elseif self:Dispeller("magic", nil, 136857) then
		self:TargetMessageOld(136857, args.destName, "yellow", nil, nil, nil, true)
	end
end

function mod:Ensnared(args)
	if self:Me(args.destGUID) then
		self:MessageOld(136878, "yellow", nil, CL["count"]:format(args.spellName, args.amount or 1))
	end
end

function mod:Quicksand(args)
	self:Bar(-7062, 33, args.spellId)
end

function mod:QuicksandApplied(args)
	if self:Me(args.destGUID) then
		self:MessageOld(-7062, "blue", "info", CL["underyou"]:format(args.spellName))
		self:Flash(-7062)
	end
end

-- Kazra'jin

function mod:RecklessCharge(_, unit, _, spellId)
	if spellId == 137107 and self:UnitBuff(unit, 136442) then
		self:Bar(137122, 21) -- Show timer when possessed
	end
end

do
	local prev = 0
	function mod:RecklessChargeDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(137122, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(137122)
		end
	end
end

--Frost King Malakk

do
	-- ugly UNIT_AURA polling
	local hasFrostbite, hasChilledToTheBone, someoneHasBodyHeat = nil, nil, nil
	local bodyHeat, chilledToTheBone = mod:SpellName(137084), mod:SpellName(137085)
	local function reset(chill) -- one unblocking function to rule them all
		if chill then hasChilledToTheBone = nil
		else someoneHasBodyHeat = nil end
	end
	function mod:UNIT_AURA(_, unit)
		if hasFrostbite and not someoneHasBodyHeat then
			local _, _, duration = self:UnitDebuff(unit, bodyHeat)
			if duration and duration > 7 then
				-- everyone should be stacked and get their debuffs at the same time (having four bars up would be annoying)
				someoneHasBodyHeat = true
				self:Bar(137084, duration)
				self:ScheduleTimer(reset, duration)
			end
		end
		if unit == "player" and not hasChilledToTheBone and self:UnitDebuff(unit, chilledToTheBone) then
			hasChilledToTheBone = true
			self:MessageOld(137085, "blue", "info") -- run away little girl!
			self:Flash(137085)
			self:ScheduleTimer(reset, 15, true) -- minimum of 16s before you can get it again
		end
	end

	function mod:FrostbiteApplied(args)
		-- We only use Icon on Biting cold, so people know that if someone has icon over their head, you need to stay away
		self:TargetMessageOld(136990, args.destName, "green", "info")
		self:Bar(136990, 45)
		frostBiteStart = GetTime()
		if self:Heroic() then
			hasFrostbite = self:Me(args.destGUID)
			someoneHasBodyHeat = nil
			hasChilledToTheBone = nil
			self:RegisterEvent("UNIT_AURA")
		end
	end

	function mod:FrostbiteRemoved(args)
		if self:Heroic() then
			self:UnregisterEvent("UNIT_AURA")
			self:StopBar(137084)
		end
	end
end

function mod:BitingColdApplied(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange", "alert")
	self:Bar(args.spellId, 45)
	self:SecondaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Biting Cold")
		if sandGuyDead then
			self:OpenProximity(args.spellId, 4)
		end
	elseif sandGuyDead then
		self:OpenProximity(args.spellId, 4, args.destName)
	end
	bitingColdStart = GetTime()
end

function mod:BitingColdRemoved(args)
	self:SecondaryIcon(args.spellId)
	if sandGuyDead then
		self:CloseProximity(args.spellId)
	end
end

-- Tank alerts so you know when you should be watching for stacks (if you're not avoiding hits, it can stack really fast)
function mod:FrigidAssaultStart(args)
	self:MessageOld(-7054, "yellow", "warning", args.spellName)
	self:Bar(-7054, 30)
end

function mod:FrigidAssault(args)
	if args.amount % 5 == 0 or args.amount > 10 then -- don't spam on low stacks, but spam close to 15 (spam so hard)
		self:StackMessageOld(-7054, args.destName, args.amount, "orange", "info", L["assault_message"])
	end
end

function mod:FrigidAssaultStun(args)
	self:MessageOld(-7054, "red", "warning", L["assault_stun"])
end

-- General

function mod:ShadowedSoul(args)
	if self:Me(args.destGUID) and self:UnitDebuff("player", self:SpellName(137641), 137641) and args.amount > 9 then -- Soul Fragment on, aka gaining more stacks, 10 stacks = 20% extra damage taken
		self:MessageOld(args.spellId, "blue", "info", CL["count"]:format(args.spellName, args.amount))
	end
end

do
	local prevPower = 0
	local function warnFullPower(guid, lastPercHPToGo)
		if prevPower < 100 then return end

		local unitId
		for i=1,5 do
			local boss = ("boss%d"):format(i)
			if mod:UnitGUID(boss) == guid then
				unitId = boss
				break
			end
		end
		if not unitId then return end

		local maxHealth, currHealth = UnitHealthMax(unitId), UnitHealth(unitId)
		local percHPToGo = 25 - math.floor((posessHPStart - currHealth) / maxHealth * 100)
		if percHPToGo < 1 then return end

		if percHPToGo < lastPercHPToGo then
			mod:MessageOld(136442, "red", "alert", L["hp_to_go_fullpower"]:format(percHPToGo))
		end
		mod:ScheduleTimer(warnFullPower, 3, guid, percHPToGo)
	end

	function mod:PossessedHPToGo(event, unitId)
		if not self:UnitBuff(unitId, 136442) then return end
		local maxHealth, currHealth = UnitHealthMax(unitId), UnitHealth(unitId)
		local percHPToGo = 25 - math.floor((posessHPStart - currHealth) / maxHealth * 100)
		if percHPToGo < 1 then return end

		local power = UnitPower(unitId)
		if power > 32 and prevPower == 0 then
			prevPower = 33
			self:MessageOld(136442, "yellow", nil, L["hp_to_go_power"]:format(percHPToGo, power))
		elseif power > 49 and prevPower == 33 then
			prevPower = 50
			self:MessageOld(136442, "yellow", nil, L["hp_to_go_power"]:format(percHPToGo, power))
		elseif power > 69 and prevPower == 50 then
			prevPower = 70
			self:MessageOld(136442, "orange", nil, L["hp_to_go_power"]:format(percHPToGo, power))
		elseif power > 79 and prevPower == 70 then
			prevPower = 80
			self:MessageOld(136442, "red", nil, L["hp_to_go_power"]:format(percHPToGo, power))
		elseif power > 89 and prevPower == 80 then
			prevPower = 90
			self:MessageOld(136442, "red", nil, L["hp_to_go_power"]:format(percHPToGo, power))
		elseif power > 99 and prevPower == 90 then
			prevPower = 100
			self:MessageOld(136442, "red", "alert", L["hp_to_go_fullpower"]:format(percHPToGo))
			self:ScheduleTimer(warnFullPower, 3, self:UnitGUID(unitId), percHPToGo)
		end
	end

	function mod:PossessedApplied(args)
		prevPower = 0
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "PossessedHPToGo", "boss1", "boss2", "boss3", "boss4", "boss5") -- need to register all, because they jump around like crazy during the encounter

		local lingeringCount = 0
		for i=1,5 do
			local boss = ("boss%d"):format(i)
			if self:UnitGUID(boss) == args.destGUID then
				local _, stack = self:UnitBuff(boss, self:SpellName(136467), 136467) -- Lingering Presence
				lingeringCount = stack or 0
				posessHPStart = UnitHealth(boss)
				if self.db.profile.custom_on_markpossessed then
					self:CustomIcon(false, boss, 8)
				end
				break
			end
		end

		local baseTime = self:Difficulty() == 3 and 76 or 66 -- 66 (76 in 10m) seconds till full power without any lingering presences stacks
		local regenMultiplier = self:Heroic() and 15 or self:LFR() and 5 or 10
		local duration = baseTime * (100 - lingeringCount * regenMultiplier) / 100
		self:MessageOld(args.spellId, "cyan", "long", CL["other"]:format(args.spellName, args.destName))
		self:Bar(args.spellId, duration, L["full_power"])

		local mobId = self:MobId(args.destGUID)
		if mobId == 69131 then -- Frost King
			self:StopBar(136992) -- Biting Cold
			if bitingColdStart then
				self:Bar(136990, 45 - (GetTime() - bitingColdStart)) -- Frostbite -- CD bar because of Possessed buff travel time
			end
		end
	end

	function mod:PossessedRemoved(args)
		prevPower = 0
		self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss1", "boss2", "boss3", "boss4", "boss5")
		if self.db.profile.custom_on_markpossessed then
			for i=1,5 do
				local boss = ("boss%d"):format(i)
				if self:UnitGUID(boss) == args.destGUID then
					self:CustomIcon(false, boss) -- clear the icon because posses have travel time, so people know when something is no longer possessed
				end
			end
		end

		local mobId = self:MobId(args.destGUID)
		if mobId == 69131 then -- Frost King
			self:StopBar(136990) -- Frostbite
			if frostBiteStart then
				self:Bar(136992, 45 - (GetTime() - frostBiteStart)) -- Biting Cold
			end
		end
	end
end

function mod:BlessedLoaDeath(args)
	if args.mobId == 69480 then -- Blessed Loa Spirit
		self:StopBar(CL["other"]:format(fixated, self:SpellName(137203)))
	end
end

function mod:Deaths(args)
	if args.mobId == 69131 then -- Frost King
		self:StopBar(136992) -- Frostbite
		self:StopBar(136990) -- Biting Cold
		self:StopBar(-7054) -- Frigid Assault
	elseif args.mobId == 69078 then -- Sandcrawler
		sandGuyDead = true
		self:StopBar(-7062) -- Quicksand
		self:StopBar(136894) -- Sandstorm
		if not self:UnitDebuff("player", self:SpellName(136992)) then -- Biting Cold
			self:CloseProximity()
		end
	elseif args.mobId == 69132 then -- Priestess
		self:StopBar(L["priestess_adds_message"])
	end

	bossDead = bossDead + 1
	if bossDead > 4 then
		self:Win()
	end
end

