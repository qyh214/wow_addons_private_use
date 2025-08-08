--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Mason the Echo", 2856)
if not mod then return end
mod:RegisterEnableMob(241021)
mod:SetEncounterID(3197)
mod:SetRespawnTime(25)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local nextTidal = 75
local curseCount = 0
local curseTime = 0
local prevTidalForceStacks = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Mason the Echo"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		1231592, -- Drowning Shallows
		1231585, -- Tidal Force
		1234347, -- Ignite Flesh
		1229005, -- Mortal Wound
		"berserk",
	},nil,{
		[1231592] = CL.curse, -- Drowning Shallows (Curse)
		[1231585] = CL.shield, -- Tidal Force (Shield)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "DrowningShallows", 1231592)
	self:Log("SPELL_AURA_APPLIED", "DrowningShallowsApplied", 1231592)
	self:Log("SPELL_AURA_REMOVED", "DrowningShallowsRemoved", 1231592)
	self:Log("SPELL_CAST_START", "TidalForce", 1231585)
	self:Log("SPELL_AURA_APPLIED", "TidalForceApplied", 1231585)
	self:Log("SPELL_AURA_REMOVED", "TidalForceRemoved", 1231585)
	self:Log("SPELL_AURA_APPLIED", "TidalForceBuffApplied", 1231587)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TidalForceBuffApplied", 1231587)
	self:Log("SPELL_CAST_START", "IgniteFlesh", 1234347)
	self:Log("SPELL_INTERRUPT", "IgniteFleshInterrupted", "*")
	self:Log("SPELL_AURA_APPLIED", "MortalWoundApplied", 1229005)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWoundApplied", 1229005)
end

function mod:OnEngage()
	nextTidal = 75
	curseCount = 0
	curseTime = 0
	prevTidalForceStacks = 0
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DrowningShallows(args)
	curseTime = args.time
	curseCount = 0
	self:Message(args.spellId, "orange", CL.curse)
	self:PlaySound(args.spellId, "alert")
end

function mod:DrowningShallowsApplied(args)
	if self:Player(args.destFlags) then -- Players, not pets
		curseCount = curseCount + 1
	end
end

function mod:DrowningShallowsRemoved(args)
	if self:Player(args.destFlags) then -- Players, not pets
		curseCount = curseCount - 1
		if curseCount == 0 then
			self:Message(args.spellId, "green", CL.removed_after:format(CL.curse, args.time-curseTime))
		end
	end
end

function mod:TidalForce(args)
	self:Message(args.spellId, "red", CL.percent:format(nextTidal, CL.shield))
	self:PlaySound(args.spellId, "long")
end

do
	local appliedTime, currentStacks = 0, 0
	function mod:TidalForceApplied(args)
		appliedTime = args.time
		nextTidal = nextTidal - 25
		self:Bar(args.spellId, 60, CL.shield)
	end

	function mod:TidalForceBuffApplied(args)
		currentStacks = args.amount or 1
	end

	function mod:TidalForceRemoved(args)
		local diff = currentStacks-prevTidalForceStacks
		prevTidalForceStacks = currentStacks
		self:StopBar(CL.shield)
		self:Message(args.spellId, "cyan", CL.removed_after:format(CL.shield, args.time-appliedTime), nil, nil, 4) -- Stay onscreen for 4s
		if nextTidal == 50 then -- The first one at 75% doesn't need extra text
			self:Message(args.spellId, "cyan", CL.stackboss:format(currentStacks, args.spellName), nil, nil, 4) -- Stay onscreen for 4s
		else
			self:Message(args.spellId, "cyan", CL.extra:format(CL.stackboss:format(currentStacks, args.spellName), CL.stack_gained:format(diff)), nil, nil, 4) -- Stay onscreen for 4s
		end
	end
end

function mod:IgniteFlesh(args)
	if args.sourceGUID == self:UnitGUID("target") then
		self:Message(args.spellId, "yellow", CL.extra:format(CL.casting:format(args.spellName), CL.interruptible))
		self:PlaySound(args.spellId, "info")
	end
end

function mod:IgniteFleshInterrupted(args)
	if args.destGUID == self:UnitGUID("target") and args.extraSpellName == self:SpellName(1234347) then
		self:Message(1234347, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:MortalWoundApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 1)
		self:PlaySound(args.spellId, "alarm")
	elseif self:Player(args.destFlags) then -- Players, not pets
		local bossUnit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID)
		if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
			self:StackMessage(args.spellId, "purple", args.destName, args.amount, 1)
		end
	end
end
