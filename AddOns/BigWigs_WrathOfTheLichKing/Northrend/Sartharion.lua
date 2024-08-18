--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Sartharion", 615, 1616)
if not mod then return end
mod:RegisterEnableMob(28860, 30449, 30451, 30452) -- Sartharion, Tenebron, Shadron, Vesperon
--mod:SetEncounterID(1090) -- Sometimes ENCOUNTER_END doesn't fire
--mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local tormentOnMe = false
local isInfoOpen = false
local flameTsunamiList = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.engage_trigger = "It is my charge to watch over these eggs. I will see you burn before any harm comes to them!"
	L.tsunami_trigger = "The lava surrounding %s churns!"
	L.twilight_trigger_vesperon = "A Vesperon Disciple appears in the Twilight!"
	L.twilight_trigger_shadron = "A Shadron Disciple appears in the Twilight!"

	L.drakes = "Drake Adds"
	L.drakes_desc = "Warn when each drake add will join the fight."
	L.drakes_icon = 61248

	-- Adds
	L.shadron = "Shadron"
	L.tenebron = "Tenebron"
	L.vesperon = "Vesperon"
	L.lava_blaze = "Lava Blaze" -- NPC 30643
	L.acolyte_shadron = "Acolyte of Shadron" -- NPC 31218
	L.acolyte_vesperon = "Acolyte of Vesperon" -- NPC 31219

	L.acolyte_shadron_icon = 58105
	L.acolyte_vesperon_icon = 61251
end

--------------------------------------------------------------------------------
-- Initialization
--


function mod:GetOptions()
	return {
		"berserk",
		{57491, "EMPHASIZE", "INFOBOX"}, -- Flame Tsunami
		{58956, "OFF"}, -- Flame Breath
		"drakes",
		{59127, "OFF"}, -- Shadow Fissure
		{59126, "OFF"}, -- Shadow Breath
		60430, -- Molten Fury
		58793, -- Hatch Eggs
		"acolyte_shadron",
		"acolyte_vesperon",
		{58835, "ME_ONLY_EMPHASIZE", "FLASH"}, -- Twilight Torment
	},{
		[60430] = L.lava_blaze,
		[58793] = L.tenebron,
		["acolyte_shadron"] = L.shadron,
		["acolyte_vesperon"] = L.vesperon,
	}
end

function mod:OnRegister()
	L.acolyte_shadron_desc = CL.spawned:format(L.acolyte_shadron)
	L.acolyte_vesperon_desc = CL.spawned:format(L.acolyte_vesperon)
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "PowerOfTenebron", 61248)
	self:Log("SPELL_CAST_SUCCESS", "PowerOfShadron", 58105)
	self:Log("SPELL_CAST_SUCCESS", "PowerOfVesperon", 61251)
	self:Log("SPELL_AURA_APPLIED", "FlameTsunamiApplied", 57491)
	self:Log("SPELL_AURA_REMOVED", "FlameTsunamiRemoved", 57491)
	self:Log("SPELL_CAST_START", "FlameBreath", 56908, 58956) -- 10, 25
	self:Log("SPELL_CAST_SUCCESS", "ShadowFissure", 57579, 59127) -- 10, 25
	self:Log("SPELL_CAST_SUCCESS", "ShadowBreath", 57570, 59126) -- 10, 25
	self:Log("SPELL_AURA_APPLIED", "MoltenFury", 60430)

	self:Emote("FlameTsunamiEmote", L.tsunami_trigger)
	self:Log("SPELL_CAST_START", "HatchEggs", 58793) -- Tenebron
	self:Emote("ShadronSpawnsAddEmote", L.twilight_trigger_shadron)
	self:Death("ShadronDies", 30451)
	self:Emote("VesperonSpawnsAddEmote", L.twilight_trigger_vesperon)
	self:Death("VesperonDies", 30452)

	self:BossYell("Engage", L.engage_trigger)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Death("Win", 28860)
end

function mod:OnEngage()
	tormentOnMe = false
	isInfoOpen = false
	flameTsunamiList = {}
	self:Berserk(900)
	self:CDBar(57491, 29) -- Flame Tsunami
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Each drake takes around 12 seconds to land
-- Tenebron called in roughly 20s after engage if left alive
-- This shadow damage debuff applies to all players on engage
function mod:PowerOfTenebron(args)
	self:Engage() -- Compensate for lacking yell translations when leaving drakes alive
	self:CDBar("drakes", 32, L.tenebron, args.spellId)
	self:DelayedMessage("drakes", 27, "yellow", CL.custom_sec:format(L.tenebron, 5))
