--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lord Marrowgar", 631, 1624)
if not mod then return end
mod:RegisterEnableMob(36612)
mod:SetEncounterID(BigWigsLoader.isWrath and 845 or 1101)
mod:SetRespawnTime(33)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bone_spike = "Bone Spike" -- NPC ID 36619
end

--------------------------------------------------------------------------------
-- Initialization
--

local boneSpikeMarker = mod:AddMarkerOption(true, "npc", 8, "bone_spike", 8, 7, 6) -- Bone Spike
function mod:GetOptions()
	return {
		69076, -- Bone Storm
		69057, -- Bone Spike Graveyard
		boneSpikeMarker,
		69138, -- Coldflame
		"berserk",
	},nil,{
		[69057] = self:SpellName(69062), -- Bone Spike Graveyard (Impale)
	}
end

function mod:OnRegister()
	-- Delayed for custom locale
	boneSpikeMarker = mod:AddMarkerOption(true, "npc", 8, "bone_spike", 8, 7, 6) -- Bone Spike
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "BoneSpikeGraveyard", 69057, 73142) -- 3s cast, 1s cast (during Bone Storm on heroic)
	self:Log("SPELL_SUMMON", "ImpaleSummon", 69062, 72669, 72670) -- standard cast, ??, rare cast
	self:Log("SPELL_CAST_START", "BoneStormStart", 69076)
	self:Log("SPELL_CAST_SUCCESS", "BoneStorm", 69076)
	self:Log("SPELL_AURA_REMOVED", "BoneStormRemoved", 69076)

	self:Log("SPELL_AURA_APPLIED", "ColdflameDamage", 69146)
	self:Log("SPELL_PERIODIC_DAMAGE", "ColdflameDamage", 69146)
	self:Log("SPELL_PERIODIC_MISSED", "ColdflameDamage", 69146)
end

function mod:OnEngage()
	self:CDBar(69057, 18, self:SpellName(69062)) -- Bone Spike Graveyard (Impale)
	self:CDBar(69076, 45) -- Bone Storm
	self:Berserk(600, true) -- Always delayed beyond 10 min by the final Bone Storm
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local spikeCollector = {}
	function mod:BoneSpikeMarking(_, unit, guid)
		if spikeCollector[guid] then
			self:CustomIcon(boneSpikeMarker, unit, spikeCollector[guid])
			spikeCollector[guid] = nil
			if not next(spikeCollector) then
				self:UnregisterTargetEvents()
			end
		end
	end

	local playerList = {}
	local spikeIcon = 8
	function mod:BoneSpikeGraveyard(args)
		playerList = {}
		spikeCollector = {}
		spikeIcon = 8
		self:CDBar(69057, args.spellId == 73142 and 15 or 18, self:SpellName(69062)) -- Bone Spike Graveyard (Impale)
	end

	function mod:ImpaleSummon(args)
		playerList[#playerList + 1] = args.sourceName

		local unit = self:GetUnitIdByGUID(args.destGUID)
		if unit then
			self:CustomIcon(boneSpikeMarker, unit, spikeIcon)
		else
			spikeCollector[args.destGUID] = spikeIcon -- Mark the spike not the player
			self:RegisterTargetEvents("BoneSpikeMarking")
		end
		spikeIcon = spikeIcon - 1

		self:TargetsMessage(69057, "yellow", playerList, 3, args.spellName)
		if spikeIcon == 7 then
			self:PlaySound(69057, "alert")
		end
	end
end

function mod:BoneStormStart(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "long")
end

do
	local prev = 0
	function mod:BoneStorm(args)
		prev = args.time
		self:StopBar(args.spellName)
		if not self:Heroic() then
			self:StopBar(69062) -- Bone Spike Graveyard (Impale)
		end
		--self:CastBar(args.spellId, self:Heroic() and 34 or 20) -- Seems to vary way too much
	end

	function mod:BoneStormRemoved(args)
		if prev > 0 then
			self:CDBar(args.spellId, 90-(args.time-prev))
		end
		-- Restart the cooldown on normal, reset the cooldown on heroic
		self:CDBar(69057, 18, self:SpellName(69062)) -- Bone Spike Graveyard (Impale)
	end
end

do
	local prev = 0
	function mod:ColdflameDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 4 then
			prev = args.time
			self:PersonalMessage(69138, "underyou")
			self:PlaySound(69138, "underyou")
		end
	end
end
