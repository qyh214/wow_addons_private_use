--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lady Sarevess Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(204068) -- Lady Sarevess Season of Discovery
mod:SetEncounterID(2699)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lady Sarevess"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{407653, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Forked Lightning
		407568, -- Freezing Arrow
		{367741, "DISPEL"}, -- Frozen Solid (Fake proxy spell)
		{407791, "DISPEL"}, -- Aku'mai's Rage
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "ForkedLightning", 407653)
	self:Log("SPELL_AURA_APPLIED", "ForkedLightningApplied", 407653)
	self:Log("SPELL_AURA_REMOVED", "ForkedLightningRemoved", 407653)
	self:Log("SPELL_CAST_START", "FreezingArrow", 407568)
	self:Log("SPELL_AURA_APPLIED", "FreezingArrowApplied", 407546)

	self:Log("SPELL_AURA_APPLIED", "FreezingArrowUnderYou", 407548)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FreezingArrowUnderYou", 407548)

	self:Log("SPELL_AURA_APPLIED", "AkumaisRageApplied", 407791)
	self:Log("SPELL_DISPEL", "AkumaisRageDispelled", "*")
end

function mod:OnEngage()
	self:CDBar(407568, 5) -- Freezing Arrow
	self:CDBar(407653, 15) -- Forked Lightning
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ForkedLightning(args)
	self:CDBar(args.spellId, 20)
end

function mod:ForkedLightningApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Forked Lightning")
		self:SayCountdown(args.spellId, 8)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:ForkedLightningRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:PrimaryIcon(args.spellId)
end

function mod:FreezingArrow(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:Bar(args.spellId, 24)
	self:PlaySound(args.spellId, "alert")
end

function mod:FreezingArrowApplied(args)
	if self:Player(args.destFlags) then -- Players
		self:TargetMessage(367741, "red", args.destName, self:SpellName(367741)) -- Frozen Solid
		if self:Dispeller("magic", nil, 367741) then
			self:PlaySound(367741, "alarm")
		end
	elseif self:Hostile(args.destFlags) then -- Also applies to the Blackfathom Elites (hostile only to filter player pets)
		self:TargetMessage(367741, "green", args.destName, self:SpellName(367741)) -- Frozen Solid
	end
end

do
	local prev = 0
	function mod:FreezingArrowUnderYou(args)
		if self:Me(args.destGUID) then
			self:PersonalMessage(407568, "underyou")
			if args.time - prev > 2 then
				prev = args.time
				self:PlaySound(407568, "underyou")
			end
		end
	end
end

function mod:AkumaisRageApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	self:Bar(args.spellId, 15)
	if self:Dispeller("enrage", true, args.spellId) then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:AkumaisRageDispelled(args)
	if args.extraSpellName == self:SpellName(407791) then
		self:Message(407791, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end
