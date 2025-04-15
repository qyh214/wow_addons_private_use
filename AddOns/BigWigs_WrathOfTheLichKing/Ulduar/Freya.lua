--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Freya", 603, 1646)
if not mod then return end
mod:RegisterEnableMob(32906)
mod:SetEncounterID(BigWigsLoader.isWrath and 753 or 1133)
mod:SetRespawnTime(34)

--------------------------------------------------------------------------------
-- Locals
--

local stage = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.wave = "Waves"
	L.wave_desc = "Warn for Waves."
	L.wave_bar = "Next Wave"
	L.conservator_trigger = "Eonar, your servant requires aid!"
	L.detonate_trigger = "The swarm of the elements shall overtake you!"
	L.elementals_trigger = "Children, assist me!"
	L.tree_trigger = "A |cFF00FFFFLifebinder's Gift|r begins to grow!"
	L.conservator_message = "Conservator!"
	L.detonate_message = "Detonating lashers!"
	L.elementals_message = "Elementals!"

	L.tree = "Eonar's Gift"
	L.tree_desc = "Alert when Freya spawns a Eonar's Gift."
	L.tree_message = "Tree is up!"

	L.fury_message = "Fury"

	L.tremor_warning = "Ground Tremor soon!"
	L.tremor_bar = "~Next Ground Tremor"
	L.energy_message = "Unstable Energy on YOU!"
	L.sunbeam_message = "Sun beams up!"
	L.sunbeam_bar = "~Next Sun Beams"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"wave",
		"tree",
		{62589, "ICON", "FLASH"}, -- Nature's Fury
		{62623, "ICON"}, -- Sunbeam
		"proximity",
		62861, -- Iron Roots
		{62437, "FLASH"}, -- Ground Tremor
		{62865, "FLASH"}, -- Unstable Energy
		"stages",
		"berserk",
	}, {
		wave = "normal",
		[62861] = "hard",
		stages = "general",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Energy", 62865, 62451)              --Elder Brightleaf
	self:Log("SPELL_CAST_SUCCESS", "EnergySpawns", 62865, 62451)        --Elder Brightleaf
	self:Log("SPELL_AURA_APPLIED", "Root", 62861, 62930, 62283, 62438)  --Elder Ironbranch
	self:Log("SPELL_CAST_START", "Tremor", 62437, 62859, 62325, 62932)  --Elder Stonebark
	self:Log("SPELL_CAST_START", "Sunbeam", 62623, 62872)
	self:Log("SPELL_AURA_APPLIED", "Fury", 62589, 63571)
	self:Log("SPELL_AURA_REMOVED", "FuryRemove", 62589, 63571)
	self:Log("SPELL_AURA_REMOVED", "AttunedRemove", 62519)

	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")

	self:Death("SunBeamDeath", 33170) -- Sun Beam
end

function mod:OnEngage()
	stage = 1
	self:Berserk(600)
	self:Bar("wave", 11, L.wave_bar, 35594)
end

function mod:VerifyEnable(unit)
	return (UnitIsEnemy(unit, "player") and UnitHealth(unit) > 100) and true or false
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local root = mod:NewTargetList()
	function mod:Root(args)
		root[#root + 1] = args.destName
		if #root == 1 then
			self:ScheduleTimer("TargetMessageOld", 0.2, 62861, root, "yellow", "info")
		end
	end
end

do
	-- XXX Why do we still do this?
	local function isCaster()
		local power = UnitPowerType("player")
		local _, class = UnitClass("player")
		if power ~= 0 or (class == "PALADIN" and not mod:Healer()) then return end
		return true
	end

	function mod:Tremor(args)
		local caster = isCaster()
		self:MessageOld(62437, caster and "blue" or "yellow", caster and "long")
		if caster then self:Flash(62437) end
		self:Bar(62437, 2)
		if stage == 1 then
			self:CDBar(62437, 30, L.tremor_bar)
			self:DelayedMessage(62437, 26, "yellow", L.tremor_warning)
		elseif stage == 2 then
			self:CDBar(62437, 23, L.tremor_bar)
			self:DelayedMessage(62437, 20, "yellow", L.tremor_warning)
		end
	end
end

do
	local handle = nil
	local function scanTarget()
		local bossId = mod:GetUnitIdByGUID(32906)
		if not bossId then return end
		local target = mod:UnitName(bossId .. "target")
		if target then
			mod:TargetMessageOld(62623, target, "yellow")
			mod:SecondaryIcon(62623, target)
		end
		handle = nil
	end

	function mod:Sunbeam(args)
		if not handle then
			handle = self:ScheduleTimer(scanTarget, 0.1)
		end
	end
end

function mod:Fury(args)
	if self:Me(args.destGUID) then
		self:OpenProximity("proximity", 10)
		self:Flash(62589)
	end
	self:TargetMessageOld(62589, args.destName, "blue", "alert", L.fury_message)
	self:TargetBar(62589, 10, args.destName, L.fury_message)
	self:PrimaryIcon(62589, args.destName)
end

function mod:FuryRemove(args)
	self:StopBar(L.fury_message, args.destName)
	if self:Me(args.destGUID) then
		self:CloseProximity()
	end
end

function mod:AttunedRemove()
	stage = 2
	self:StopBar(L.wave_bar)
	self:MessageOld("stages", "red", nil, CL.stage:format(2), false)
end

do
	local prev = 0
	function mod:Energy(args)
		if self:Me(args.destGUID) then
			local t = GetTime()
			if t-prev > 4 then
				prev = t
				self:MessageOld(62865, "blue", "alarm", L.energy_message, 62451)
				self:Flash(62865)
			end
		end
	end
end

do
	local prev = 0
	function mod:EnergySpawns()
		local t = GetTime()
		if t-prev > 10 then
			prev = t
			self:MessageOld(62865, "red", nil, L.sunbeam_message)
		end
	end
	function mod:SunBeamDeath()
		self:CDBar(62865, 35, L.sunbeam_bar)
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg == L.conservator_trigger then
		self:MessageOld("wave", "green", nil, L.conservator_message, 35594)
		self:Bar("wave", 60, L.wave_bar, 35594)
	elseif msg == L.detonate_trigger then
		self:MessageOld("wave", "green", nil, L.detonate_message, 35594)
		self:Bar("wave", 60, L.wave_bar, 35594)
	elseif msg == L.elementals_trigger then
		self:MessageOld("wave", "green", nil, L.elementals_message, 35594)
		self:Bar("wave", 60, L.wave_bar, 35594)
	end
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
	if msg == L.tree_trigger then
		self:MessageOld("tree", "orange", "alarm", L.tree_message, 5420) -- 5420 / Incarnation: Tree of Life / ability_druid_treeoflife / icon 132145
	end
end
