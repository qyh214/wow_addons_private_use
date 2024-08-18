--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Onyxia", 249, 1651)
if not mod then return end
mod:RegisterEnableMob(10184)
mod:SetEncounterID(1084)
mod:SetRespawnTime(60)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.phase1_trigger = "How fortuitous"
	L.phase2_trigger = "from above"
	L.phase3_trigger = "It seems you'll need another lesson"

	L.deep_breath = "Deep Breath" -- Preserving the original way it was referred to during classic
	L["18431_icon"] = "spell_shadow_psychicscream"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		18435, -- Flame Breath
		{18392, "SAY", "ICON"}, -- Fireball
		{17086, "EMPHASIZE", "CASTBAR", "CASTBAR_COUNTDOWN"}, -- Breath
		18431, -- Bellowing Roar
	},{
		[18435] = CL.stage:format(1),
		[18392] = CL.stage:format(2),
		[18431] = CL.stage:format(3),
	},{
		[18435] = CL.frontal_cone, -- Flame Breath (Frontal Cone)
		[17086] = L.deep_breath, -- Breath (Deep Breath)
		[18431] = CL.fear, -- Bellowing Roar (Fear)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_CAST_START", "FlameBreath", 18435)
	self:Log("SPELL_CAST_START", "Fireball", 18392)
	self:Log("SPELL_CAST_START", "Breath", 17086, 18351, 18564, 18576, 18584, 18596, 18609, 18617) -- Deep Breath (various directions)
	self:Log("SPELL_CAST_START", "BellowingRoar", 18431)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:PlaySound("stages", "long")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:FlameBreath(args) -- Stage 1 Frontal Cone
	self:Message(args.spellId, "orange", CL.frontal_cone)
	self:PlaySound(args.spellId, "alert")
end

do
	local function printTarget(self, player, guid)
		self:PrimaryIcon(18392, player)
		if self:Me(guid) then
			self:Say(18392, nil, nil, "Fireball")
			self:PersonalMessage(18392)
			self:PlaySound(18392, "alarm")
		end
	end
	function mod:Fireball(args) -- Stage 2 Targetted Fireball threat wipe
		self:GetUnitTarget(printTarget, 0.1, args.sourceGUID)
	end
end

function mod:Breath() -- Stage 2 "Deep Breath"
	self:Message(17086, "red", L.deep_breath)
	self:CastBar(17086, 8, L.deep_breath) -- 8s on Wrath, 5s on Classic Era
	self:PrimaryIcon(18392) -- Clear Fireball raid icon
	self:PlaySound(17086, "warning")
end

function mod:BellowingRoar(args) -- Stage 3 "Fear"
	self:Message(args.spellId, "yellow", CL.incoming:format(CL.fear), L["18431_icon"]) -- Use custom icon instead of the same fire icon for 3 different abilities
	self:PlaySound(args.spellId, "info")
end

function mod:CHAT_MSG_MONSTER_YELL(event, msg)
	if msg:find(L.phase2_trigger, nil, true) then
		self:SetStage(2)
		self:Message("stages", "cyan", CL.percent:format(65, CL.stage:format(2)), false)
		self:PlaySound("stages", "long")
	elseif msg:find(L.phase3_trigger, nil, true) then
		self:UnregisterEvent(event)
		self:PrimaryIcon(18392) -- Clear Fireball raid icon

		self:SetStage(3)
		self:Message("stages", "cyan", CL.stage:format(3), false)
		self:PlaySound("stages", "long")
	end
end
