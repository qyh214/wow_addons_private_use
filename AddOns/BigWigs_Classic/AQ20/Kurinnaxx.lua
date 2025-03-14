--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Kurinnaxx", 509, 1537)
if not mod then return end
mod:RegisterEnableMob(15348)
mod:SetEncounterID(718)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["25648_desc"] = 25656 -- 25648 has no description, so using an alternative
	L["25648_icon"] = "inv_misc_dust_02" -- 25648 has no icon, so using an alternative
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		25646, -- Mortal Wound
		{25648, "SAY", "ME_ONLY_EMPHASIZE"}, -- Sand Trap
		26527, -- Frenzy / Enrage (different name on classic era)
	},nil,{
		[26527] = CL.health_percent:format(30), -- Frenzy / Enrage (30% Health)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MortalWound", 25646)
	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWound", 25646)
	self:Log("SPELL_AURA_REMOVED", "MortalWoundRemoved", 25646)
	self:Log("SPELL_CREATE", "SandTrap", 25648)
	self:Log("SPELL_AURA_APPLIED", "FrenzyEnrage", 26527)
end

function mod:OnEngage()
	self:RegisterEvent("UNIT_HEALTH")
	self:CDBar(25648, 8, nil, L["25648_icon"]) -- Sand Trap
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MortalWound(args)
	local amount = args.amount or 1
	self:StackMessage(args.spellId, "purple", args.destName, amount, 5)
	self:TargetBar(args.spellId, 15, args.destName)
	if amount >= 5 and self:Tank() then
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:MortalWoundRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:SandTrap(args)
	self:TargetMessage(args.spellId, "orange", args.sourceName, args.spellName, L["25648_icon"])
	self:CDBar(args.spellId, 8, args.spellName, L["25648_icon"])
	if self:Me(args.sourceGUID) then
		self:Say(args.spellId, nil, nil, "Sand Trap")
		self:PlaySound(args.spellId, "alert", nil, args.sourceName)
	end
end

function mod:FrenzyEnrage(args)
	self:Message(args.spellId, "red", CL.percent:format(30, args.spellName))
	self:PlaySound(args.spellId, "long")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15348 then
		local hp = self:GetHealth(unit)
		if hp < 36 then
			self:UnregisterEvent(event)
			if hp > 30 then
				self:Message(26527, "green", CL.soon:format(self:SpellName(26527)), false) -- Frenzy / Enrage
			end
		end
	end
end
