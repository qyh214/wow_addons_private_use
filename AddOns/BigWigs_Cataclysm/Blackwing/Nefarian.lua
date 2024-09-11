--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Nefarian", 669, 174)
if not mod then return end
mod:RegisterEnableMob(41270, 41376) -- Onyxia, Nefarian
mod:SetEncounterID(1026)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local sparkCount = 0
local blastNovaCollector = {}
local addsCollector = {}
local currentPercent = 100
local electrocuteCount = 0
local addsActive = 0
local addsDead = 0
local chromaticPrototypeKilled = 0
local powerWarned = false
local highestEmpower = 0
local empowerLine = 9

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.discharge = "Discharge"
	L.stage3_yell_trigger = "KILL YOU ALL" -- I have tried to be an accommodating host, but you simply will not die! Time to throw all pretense aside and just... KILL YOU ALL!
	L.too_close = "Dragons are too close"
	L["77939_icon"] = "spell_nature_lightning"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Onyxia
		{77939, "CASTBAR"}, -- Lightning Discharge
		78999, -- Electrical Overload
		-- Normal
		{81272, "CASTBAR"}, -- Electrocute
		78620, -- Children of Deathwing
		77826, -- Shadowflame Breath
		{77827, "OFF"}, -- Tail Lash
		"infobox",
		"stages",
		-- Stage 2
		80734, -- Blast Nova
		81031, -- Shadowblaze Spark
		81007, -- Shadowblaze
		-- Heroic
		{79339, "CASTBAR", "CASTBAR_COUNTDOWN", "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Explosive Cinders
		79318, -- Dominion
		"berserk",
	},{
		[77939] = -3283, -- Onyxia
		[81272] = "normal",
		[80734] = CL.stage:format(2),
		[81031] = CL.stage:format(3),
		[79339] = "heroic",
	},{
		[77939] = L.discharge, -- Lightning Discharge (Discharge)
		[78999] = CL.full_energy, -- Electrical Overload (Full Energy)
		[78620] = L.too_close, -- Children of Deathwing (Dragons are too close)
		[77826] = CL.breath, -- Shadowflame Breath (Breath)
		[81007] = CL.underyou:format(CL.fire), -- Shadowblaze (Fire under YOU)
		[79339] = CL.bomb, -- Explosive Cinders (Bomb)
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
	self:Log("SPELL_CAST_START", "Dominion", 79318)
	self:Log("SPELL_AURA_APPLIED", "DominionApplied", 79318)
	self:Log("SPELL_CAST_START", "ShadowflameBreath", 77826)
	self:Log("SPELL_CAST_SUCCESS", "TailLash", 77827)

	-- Stage 1
	self:Log("SPELL_CAST_SUCCESS", "LightningDischarge", 78090)
	self:Log("SPELL_AURA_APPLIED", "ChildrenOfDeathwingApplied", 78619, 78620)
	self:Log("SPELL_AURA_REFRESH", "ChildrenOfDeathwingApplied", 78619, 78620)
	self:Log("SPELL_AURA_APPLIED", "Empower", 79330)
	self:Log("SPELL_AURA_APPLIED_DOSE", "EmpowerStacks", 79330)
	self:Log("SPELL_SUMMON", "HailOfBones", 78684) -- Summon adds
	self:Death("AnimatedBoneWarriorDeaths", 41918) -- Animated Bone Warrior
	self:Death("OnyxiaDeath", 41270) -- Onyxia

	-- Stage 2
	self:Log("SPELL_CAST_START", "BlastNova", 80734)
	self:Log("SPELL_CAST_START", "ExplosiveCinders", 79339)
	self:Log("SPELL_AURA_APPLIED", "ExplosiveCindersApplied", 79339)
	self:Log("SPELL_AURA_REMOVED", "ExplosiveCindersRemoved", 79339)
	self:Death("ChromaticPrototypeDeaths", 41948) -- Chromatic Prototype

	-- Stage 3
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
	self:Log("SPELL_CAST_SUCCESS", "ShadowblazeSpark", 81031)
	self:Log("SPELL_DAMAGE", "ShadowblazeDamage", 81007)
	self:Log("SPELL_MISSED", "ShadowblazeDamage", 81007)
end

function mod:OnEngage()
	sparkCount = 0
	blastNovaCollector = {}
	addsCollector = {}
	currentPercent = 100
	electrocuteCount = 0
	addsActive = 0
	addsDead = 0
	chromaticPrototypeKilled = 0
	powerWarned = false
	highestEmpower = 0
	empowerLine = 9
	self:SetStage(1)
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", nil, "boss1", "boss2")
	self:Berserk(630)
	self:CDBar(77939, 24, L.discharge, "spell_nature_lightning")
	self:Bar("stages", 30, self:SpellName(-3279), "achievement_boss_nefarion") -- Nefarian
	self:ScheduleTimer("NefarianLanding", 30)
	if self:Heroic() and not self:Solo() then
		self:CDBar(79318, 45) -- Dominion
	end
	self:OpenInfo("infobox", "BigWigs")
	self:SetInfo("infobox", 1, CL.other:format(self:SpellName(-3283), CL.energy)) -- Onyxia: Energy
	self:SetInfo("infobox", 2, 0)
	self:SetInfoBar("infobox", 1, 0)
	self:SetInfo("infobox", 3, CL.other:format(CL.adds, ""), 1, 0.4, 0.4)
	self:SetInfo("infobox", 5, CL.active)
	self:SetInfo("infobox", 6, addsActive)
	self:SetInfo("infobox", 7, CL.dead)
	self:SetInfo("infobox", 8, addsDead)
	self:SetInfo("infobox", 9, self:SpellName(79330), 0.4, 1, 0.6)
	self:SetInfo("infobox", 10, 0)
	self:SetInfoBar("infobox", 9, 0)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:NefarianLanding()
	self:Message("stages", "cyan", CL.landing:format(self:SpellName(-3279)), false) -- Nefarian
	self:PlaySound("stages", "long")
end

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg, _, _, _, target)
	if target == self:SpellName(-3279) and self:IsEngaged() then -- Not during the RP of activating the boss
		currentPercent = currentPercent - 10
		electrocuteCount = electrocuteCount + 1
		local msg = CL.count:format(self:SpellName(81272), electrocuteCount)
		self:Message(81272, "orange", CL.percent:format(currentPercent, CL.custom_sec:format(msg, 5)))
		self:CastBar(81272, 5, msg) -- Electrocute
		self:PlaySound(81272, "alert")
	end
