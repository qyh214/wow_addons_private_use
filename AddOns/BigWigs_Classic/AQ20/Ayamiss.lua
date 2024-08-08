--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ayamiss the Hunter", 509, 1541)
if not mod then return end
mod:RegisterEnableMob(15369)
mod:SetEncounterID(722)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local hasStageWarned = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.sacrifice = "Sacrifice"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		{25725, "ICON"}, -- Paralyze
		8269, -- Frenzy / Enrage (different name on classic era)
		17742, -- Cloud of Disease
	},nil,{
		[25725] = L.sacrifice, -- Paralyze (Sacrifice)
		[8269] = CL.health_percent:format(20), -- Frenzy / Enrage (20% Health)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Paralyze", 25725)
	self:Log("SPELL_AURA_REMOVED", "ParalyzeRemoved", 25725)
	self:Log("SPELL_AURA_APPLIED", "FrenzyEnrage", 8269)

	self:Log("SPELL_AURA_APPLIED", "CloudOfDiseaseDamage", 17742)
	self:Log("SPELL_PERIODIC_DAMAGE", "CloudOfDiseaseDamage", 17742)
	self:Log("SPELL_PERIODIC_MISSED", "CloudOfDiseaseDamage", 17742)
end

function mod:OnEngage()
	hasStageWarned = false
	self:SetStage(1)
	self:RegisterEvent("UNIT_HEALTH")
	self:Message("stages", "cyan", CL.stage:format(1), false)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Paralyze(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, L.sacrifice)
	self:TargetBar(args.spellId, 10, args.destName, L.sacrifice)
	self:PrimaryIcon(args.spellId, args.destName)
	self:PlaySound(args.spellId, "alarm")
end

function mod:ParalyzeRemoved(args)
	self:PrimaryIcon(args.spellId)
	self:StopBar(L.sacrifice, args.destName)
end

function mod:FrenzyEnrage(args)
	self:Message(args.spellId, "red", CL.percent:format(20, args.spellName))
end

do
	local prev = 0
	function mod:CloudOfDiseaseDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15369 then
		local hp = self:GetHealth(unit)
		if hp < 71 and not hasStageWarned then
			hasStageWarned = true
			self:SetStage(2)
			self:Message("stages", "cyan", CL.percent:format(70, CL.stage:format(2)), false)
			self:PlaySound("stages", "long")
		elseif hp < 26 then
			self:UnregisterEvent(event)
			if hp > 20 then
				self:Message(8269, "green", CL.soon:format(self:SpellName(8269)), false) -- Frenzy / Enrage
			end
		end
	end
end
