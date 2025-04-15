--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Flame Leviathan", 603, 1637)
if not mod then return end
mod:RegisterEnableMob(33113)
mod:SetEncounterID(BigWigsLoader.isWrath and 744 or 1132)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		68605, -- Blue Pyrite
		62396, -- Flame Vents
		{62374, "FLASH"}, -- Pursued
		62475, -- Systems Shutdown
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "FlameVents", 62396)
	self:Log("SPELL_AURA_REMOVED", "FlameVentsStopped", 62396)

	self:Log("SPELL_AURA_APPLIED", "SystemsShutdown", 62475)

	self:Log("SPELL_AURA_APPLIED", "BluePyrite", 68605)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BluePyrite", 68605)
	self:Log("SPELL_AURA_REFRESH", "BluePyrite", 68605)

	self:Log("SPELL_AURA_APPLIED", "Pursued", 62374)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BluePyrite(args)
	if bit.band(args.sourceFlags, 0x1) ~= 0 then -- Can't rely on GUID when we're in a vehicle. COMBATLOG_OBJECT_AFFILIATION_MINE = 0x1
		self:Bar(args.spellId, 10) -- Your specific debuff duration
	end
end

function mod:FlameVents(args)
	self:MessageOld(args.spellId, "orange")
	self:Bar(args.spellId, 10) -- Buff duration
end

function mod:FlameVentsStopped(args)
	self:StopBar(args.spellName)
end

function mod:SystemsShutdown(args)
	if self:MobId(args.destGUID) == 33113 then -- Flame Leviathan
		self:MessageOld(args.spellId, "green", "long")
		self:Bar(args.spellId, 20)
	end
end

function mod:Pursued(args)
	if bit.band(args.destFlags, 0x1) ~= 0 then -- Can't rely on GUID when we're in a vehicle. COMBATLOG_OBJECT_AFFILIATION_MINE = 0x1
		local me = self:UnitName("player")
		self:TargetMessageOld(args.spellId, me, "blue", "alarm")
		self:Flash(args.spellId)
		self:TargetBar(args.spellId, 30, me)
	else
		for unit in self:IterateGroup() do
			local guid = self:UnitGUID(unit.."pet")
			if guid == args.destGUID then
				local name = self:UnitName(unit)
				self:TargetMessageOld(args.spellId, name, "blue", "alarm")
				self:TargetBar(args.spellId, 30, name)
				break
			end
		end
	end
end