end

-- Shadron called in roughly 66s after engage if left alive
-- This fire damage debuff applies to all players on engage
function mod:PowerOfShadron(args)
	self:Engage() -- Compensate for lacking yell translations when leaving drakes alive
	self:CDBar("drakes", 78, L.shadron, args.spellId)
	self:DelayedMessage("drakes", 73, "yellow", CL.custom_sec:format(L.shadron, 5))
end

-- Vesperon called in roughly 112s after engage if left alive
-- This health decrease debuff applies to all players on engage
function mod:PowerOfVesperon(args)
	self:Engage() -- Compensate for lacking yell translations when leaving drakes alive
	self:CDBar("drakes", 124, L.vesperon, args.spellId)
	self:DelayedMessage("drakes", 119, "yellow", CL.custom_sec:format(L.vesperon, 5))
	self:RegisterUnitEvent("UNIT_AURA", nil, "player") -- Twilight Torment debuff is hidden
end

function mod:FlameTsunamiApplied(args)
	if self:Player(args.destFlags) then
		if not isInfoOpen then
			isInfoOpen = true
			self:OpenInfo(args.spellId, args.spellName)
		end
		flameTsunamiList[args.destName] = 1
		self:SetInfoByTable(args.spellId, flameTsunamiList)
	end
end

function mod:FlameTsunamiRemoved(args)
	if self:Player(args.destFlags) then
		flameTsunamiList[args.destName] = nil
		if next(flameTsunamiList) then
			self:SetInfoByTable(args.spellId, flameTsunamiList)
		elseif isInfoOpen then
			isInfoOpen = false
			self:CloseInfo(args.spellId)
		end
	end
end

function mod:FlameBreath()
	self:CDBar(58956, 12)
end

function mod:ShadowFissure()
	self:Message(59127, "yellow")
	self:PlaySound(59127, "alert")
end

function mod:ShadowBreath()
	self:CDBar(59126, 12)
end

function mod:FlameTsunamiEmote()
	self:Message(57491, "red")
	self:CDBar(57491, 28)
	self:PlaySound(57491, "warning")
end

do
	local prev = 0
	function mod:MoltenFury(args)
		local t = args.time
		if t-prev > 2 then
			prev = t
			self:TargetMessage(args.spellId, "purple", L.lava_blaze)
		end
	end
end

function mod:HatchEggs(args) -- Emote "Tenebron begins to hatch eggs in the Twilight!"
	self:Bar(args.spellId, 19)
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "info")
end

function mod:ShadronSpawnsAddEmote(msg, mob)
	if mob ~= L.shadron then return end
	self:Message("acolyte_shadron", "orange", CL.spawned:format(L.acolyte_shadron), 58105)
	self:PlaySound("acolyte_shadron", "info")
	self:CDBar("acolyte_shadron", 52, L.acolyte_shadron, 58105)
end

function mod:ShadronDies()
	self:StopBar(L.acolyte_shadron)
end

function mod:VesperonSpawnsAddEmote(msg, mob)
	if mob ~= L.vesperon then return end
	self:Message("acolyte_vesperon", "orange", CL.spawned:format(L.acolyte_vesperon), 61251)
	self:CDBar("acolyte_vesperon", 58, L.acolyte_vesperon, 61251)
end

function mod:VesperonDies()
	self:StopBar(L.acolyte_vesperon)
	self:UnregisterUnitEvent("UNIT_AURA", "player")
end

function mod:UNIT_AURA(_, unit)
	local hasSpellReflectDebuff = self:UnitDebuff(unit, 58835) -- Twilight Torment

	if hasSpellReflectDebuff and not tormentOnMe then
		tormentOnMe = true
		self:PersonalMessage(58835)
		self:Flash(58835)
		self:PlaySound(58835, "long")
	elseif not hasSpellReflectDebuff and tormentOnMe then
		tormentOnMe = false
		self:Message(58835, "green", CL.removed:format(self:SpellName(58835)))
	end
end