end

do
	local playerList = {}
	function mod:Dominion(args)
		playerList = {}
		self:CDBar(args.spellId, 16.2)
	end

	function mod:DominionApplied(args)
		local count = #playerList
		playerList[count+1] = args.destName
		self:TargetsMessage(args.spellId, "yellow", playerList, 5)
		if count == 0 then
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:ShadowflameBreath(args)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if self:GetStage() == 3 or args.sourceGUID == self:UnitGUID("target") or (unit and self:UnitWithinRange(unit, 30)) then
		self:Message(args.spellId, "orange", CL.breath)
		self:CDBar(args.spellId, 12.1, CL.breath)
		self:PlaySound(args.spellId, "info")
	end
end

function mod:TailLash(args)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if args.sourceGUID == self:UnitGUID("target") or (unit and self:UnitWithinRange(unit, 30)) then
		self:CDBar(args.spellId, 12.1)
	end
end

-- Stage 1
function mod:LightningDischarge(args)
	self:CDBar(77939, 22, L.discharge, args.spellId)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if self:UnitGUID("target") == args.sourceGUID or (unit and self:UnitWithinRange(unit, 30)) then -- Target is Onyxia, or she is nearby
		self:Message(77939, "yellow", CL.casting:format(L.discharge), args.spellId)
		self:CastBar(77939, 5, L.discharge, args.spellId)
	end
end

function mod:UNIT_POWER_FREQUENT(event, unit)
	if self:MobId(self:UnitGUID(unit)) == 41270 then -- Onyxia
		local power = UnitPower(unit, 10) -- Enum.PowerType.Alternate = 10
		self:SetInfo("infobox", 2, power)
		self:SetInfoBar("infobox", 1, power/100)
		if power >= 85 and not powerWarned then
			powerWarned = true
			self:Message(78999, "red", CL.soon:format(CL.full_energy))
		end
	end
end

do
	local prev = 0
	function mod:ChildrenOfDeathwingApplied(args)
		if args.time - prev > 5 then
			prev = args.time
			self:Message(78620, "purple", L.too_close)
		end
	end
end

function mod:Empower(args)
	if not addsCollector[args.destGUID] then
		addsActive = addsActive + 1
		addsDead = addsDead - 1
		addsCollector[args.destGUID] = 0
		self:SetInfo("infobox", 2, addsActive)
		self:SetInfo("infobox", 4, addsDead)
	end
end

