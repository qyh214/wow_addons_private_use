--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Omnotron Defense System", 669, 169)
if not mod then return end
mod:RegisterEnableMob(42166, 42179, 42178, 42180, 49226) -- Arcanotron, Electron, Magmatron, Toxitron, Lord Victor Nefarius
mod:SetEncounterID(1027)
mod:SetRespawnTime(72)

--------------------------------------------------------------------------------
-- Locals
--

local prevIcon = nil
local acquiringTargetCount = 1
local incinerationCount = 1
local poisonProtocolCount = 1
local lightningConductorCount = 1
local powerGeneratorCount = 1
local arcaneAnnihilatorCount = 0
local gripOfDeathCount = 0
local chemicalCloudDamageThrottle = 2
local poolExplosionUnderMe = false
local flamethrowerApplied = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.nef = "Lord Victor Nefarius"
	L.nef_desc = "Warnings for Lord Victor Nefarius abilities."
	L.nef_icon = "inv_misc_head_dragon_black"

	L.pool_explosion = "Pool Explosion"
	L.incinerate = "Incinerate"
	L.flamethrower = "Flamethrower"
	L.lightning = "Lightning"
	L.infusion = "Infusion"
end

--------------------------------------------------------------------------------
-- Initialization
--

local activatedMarker = mod:AddMarkerOption(true, "npc", 8, 78740, 8) -- Activated
function mod:GetOptions()
	return {
		-- Magmatron
		{79501, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Acquiring Target
		79023, -- Incineration Security Measure
		-- Electron
		{79888, "ICON", "SAY", "ME_ONLY", "ME_ONLY_EMPHASIZE"}, -- Lightning Conductor
		-- Toxitron
		80161, -- Chemical Cloud
		{80157, "SAY"}, -- Chemical Bomb
		80053, -- Poison Protocol
		80094, -- Fixate
		-- Arcanotron
		79710, -- Arcane Annihilator
		79624, -- Power Generator
		{79735, "DISPEL"}, -- Converted Power
		-- Heroic
		"nef",
		{91849, "CASTBAR"}, -- Grip of Death
		91879, -- Arcane Blowback
		{92048, "ICON", "SAY", "SAY_COUNTDOWN", "CASTBAR", "CASTBAR_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Shadow Infusion
		{92053, "SAY", "SAY_COUNTDOWN"}, -- Shadow Conductor
		{92023, "SAY", "SAY_COUNTDOWN"}, -- Encasing Shadows
		"berserk",
		-- General
		78740, -- Activated
		activatedMarker,
	},{
		[79501] = -3207, -- Magmatron
		[79888] = -3201, -- Electron
		[80161] = -3208, -- Toxitron
		[79710] = -3194, -- Arcanotron
		nef = "heroic",
		[78740] = "general"
	},{
		[79501] = L.flamethrower, -- Acquiring Target (Flamethrower)
		[79023] = L.incinerate, -- Incineration Security Measure (Incinerate)
		[79888] = L.lightning, -- Lightning Conductor (Lightning)
		[80053] = CL.adds, -- Poison Protocol (Adds)
		[79624] = CL.pool, -- Power Generator (Pool)
		[79735] = CL.magic_buff_boss:format(""), -- Converted Power (Magic buff on BOSS:)
		["nef"] = CL.next_ability, -- Lord Victor Nefarius (Next ability)
		[91879] = L.pool_explosion, -- Arcane Blowback (Pool Explosion)
		[92048] = L.infusion, -- Shadow Infusion (Infusion)
		[92023] = CL.rooted, -- Encasing Shadows (Rooted)
	}
end

function mod:OnBossEnable()
	 -- Magmatron
	self:Log("SPELL_AURA_APPLIED", "AcquiringTargetApplied", 79501)
	self:Log("SPELL_AURA_REMOVED", "AcquiringTargetRemoved", 79501)
	self:Log("SPELL_CAST_SUCCESS", "IncinerationSecurityMeasure", 79023)
	-- Electron
	self:Log("SPELL_CAST_SUCCESS", "LightningConductor", 79888)
	self:Log("SPELL_AURA_APPLIED", "LightningConductorApplied", 79888)
	self:Log("SPELL_AURA_REMOVED", "LightningConductorRemoved", 79888)
	-- Toxitron
	self:Log("SPELL_CAST_SUCCESS", "ChemicalBomb", 80157)
	self:Log("SPELL_AURA_APPLIED", "FixateApplied", 80094)
	self:Log("SPELL_CAST_SUCCESS", "PoisonProtocol", 80053)
	self:Log("SPELL_AURA_APPLIED", "ChemicalCloudDamage", 80161)
	self:Log("SPELL_DAMAGE", "ChemicalCloudDamage", 80161)
	self:Log("SPELL_MISSED", "ChemicalCloudDamage", 80161)
	-- Arcanotron
	self:Log("SPELL_CAST_START", "ArcaneAnnihilator", 79710)
	self:Log("SPELL_CAST_SUCCESS", "PowerGenerator", 79624)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ConvertedPowerAppliedDose", 79735)
	-- Heroic
	self:Log("SPELL_CAST_SUCCESS", "OverchargedPowerGenerator", 91857)
	self:Log("SPELL_AURA_APPLIED", "OverchargedPowerGeneratorApplied", 91858)
	self:Log("SPELL_AURA_REMOVED", "OverchargedPowerGeneratorRemoved", 91858)
	self:Log("SPELL_CAST_START", "GripOfDeath", 91849)
	self:Log("SPELL_CAST_SUCCESS", "EncasingShadows", 92023)
	self:Log("SPELL_AURA_APPLIED", "EncasingShadowsApplied", 92023)
	self:Log("SPELL_AURA_REMOVED", "EncasingShadowsRemoved", 92023)
	self:Log("SPELL_AURA_APPLIED", "ShadowInfusionApplied", 92048)
	self:Log("SPELL_AURA_REMOVED", "ShadowInfusionRemoved", 92048)
	self:Log("SPELL_AURA_APPLIED", "ShadowConductorApplied", 92053)
	self:Log("SPELL_AURA_REMOVED", "ShadowConductorRemoved", 92053)
	-- General
	self:Log("SPELL_AURA_APPLIED", "ActivatedApplied", 78740)
	self:Log("SPELL_CAST_SUCCESS", "ShuttingDown", 78746)
end

function mod:OnEngage()
	acquiringTargetCount = 1
	incinerationCount = 1
	poisonProtocolCount = 1
	lightningConductorCount = 1
	powerGeneratorCount = 1
	arcaneAnnihilatorCount = 0
	gripOfDeathCount = 0
	chemicalCloudDamageThrottle = 2
	poolExplosionUnderMe = false
	flamethrowerApplied = 0
	if self:Heroic() then
		self:Berserk(600, true) -- The "Activated" message happens on engage
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Magmatron
function mod:AcquiringTargetApplied(args)
	prevIcon = args.spellId
	self:StopBar(CL.count:format(L.flamethrower, acquiringTargetCount))
	self:TargetMessage(args.spellId, "yellow", args.destName, L.flamethrower)
	acquiringTargetCount = acquiringTargetCount + 1
	if acquiringTargetCount < 3 then
		self:CDBar(79501, self:Normal() and 40.2 or 27.5, CL.count:format(L.flamethrower, acquiringTargetCount))
	end
	self:SecondaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		flamethrowerApplied = args.time
		self:Say(args.spellId, L.flamethrower, nil, "Flamethrower")
		self:SayCountdown(args.spellId, 4, L.flamethrower, 2, "Flamethrower")
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:AcquiringTargetRemoved(args)
	if args.spellId == prevIcon then
		self:SecondaryIcon(args.spellId)
	end
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:IncinerationSecurityMeasure(args)
	local msg = CL.count:format(L.incinerate, incinerationCount)
	self:StopBar(msg)
	self:Message(args.spellId, "red", msg)
	incinerationCount = incinerationCount + 1
	if incinerationCount < 3 then
		self:CDBar(args.spellId, 27.5, CL.count:format(L.incinerate, incinerationCount))
	elseif incinerationCount == 3 and self:Normal() then
		self:CDBar(args.spellId, 30.7, CL.count:format(L.incinerate, incinerationCount))
	end
	self:PlaySound(args.spellId, "alert")
end

-- Electron
function mod:LightningConductor(args)
	self:StopBar(CL.count:format(L.lightning, lightningConductorCount))
	lightningConductorCount = lightningConductorCount + 1
	if lightningConductorCount < 4 then
		self:CDBar(args.spellId, self:Normal() and 25.8 or 21, CL.count:format(L.lightning, lightningConductorCount))
	end
end

function mod:LightningConductorApplied(args)
	prevIcon = args.spellId
	self:TargetMessage(args.spellId, "yellow", args.destName, L.lightning)
	self:SecondaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, L.lightning, nil, "Lightning")
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:LightningConductorRemoved(args)
	if args.spellId == prevIcon then
		self:SecondaryIcon(args.spellId)
	end
end

-- Toxitron
do
	local function printTarget(self, _, guid)
		if self:Me(guid) then
			-- Not shortening this to "Bomb" as the adds are called "Poison Bomb" and might cause confusion
			self:PersonalMessage(80157)
			self:Say(80157, nil, nil, "Chemical Bomb")
		end
	end
	function mod:ChemicalBomb(args)
		self:GetUnitTarget(printTarget, 0.3, args.sourceGUID)
	end
end

function mod:FixateApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:PoisonProtocol(args)
	self:StopBar(CL.count:format(CL.adds, poisonProtocolCount))
	self:Message(args.spellId, "red", CL.incoming:format(CL.adds))
	poisonProtocolCount = poisonProtocolCount + 1
	if poisonProtocolCount < 3 then
		self:CDBar(args.spellId, self:Normal() and 45.5 or 25.6, CL.count:format(CL.adds, poisonProtocolCount))
	end
	self:PlaySound(args.spellId, "info")
end

do
	local prev = 0
	function mod:ChemicalCloudDamage(args)
		if self:Me(args.destGUID) and args.time - prev > chemicalCloudDamageThrottle then -- Some people ignore it if a Power Generator (Pool) is under it, so we try to slowly increase the throttle
			prev = args.time
			chemicalCloudDamageThrottle = chemicalCloudDamageThrottle + 1
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

-- Arcanotron
function mod:ArcaneAnnihilator(args)
	arcaneAnnihilatorCount = arcaneAnnihilatorCount + 1
	if arcaneAnnihilatorCount == 4 then arcaneAnnihilatorCount = 1 end

	local isPossible, isReady = self:Interrupter(args.sourceGUID)
	if isPossible then
		self:Message(args.spellId, "red", CL.count:format(args.spellName, arcaneAnnihilatorCount))
		if isReady then
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:PowerGenerator(args)
	local msg = CL.count:format(CL.pool, powerGeneratorCount)
	self:StopBar(msg)
	self:Message(args.spellId, "orange", msg)
	powerGeneratorCount = powerGeneratorCount + 1
	if powerGeneratorCount < 4 then
		self:CDBar(args.spellId, self:Normal() and 29.4 or 21, CL.count:format(CL.pool, powerGeneratorCount))
	end
	self:PlaySound(args.spellId, "info")
end

do
	local prev = 0
	function mod:ConvertedPowerAppliedDose(args)
		if not self:Player(args.destFlags) and args.time - prev > 2 and self:Dispeller("magic", true, args.spellId) then -- Can be Spellstolen
			prev = args.time
			self:Message(args.spellId, "orange", CL.magic_buff_other:format(args.destName, args.spellName))
			self:PlaySound(args.spellId, "info")
		end
	end
end

-- Heroic
function mod:OverchargedPowerGenerator()
	self:Message(91879, "orange", L.pool_explosion)
	self:Bar(91879, 8, L.pool_explosion)
	self:CDBar("nef", 35, CL.next_ability, L.nef_icon)
	self:PlaySound(91879, "warning")
end

do
	local function PoolExplosion()
		if poolExplosionUnderMe and mod:IsEngaged() then
			mod:SimpleTimer(PoolExplosion, 2)
			mod:PersonalMessage(91879, "underyou", L.pool_explosion)
			mod:PlaySound(91879, "underyou")
		end
	end
	function mod:OverchargedPowerGeneratorApplied(args)
		if not poolExplosionUnderMe and self:Me(args.destGUID) then
			poolExplosionUnderMe = true
			PoolExplosion()
		end
	end

	function mod:OverchargedPowerGeneratorRemoved(args)
		if poolExplosionUnderMe and self:Me(args.destGUID) then
			poolExplosionUnderMe = false
		end
	end
end

function mod:GripOfDeath(args)
	gripOfDeathCount = gripOfDeathCount + 1
	self:Message(args.spellId, "orange", CL.count:format(args.spellName, gripOfDeathCount))
	self:CastBar(args.spellId, 2, CL.count:format(args.spellName, gripOfDeathCount))
	self:CDBar("nef", 35, CL.next_ability, L.nef_icon)
end

function mod:EncasingShadows()
	self:CDBar("nef", 35, CL.next_ability, L.nef_icon)
end

function mod:EncasingShadowsApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName, CL.rooted)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(79501) -- Acquiring Target (Flamethrower)
		local duration = 4 - (args.time-flamethrowerApplied)
		self:SayCountdown(79501, duration > 1 and duration or 4, CL.plus:format(L.flamethrower, CL.rooted), 2, "Flamethrower + Rooted")
		self:Say(args.spellId, CL.rooted, nil, "Rooted")
		self:SayCountdown(args.spellId, 8, CL.rooted, 4, "Rooted")
	end
