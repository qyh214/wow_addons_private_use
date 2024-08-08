--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("General Rajaxx", 509, 1538)
if not mod then return end
mod:RegisterEnableMob(15341, 15471) -- General Rajaxx, Lieutenant General Andorov
mod:SetEncounterID(719)
mod:SetRespawnTime(900)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local rajdead = false
local andorovDied = 0
local addsAlive = 7

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.wave_trigger1a = "Kill first, ask questions later... Incoming!"
	L.wave_trigger1b = "kill you last" -- Remember, Rajaxx, when I said I'd kill you last? [when you pull the first wave instead of talking to Andorov]

	L.warmup_icon = "inv_misc_ahnqirajtrinket_01"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"warmup",
		"stages",
		{25471, "SAY", "ME_ONLY_EMPHASIZE"}, -- Attack Order
		8269, -- Frenzy / Enrage (different name on classic era)
		25599, -- Thundercrash
		25462, -- Enlarge
		26550, -- Lightning Cloud
	},nil,{
		[8269] = CL.health_percent:format(30), -- Frenzy / Enrage (30% Health)
		[25599] = CL.knockback, -- Thundercrash (Knockback)
	}
end

function mod:VerifyEnable(unit)
	return not rajdead
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:RegisterEvent("GOSSIP_CONFIRM_CANCEL")
	self:RegisterMessage("BigWigs_BossComm")

	self:Log("SPELL_AURA_APPLIED", "AttackOrderApplied", 25471)
	self:Log("SPELL_AURA_REMOVED", "AttackOrderRemoved", 25471)
	self:Log("SPELL_AURA_APPLIED", "FrenzyEnrage", 8269)
	self:Log("SPELL_CAST_SUCCESS", "Thundercrash", 25599)
	self:Log("SPELL_AURA_APPLIED", "EnlargeApplied", 25462)
	self:Log("SPELL_DISPEL", "EnlargeDispelled", "*")

	self:Log("SPELL_AURA_APPLIED", "LightningCloudDamage", 26550)
	self:Log("SPELL_PERIODIC_DAMAGE", "LightningCloudDamage", 26550)
	self:Log("SPELL_PERIODIC_MISSED", "LightningCloudDamage", 26550)

	self:Death("AddsDie", 15344, 15387, -- Swarmguard Needler, Qiraji Warrior
		15391, -- Captain Qeez (Stage 1)
		15392, -- Captain Tuubid (Stage 2)
		15389, -- Captain Drenn (Stage 3)
		15390, -- Captain Xurrem (Stage 4)
		15386, -- Major Yeggeth (Stage 5)
		15388, -- Major Pakkon (Stage 6)
		15385 -- Colonel Zerran (Stage 7)
	)
	self:Death("AndorovDies", 15471)
end

function mod:OnWin()
	rajdead = true
	andorovDied = 0
end

function mod:OnWipe() -- Will only trigger on classic, retail doesn't have accurate encounter events
	if andorovDied > 0 and GetTime()-andorovDied < 900 then
		self:SetRespawnTime(900-(GetTime()-andorovDied))
		andorovDied = 0
		self:SendMessage("BigWigs_EncounterEnd", self, self:GetEncounterID(), self.displayName, self:Difficulty(), 10, 0)
		self:SetRespawnTime(900)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.wave_trigger1a, nil, true) or msg:find(L.wave_trigger1b, nil, true) then
		addsAlive = 7
		self:SetStage(1)
		self:Message("stages", "cyan", CL.stage:format(1), false)
		self:PlaySound("stages", "info")
	end
end

function mod:GOSSIP_CONFIRM_CANCEL()
	if self:MobId(self:UnitGUID("npc")) == 15471 then
		self:Sync("RajWarmup")
	end
end

do
	local prev = 0
	function mod:BigWigs_BossComm(_, msg)
		local t = GetTime()
		if msg == "RajWarmup" and t - prev > 20 then
			prev = t
			self:Bar("warmup", 30, CL.active, L.warmup_icon)
		end
	end
end

function mod:AttackOrderApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:TargetBar(args.spellId, 10, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Attack Order")
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:AttackOrderRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:FrenzyEnrage(args)
	self:Message(args.spellId, "red", CL.percent:format(30, args.spellName))
	self:PlaySound(args.spellId, "long")
end

function mod:Thundercrash(args)
	self:Message(args.spellId, "orange", CL.knockback)
	self:CDBar(args.spellId, 21, CL.knockback)
	self:PlaySound(args.spellId, "alert")
end

function mod:EnlargeApplied(args)
	self:Message(args.spellId, "orange", CL.buff_other:format(args.destName, args.spellName))
	if self:Dispeller("magic", true) then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:EnlargeDispelled(args)
	if args.extraSpellName == self:SpellName(25462) then
		self:Message(25462, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

do
	local prev = 0
	function mod:LightningCloudDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:AddsDie()
	addsAlive = addsAlive - 1
	if addsAlive == 0 then
		local stage = self:GetStage()
		stage = stage + 1
		addsAlive = 7
		self:SetStage(stage)
		if stage == 8 then
			self:Message("stages", "cyan", CL.other:format(CL.stage:format(stage), CL.boss), false)
		else
			self:Message("stages", "cyan", CL.stage:format(stage), false)
		end
		self:PlaySound("stages", "info")
	end
end

function mod:AndorovDies()
	andorovDied = GetTime()
end
