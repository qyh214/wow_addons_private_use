--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Prophet Skeram", 531, 1543)
if not mod then return end
mod:RegisterEnableMob(15263)
mod:SetEncounterID(709)

--------------------------------------------------------------------------------
-- Locals
--

local splitPhase = 1
local summonImagePercent = 75

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["747_icon"] = "spell_shadow_impphaseshift"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{785, "ICON", "SAY", "SAY_COUNTDOWN"}, -- True Fulfillment
		20449, -- Teleport
		26192, -- Arcane Explosion
		747, -- Summon Images
	},nil,{
		[785] = CL.mind_control, -- True Fulfillment (Mind Control)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "TrueFulfillmentApplied", 785)
	self:Log("SPELL_AURA_REMOVED", "TrueFulfillmentRemoved", 785)
	self:Log("SPELL_CAST_SUCCESS", "Teleport", 20449, 4801, 8195)
	self:Log("SPELL_CAST_START", "ArcaneExplosion", 26192)
	self:Log("SPELL_CAST_SUCCESS", "SummonImages", 747)
end

function mod:OnEngage()
	splitPhase = 1
	summonImagePercent = 75
	self:RegisterEvent("UNIT_HEALTH")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prevMindControl = nil
	function mod:TrueFulfillmentApplied(args) -- Mind control
		prevMindControl = args.destGUID
		self:TargetMessage(args.spellId, "yellow", args.destName, CL.mind_control)
		self:TargetBar(args.spellId, 20, args.destName, CL.mind_control_short)
		self:PrimaryIcon(args.spellId, args.destName)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, CL.mind_control, nil, "Mind Control")
			self:SayCountdown(args.spellId, 20, 8, 18)
		end
		self:PlaySound(args.spellId, "alert", nil, args.destName)
	end
	function mod:TrueFulfillmentRemoved(args)
		self:StopBar(CL.mind_control_short, args.destName)
		if self:Me(args.destGUID) then
			self:CancelSayCountdown(args.spellId)
		end
		if args.destGUID == prevMindControl then
			prevMindControl = nil
			self:PrimaryIcon(args.spellId)
		end
	end
end

function mod:Teleport(args)
	if self:MobId(args.sourceGUID) == 15263 then -- Filter out his images
		self:Message(20449, "red")
		self:PlaySound(20449, "alert")
	end
end

function mod:ArcaneExplosion(args)
	self:Message(args.spellId, "orange")
end

function mod:SummonImages(args)
	self:Message(args.spellId, "cyan", CL.percent:format(summonImagePercent, args.spellName), L["747_icon"])
	summonImagePercent = summonImagePercent - 25
	self:PlaySound(args.spellId, "info")
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15263 then
		local hp = self:GetHealth(unit)
		if (hp < 82 and splitPhase == 1) or (hp < 57 and splitPhase == 2) or (hp < 32 and splitPhase == 3) then
			splitPhase = splitPhase + 1
			if splitPhase > 3 then
				self:UnregisterEvent(event)
			end
			self:Message(747, "cyan", CL.soon:format(self:SpellName(747)), false) -- Summon Images
		end
	end
end
