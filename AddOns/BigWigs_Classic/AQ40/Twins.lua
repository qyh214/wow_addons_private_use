--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Twin Emperors", 531, 1549)
if not mod then return end
mod:RegisterEnableMob(15275, 15276) -- Emperor Vek'nilash, Emperor Vek'lor
mod:SetEncounterID(715)

--------------------------------------------------------------------------------
-- Initialization
--

local explodeMarker = mod:AddMarkerOption(true, "npc", 8, 804, 8) -- Explode Bug
function mod:GetOptions()
	return {
		7393, -- Heal Brother
		800, -- Twin Teleport
		802, -- Mutate Bug
		{804, "EMPHASIZE"}, -- Explode Bug
		explodeMarker,
		26607, -- Blizzard
		"berserk",
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "TwinTeleport", 800)
	self:Log("SPELL_HEAL", "HealBrother", 7393)
	self:Log("SPELL_AURA_APPLIED", "MutateBug", 802)
	self:Log("SPELL_AURA_APPLIED", "ExplodeBug", 804)

	self:Log("SPELL_AURA_APPLIED", "BlizzardDamage", 26607)
	self:Log("SPELL_PERIODIC_DAMAGE", "BlizzardDamage", 26607)
	self:Log("SPELL_PERIODIC_MISSED", "BlizzardDamage", 26607)
end

function mod:OnEngage()
	self:Berserk(900)
	self:CDBar(800, 30) -- Twin Teleport
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:TwinTeleport(args)
		if args.time - prev > 2 then
			prev = args.time
			self:Message(args.spellId, "orange")
			self:CDBar(args.spellId, 30)
			self:PlaySound(args.spellId, "alert")
		end
	end
end

do
	local prev = 0
	function mod:HealBrother(args)
		if args.time - prev > 10 then
			prev = args.time
			self:Message(args.spellId, "red", CL.casting:format(args.spellName))
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:MutateBug(args)
	self:Message(args.spellId, "yellow")
	self:PlaySound(args.spellId, "info")
end

function mod:ExplodeBug(args)
	local unit = self:GetUnitIdByGUID(args.destGUID)
	if unit then
		self:CustomIcon(explodeMarker, unit, 8)
		if self:UnitWithinRange(unit, 20) then
			self:Message(args.spellId, "red", CL.near:format(args.spellName))
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

do
	local prev = 0
	function mod:BlizzardDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
