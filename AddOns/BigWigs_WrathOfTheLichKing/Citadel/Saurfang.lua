--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Deathbringer Saurfang", 631, 1628)
if not mod then return end
mod:RegisterEnableMob(37813, 37200, 37187) -- Deathbringer Saurfang, Muradin Bronzebeard, High Overlord Saurfang
mod:SetEncounterID(BigWigsLoader.isWrath and 848 or 1096)
--mod:SetRespawnTime(30) -- Instantly respawns

--------------------------------------------------------------------------------
-- Locals
--

local markCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.warmup_icon = "achievement_boss_saurfang"
	L.adds_icon = "spell_shadow_rune"
	L.blood_beast = "Blood Beast" --  NPC ID 38508

	L.warmup_alliance = "Let's get a move on then! Move ou..."
	L.warmup_horde = "Kor'kron, move out! Champions, watch your backs. The Scourge have been..."
end

--------------------------------------------------------------------------------
-- Initialization
--

local bloodBeastMarker = mod:AddMarkerOption(true, "npc", 8, "blood_beast", 8, 7, 6, 5, 4) -- Blood Beast
function mod:GetOptions()
	return {
		"warmup",
		"adds",
		bloodBeastMarker,
		72410, -- Rune of Blood
		72385, -- Boiling Blood
		{72293, "ME_ONLY_EMPHASIZE"}, -- Mark of the Fallen Champion
		72737, -- Frenzy
		"berserk",
	},nil,{
		["adds"] = L.blood_beast, -- Adds (Blood Beast)
		[72293] = CL.mark, -- Mark of the Fallen Champion (Mark)
		[72737] = CL.health_percent:format(30), -- Frenzy (30% Health)
	}
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 37813 then -- Deathbringer Saurfang
		return true
	else
		return self:UnitIsInteractable(unit) -- Muradin Bronzebeard & High Overlord Saurfang
	end
end

function mod:OnRegister()
	-- Delayed for custom locale
	bloodBeastMarker = mod:AddMarkerOption(true, "npc", 8, "blood_beast", 8, 7, 6, 5, 4) -- Blood Beast
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_SUMMON", "CallBloodBeast", 72172, 72173, 72356, 72357, 72358)
	self:Log("SPELL_CAST_SUCCESS", "BoilingBlood", 72385)
	self:Log("SPELL_AURA_APPLIED", "BoilingBloodApplied", 72385)
	self:Log("SPELL_CAST_SUCCESS", "RuneOfBlood", 72410)
	self:Log("SPELL_CAST_SUCCESS", "MarkOfTheFallenChampion", 72293)
	self:Log("SPELL_CAST_SUCCESS", "Frenzy", 72737)
end

function mod:OnEngage()
	markCount = 0
	self:Berserk(self:Heroic() and 360 or 480)
	self:CDBar(72385, 16) -- Boiling Blood
	self:CDBar(72410, 20) -- Rune of Blood
	self:Bar("adds", 40, CL.adds, L.adds_icon)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.warmup_horde, nil, true) then
		self:Bar("warmup", 96, CL.active, L.warmup_icon)
	elseif msg:find(L.warmup_alliance, nil, true) then
		self:Bar("warmup", 48, CL.active, L.warmup_icon)
	end
end

do
	local beastCollector = {}
	function mod:BeastMarking(_, unit, guid)
		if beastCollector[guid] then
			self:CustomIcon(bloodBeastMarker, unit, beastCollector[guid])
			beastCollector[guid] = nil
			if not next(beastCollector) then
				self:UnregisterTargetEvents()
			end
		end
	end

	local prev = 0
	local beastIcon = 8
	function mod:CallBloodBeast(args)
		if args.time - prev > 5 then
			prev = args.time
			beastCollector = {}
			beastIcon = 8
			self:Message("adds", "cyan", CL.adds, L.adds_icon)
			self:Bar("adds", 40, CL.adds, L.adds_icon)
		end

		local unit = self:GetUnitIdByGUID(args.destGUID)
		if unit then
			self:CustomIcon(bloodBeastMarker, unit, beastIcon)
		else
			beastCollector[args.destGUID] = beastIcon
			self:RegisterTargetEvents("BeastMarking")
		end
		beastIcon = beastIcon - 1

		if beastIcon == 7 then
			self:PlaySound("adds", "info")
		end
	end
end

do
	local playerList = {}
	function mod:BoilingBlood(args)
		playerList = {}
		self:CDBar(args.spellId, 15.3) -- 15.3-16.3
	end
	function mod:BoilingBloodApplied(args)
		if self:Difficulty() == 4 or self:Difficulty() == 6 then -- 3 debuffs on 25
			playerList[#playerList+1] = args.destName
			self:TargetsMessage(args.spellId, "orange", playerList, 3)
		else
			self:TargetMessage(args.spellId, "orange", args.destName)
		end
	end
end

function mod:RuneOfBlood(args)
	self:TargetMessage(args.spellId, "purple", args.destName)
	self:CDBar(args.spellId, 20)
	if self:Tank() then
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:MarkOfTheFallenChampion(args)
	markCount = markCount + 1
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.count:format(CL.mark, markCount))
	self:PlaySound(args.spellId, "alert")
end

function mod:Frenzy(args)
	self:Message(args.spellId, "red", CL.percent:format(30, args.spellName))
	self:PlaySound(args.spellId, "long")
end
