--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Atramedes", 669, 171)
if not mod then return end
mod:RegisterEnableMob(41442)
mod:SetEncounterID(1022)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local searingFlameCount = 1
local modulationCount = 1
local shieldCount = 0
local shieldClickers = {"None"}
local shieldCollector = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.obnoxious_fiend = "Obnoxious Fiend" -- NPC ID 49740
	L.circles = "Circles"
end

--------------------------------------------------------------------------------
-- Initialization
--

local obnoxiousFiendMarker = mod:AddMarkerOption(true, "npc", 7, "obnoxious_fiend", 7) -- Obnoxious Fiend
function mod:GetOptions()
	return {
		-- Grounded Abilities
		77840, -- Searing Flame
		77612, -- Modulation
		{77672, "OFF"}, -- Sonar Pulse
		-- Heroic
		{92685, "SAY"}, -- Pestered!
		obnoxiousFiendMarker,
		"berserk",
		-- General
		{78075, "ICON", "SAY", "ME_ONLY_EMPHASIZE"}, -- Sonic Breath
		{77611, "INFOBOX"}, -- Resonating Clash
		78023, -- Roaring Flame
		77717, -- Vertigo
		"stages",
		"altpower",
	},{
		[77840] = -3061, -- Grounded Abilities
		[92685] = "heroic",
		[78075] = "general"
	},{
		[77672] = L.circles, -- Sonar Pulse (Circles)
		[92685] = CL.add, -- Pestered! (Add)
		[78075] = CL.breath, -- Sonic Breath (Breath)
		[77611] = CL.shield, -- Resonating Clash (Shield)
		[78023] = CL.underyou:format(CL.fire), -- Roaring Flame (Fire under YOU)
		[77717] = CL.stunned, -- Vertigo (Stunned)
	}
end

function mod:OnRegister()
	-- Delayed for custom locale
	obnoxiousFiendMarker = mod:AddMarkerOption(true, "npc", 7, "obnoxious_fiend", 7) -- Obnoxious Fiend
end

function mod:OnBossEnable()
	if IsEncounterInProgress() then
		self:OpenAltPower("altpower", self:SpellName(-3072)) -- "Sound"
	end

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")
	self:Log("SPELL_AURA_APPLIED", "TrackingApplied", 78092)
	self:Log("SPELL_AURA_REMOVED", "TrackingRemoved", 78092)

	self:Log("SPELL_CAST_SUCCESS", "SonicBreath", 78075)
	self:Log("SPELL_AURA_APPLIED", "SearingFlameApplied", 77840)
	self:Log("SPELL_CAST_SUCCESS", "Modulation", 77612)
	self:Log("SPELL_CAST_SUCCESS", "SonarPulse", 77672)
	self:Log("SPELL_CAST_SUCCESS", "ResonatingClash", 77611, 78168) -- Stage 1, Stage 2
	self:Log("SPELL_INSTAKILL", "SonicFlamesKill", 77782, 78945) -- Stage 1, Stage 2
	self:Death("ShieldDies", 42954, 42960, 42949, 42947, 42956, 42951, 42958, 41445) -- 8 Ancient Dwarven Shield, there are 10, but 2 share the same ID...
	self:Log("SPELL_AURA_APPLIED", "VertigoApplied", 77717)

	self:Log("SPELL_CAST_SUCCESS", "PhaseShift", 92681)
	self:Log("SPELL_AURA_APPLIED", "PesteredApplied", 92685)

	self:Log("SPELL_DAMAGE", "RoaringFlameDamage", 78023)
	self:Log("SPELL_MISSED", "RoaringFlameDamage", 78023)
end

function mod:OnEngage()
	searingFlameCount = 1
	modulationCount = 1
	shieldCount = 0
	shieldClickers = {"None"}
	shieldCollector = {}
	self:SetStage(1)
	self:CDBar(77612, 11, CL.count:format(self:SpellName(77612), modulationCount)) -- Modulation
	self:CDBar(77672, 11.3, L.circles) -- Sonar Pulse
	self:CDBar(78075, 22, CL.breath) -- Sonic Breath
	self:CDBar(77840, 45, CL.count:format(self:SpellName(77840), searingFlameCount)) -- Searing Flame
	self:Bar("stages", 91, CL.stage:format(2), "achievement_boss_nefarion")
	if self:Heroic() then
		self:Berserk(600)
	end
	self:OpenAltPower("altpower", self:SpellName(-3072)) -- "Sound"
	self:OpenInfo(77611, CL.other:format("BigWigs", CL.shield))
	self:SetInfo(77611, 1, CL.remaining:format(10))
	self:SetInfoBar(77611, 1, 1)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function groundPhase(self)
		self:SetStage(1)
		self:Message("stages", "cyan", CL.stage:format(1), false)
		self:Bar("stages", 85, CL.stage:format(2), "achievement_boss_nefarion")
		self:CDBar(77672, 12.3, L.circles) -- Sonar Pulse
		self:CDBar(77612, 14, CL.count:format(self:SpellName(77612), modulationCount)) -- Modulation
		self:CDBar(78075, 23, CL.breath) -- Sonic Breath
		self:CDBar(77840, self:Classic() and 47 or 39, CL.count:format(self:SpellName(77840), searingFlameCount)) -- Searing Flame
		self:PlaySound("stages", "long")
	end
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
		if spellId == 86915 then -- Take Off Anim Kit
			local stage2Msg = CL.stage:format(2)
			self:StopBar(stage2Msg)
			self:StopBar(CL.breath) -- Sonic Breath
			self:StopBar(L.circles) -- Sonar Pulse
			self:SetStage(2)
			self:StopBar(CL.count:format(self:SpellName(77612), modulationCount)) -- Modulation
			self:Message("stages", "cyan", stage2Msg, false)
			self:Bar("stages", 36, CL.stage:format(1), "achievement_boss_nefarion")
			self:ScheduleTimer(groundPhase, 36, self)
			self:PlaySound("stages", "long")
		end
	end