end

function mod:EncasingShadowsRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(79501) -- Acquiring Target (Flamethrower)
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:ShadowInfusionApplied(args)
	prevIcon = args.spellId
	self:TargetMessage(args.spellId, "orange", args.destName, L.infusion)
	self:CDBar("nef", 35, CL.next_ability, L.nef_icon)
	self:SecondaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:CastBar(args.spellId, 5)
		self:Say(args.spellId, L.infusion, nil, "Infusion")
		self:SayCountdown(args.spellId, 5)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:ShadowInfusionRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:ShadowConductorApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:Yell(args.spellId, nil, nil, "Shadow Conductor")
		self:YellCountdown(args.spellId, 10, nil, 6)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:ShadowConductorRemoved(args)
	if 92048 == prevIcon then
		self:SecondaryIcon(92048) -- Shadow Infusion
	end
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "removed")
		self:CancelYellCountdown(args.spellId)
	end
end

-- General
do
	local prev = 0
	function mod:ActivatedApplied(args)
		local timer = self:Heroic() and 27 or 42
		if (args.time - prev) > timer then
			prev = args.time
			self:Bar(args.spellId, timer+3)
			self:TargetMessage(args.spellId, "cyan", args.destName)
			local npcId = self:MobId(args.sourceGUID)
			if npcId == 42180 then -- Toxitron
				poisonProtocolCount = 1
				chemicalCloudDamageThrottle = 2
				self:CDBar(80053, self:Normal() and 21 or 15.5, CL.count:format(CL.adds, poisonProtocolCount)) -- Poison Protocol
			elseif npcId == 42178 then -- Magmatron
				acquiringTargetCount = 1
				incinerationCount = 1
				self:CDBar(79023, 12, CL.count:format(L.incinerate, incinerationCount)) -- Incineration Security Measure
				self:CDBar(79501, 20.5, CL.count:format(L.flamethrower, acquiringTargetCount)) -- Acquiring Target
			elseif npcId == 42179 then -- Electron
				lightningConductorCount = 1
				self:CDBar(79888, self:Normal() and 13 or 15.7, CL.count:format(L.lightning, lightningConductorCount)) -- Lightning Conductor
			elseif npcId == 42166 then -- Arcanotron
				arcaneAnnihilatorCount = 0
				powerGeneratorCount = 1
				self:CDBar(79624, 15, CL.count:format(CL.pool, powerGeneratorCount)) -- Power Generator
			end
			local unit = self:GetUnitIdByGUID(args.destGUID)
			if unit then
				self:CustomIcon(activatedMarker, unit, 8)
			end
			self:PlaySound(args.spellId, "long")
		end
	end
end

function mod:ShuttingDown(args)
	local npcId = self:MobId(args.sourceGUID)
	if npcId == 42180 then -- Toxitron
		self:StopBar(CL.count:format(CL.adds, poisonProtocolCount)) -- Poison Protocol
	elseif npcId == 42178 then -- Magmatron
		self:StopBar(CL.count:format(L.incinerate, incinerationCount)) -- Incineration Security Measure
		self:StopBar(CL.count:format(L.flamethrower, acquiringTargetCount)) -- Acquiring Target
	elseif npcId == 42179 then -- Electron
		self:StopBar(CL.count:format(L.lightning, lightningConductorCount)) -- Lightning Conductor
	elseif npcId == 42166 then -- Arcanotron
		self:StopBar(CL.count:format(CL.pool, powerGeneratorCount)) -- Power Generator
	end
end
