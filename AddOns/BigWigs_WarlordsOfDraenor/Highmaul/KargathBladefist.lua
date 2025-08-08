
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Kargath Bladefist", 1228, 1128)
if not mod then return end
mod:RegisterEnableMob(78714)
mod.engageId = 1721

--------------------------------------------------------------------------------
-- Locals
--

local hurled = nil
local tigers = {}
local berserkerRushPlayer = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.blade_dance_bar = "Dancing"

	L.arena_sweeper = 177776
	L.arena_sweeper_desc = "Timer for getting knocked out of the stadium stands after you've been Chain Hurled."
	L.arena_sweeper_icon = "ability_kick"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		--[[ Mythic ]]--
		-9396, -- Ravenous Bloodmaw
		{162497, "FLASH", "SAY"}, -- On the Hunt
		"arena_sweeper", -- Arena Sweeper
		--[[ General ]]--
		-9394, -- Fire Pillar
		{159113, "TANK_HEALER"}, -- Impale
		159250, -- Blade Dance
		{158986, "SAY", "ICON", "FLASH"}, -- Berserker Rush
		159947, -- Chain Hurl
		159413, -- Mauling Brew
		159311, -- Flame Jet
		160521, -- Vile Breath
	}, {
		[-9396] = "mythic",
		[-9394] = "general"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "FlameJetDamage", 159311)
	self:Log("SPELL_PERIODIC_DAMAGE", "FlameJetDamage", 159311)
	self:Log("SPELL_PERIODIC_MISSED", "FlameJetDamage", 159311)

	self:Log("SPELL_AURA_APPLIED", "MaulingBrewDamage", 159413)
	self:Log("SPELL_PERIODIC_DAMAGE", "MaulingBrewDamage", 159413)
	self:Log("SPELL_PERIODIC_MISSED", "MaulingBrewDamage", 159413)

	self:Log("SPELL_AURA_APPLIED", "FirePillar", 159202) -- Flame Jet
	self:Log("SPELL_CAST_START", "Impale", 159113)
	self:Log("SPELL_AURA_APPLIED", "BladeDance", 159250)
	self:Log("SPELL_CAST_START", "BerserkerRushCast", 158986)
	self:Log("SPELL_AURA_APPLIED", "BerserkerRushAppliedFallback", 158986)
	self:Log("SPELL_AURA_REMOVED", "BerserkerRushRemoved", 158986)
	self:Log("SPELL_CAST_START", "ChainHurl", 159947)
	self:Log("SPELL_AURA_APPLIED", "ChainHurlApplied", 159947)
	self:Log("SPELL_CAST_START", "VileBreath", 160521)
	-- Mythic
	self:Log("SPELL_AURA_APPLIED", "OnTheHunt", 162497)
	self:Log("SPELL_CAST_SUCCESS", "CatSpawn", 181113) -- Encounter Spawn
end

function mod:OnEngage()
	hurled = nil
	berserkerRushPlayer = nil
	self:Bar(-9394, 20) -- Fire Pillar
	self:CDBar(159113, 37) -- Impale
	self:CDBar(158986, 54) -- Berserker Rush
	self:CDBar(159947, 90) -- Chain Hurl
	if self:Mythic() then
		tigers = {}
		self:Bar(-9396, 110, nil, "ability_druid_tigersroar") -- Ravenous Bloodmaw
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CatSpawn()
	self:MessageOld(-9396, "cyan", nil, nil, false) -- Ravenous Bloodmaw
	self:Bar(-9396, 110, nil, "ability_druid_tigersroar")
end

function mod:OnTheHunt(args)
	self:TargetMessageOld(args.spellId, args.destName, "red", "alarm")
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
		self:Say(args.spellId, nil, nil, "On the Hunt")
	end
end

do
	local function printTarget(self, name)
		self:TargetMessageOld(159113, name, "orange", "warning", nil, nil, true)
		self:TargetBar(159113, 10.2, name) -- cast+channel (10.25 - 0.05)
	end
	function mod:Impale(args)
		self:GetBossTarget(printTarget, 0, args.sourceGUID)
		self:CDBar(args.spellId, 43) -- delayed by chain hurl/berserker rush
	end
end

function mod:BladeDance(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, 10, L.blade_dance_bar)
	--self:CDBar(args.spellId, 20)
end

do
	local function printTarget(self, name, guid)
		berserkerRushPlayer = guid
		self:PrimaryIcon(158986, name)
		if self:Me(guid) then
			self:Say(158986, nil, nil, "Berserker Rush")
			self:Flash(158986)
		end
		self:TargetMessageOld(158986, name, "red", "long", nil, nil, true)
	end
	function mod:BerserkerRushAppliedFallback(args)
		-- Kargath will rarely drop his target (bug?) and swap to another one mid cast.
		-- Doing so fires APPLIED, but not a SPELL_CAST event. This is our fallback for it.
		if args.destGUID ~= berserkerRushPlayer then
			printTarget(self, args.destName, args.destGUID)
		end
	end
	function mod:BerserkerRushCast(args)
		self:GetBossTarget(printTarget, 0.5, args.sourceGUID)
		self:CDBar(args.spellId, 46) -- cd is 46/51 :\
	end
end

function mod:BerserkerRushRemoved(args)
	berserkerRushPlayer = nil
	self:PrimaryIcon(args.spellId)
end

function mod:FirePillar()
	self:Bar(-9394, 20) -- Fire Pillar
end

do
	local hurlList, scheduled = mod:NewTargetList(), nil

	local function knockdown()
		hurled = nil
	end

	local function printTargets(spellId)
		mod:TargetMessageOld(spellId, hurlList, "yellow")
		scheduled = nil
	end

	function mod:ChainHurl(args)
		self:MessageOld(args.spellId, "orange", "alert", CL.incoming:format(args.spellName))
		self:Bar(args.spellId, 3.4)
	end

	function mod:ChainHurlApplied(args)
		hurlList[#hurlList+1] = args.destName
		if self:Me(args.destGUID) then
			hurled = true
			self:Bar("arena_sweeper", 55, L.arena_sweeper, L.arena_sweeper_icon)
			self:DelayedMessage("arena_sweeper", 55, "orange", CL.incoming:format(self:SpellName(L.arena_sweeper)), false, "info")
			self:ScheduleTimer(knockdown, 65)
		end
		if not scheduled then
			self:Bar(args.spellId, 103)
			scheduled = self:ScheduleTimer(printTargets, 0.1, args.spellId)
		end
	end
end

do
	local prev = 0
	function mod:MaulingBrewDamage(args)
		local t = GetTime()
		if self:Me(args.destGUID) and t-prev > 1 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
		end
	end
end

do
	local prev = 0
	function mod:FlameJetDamage(args)
		local t = GetTime()
		if self:Me(args.destGUID) and t-prev > 1 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
		end
	end
end

function mod:VileBreath(args)
	if hurled then
		self:MessageOld(args.spellId, "yellow", "alarm")
	end
end