end

function mod:TrackingApplied(args) -- Sonic Breath (Stage 1) / Roaring Flame Breath (Stage 2)
	self:TargetMessage(78075, "red", args.destName, CL.breath)
	self:PrimaryIcon(78075, args.destName)
	if self:Me(args.destGUID) then
		self:Say(78075, CL.breath, nil, "Breath")
		self:PlaySound(78075, "warning", nil, args.destName)
	end
end

function mod:TrackingRemoved()
	self:PrimaryIcon(78075)
end

function mod:SonicBreath(args)
	self:CDBar(args.spellId, 42, CL.breath)
end

function mod:SearingFlameApplied(args)
	local msg = CL.count:format(args.spellName, searingFlameCount)
	self:StopBar(msg)
	self:Message(args.spellId, "yellow", msg)
	searingFlameCount = searingFlameCount + 1
	self:PlaySound(args.spellId, "warning")
end

function mod:Modulation(args)
	local msg = CL.count:format(args.spellName, modulationCount)
	self:StopBar(msg)
	self:Message(args.spellId, "orange", msg)
	modulationCount = modulationCount + 1
	self:CDBar(args.spellId, 16, CL.count:format(args.spellName, modulationCount))
	self:PlaySound(args.spellId, "alert")
end

function mod:SonarPulse(args)
	self:CDBar(args.spellId, 11.3, L.circles)
end

do
	local lineRef = {1,3,5,7,9}
	local prev = 0
	function mod:ResonatingClash(args)
		if self:Player(args.sourceFlags) then -- The shield itself also casts it
			prev = args.time
			shieldCount = shieldCount + 1
			local colorName = self:ColorName(args.sourceName, true)
			table.insert(shieldClickers, 2, ("%d %s"):format(shieldCount, colorName))
			self:Message(77611, "cyan", CL.other:format(CL.count:format(CL.shield, shieldCount), colorName), false)
			self:SetInfo(77611, 1, CL.remaining:format(10-shieldCount))
			local per = shieldCount / 10
			self:SetInfoBar(77611, 1, 1-per)
			for i = 2, 5 do
				self:SetInfo(77611, lineRef[i], shieldClickers[i] or "")
			end
			self:PlaySound(77611, "info")
		elseif args.spellId == 77611 and (args.time - prev) > 0.5 then -- Rarely it seems like the player cast is missing in Stage 1
			shieldCount = shieldCount + 1
			table.insert(shieldClickers, 2, ("%d ?"):format(shieldCount))
			self:Message(77611, "cyan", CL.other:format(CL.count:format(CL.shield, shieldCount), "?"), false)
			self:SetInfo(77611, 1, CL.remaining:format(10-shieldCount))
			local per = shieldCount / 10
			self:SetInfoBar(77611, 1, 1-per)
			for i = 2, 5 do
				self:SetInfo(77611, lineRef[i], shieldClickers[i] or "")
			end
			self:PlaySound(77611, "info")
		end
	end

	function mod:SonicFlamesKill(args)
		shieldCollector[args.destGUID] = true
	end

	function mod:ShieldDies(args)
		if not shieldCollector[args.destGUID] then
			shieldCollector[args.destGUID] = true
			shieldCount = shieldCount + 1
			local nefarianName = self:SpellName(-3279) -- Nefarian
			table.insert(shieldClickers, 2, ("%d %s"):format(shieldCount, nefarianName))
			self:SetInfo(77611, 1, CL.remaining:format(10-shieldCount))
			local per = shieldCount / 10
			self:SetInfoBar(77611, 1, 1-per)
			for i = 2, 5 do
				self:SetInfo(77611, lineRef[i], shieldClickers[i] or "")
			end
		end
	end
end

function mod:VertigoApplied(args)
	self:Bar(args.spellId, 5, CL.stunned)
end

do
	local addGUID = nil
	function mod:ObnoxiousFiendMarking(_, unit, guid)
		if addGUID and guid == addGUID then
			addGUID = nil
			self:CustomIcon(obnoxiousFiendMarker, unit, 7)
			self:UnregisterTargetEvents()
		end
	end

	function mod:PhaseShift(args)
		addGUID = args.sourceGUID
		self:RegisterTargetEvents("ObnoxiousFiendMarking")
	end
end

function mod:PesteredApplied(args)
	if self:Player(args.destFlags) then -- The add itself also gains it
		if self:Me(args.destGUID) then
			self:Yell(args.spellId, CL.add, nil, "Add")
		end
		self:TargetMessage(args.spellId, "red", args.destName, CL.add)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

do
	local prev = 0
	function mod:RoaringFlameDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
