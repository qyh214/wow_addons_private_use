--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lady Deathwhisper", 631, 1625)
if not mod then return end
mod:RegisterEnableMob(36855, 37949, 38010, 37890, 38009) -- Lady Deathwhisper, Cult Adherent, Reanimated Adherent, Cult Fanatic, Reanimated Fanatic
mod:SetEncounterID(BigWigsLoader.isWrath and 846 or 1100)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local addsTimer = nil
local addCollector = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.touch = "Touch"
	L.deformed_fanatic = "Deformed Fanatic" -- NPC ID 38135
	L.empowered_adherent = "Empowered Adherent" -- NPC ID 38136
	L.adds_icon = "spell_shadow_twistedfaith"
end

--------------------------------------------------------------------------------
-- Initialization
--

local deformedFanaticMarker = mod:AddMarkerOption(true, "npc", 8, "deformed_fanatic", 8) -- Deformed Fanatic
local empoweredAdherentMarker = mod:AddMarkerOption(true, "npc", 7, "empowered_adherent", 7) -- Empowered Adherent
local dominateMindMarker = mod:AddMarkerOption(false, "player", 1, 71289, 1, 2, 3) -- Dominate Mind
function mod:GetOptions()
	return {
		-- Adds
		"adds",
		70900, -- Dark Transformation
		deformedFanaticMarker,
		70901, -- Dark Empowerment
		empoweredAdherentMarker,
		71237, -- Curse of Torpor
		-- Stage 2
		71204, -- Touch of Insignificance
		71426, -- Summon Spirit
		-- General
		71289, -- Dominate Mind
		dominateMindMarker,
		71001, -- Death and Decay
		"stages",
		"berserk"
	},{
		["adds"] = CL.adds,
		[71204] = CL.stage:format(2),
		[71289] = "general",
	},{
		[70900] = L.deformed_fanatic, -- Dark Transformation (Deformed Fanatic)
		[70901] = L.empowered_adherent, -- Dark Empowerment (Empowered Adherent)
		[71237] = CL.curse, -- Curse of Torpor (Curse)
		[71204] = L.touch, -- Touch of Insignificance (Touch)
		[71426] = CL.spirits, -- Summon Spirit (Spirits)
		[71289] = CL.mind_control, -- Dominate Mind (Mind Control)
	}
end

function mod:OnRegister()
	-- Delayed for custom locale
	deformedFanaticMarker = mod:AddMarkerOption(true, "npc", 8, "deformed_fanatic", 8) -- Deformed Fanatic
	empoweredAdherentMarker = mod:AddMarkerOption(true, "npc", 7, "empowered_adherent", 7) -- Empowered Adherent
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "CurseOfTorporApplied", 71237)
	self:Log("SPELL_AURA_REMOVED", "ManaBarrierRemoved", 70842)
	self:Log("SPELL_AURA_APPLIED", "DominateMindApplied", 71289)
	self:Log("SPELL_AURA_REMOVED", "DominateMindRemoved", 71289)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TouchOfInsignificanceApplied", 71204)
	self:Log("SPELL_CAST_START", "DarkTransformation", 70900)
	self:Log("SPELL_CAST_START", "DarkEmpowerment", 70901)
	self:Log("SPELL_SUMMON", "SummonSpirit", 71426)

	self:Log("SPELL_AURA_APPLIED", "DeathAndDecayDamage", 71001)
	self:Log("SPELL_PERIODIC_DAMAGE", "DeathAndDecayDamage", 71001)
	self:Log("SPELL_PERIODIC_MISSED", "DeathAndDecayDamage", 71001)
end

function mod:OnEngage()
	addCollector = {}
	self:SetStage(1)
	self:Berserk(600, true)
	self:Bar("adds", 7, CL.adds, L.adds_icon)
	if self:Difficulty() > 3 and not self:Solo() then -- Doesn't happen on 10 N or solo
		self:CDBar(71289, 30, CL.mind_control) -- Dominate Mind
	end
	self:Message("stages", "cyan", CL.stage:format(1), false)
	addsTimer = self:ScheduleTimer("SpawnAdds", 7, self:Heroic() and 45 or 60)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SpawnAdds(duration)
	self:Bar("adds", duration, CL.adds, L.adds_icon)
	self:Message("adds", "cyan", CL.adds, L.adds_icon)
	self:PlaySound("adds", "info")
	addsTimer = self:ScheduleTimer("SpawnAdds", duration, duration)
