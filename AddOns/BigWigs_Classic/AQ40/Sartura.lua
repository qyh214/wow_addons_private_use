--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Battleguard Sartura", 531, 1544)
if not mod then return end
mod:RegisterEnableMob(15516, 15984) -- Battleguard Sartura, Sartura's Royal Guard
mod:SetEncounterID(711)

--------------------------------------------------------------------------------
-- Locals
--

local addsLeft = 3

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		26083, -- Whirlwind
		8269, -- Frenzy / Enrage (different name on classic era)
		"stages",
		"berserk",
	},nil,{
		[8269] = CL.health_percent:format(25), -- Frenzy / Enrage (25% Health)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "WhirlwindApplied", 26083)
	self:Log("SPELL_AURA_REMOVED", "WhirlwindRemoved", 26083)
	self:Log("SPELL_AURA_APPLIED", "FrenzyEnrage", 8269)

	self:Death("AddDies", 15984)
end

function mod:OnEngage()
	addsLeft = 3
	self:RegisterEvent("UNIT_HEALTH")
	self:Berserk(600)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WhirlwindApplied(args)
	self:Message(args.spellId, "red")
	self:Bar(args.spellId, 15)
	self:PlaySound(args.spellId, "warning")
end

function mod:WhirlwindRemoved(args)
	self:Message(args.spellId, "green", CL.over:format(args.spellName))
end

function mod:FrenzyEnrage(args)
	self:Message(args.spellId, "orange", CL.percent:format(25, args.spellName))
	self:PlaySound(args.spellId, "long")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15516 then
		local hp = self:GetHealth(unit)
		if hp < 31 then
			self:UnregisterEvent(event)
			if hp > 25 then
				self:Message(8269, "orange", CL.soon:format(self:SpellName(8269)), false)
			end
		end
	end
end

function mod:AddDies()
	addsLeft = addsLeft - 1
	self:Message("stages", "cyan", CL.add_remaining:format(addsLeft), false)
	self:PlaySound("stages", "info")
end
