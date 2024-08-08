--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Grubbis Discovery", 90)
if not mod then return end
mod:RegisterEnableMob(217969, 217280) -- Blastmaster Emi Shortfuse, Grubbis
mod:SetEncounterID(2925)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local quakeCount = 0
local addsCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Grubbis"
	L.aoe = "AoE melee damage"
	L.cloud = "A cloud reached the boss"
	L.cone = "\"Frontal\" cone" -- "Frontal" Cone, it's a rear cone (he's farting)
	L.warmup_say_chat_trigger = "Gnomeregan" -- There are still ventilation shafts actively spewing radioactive material throughout Gnomeregan.
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"stages",
		434168, -- Irradiated Cloud
		434724, -- Radiation Sickness
		"adds",
		3019, -- Enrage
		436100, -- Petrify
		{436074, "CASTBAR"}, -- Trogg Rage
		{436027, "CASTBAR"}, -- Grubbis Mad!
		434941, -- Toxic Vigor
		{436059, "CASTBAR"}, -- Radiation?
		{439956, "CASTBAR"}, -- Revive Pet
	},{
		["adds"] = CL.adds,
		[436100] = L.bossName,
	},{
		[434724] = CL.disease, -- Radiation Sickness (Disease)
		[436027] = L.aoe, -- Grubbis Mad! (AoE melee damage)
		[434941] = L.cloud, -- Toxic Vigor (A cloud reached the boss)
		[436059] = L.cone, -- Radiation? ("Frontal" Cone)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY")
	self:RegisterMessage("BigWigs_BossComm")

	self:Log("SPELL_DISPEL", "Dispelled", "*")
	self:Log("SPELL_AURA_APPLIED", "EnrageApplied", 3019)
	self:Log("SPELL_CAST_START", "Petrify", 436100)
	self:Log("SPELL_INTERRUPT", "PetrifyInterrupted", "*")
	self:Log("SPELL_AURA_APPLIED", "PetrifyApplied", 436100)
	self:Log("SPELL_AURA_REMOVED", "PetrifyRemoved", 436100)
	self:Death("ChomperDied", 217956)
	self:Log("SPELL_AURA_APPLIED", "TroggRageApplied", 436074)
	self:Log("SPELL_AURA_REMOVED", "TroggRageRemoved", 436074)
	self:Log("SPELL_CAST_START", "GrubbisMad", 436027)
	self:Log("SPELL_AURA_APPLIED", "GrubbisMadChannel", 436027)
	self:Log("SPELL_AURA_REMOVED", "GrubbisMadChannelOver", 436027)
	self:Log("SPELL_AURA_APPLIED", "ToxicVigorApplied", 434941)
	self:Log("SPELL_CAST_START", "RadiationStart", 436059)
	self:Log("SPELL_CAST_SUCCESS", "Radiation", 436059)
	self:Log("SPELL_CAST_SUCCESS", "Adds", 435361, 435362, 435363)
	self:Log("SPELL_CAST_SUCCESS", "Troggquake", 436168)
	self:Log("SPELL_AURA_APPLIED", "RadiationSicknessApplied", 434724)
	self:Log("SPELL_SUMMON", "IrradiatedCloudSummon", 434168)
	self:Log("SPELL_DAMAGE", "IrradiatedCloudKilled", 434948)
	self:Log("SPELL_CAST_START", "RevivePet", 439956)
end

function mod:OnEngage()
	quakeCount = 0
	addsCount = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_SAY(_, msg)
	if msg:find(L.warmup_say_chat_trigger, nil, true) then
		self:Sync("warmup")
	end
end

do
	local prev = 0
	function mod:BigWigs_BossComm(_, msg)
		if msg == "warmup" and self:GetStage() == 1 then
			local t = GetTime()
			if t-prev > 10 then
				prev = t
				self:Bar("stages", 45, CL.stage:format(1), "inv_stone_10")
			end
		end
	end
end

function mod:Dispelled(args)
	if args.extraSpellName == self:SpellName(3019) then -- Enrage
		self:Message(3019, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	elseif args.extraSpellName == self:SpellName(436074) then -- Trogg Rage
		self:Message(436074, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	elseif args.extraSpellName == self:SpellName(436100) then
		self:Message(436100, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:EnrageApplied(args)
	if self:GetStage() ~= 3 or (self:GetStage() == 3 and args.destGUID == self:UnitGUID("target")) then
		self:Message(args.spellId, "red", CL.magic_buff_other:format(args.destName, args.spellName))
	end
end

function mod:Petrify(args)
	self:CDBar(args.spellId, 21)
	self:Message(args.spellId, "orange", CL.extra:format(args.spellName, CL.interruptible)) -- XXX target filter this in a few weeks

	local npcId = self:MobId(self:UnitGUID("target"))
	if npcId == 217956 then -- Chomper
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:PetrifyInterrupted(args)
	if args.extraSpellName == self:SpellName(436100) then
		self:Message(436100, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:PetrifyApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:TargetBar(args.spellId, 8, args.destName)
	self:PlaySound(args.spellId, "alert")
end

function mod:PetrifyRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:ChomperDied()
	self:StopBar(436100) -- Petrify
end

function mod:TroggRageApplied(args)
	self:Message(args.spellId, "red", CL.on:format(args.spellName, args.destName))
	self:CastBar(args.spellId, 10)
	self:CDBar(args.spellId, 22)
	self:PlaySound(args.spellId, "alarm")
end

function mod:TroggRageRemoved(args)
	self:StopBar(CL.cast:format(args.spellName))
end

function mod:GrubbisMad(args)
	self:StopBar(L.aoe)
	self:Message(args.spellId, "yellow", CL.incoming:format(L.aoe))
	self:PlaySound(args.spellId, "long")
end

function mod:GrubbisMadChannel(args)
	self:CastBar(args.spellId, 5, L.aoe)
end

function mod:GrubbisMadChannelOver(args)
	self:CDBar(args.spellId, 19.5, L.aoe)
end

function mod:ToxicVigorApplied(args)
	self:Message(args.spellId, "orange", CL.other:format(args.spellName, L.cloud))
	self:Bar(args.spellId, 30)
	self:PlaySound(args.spellId, "info")
end

function mod:RadiationStart(args)
	self:Message(args.spellId, "yellow", CL.incoming:format(L.cone))
	self:PlaySound(args.spellId, "long")
end

function mod:Radiation(args)
	self:CastBar(args.spellId, 3, L.cone)
end

function mod:Adds(args)
	addsCount = addsCount + 1
	self:Message("adds", "cyan", CL.count:format(CL.adds_spawned, addsCount), false)
	self:PlaySound("adds", "info")
end

function mod:Troggquake(args)
	quakeCount = quakeCount + 1
	self:SetStage(quakeCount)
	if quakeCount == 3 then
		self:Bar(434168, 23.8) -- Irradiated Cloud
		self:Message("stages", "cyan", CL.other:format(CL.stage:format(quakeCount), CL.boss), false)
		self:PlaySound("stages", "info")
	else
		self:Message("stages", "cyan", CL.other:format(CL.stage:format(quakeCount), CL.adds), false)
		if quakeCount == 1 then
			self:Bar("adds", 10, CL.adds, "inv_hammer_15")
		end
	end
end

do
	local playerList, prev = {}, 0
	function mod:RadiationSicknessApplied(args)
		if args.time - prev > 0.4 then
			prev = args.time
			playerList = {}
		end
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "yellow", playerList, nil, CL.disease)
	end
end

do
	local prev = 0
	function mod:IrradiatedCloudSummon(args)
		if args.time - prev > 1 then
			prev = args.time
			self:Message(args.spellId, "cyan", CL.spawned:format(args.spellName))
		end
	end
end

do
	local prev = 0
	function mod:IrradiatedCloudKilled(args)
		if args.time - prev > 1 then
			prev = args.time
			self:Message(434168, "cyan", CL.killed:format(args.spellName))
		end
	end
end

function mod:RevivePet(args)
	self:Message(args.spellId, "orange")
	self:CastBar(args.spellId, 10)
	self:PlaySound(args.spellId, "warning")
end
