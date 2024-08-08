--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Twilight Lord Kelris Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(209678) -- Twilight Lord Kelris Season of Discovery
mod:SetEncounterID(2825)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Twilight Lord Kelris"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		423135, -- Sleep
		{425460, "COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Dream Eater
		425265, -- Shadowy Chains
		"stages",
		426489, -- Manifesting Dreams
	},nil,{
		[425460] = CL.you_die, -- Dream Eater (You die)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "SleepApplied", 423135)
	self:Log("SPELL_AURA_REMOVED", "SleepRemoved", 423135)
	self:Log("SPELL_AURA_APPLIED", "DreamEaterApplied", 425460)
	self:Log("SPELL_AURA_REMOVED", "DreamEaterRemoved", 425460)
	self:Log("SPELL_CAST_START", "ShadowyChainsStart", 425265) -- Stage 1
	self:Log("SPELL_INTERRUPT", "ShadowyChainsInterrupted", "*")
	self:Log("SPELL_CAST_SUCCESS", "ShadowyChainsSuccess", 425265, 426494) -- Stage 1, Stage 2
	self:Log("SPELL_AURA_APPLIED", "ShadowyChainsApplied", 425239, 426495) -- Stage 1, Stage 2
	self:Log("SPELL_CAST_START", "MindBlast", 426493) -- Stage 2
	self:Log("SPELL_AURA_APPLIED", "ManifestingDreamsApplied", 426489)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ManifestingDreamsApplied", 426489)
end

function mod:OnEngage()
	self:SetStage(1)
	self:CDBar(423135, 8.5) -- Sleep
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local playerList, prev = {}, 0
	function mod:SleepApplied(args)
		if args.time - prev > 5 then
			prev = args.time
			playerList = {}
			self:StopBar(args.spellName) -- Sleep
		end
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "yellow", playerList, 2)
	end

	function mod:SleepRemoved(args)
		playerList[#playerList] = nil
		if #playerList == 0 then
			self:Bar(args.spellId, 10)
		end
	end
end

function mod:DreamEaterApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, false, CL.you_die_sec:format(15))
		self:Bar(args.spellId, 15, CL.you_die)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:DreamEaterRemoved(args)
	if self:Me(args.destGUID) then
		self:StopBar(CL.you_die)
	end
end

function mod:ShadowyChainsStart(args) -- First stage only
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:CDBar(args.spellId, 11.3) -- 11.3-16.2, varies depending on what's interrupted?
	if self:Interrupter() then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:ShadowyChainsInterrupted(args)
	if args.extraSpellName == self:SpellName(425265) then
		self:Message(425265, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

do
	local playerList = {}
	function mod:ShadowyChainsSuccess(args)
		playerList = {}
		if args.spellId == 426494 then -- Stage 2 (cast cannot be interrupted so we warn on success instead of start)
			self:CDBar(425265, 9.7)
		end
	end

	function mod:ShadowyChainsApplied(args)
		if self:Player(args.destFlags) then -- Players, not pets
			local count = #playerList
			if count == 0 then
				self:PlaySound(425265, "info")
			end
			playerList[count+1] = args.destName
			self:TargetsMessage(425265, "orange", playerList)
		end
	end
end

function mod:MindBlast(args) -- For lack of a better stage 2 indicator
	self:RemoveLog("SPELL_CAST_START", args.spellId)
	self:RemoveLog("SPELL_AURA_REMOVED", 423135) -- Sleep, there seems to be a bug where he might cast this once after entering stage 2
	self:StopBar(423135) -- Sleep
	self:StopBar(425265) -- Shadowy Chains
	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "long")
end

function mod:ManifestingDreamsApplied(args)
	self:StackMessage(args.spellId, "cyan", CL.boss, args.amount, 0)
	self:Bar(args.spellId, 15)
end
