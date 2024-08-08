--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Avatar of Hakkar Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(221426, 221396, 221394) -- Atal'ai Ritualist, Hakkari Bloodkeeper, Avatar of Hakkar
mod:SetEncounterID(2956)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local corruptedBloodOnMe = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Avatar of Hakkar"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		443990, -- Frightsome Howl
		443953, -- Bubbling Blood
		{444039, "SAY", "ME_ONLY_EMPHASIZE"}, -- Insanity
		444046, -- Curse of Tongues
		{444255, "SAY", "ME_ONLY_EMPHASIZE"}, -- Corrupted Blood
		{444132, "CASTBAR", "CASTBAR_COUNTDOWN"}, -- Drain Blood
	},nil,{
		[443990] = CL.fear, -- Frightsome Howl (Fear)
		[444039] = CL.mind_control, -- Insanity (Mind Control)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "FrightsomeHowlStart", 443990)
	self:Log("SPELL_INTERRUPT", "Interrupted", "*")
	self:Log("SPELL_CAST_SUCCESS", "Hakkar", 444761)
	self:Log("SPELL_CAST_START", "InsanityStart", 444039)
	self:Log("SPELL_CAST_START", "CurseOfTonguesStart", 444046)
	self:Log("SPELL_AURA_APPLIED", "CorruptedBloodApplied", 444255)
	self:Log("SPELL_AURA_REMOVED", "CorruptedBloodRemoved", 444255)
	self:Log("SPELL_CAST_START", "DrainBloodStart", 444132)

	self:Log("SPELL_AURA_APPLIED", "BubblingBloodDamage", 443953)
	self:Log("SPELL_PERIODIC_DAMAGE", "BubblingBloodDamage", 443953)
	self:Log("SPELL_PERIODIC_MISSED", "BubblingBloodDamage", 443953)
end

function mod:OnEngage()
	corruptedBloodOnMe = false
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(443990, 31.4, CL.fear) -- Frightsome Howl
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FrightsomeHowlStart(args)
	self:StopBar(CL.fear)
	self:Message(args.spellId, "red", CL.fear)
	self:PlaySound(args.spellId, "warning")
end

function mod:Interrupted(args)
	if args.extraSpellName == self:SpellName(443990) then
		self:Message(443990, "green", CL.interrupted_by:format(CL.fear, self:ColorName(args.sourceName)))
	elseif args.extraSpellName == self:SpellName(444046) then
		self:Message(444046, "green", CL.interrupted_by:format(args.spellName, self:ColorName(args.sourceName)))
	end
end

function mod:Hakkar() -- Stage 2
	self:StopBar(CL.fear)
	self:SetStage(2)
	self:CDBar(444039, 13, CL.mind_control) -- Insanity
	self:CDBar(444046, 19.1) -- Curse of Tongues
	self:CDBar(444132, 26) -- Drain Blood
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "info")
end

do
	local function printTarget(self, name, guid)
		self:TargetMessage(444039, "red", name, CL.mind_control)
		if self:Me(guid) then
			self:Say(444039, CL.mind_control, nil, "Mind Control")
			self:PlaySound(444039, "warning", nil, name)
		end
	end

	function mod:InsanityStart(args)
		self:GetUnitTarget(printTarget, 0.5, args.sourceGUID) -- Can take a while to swap target
		self:CDBar(args.spellId, 27.5, CL.mind_control)
	end
end

function mod:CurseOfTonguesStart(args)
	self:Message(args.spellId, "orange", CL.extra:format(args.spellName, CL.interruptible))
	self:CDBar(args.spellId, 32.3)
	self:PlaySound(args.spellId, "alarm")
end

function mod:CorruptedBloodApplied(args)
	if self:Me(args.destGUID) then
		corruptedBloodOnMe = true
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
		self:Say(args.spellId, nil, nil, "Corrupted Blood")
	end
end

function mod:CorruptedBloodRemoved(args)
	if self:Me(args.destGUID) then
		corruptedBloodOnMe = false
		self:PersonalMessage(args.spellId, "removed")
	end
end

function mod:DrainBloodStart(args)
	self:Message(args.spellId, "yellow")
	self:CDBar(args.spellId, 34)
	if corruptedBloodOnMe then
		self:CastBar(args.spellId, 4)
	end
	self:PlaySound(args.spellId, "long")
end

do
	local prev = 0
	function mod:BubblingBloodDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
