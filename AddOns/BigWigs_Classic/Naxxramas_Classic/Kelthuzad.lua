--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Kel'Thuzad", 533, 1615)
if not mod then return end
mod:RegisterEnableMob(15990, 16428, 16427, 16429) -- Kel'Thuzad, Unstoppable Abomination, Soldier of the Frozen Wastes, Soul Weaver
mod:SetEncounterID(1114)
mod:SetRespawnTime(61)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.KELTHUZADCHAMBERLOCALIZEDLOLHAX = "Kel'Thuzad's Chamber"

	L.engage_yell_trigger = "Minions, servants, soldiers of the cold dark! Obey the call of Kel'Thuzad!"
	L.stage2_yell_trigger1 = "Pray for mercy!"
	L.stage2_yell_trigger2 = "Scream your dying breath!"
	L.stage2_yell_trigger3 = "The end is upon you!"
	L.stage3_yell_trigger = "Master, I require aid!"
	L.adds_yell_trigger = "Very well. Warriors of the frozen wastes, rise up! I command you to fight, kill and die for your master! Let none survive!"
	L.adds_icon = "inv_trinket_naxxramas04"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		28467, -- Mortal Wound
		27808, -- Frost Blast
		{27810, "SAY", "ME_ONLY_EMPHASIZE"}, -- Shadow Fissure
		28410, -- Chains of Kel'Thuzad
		{27819, "ICON", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Detonate Mana
		"adds",
		"stages",
	},nil,{
		[28410] = CL.mind_control, -- Chains of Kel'Thuzad (Mind Control)
		[27819] = CL.bomb, -- Detonate Mana (Bomb)
	}
end

-- Big evul hack to enable the module when entering Kel'Thuzads chamber.
function mod:OnRegister()
	local f = CreateFrame("Frame")
	local func = function()
		if not mod:IsEnabled() and GetSubZoneText() == L.KELTHUZADCHAMBERLOCALIZEDLOLHAX then
			mod:Enable()
		end
	end
	f:SetScript("OnEvent", func)
	f:RegisterEvent("ZONE_CHANGED_INDOORS")
	func()
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")

	self:Log("SPELL_AURA_APPLIED_DOSE", "MortalWoundApplied", 28467)
	self:Log("SPELL_CAST_SUCCESS", "ShadowFissure", 27810)
	self:Log("SPELL_CAST_SUCCESS", "FrostBlast", 27808)
	self:Log("SPELL_AURA_APPLIED", "FrostBlastApplied", 27808)
	self:Log("SPELL_CAST_SUCCESS", "DetonateMana", 27819)
	self:Log("SPELL_AURA_APPLIED", "DetonateManaApplied", 27819)
	self:Log("SPELL_AURA_REMOVED", "DetonateManaRemoved", 27819)
	self:Log("SPELL_CAST_SUCCESS", "ChainsOfKelThuzad", 28408)
	self:Log("SPELL_AURA_APPLIED", "ChainsOfKelThuzadApplied", 28410)
end

function mod:OnEngage()
	self:SetStage(1)

	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar("stages", self:GetSeason() == 2 and 221 or 308, CL.stage:format(2), "inv_jewelry_trinket_04")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.engage_yell_trigger, nil, true) then
		self:Engage()
	elseif msg:find(L.stage2_yell_trigger1, nil, true) or msg:find(L.stage2_yell_trigger2, nil, true) or msg:find(L.stage2_yell_trigger3, nil, true) then
		self:StopBar(CL.stage:format(2))
		self:SetStage(2)
		self:RegisterEvent("UNIT_HEALTH")

		self:Message("stages", "cyan", CL.stage:format(2), false)
		self:Bar("stages", 15, CL.active, "achievement_boss_kelthuzad_01")
		self:PlaySound("stages", "info")
	elseif msg:find(L.stage3_yell_trigger, nil, true) then
		self:SetStage(3)
		self:Message("stages", "cyan", CL.percent:format(40, CL.stage:format(3)), false)
		self:PlaySound("stages", "info")
	elseif msg:find(L.adds_yell_trigger, nil, true) then
		self:Message("adds", "cyan", CL.adds_spawning, L.adds_icon)
		self:Bar("adds", 9, CL.adds, L.adds_icon)
		self:PlaySound("adds", "info")
	end
end

function mod:MortalWoundApplied(args)
	if args.amount >= 3 then
		self:StackMessage(args.spellId, "purple", args.destName, args.amount, 5)
	end
end

function mod:ShadowFissure(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Shadow Fissure")
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

do
	local playerList = {}
	function mod:FrostBlast(args)
		playerList = {}
		self:CDBar(args.spellId, 25)
		self:PlaySound(args.spellId, "alert")
	end

	function mod:FrostBlastApplied(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "yellow", playerList)
	end
end

function mod:DetonateMana(args)
	self:CDBar(args.spellId, 20, CL.bomb)
end

function mod:DetonateManaApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.bomb)
	self:TargetBar(args.spellId, 5, args.destName, CL.bomb)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.bomb, nil, "Bomb")
		self:SayCountdown(args.spellId, 5)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:DetonateManaRemoved(args)
	self:StopBar(CL.bomb, args.destName)
	self:PrimaryIcon(args.spellId)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

do
	local playerList = {}
	function mod:ChainsOfKelThuzad()
		playerList = {}
		self:CDBar(28410, 68, CL.mind_control)
		self:PlaySound(28410, "long")
	end

	function mod:ChainsOfKelThuzadApplied(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "orange", playerList, 5, CL.mind_control, nil, 1)
	end
end

function mod:UNIT_HEALTH(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 15990 then
		local hp = self:GetHealth(unit)
		if hp < 45 then
			self:UnregisterEvent(event)
			if hp > 40 then
				self:Message("stages", "cyan", CL.soon:format(CL.stage:format(3)), false)
			end
		end
	end
end