function mod:EmpowerStacks(args)
	addsCollector[args.destGUID] = args.amount
	if args.amount > highestEmpower then
		highestEmpower = args.amount
		self:SetInfo("infobox", empowerLine+1, highestEmpower)
		self:SetInfoBar("infobox", empowerLine, highestEmpower/100)
	end
end

function mod:HailOfBones(args) -- Summon adds
	addsActive = addsActive + 1
	addsCollector[args.destGUID] = 0
	self:SetInfo("infobox", empowerLine-3, addsActive)
end

function mod:AnimatedBoneWarriorDeaths(args)
	addsActive = addsActive - 1
	addsDead = addsDead + 1
	addsCollector[args.destGUID] = nil
	self:SetInfo("infobox", empowerLine-3, addsActive)
	self:SetInfo("infobox", empowerLine-1, addsDead)
	local highest = 0
	for _,v in next, addsCollector do
		if v > highest then
			highest = v
		end
	end
	highestEmpower = highest
	self:SetInfo("infobox", empowerLine+1, highest)
	self:SetInfoBar("infobox", empowerLine, highest/100)
end

-- Stage 2
function mod:OnyxiaDeath() -- Stage 2
	self:SetStage(2)
	self:StopBar(79318) -- Dominion
	self:StopBar(77827) -- Tail Lash
	self:StopBar(L.discharge) -- Lightning Discharge
	self:StopBar(CL.cast:format(L.discharge)) -- Lightning Discharge
	self:StopBar(CL.breath) -- Shadowflame Breath
	self:CloseInfo("infobox")
	self:UnregisterUnitEvent("UNIT_POWER_FREQUENT", "boss1", "boss2")
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "long")
end

function mod:BlastNova(args)
	blastNovaCollector[args.sourceGUID] = (blastNovaCollector[args.sourceGUID] or 0) + 1
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 30) then
		self:Message(args.spellId, "orange", CL.count:format(args.spellName, blastNovaCollector[args.sourceGUID]))
		local _, isReady = self:Interrupter()
		if isReady then
			self:PlaySound(args.spellId, "alert")
		end
	end
end

do
	local playerList = {}
	function mod:ExplosiveCinders(args)
		playerList = {}
		self:Bar(args.spellId, 24.2, CL.bombs)
	end

	function mod:ExplosiveCindersApplied(args)
		playerList[#playerList+1] = args.destName
		self:TargetsMessage(args.spellId, "orange", playerList, 3, CL.bomb)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, CL.bomb, nil, "Bomb")
			self:SayCountdown(args.spellId, 8, nil, 5)
			self:CastBar(args.spellId, 8, CL.explosion)
			self:PlaySound(args.spellId, "warning")
		end
	end
end

function mod:ExplosiveCindersRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
		self:StopBar(CL.cast:format(CL.explosion))
		self:PersonalMessage(args.spellId, "removed", CL.bomb)
	end
end

-- Stage 3
function mod:ChromaticPrototypeDeaths()
	chromaticPrototypeKilled = chromaticPrototypeKilled + 1
	if chromaticPrototypeKilled == (self:Heroic() and 1 or 3) then
		addsActive = 0
		addsDead = 12
		highestEmpower = 0
		empowerLine = 5
		self:SetStage(3)
		self:Message("stages", "cyan", CL.stage:format(3), false)
		self:OpenInfo("infobox", CL.other:format("BigWigs", CL.adds))
		self:SetInfo("infobox", 1, CL.active)
		self:SetInfo("infobox", 2, addsActive)
		self:SetInfo("infobox", 3, CL.dead)
		self:SetInfo("infobox", 4, addsDead)
		self:SetInfo("infobox", 5, self:SpellName(79330), 0.4, 1, 0.6)
		self:SetInfo("infobox", 6, 0)
		self:SetInfoBar("infobox", 5, 0)
		self:PlaySound("stages", "long")
	end
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L.stage3_yell_trigger, nil, true) then
		self:StopBar(CL.bombs) -- Explosive Cinders
		if self:Heroic() and not self:Solo() then
			self:CDBar(79318, 20) -- Dominion
		end
		self:CDBar(81031, 10) -- Shadowblaze Spark
	end
end

do
	local timers = {30, 25, 20, 15}
	function mod:ShadowblazeSpark(args)
		sparkCount = sparkCount + 1
		self:Message(args.spellId, "red")
		self:Bar(args.spellId, timers[sparkCount] or self:Normal() and 15 or 10)
		self:PlaySound(args.spellId, "alarm")
	end
end

do
	local prev = 0
	function mod:ShadowblazeDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end