end

do
	local prev = 0
	function mod:CurseOfTorporApplied(args)
		if self:GetStage() == 1 then
			if args.time - prev > 5 then
				prev = args.time
				self:Message(args.spellId, "red", CL.curses)
			end
		else
			self:TargetMessage(args.spellId, "red", args.destName, CL.curse)
		end
	end
end

function mod:ManaBarrierRemoved()
	self:SetStage(2)
	if not self:Heroic() then
		if addsTimer then
			self:CancelTimer(addsTimer)
		end
		self:StopBar(CL.adds)
	end
	self:Message("stages", "cyan", CL.stage:format(2), false)
	if not self:Solo() then
		if self:Difficulty() == 4 or self:Difficulty() == 6 then -- 3 spirits on 25
			self:CDBar(71426, 10, CL.spirits) -- Summon Spirit
		else
			self:CDBar(71426, 10, CL.spirit) -- Summon Spirit
		end
	end
	self:PlaySound("stages", "long")
end

do
	local playerList = {}
	local prev = 0
	function mod:DominateMindApplied(args)
		if self:Difficulty() == 6 then -- Multiple players on 25 HC
			if args.time - prev > 5 then
				prev = args.time
				playerList = {}
			end
			local count = #playerList+1
			playerList[count] = args.destName
			playerList[args.destName] = count -- Set raid marker
			self:TargetsMessage(args.spellId, "orange", playerList, 3, CL.mind_control, nil, 1)
			self:CustomIcon(dominateMindMarker, args.destName, count)
			if #playerList == 1 then
				self:CDBar(args.spellId, 40, CL.mind_control)
				self:PlaySound(args.spellId, "alarm")
			end
		else -- 1 player on 25 N and 10 HC
			self:TargetMessage(args.spellId, "orange", args.destName, CL.mind_control)
			self:CDBar(args.spellId, 40, CL.mind_control)
			self:CustomIcon(dominateMindMarker, args.destName, 1)
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

function mod:DominateMindRemoved(args)
	self:CustomIcon(dominateMindMarker, args.destName)
end

function mod:TouchOfInsignificanceApplied(args)
	self:StackMessage(args.spellId, "orange", args.destName, args.amount, 3, L.touch)
end

function mod:AddMarking(_, unit, guid)
	if addCollector[guid] then
		if addCollector[guid] == 8 then
			self:CustomIcon(deformedFanaticMarker, unit, 8)
		else
			self:CustomIcon(empoweredAdherentMarker, unit, 7)
		end
		addCollector[guid] = nil
		if not next(addCollector) then
			self:UnregisterTargetEvents()
		end
	end
end

function mod:DarkTransformation(args)
	self:Message(args.spellId, "cyan", L.deformed_fanatic)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if unit then
		self:CustomIcon(deformedFanaticMarker, unit, 8)
	else
		addCollector[args.sourceGUID] = 8
		self:RegisterTargetEvents("AddMarking")
	end
	self:PlaySound(args.spellId, "alert")
end

function mod:DarkEmpowerment(args)
	self:Message(args.spellId, "cyan", L.empowered_adherent)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if unit then
		self:CustomIcon(empoweredAdherentMarker, unit, 7)
	else
		addCollector[args.sourceGUID] = 7
		self:RegisterTargetEvents("AddMarking")
	end
	self:PlaySound(args.spellId, "alert")
end

do
	local prev = 0
	function mod:SummonSpirit(args)
		if args.time - prev > 5 then
			prev = args.time
			if self:Difficulty() == 4 or self:Difficulty() == 6 then -- 3 spirits on 25
				self:Message(args.spellId, "yellow", CL.spirits)
				self:CDBar(args.spellId, 10, CL.spirits)
			else
				self:Message(args.spellId, "yellow", CL.spirit)
				self:CDBar(args.spellId, 10, CL.spirit)
			end
			self:PlaySound(args.spellId, "long")
		end
	end
end

do
	local prev = 0
	function mod:DeathAndDecayDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 4 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
