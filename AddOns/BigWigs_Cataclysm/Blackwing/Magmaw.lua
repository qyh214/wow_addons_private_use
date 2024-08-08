--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Magmaw", 669, 170)
if not mod then return end
mod:RegisterEnableMob(41570, 42347) -- Magmaw, Exposed Head of Magmaw
mod:SetEncounterID(1024)
mod:SetRespawnTime(32)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local isHeadPhase = false
local lavaSpewCount = 1
local massiveCrashCount = 1
local mangleCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.adds_icon = "SPELL_SHADOW_RAISEDEAD"

	L.stage2_yell_trigger = "You may actually defeat my lava worm"

	L.slump = "Slump"
	L.slump_desc = "Warn for when Magmaw slumps forward and exposes himself, allowing the riding rodeo to start."
	L.slump_bar = "Rodeo"
	L.slump_message = "Yeehaw, ride on!"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Normal
		"slump",
		88253, -- Massive Crash
		{79011, "EMPHASIZE"}, -- Point of Vulnerability
		78006, -- Pillar of Flame
		{78941, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Parasitic Infection
		77690, -- Lava Spew
		92134, -- Ignition
		{89773, "TANK_HEALER"}, -- Mangle
		{78199, "TANK"}, -- Sweltering Armor
		78403, -- Molten Tantrum
		-- Heroic
		"adds",
		{92177, "CASTBAR"}, -- Armageddon
		-- General
		"stages",
		"berserk",
	},{
		["slump"] = "normal",
		["adds"] = "heroic",
		["stages"] = "general"
	},{
		["slump"] = L.slump_bar, -- Slump (Rodeo)
		[79011] = CL.weakened, -- Point of Vulnerability (Weakened)
		[78941] = CL.parasite, -- Parasitic Infection (Parasite)
		[92134] = CL.underyou:format(CL.fire), -- Ignition (Fire under YOU)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "MassiveCrash", 88253)
	self:Log("SPELL_AURA_APPLIED", "ParasiticInfection", 78097, 78941)
	self:Log("SPELL_AURA_APPLIED", "PillarOfFlame", 78006)
	self:Log("SPELL_CAST_SUCCESS", "LavaSpew", 77690)
	self:Log("SPELL_AURA_APPLIED", "ArmageddonApplied", 92177)
	self:Log("SPELL_AURA_REMOVED", "ArmageddonRemoved", 92177)
	self:Log("SPELL_AURA_APPLIED", "MangleApplied", 89773)
	self:Log("SPELL_AURA_REMOVED", "MangleRemoved", 89773)
	self:Log("SPELL_AURA_APPLIED", "SwelteringArmorApplied", 78199)
	self:Log("SPELL_AURA_APPLIED", "MoltenTantrumApplied", 78403)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MoltenTantrumApplied", 78403)

	self:Log("SPELL_DAMAGE", "IgnitionDamage", 92134)
	self:Log("SPELL_MISSED", "IgnitionDamage", 92134)

	-- Heroic
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:Log("SPELL_SUMMON", "BlazingInferno", 92154)
end

function mod:OnEngage()
	isHeadPhase = false
	lavaSpewCount = 1
	massiveCrashCount = 1
	mangleCount = 1
	self:SetStage(1)
	self:Berserk(600)
	self:Bar("slump", 100, CL.count:format(L.slump_bar, massiveCrashCount), 36702) -- Slump/Rodeo/Massive Crash
	self:CDBar(78006, 30) -- Pillar of Flame
	self:CDBar(77690, 24, CL.count:format(self:SpellName(77690), lavaSpewCount)) -- Lava Spew
	self:CDBar(89773, 90, CL.count:format(self:SpellName(89773), mangleCount)) -- Mangle
	if self:Heroic() then
		self:Bar("adds", 30, CL.add, L.adds_icon)
		self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1")
	end
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.stage2_yell_trigger, nil, true) then
		self:SetStage(2)
		self:StopBar(CL.add)
		self:Message("stages", "cyan", CL.percent:format(30, CL.stage:format(2)), false)
	end
