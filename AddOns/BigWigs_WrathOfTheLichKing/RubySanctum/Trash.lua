--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Ruby Sanctum Trash", 724)
if not mod then return end
mod.displayName = CL.trash
mod:RegisterEnableMob(
	39751, -- Baltharus the Warborn
	39747, -- Saviana Ragefire
	39746 -- General Zarithrian
)

--------------------------------------------------------------------------------
-- Locals
--

local baltharusClones = {count = 1}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.baltharus = "Baltharus the Warborn"
	L.saviana = "Saviana Ragefire"
	L.zarithrian = "General Zarithrian"

	L.adds_yell_trigger = "Turn them to ash, minions!"
	L.adds_icon = "inv_misc_head_dragon_01"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		--[[ Baltharus the Warborn ]]--
		40504, -- Cleave
		75125, -- Blade Tempest
		74509, -- Repelling Wave
		{74502, "SAY", "ICON", "ME_ONLY_EMPHASIZE"}, -- Enervating Brand

		--[[ Saviana Ragefire ]]--
		74403, -- Flame Breath
		78722, -- Enrage
		{74452, "SAY", "COUNTDOWN"}, -- Conflagration
		{74453, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Flame Beacon

		--[[ General Zarithrian ]]--
		74367, -- Cleave Armor
		74384, -- Intimidating Roar
		"adds",
	},{
		[40504] = L.baltharus,
		[74403] = L.saviana,
		[74367] = L.zarithrian,
	},{
		[74509] = CL.knockback, -- Repelling Wave (Knockback)
		[74403] = CL.breath, -- Flame Breath (Breath)
	}
end

function mod:OnBossEnable()
	--[[ General ]]--
	self:RegisterMessage("BigWigs_OnBossEngage", "Disable")
	self:RegisterEvent("ENCOUNTER_START")

	--[[ Baltharus the Warborn ]]--
	self:Log("SPELL_CAST_SUCCESS", "Cleave", 40504)
	self:Log("SPELL_CAST_SUCCESS", "BladeTempest", 75125)
	self:Log("SPELL_CAST_START", "RepellingWave", 74509)
	self:Log("SPELL_AURA_APPLIED", "EnervatingBrandApplied", 74502)
	self:Log("SPELL_AURA_REMOVED", "EnervatingBrandRemoved", 74502)
	self:Death("BaltharusDies", 39751)

	--[[ Saviana Ragefire ]]--
	self:Log("SPELL_CAST_START", "FlameBreath", 74403)
	self:Log("SPELL_AURA_APPLIED", "EnrageApplied", 78722)
	self:Log("SPELL_DISPEL", "EnrageDispelled", "*")
	self:Log("SPELL_AURA_REMOVED", "EnrageRemoved", 78722)
	self:Log("SPELL_AURA_APPLIED", "ConflagrationApplied", 74456)
	self:Log("SPELL_CAST_SUCCESS", "Conflagration", 74452)
	self:Log("SPELL_AURA_APPLIED", "FlameBeaconApplied", 74453)
	self:Log("SPELL_AURA_REMOVED", "FlameBeaconRemoved", 74453)
	self:Death("SavianaDies", 39747)

	--[[ General Zarithrian ]]--
	self:Log("SPELL_CAST_SUCCESS", "CleaveArmor", 74367)
	self:Log("SPELL_AURA_APPLIED", "CleaveArmorApplied", 74367)
	self:Log("SPELL_AURA_APPLIED_DOSE", "CleaveArmorApplied", 74367)
	self:Log("SPELL_CAST_START", "IntimidatingRoar", 74384)
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL") -- Adds
	self:Death("ZarithrianDies", 39746)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:ENCOUNTER_START(_, id)
	if id == 1147 or id == 890 then -- Baltharus the Warborn (Retail/Classic)
		baltharusClones = {count = 1}
		self:CDBar(40504, 14) -- Cleave
		self:CDBar(75125, 15.5) -- Blade Tempest
	elseif id == 1149 or id == 891 then -- Saviana Ragefire (Retail/Classic)
		self:CDBar(74403, 11, CL.breath) -- Flame Breath
		self:CDBar(78722, 15) -- Enrage
		self:CDBar(74453, 33) -- Flame Beacon
	elseif id == 1148 or id == 893 then -- General Zarithrian (Retail/Classic)
		self:CDBar(74367, 8) -- Cleave Armor
		self:CDBar(74384, 13) -- Intimidating Roar
		self:CDBar("adds", 15.9, CL.adds, L.adds_icon)
	end
end

