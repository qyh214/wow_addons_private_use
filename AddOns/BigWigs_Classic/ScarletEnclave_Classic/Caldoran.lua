--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Grand Crusader Caldoran", 2856)
if not mod then return end
mod:RegisterEnableMob(241006)
mod:SetEncounterID(3189)
mod:SetRespawnTime(12)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Grand Crusader Caldoran"
	L.run = "Run to the door"
	L.run_desc = "Show a message after stage 2 ends reminding you to run to the door."
	L.run_icon = "ability_rogue_sprint"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Stage 1
		"stages",
		{1229714, "EMPHASIZE", "CASTBAR", "CASTBAR_COUNTDOWN"}, -- Blinding Flare
		1231618, -- Wake of Ashes
		1229114, -- Devoted Offering
		{1229272, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Divine Conflagration
		{1229503, "CASTBAR"}, -- Execution Sentence
		-- Stage 2
		{"run", "EMPHASIZE", "COUNTDOWN"},
		-- Stage 3
		1230697, -- Cessation
		1231651, -- Quietus
		{1231027, "COUNTDOWN"}, -- Darkgraven Blade
		"berserk",
		-- Stage 5
		1231654, -- Wake of Ashes
	},{
		["stages"] = CL.stage:format(1),
		["run"] = CL.stage:format(2),
		[1230697] = CL.stage:format(3),
		[1231654] = CL.stage:format(5),
	},{
		[1229714] = CL.blind, -- Blinding Flare (Blind)
		[1231618] = CL.frontal_cone, -- Wake of Ashes (Frontal Cone)
		[1229503] = CL.tank_debuff, -- Execution Sentence (Tank Debuff)
		[1230697] = CL.adds, -- Cessation (Adds)
		[1231651] = CL.frontal_cone, -- Quietus (Frontal Cone)
		[1231027] = CL.you_die, -- Darkgraven Blade (You die)
		[1231654] = CL.frontal_cone, -- Wake of Ashes (Frontal Cone)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
	self:SetSpellRename(1229714, CL.blind) -- Blinding Flare (Blind)
	self:SetSpellRename(1231618, CL.frontal_cone) -- Wake of Ashes (Frontal Cone)
	self:SetSpellRename(1230697, CL.adds) -- Cessation (Adds)
	self:SetSpellRename(1231651, CL.frontal_cone) -- Quietus (Frontal Cone)
	self:SetSpellRename(1231027, CL.you_die) -- Darkgraven Blade (You die)
	self:SetSpellRename(1231654, CL.frontal_cone) -- Wake of Ashes (Frontal Cone)
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "BlindingFlare", 1229714)
	self:Log("SPELL_CAST_START", "WakeOfAshes", 1231618, 1231654) -- Stage 1, Stage 5
	self:Log("SPELL_CAST_START", "DevotedOffering", 1229114)
	self:Log("SPELL_AURA_APPLIED", "DivineConflagrationApplied", 1229272)
	self:Log("SPELL_AURA_REMOVED", "DivineConflagrationRemoved", 1229272)
	self:Log("SPELL_AURA_APPLIED", "ExecutionSentenceApplied", 1229503)
	self:Log("SPELL_CAST_SUCCESS", "WrathOfTheCrusade", 1230125)
	self:Log("SPELL_CAST_START", "DyingLight", 1230271)
	self:Log("SPELL_CAST_SUCCESS", "DyingLightSuccess", 1230271)
	self:Log("SPELL_CAST_SUCCESS", "ConjurePortal", 1230333)
	self:Log("SPELL_CAST_START", "Quietus", 1231651)
	self:Log("SPELL_CAST_START", "Cessation", 1230697)
	self:Log("SPELL_CAST_START", "DarkgravenBlade", 1231027)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(1229714, 27, CL.blind) -- Blinding Flare
	self:CDBar(1231618, 21.4, CL.frontal_cone) -- Wake of Ashes
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BlindingFlare(args)
	if self:GetStage() == 1 or self:GetStage() == 3 then -- He casts it in Stage 2.5 after he takes the portal, when you are still stunned
		self:Message(args.spellId, "red", CL.blind)
		self:CastBar(args.spellId, 3, CL.blind)
		self:CDBar(args.spellId, 29.1, CL.blind)
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:WakeOfAshes(args)
	if self:GetStage() == 1 or self:GetStage() == 5 then -- He casts it in Stage 2.5 after he takes the portal, when you are still stunned
		self:Message(args.spellId, "orange", CL.frontal_cone)
		self:CDBar(args.spellId, args.spellId == 1231654 and 21 or 24.2, CL.frontal_cone)
		self:PlaySound(args.spellId, "alert")
	end