end

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	-- Purposely only checking boss frames
	local headUnit = self:GetBossId(42347) -- Exposed Head of Magmaw
	local bossUnit = self:GetBossId(41570) -- Magmaw
	if not isHeadPhase and headUnit and not bossUnit then -- Wait until the boss is gone before starting
		isHeadPhase = true
		self:Message(79011, "green", CL.weakened)
		self:Bar(79011, 30, CL.weakened)
		self:StopBar(78006) -- Pillar of Flame
		self:StopBar(CL.count:format(self:SpellName(77690), lavaSpewCount)) -- Lava Spew
		self:PlaySound(79011, "long")
	elseif isHeadPhase and not headUnit and bossUnit then -- Wait until the boss is back before ending
		isHeadPhase = false
		self:Message(79011, "green", CL.over:format(CL.weakened), false, true)
		self:CDBar(78006, 9.5) -- Pillar of Flame
		self:CDBar(77690, 4.5, CL.count:format(mod:SpellName(77690), lavaSpewCount)) -- Lava Spew
	end
end

do
	local function Rodeo()
		if mod:IsEngaged() then
			mod:StopBar(CL.count:format(L.slump_bar, massiveCrashCount))
			mod:Message("slump", "green", CL.count:format(L.slump_message, massiveCrashCount), 36702)
			massiveCrashCount = massiveCrashCount + 1
			mod:Bar("slump", 95, CL.count:format(L.slump_bar, massiveCrashCount), 36702)
		end
	end
	function mod:MassiveCrash(args)
		self:StopBar(78006) -- Pillar of Flame
		self:SimpleTimer(Rodeo, 2)
		self:Message(args.spellId, "red", CL.count:format(args.spellName, massiveCrashCount))
		self:PlaySound(args.spellId, "info")
	end
end

function mod:ArmageddonApplied(args)
	self:Message(args.spellId, "red", CL.other:format(CL.add, args.spellName))
	self:CastBar(args.spellId, 8)
	if isHeadPhase then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:ArmageddonRemoved(args)
	self:StopBar(CL.cast:format(args.spellName))
end

do
	local prev = 0
	function mod:LavaSpew(args)
		if args.time - prev > 10 then
			prev = args.time
			local msg = CL.count:format(args.spellName, lavaSpewCount)
			self:StopBar(msg)
			self:Message(args.spellId, "yellow", msg)
			lavaSpewCount = lavaSpewCount + 1
			self:CDBar(args.spellId, 26, CL.count:format(args.spellName, lavaSpewCount))
		end
	end
end

function mod:BlazingInferno()
	self:Message("adds", "cyan", CL.add_spawned, L.adds_icon)
	if self:GetStage() == 1 then -- Add can sometimes spawn just as stage 2 begins
		self:Bar("adds", 35, CL.add, L.adds_icon)
	end
	self:PlaySound("adds", "info")
end

function mod:PillarOfFlame(args)
	self:Message(args.spellId, "orange")
	self:CDBar(args.spellId, 32)
	self:PlaySound(args.spellId, "alert")
end

function mod:ParasiticInfection(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(78941, nil, CL.parasite)
		self:Say(78941, CL.parasite, nil, "Parasite")
		self:SayCountdown(78941, 10) -- Not removed on death
		self:PlaySound(78941, "warning", nil, args.destName)
	end
end

do
	local prevMangle = 0
	function mod:MangleApplied(args)
		prevMangle = args.time
		local msg = CL.count:format(args.spellName, mangleCount)
		self:StopBar(msg)
		self:TargetMessage(args.spellId, "purple", args.destName, msg)
		self:TargetBar(args.spellId, 30, args.destName)
		self:Bar(88253, 9.6, CL.count:format(self:SpellName(88253), massiveCrashCount)) -- Massive Crash, time until damage actually hits
		self:PlaySound(args.spellId, "info", nil, args.destName)
	end

	function mod:MangleRemoved(args)
		mangleCount = mangleCount + 1
		self:StopBar(args.spellName, args.destName)
		self:CDBar(args.spellId, prevMangle > 0 and (95 - (args.time-prevMangle)) or 65, CL.count:format(args.spellName, mangleCount)) -- Show the bar after it ends on the tank
	end
end

function mod:SwelteringArmorApplied(args)
	self:TargetMessage(args.spellId, "purple", args.destName)
end

function mod:MoltenTantrumApplied(args)
	self:StackMessage(args.spellId, "purple", args.destName, args.amount, 1)
end

do
	local prev = 0
	function mod:IgnitionDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if hp < 36 then
		self:UnregisterUnitEvent(event, unit)
		if hp > 30 then
			self:Message("stages", "cyan", CL.soon:format(CL.stage:format(2)), false)
		end
	end
end
