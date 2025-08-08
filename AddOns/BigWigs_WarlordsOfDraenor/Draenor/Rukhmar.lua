
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Rukhmar", -542, 1262)
if not mod then return end
mod:RegisterEnableMob(83746)
mod.otherMenu = -572
mod.worldBoss = 83746
--BOSS_KILL#1755#Rukhmar, Sun-God of the Arakkoa

--------------------------------------------------------------------------------
-- Locals
--

local fixateOnMe = nil

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{167615, "TANK"}, -- Pierce Armor
		167679, -- Solar Breath
		167647, -- Loose Quills
		{167757, "FLASH"}, -- Fixate
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:Log("SPELL_AURA_APPLIED", "PiercedArmor", 167615)
	self:Log("SPELL_AURA_APPLIED_DOSE", "PiercedArmor", 167615)
	self:Log("SPELL_CAST_START", "SolarBreath", 167679)
	self:Log("SPELL_AURA_APPLIED", "LooseQuills", 167647)
	self:Log("SPELL_AURA_REMOVED", "LooseQuillsOver", 167647)
	self:Log("SPELL_AURA_APPLIED", "Fixate", 167757)
	self:Log("SPELL_AURA_REMOVED", "FixateOver", 167757)

	self:RegisterEvent("BOSS_KILL")
end

function mod:OnEngage()
	fixateOnMe = nil
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Fixate(args)
	if self:Me(args.destGUID) and not fixateOnMe then -- Multiple debuffs, warn for the first.
		fixateOnMe = true
		self:TargetMessageOld(args.spellId, args.destName, "blue", "alarm")
		self:Flash(args.spellId)
	end
end

function mod:FixateOver(args)
	if self:Me(args.destGUID) and not self:UnitDebuff("player", args.spellName, 167757) then
		fixateOnMe = nil
		self:MessageOld(args.spellId, "blue", "alarm", CL.over:format(args.spellName))
	end
end

function mod:PiercedArmor(args)
	self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow", "warning")
end

function mod:SolarBreath(args)
	self:MessageOld(args.spellId, "orange")
	self:CDBar(args.spellId, 28)
end

function mod:LooseQuills(args)
	self:MessageOld(args.spellId, "yellow", "long")
	self:Bar(args.spellId, 30)
	self:StopBar(167679) -- Solar Breath
end

function mod:LooseQuillsOver(args)
	self:MessageOld(args.spellId, "yellow", nil, CL.over:format(args.spellName))
end

function mod:BOSS_KILL(_, id)
	if id == 1755 then
		self:Win()
	end
end