--[[ Baltharus the Warborn ]]--
function mod:Cleave(args)
	if self:MobId(args.sourceGUID) == 39751 then -- Baltharus
		self:Message(args.spellId, "yellow")
		self:CDBar(args.spellId, 21.5)
		self:PlaySound(args.spellId, "alert")
	elseif self:MobId(args.sourceGUID) == 39899 then -- Baltharus Clone
		if not baltharusClones[args.sourceGUID] then
			baltharusClones[args.sourceGUID] = CL.count:format(CL.add, baltharusClones.count)
			baltharusClones.count = baltharusClones.count + 1
		end
		local msg = CL.other:format(baltharusClones[args.sourceGUID], args.spellName)
		self:Message(args.spellId, "yellow", msg)
		self:CDBar(args.spellId, 21.5, msg)
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:BladeTempest(args)
	if self:MobId(args.sourceGUID) == 39751 then -- Baltharus
		self:Message(args.spellId, "red")
		self:CDBar(args.spellId, 23)
		self:PlaySound(args.spellId, "info")
	elseif self:MobId(args.sourceGUID) == 39899 then -- Baltharus Clone
		if not baltharusClones[args.sourceGUID] then
			baltharusClones[args.sourceGUID] = CL.count:format(CL.add, baltharusClones.count)
			baltharusClones.count = baltharusClones.count + 1
		end
		local msg = CL.other:format(baltharusClones[args.sourceGUID], args.spellName)
		self:Message(args.spellId, "red", msg)
		self:CDBar(args.spellId, 23, msg)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:RepellingWave(args)
	self:Message(args.spellId, "orange", CL.incoming:format(CL.knockback))
	self:PlaySound(args.spellId, "long")
end

do
	local brandTarget = nil
	function mod:EnervatingBrandApplied(args)
		brandTarget = args.destGUID
		self:PrimaryIcon(args.spellId, args.destName)
		self:TargetMessage(args.spellId, "orange", args.destName)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Enervating Brand")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
	function mod:EnervatingBrandRemoved(args)
		if brandTarget == args.destGUID then
			self:PrimaryIcon(args.spellId)
		end
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId, "removed")
		end
	end
end

function mod:BaltharusDies()
	for k,v in next, baltharusClones do
		if k ~= "count" then
			self:StopBar(CL.other:format(v, self:SpellName(40504))) -- Cleave
			self:StopBar(CL.other:format(v, self:SpellName(75125))) -- Blade Tempest
		end
	end
	baltharusClones = {count = 1}
	self:StopBar(40504) -- Cleave
	self:StopBar(75125) -- Blade Tempest
	self:PlayVictorySound()
end

--[[ Saviana Ragefire ]]--
function mod:FlameBreath(args)
	self:Message(args.spellId, "red", CL.breath)
	self:CDBar(args.spellId, 23, CL.breath)
	self:PlaySound(args.spellId, "info")
end

function mod:EnrageApplied(args)
	self:Message(args.spellId, "orange", CL.buff_other:format(args.destName, args.spellName))
	self:TargetBar(args.spellId, 10, args.destName)
	self:CDBar(args.spellId, 22)
	self:PlaySound(args.spellId, "alarm")
end

function mod:EnrageDispelled(args)
	if args.extraSpellId == 78722 then
		self:Message(78722, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:EnrageRemoved(args)
	self:StopBar(args.spellName, args.destName)
end

function mod:ConflagrationApplied(args)
	if self:Me(args.destGUID) then
		self:Say(74452, nil, nil, "Conflagration")
	end
end

do
	local playerList = {}
	function mod:Conflagration(args)
		playerList = {}
		self:Bar(args.spellId, 5)
		self:CDBar(74453, 50) -- Flame Beacon
	end

	function mod:FlameBeaconApplied(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "yellow", playerList)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Flame Beacon")
			self:SayCountdown(args.spellId, 5)
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

function mod:FlameBeaconRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
end

function mod:SavianaDies()
	self:StopBar(78722) -- Enrage
	self:StopBar(74453) -- Flame Beacon
	self:StopBar(CL.breath) -- Flame Breath
	self:PlayVictorySound()
end

--[[ General Zarithrian ]]--
function mod:CleaveArmor(args)
	self:CDBar(args.spellId, 15)
end

function mod:CleaveArmorApplied(args)
	self:StackMessage(args.spellId, "purple", args.destName, args.amount, 2)
	if args.amount then
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:IntimidatingRoar(args)
	self:Message(args.spellId, "yellow")
	self:CDBar(args.spellId, 34)
	self:PlaySound(args.spellId, "alert")
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.adds_yell_trigger, nil, true) then
		self:Message("adds", "cyan", CL.adds_spawned, L.adds_icon)
		self:CDBar("adds", 45.5, CL.adds, L.adds_icon)
		self:PlaySound("adds", "long")
	end
end

function mod:ZarithrianDies()
	self:StopBar(74367) -- Cleave Armor
	self:StopBar(74384) -- Intimidating Roar
	self:StopBar(CL.adds)
	self:PlayVictorySound()
end
