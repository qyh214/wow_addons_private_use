--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Onyxia", 249, 1651)
if not mod then return end
mod:RegisterEnableMob(10184, 12129) -- Onyxia, Onyxian Warder
mod:SetEncounterID(1084)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local castCollector = {}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.stage2_yell_trigger = "from above"
	L.stage3_yell_trigger = "It seems you'll need another lesson"

	L.deep_breath = "Deep Breath" -- Preserving the original way it was referred to during classic
	L["18431_icon"] = "spell_shadow_psychicscream"
	L.warder = "Onyxian Warder" -- NPC ID 12129
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		18435, -- Flame Breath
		{18392, "SAY", "ICON", "ME_ONLY"}, -- Fireball
		{17086, "EMPHASIZE", "CASTBAR", "CASTBAR_COUNTDOWN"}, -- Breath
		18431, -- Bellowing Roar
		18958, -- Flame Lash
	},{
		[18435] = CL.stage:format(1),
		[18392] = CL.stage:format(2),
		[18431] = CL.stage:format(3),
		[18958] = L.warder,
	},{
		[18435] = CL.frontal_cone, -- Flame Breath (Frontal Cone)
		[17086] = L.deep_breath, -- Breath (Deep Breath)
		[18431] = CL.fear, -- Bellowing Roar (Fear)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			"stages",
			18435, -- Flame Breath
			{18392, "SAY", "ICON", "ME_ONLY"}, -- Fireball
			{17086, "EMPHASIZE", "CASTBAR", "CASTBAR_COUNTDOWN"}, -- Breath
			364849, -- Summon Onyxian Warder
			18431, -- Bellowing Roar
			18958, -- Flame Lash
		},{
			[18435] = CL.stage:format(1),
			[18392] = CL.stage:format(2),
			[18431] = CL.stage:format(3),
			[18958] = L.warder,
		},{
			[18435] = CL.frontal_cone, -- Flame Breath (Frontal Cone)
			[17086] = L.deep_breath, -- Breath (Deep Breath)
			[18431] = CL.fear, -- Bellowing Roar (Fear)
		}
	end
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_CAST_START", "FlameBreath", 18435)
	self:Log("SPELL_CAST_START", "Fireball", 18392)
	self:Log("SPELL_CAST_START", "Breath", 17086, 18351, 18564, 18576, 18584, 18596, 18609, 18617) -- Deep Breath (various directions)
	self:Log("SPELL_CAST_START", "BellowingRoar", 18431)
	self:Log("SPELL_AURA_APPLIED", "FlameLashApplied", 18958)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FlameLashApplied", 18958)

	if self:GetSeason() == 2 then
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		self:RegisterMessage("BigWigs_BossComm")
	end
end

function mod:OnEngage()
	castCollector = {}
	self:SetStage(1)
	self:RegisterEvent("UNIT_HEALTH")
	self:CDBar(18435, 13, CL.frontal_cone) -- Flame Breath
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:PlaySound("stages", "long")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
		if spellId == 364849 and not castCollector[castGUID] then -- Summon Onyxian Warder
			castCollector[castGUID] = true
			self:Sync("sumony")
		end
	end
end

do
	local times = {
		["sumony"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "sumony" then
					self:Message(364849, "cyan", self:SpellName(364849), false)
					self:PlaySound(364849, "alert")
				end
			end
		end
	end
end

function mod:FlameBreath(args) -- Stage 1 Frontal Cone
	self:Message(args.spellId, "orange", CL.frontal_cone)
	self:CDBar(args.spellId, 12, CL.frontal_cone) -- 12-19
	self:PlaySound(args.spellId, "alert")
end

do
	local sourceGUID = nil
	local targetGUID = nil
	local function scanTarget()
		if targetGUID and sourceGUID and mod:IsEngaged() and mod:GetStage() == 2 then
			local unit = mod:GetUnitIdByGUID(sourceGUID)
			if unit then
				local newTargetGUID = mod:UnitGUID(unit.."target")
				if newTargetGUID and newTargetGUID ~= targetGUID then
					sourceGUID = nil
					targetGUID = nil
					local newTargetName = mod:UnitName(unit.."target")
					mod:PrimaryIcon(18392, newTargetName)
					mod:TargetMessage(18392, "yellow", newTargetName)
					if mod:Me(newTargetGUID) then
						mod:Say(18392, nil, nil, "Fireball")
						mod:PlaySound(18392, "alarm")
					end
				else
					mod:SimpleTimer(scanTarget, 0.05)
				end
			else
				sourceGUID = nil
				targetGUID = nil
			end
		end
	end
	function mod:Fireball(args) -- Stage 2 Targetted Fireball threat wipe
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if unit then
			sourceGUID = args.sourceGUID
			targetGUID = self:UnitGUID(unit.."target") or "??"
			self:SimpleTimer(scanTarget, 0.05)
		else
			sourceGUID = nil
			targetGUID = nil
		end
	end
end

function mod:Breath() -- Stage 2 "Deep Breath"
	self:StopBar(L.deep_breath)
	self:Message(17086, "red", L.deep_breath)
	self:CastBar(17086, 5, L.deep_breath) -- 8s on Wrath, 5s on Classic Era
	self:PrimaryIcon(18392) -- Clear Fireball raid icon
	self:PlaySound(17086, "warning")
end

function mod:BellowingRoar(args) -- Stage 3 "Fear"
	self:Message(args.spellId, "yellow", CL.incoming:format(CL.fear), L["18431_icon"]) -- Use custom icon instead of the same fire icon for 3 different abilities
	self:PlaySound(args.spellId, "info")
end

function mod:CHAT_MSG_MONSTER_YELL(event, msg)
	if msg:find(L.stage2_yell_trigger, nil, true) then
		self:SetStage(2)
		self:StopBar(CL.frontal_cone) -- Flame Breath
		if self:GetSeason() == 2 then
			self:Bar(17086, 28.5, L.deep_breath) -- Stage 2 "Deep Breath"
		end
		self:Message("stages", "cyan", CL.percent:format(65, CL.stage:format(2)), false)
		self:PlaySound("stages", "long")
	elseif msg:find(L.stage3_yell_trigger, nil, true) then
		self:UnregisterEvent(event)
		self:PrimaryIcon(18392) -- Clear Fireball raid icon

		self:SetStage(3)
		self:Message("stages", "cyan", CL.stage:format(3), false)
		self:PlaySound("stages", "long")
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 10184 then -- Onyxia
		local hp = self:GetHealth(unit)
		if hp < 71 then
			self:UnregisterEvent(event)
			if hp > 65 then
				self:Message("stages", "cyan", CL.soon:format(CL.stage:format(2)), false)
			end
		end
	end
end

function mod:FlameLashApplied(args)
	local unit, targetUnit = self:GetUnitIdByGUID(args.sourceGUID), self:UnitTokenFromGUID(args.destGUID, true)
	if unit and targetUnit and self:Tanking(unit, targetUnit) then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 2)
	end
end