end

do
	local prev = 0
	function mod:DevotedOffering(args)
		if args.time - prev > 3 then
			prev = args.time
			self:Message(args.spellId, "yellow")
			self:PlaySound(args.spellId, "alert")
		end
	end
end

function mod:DivineConflagrationApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Divine Conflagration")
		self:SayCountdown(args.spellId, 5)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:DivineConflagrationRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:ExecutionSentenceApplied(args)
	self:TargetMessage(args.spellId, "purple", args.destName, CL.tank_debuff)
	self:CastBar(args.spellId, 8, CL.tank_debuff)
	self:PlaySound(args.spellId, "info")
end

function mod:WrathOfTheCrusade()
	self:SetStage(2)
	self:StopBar(CL.blind) -- Blinding Flare
	self:StopBar(CL.frontal_cone) -- Wake of Ashes
	self:Message("stages", "cyan", CL.percent:format(55, CL.stage:format(2)), false)
	self:PlaySound("stages", "long")
end

function mod:DyingLight()
	self:SetStage(2.5)
	self:Message("run", "blue", L.run, L.run_icon, nil, 3) -- Stay onscreen for 3s
	self:Bar("run", 20, L.run, L.run_icon)
end

do
	local function SetStage3()
		mod:SetStage(3)
		mod:Message("stages", "cyan", CL.stage:format(3), false)
		mod:PlaySound("stages", "long")
	end

	function mod:DyingLightSuccess(args)
		self:Bar("stages", 20, CL.intermission, args.spellId)
		self:ScheduleTimer(SetStage3, 20)
	end
end

function mod:ConjurePortal()
	self:Berserk(390, true) -- XXX completely broken since hotfix
end

function mod:Cessation(args)
	self:Message(args.spellId, "cyan", CL.incoming:format(CL.adds))
	self:PlaySound(args.spellId, "alarm")
end

function mod:Quietus(args)
	self:Message(args.spellId, "orange", CL.frontal_cone)
	self:CDBar(args.spellId, 24.2, CL.frontal_cone)
	self:PlaySound(args.spellId, "alert")
end

do
	local function RegisterYell()
		mod:RegisterEvent("CHAT_MSG_MONSTER_YELL")
		mod:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
		mod:RegisterMessage("BigWigs_BossComm")
	end

	local castCollector = {}
	function mod:DarkgravenBlade(args)
		castCollector = {}
		self:SetStage(4)
		self:StopBar(CL.blind) -- Blinding Flare
		self:StopBar(CL.frontal_cone) -- Quietus
		self:Message(args.spellId, "yellow", CL.you_die_sec:format(60))
		self:Bar(args.spellId, 60, CL.you_die)
		self:ScheduleTimer(RegisterYell, 2)
		self:PlaySound(args.spellId, "long")
	end

	function mod:UNIT_SPELLCAST_INTERRUPTED(event, _, castGUID, spellId) -- Earlier than CHAT_MSG_MONSTER_YELL but requires nameplates/target
		if spellId == 1231027 and not castCollector[castGUID] then -- Darkgraven Blade
			castCollector[castGUID] = true
			self:Sync("s5")
		end
	end
end

do
	local times = {
		["s5"] = 0,
	}
	function mod:BigWigs_BossComm(event, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
				self:UnregisterEvent("CHAT_MSG_MONSTER_YELL")
				self:UnregisterMessage(event)
				self:SetStage(5)
				self:StopBar(CL.you_die)
				self:Message("stages", "cyan", CL.stage:format(5), false)
				self:CDBar(1231654, 23.7, CL.frontal_cone) -- Wake of Ashes
				self:PlaySound("stages", "long")
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_YELL(event)
	self:UnregisterEvent(event)
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterMessage("BigWigs_BossComm")
	self:SetStage(5)
	self:StopBar(CL.you_die)
	self:Message("stages", "cyan", CL.stage:format(5), false)
	self:CDBar(1231654, 20.7, CL.frontal_cone) -- Wake of Ashes
	self:PlaySound("stages", "long")
end
