--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Princess Huhuran", 531, 1546)
if not mod then return end
mod:RegisterEnableMob(15509)
mod:SetEncounterID(714)

--------------------------------------------------------------------------------
-- Locals
--

local poisonCount = 0
local poisonTime = 0

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		26180, -- Wyvern Sting
		26051, -- Enrage / Frenzy (different name on classic era)
		"berserk",
	},nil,{
		["berserk"] = CL.health_percent:format(30), -- Berserk (30% Health)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "WyvernSting", 26180)
	self:Log("SPELL_AURA_APPLIED", "WyvernStingApplied", 26180)
	self:Log("SPELL_AURA_REMOVED", "WyvernStingRemoved", 26180)
	self:Log("SPELL_AURA_APPLIED", "EnrageFrenzy", 26051)
	self:Log("SPELL_DISPEL", "EnrageFrenzyDispelled", "*")
	self:Log("SPELL_AURA_APPLIED", "BerserkApplied", 26068)
end

function mod:OnEngage()
	poisonCount = 0
	poisonTime = 0
	self:RegisterEvent("UNIT_HEALTH")
	self:Berserk(300)
	self:CDBar(26180, 21) -- Wyvern Sting, can randomly be way higher
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WyvernSting(args)
	poisonCount = 0
	poisonTime = args.time
	self:CDBar(args.spellId, 25) -- Can randomly be way higher than 25
	self:Message(args.spellId, "red", CL.on_group:format(args.spellName))
	self:PlaySound(args.spellId, "alert")
end

function mod:WyvernStingApplied(args)
	if self:Player(args.destFlags) then -- Players, not pets
		poisonCount = poisonCount + 1
	end
end

function mod:WyvernStingRemoved(args)
	if self:Player(args.destFlags) then -- Players, not pets
		poisonCount = poisonCount - 1
		if poisonCount == 0 then
			self:Message(args.spellId, "green", CL.removed_after:format(args.spellName, args.time-poisonTime))
		end
	end
end

function mod:EnrageFrenzy(args)
	self:CDBar(args.spellId, 14.5)
	self:Message(args.spellId, "yellow", CL.buff_boss:format(args.spellName))
	if self:Dispeller("enrage", true) then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:EnrageFrenzyDispelled(args)
	if args.extraSpellName == self:SpellName(26051) then
		self:Message(26051, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:BerserkApplied()
	self:StopBar(26051) -- Enrage / Frenzy (different name on classic era)
	self:StopBerserk(self:SpellName(26662))

	self:Message("berserk", "red", CL.percent:format(30, self:SpellName(26662)), 26662)
	self:PlaySound("berserk", "long")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15509 then
		local hp = self:GetHealth(unit)
		if hp < 36 then
			self:UnregisterEvent(event)
			if hp > 30 then
				self:Message("berserk", "red", CL.soon:format(self:SpellName(26662)), false)
			end
		end
	end
end
