--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Oondasta", -507, 826)
if not mod then return end
mod:RegisterEnableMob(69161)
mod.otherMenu = -424
mod.worldBoss = 69161

--------------------------------------------------------------------------------
-- Locals
--

local roarCounter = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {{137504, "TANK_HEALER"}, 137457, 137505, "proximity"}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Crush", 137504)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Crush", 137504)
	self:Log("SPELL_CAST_START", "PiercingRoar", 137457)
	self:Log("SPELL_CAST_START", "FrillBlast", 137505)

	self:RegisterEvent("PLAYER_REGEN_DISABLED", "CheckForEngage")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")

	self:Death("Win", 69161)
end

function mod:OnEngage()
	self:OpenProximity("proximity", 10)
	roarCounter = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Crush(args)
	self:StackMessageOld(args.spellId, args.destName, args.amount, "orange", "info")
end

function mod:PiercingRoar(args)
	roarCounter = roarCounter + 1
	self:MessageOld(args.spellId, "yellow", UnitPowerType("player") == 0 and "long", CL["count"]:format(args.spellName, roarCounter)) -- sound for mana users
	self:Bar(args.spellId, 25, CL["count"]:format(args.spellName, roarCounter+1))
end

function mod:FrillBlast(args)
	self:MessageOld(args.spellId, "red", "alert")
	self:Bar(args.spellId, 25)
end

