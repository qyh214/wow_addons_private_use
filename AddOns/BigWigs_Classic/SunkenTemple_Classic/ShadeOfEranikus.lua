--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Shade of Eranikus Discovery", 109)
if not mod then return end
mod:RegisterEnableMob(218571) -- Shade of Eranikus
mod:SetEncounterID(2959)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Shade of Eranikus"
	L.deep_slumber_clouds = "Clouds" -- Clouds of Slumber
	L.deep_slumber_player_debuff = "Player"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		437353, -- Corrosive Breath
		445498, -- Bellowing Roar
		437301, -- Deep Slumber (Clouds)
		437324, -- Deep Slumber (Player)
		437390, -- Lethargic Poison
		437398, -- Waking Nightmare
		{3391, "TANK"}, -- Thrash
		{437416, "CASTBAR"}, -- Dreamwalker
	},{},{
		[437353] = CL.breath,
		[437301] = L.deep_slumber_clouds,
		[437324] = L.deep_slumber_player_debuff,
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "CorrosiveBreath", 437353)
	self:Log("SPELL_AURA_APPLIED", "CorrosiveBreathApplied", 437353)
	self:Log("SPELL_CAST_START", "BellowingRoar", 445498)
	self:Log("SPELL_CAST_START", "DeepSlumberClouds", 437301)
	self:Log("SPELL_AURA_APPLIED", "DeepSlumberApplied", 437324)
	self:Log("SPELL_AURA_REMOVED", "DeepSlumberRemoved", 437324)
	self:Log("SPELL_CAST_START", "LethargicPoison", 437390)
	self:Log("SPELL_AURA_APPLIED", "LethargicPoisonApplied", 437390)
	self:Log("SPELL_AURA_REMOVED", "LethargicPoisonRemoved", 437390)

	self:Log("SPELL_CAST_START", "WakingNightmare", 437398)
	self:Log("SPELL_CAST_SUCCESS", "Thrash", 3391)

	-- Dreamwalker / Sleeping Boss, Cast at 70% and 40%
	self:Log("SPELL_CAST_SUCCESS", "Dreamwalker", 437416)
	self:Log("SPELL_AURA_REMOVED", "DreamwalkerOver", 437410) -- Deep Slumber Removed
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(437353, 6, CL.breath) -- Corrosive Breath
	self:CDBar(437301, 14.5, L.deep_slumber_clouds) -- Deep Slumber (Clouds)
	self:CDBar(437390, 16.5) -- Lethargic Poison
	self:CDBar(445498, 21) -- Bellowing Roar
	self:CDBar(437398, 66) -- Waking Nightmare
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CorrosiveBreath(args)
	self:StopBar(CL.breath)
	self:Message(args.spellId, "purple", CL.breath)
	if self:Tank() then
		self:PlaySound(args.spellId, "alert")
	end
	self:CDBar(args.spellId, 19.5, CL.breath)
end

function mod:CorrosiveBreathApplied(args)
    if self:Me(args.destGUID) then
        self:PersonalMessage(args.spellId)
        self:PlaySound(args.spellId, "alarm")
    end
end

function mod:BellowingRoar(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "warning")
	-- This timer is based on combattime? It's not a fixed timer.
	--self:CDBar(args.spellId, 34) -- 34~63s
end

function mod:DeepSlumberClouds(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "cyan")
	self:PlaySound(args.spellId, "info")
	self:CDBar(args.spellId, 19, L.deep_slumber_clouds)
end

function mod:DeepSlumberApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:DeepSlumberRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "green", CL.removed:format(args.spellName))
		self:PlaySound(args.spellId, "info")
	end
end

function mod:LethargicPoison(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "yellow")
	if self:Dispeller("poison") then
		self:PlaySound(args.spellId, "alert")
	end
	self:CDBar(args.spellId, self:GetStage() > 1 and 17 or 19)
end

function mod:LethargicPoisonApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:LethargicPoisonRemoved(args)
	if self:Me(args.destGUID) then
		self:Message(args.spellId, "green", CL.removed:format(args.spellName))
		self:PlaySound(args.spellId, "info")
	end
end

function mod:WakingNightmare(args)
	self:StopBar(args.spellId)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "warning")
	self:CDBar(args.spellId, 66)
end

function mod:Thrash(args)
	self:Message(args.spellId, "purple")
	self:PlaySound(args.spellId, "info")
end

function mod:Dreamwalker(args)
	-- Increment stage by +1 every dreamwalker
	local stage = self:GetStage()
	self:SetStage(stage + 1)

	self:StopBar(CL.breath) -- Corrosive Breath
	self:StopBar(445498) -- Bellowing Roar
	self:StopBar(L.deep_slumber_clouds) -- Deep Slumber (Clouds)
	self:StopBar(437390) -- Lethargic Poison
	self:StopBar(437398) -- Waking Nightmare

	self:Message(args.spellId, "cyan")
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 23) -- 3s cast, 20s buff before waking up again
end

function mod:DreamwalkerOver(args)
	local stage = self:GetStage()
	self:CDBar(437301, stage == 3 and 10 or 2, L.deep_slumber_clouds) -- Deep Slumber (Clouds)
	self:CDBar(437390, 3) -- Lethargic Poison
	self:CDBar(437353, 4, CL.breath) -- Corrosive Breath
	-- Bellowing Roar seems to be based on combattime, so hard to judge here right now.
	--self:CDBar(445498, 21) -- Bellowing Roar
	self:CDBar(437398, 45) -- Waking Nightmare ~45~65
end
