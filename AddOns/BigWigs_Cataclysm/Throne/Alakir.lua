--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Al'Akir", 754, 155)
if not mod then return end
mod:RegisterEnableMob(46753)
mod:SetEncounterID(1034)
mod:SetRespawnTime(25)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local lastWindburst = 0
local shock = false
local acidRainCounter = 1
local acidRainCounted = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.stormling = "Stormling adds"
	L.stormling_desc = "Summons a Stormling."
	L.stormling_icon = 88272

	L.acid_rain = "Acid Rain (%d)"

	L.feedback_message = "%dx Feedback"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- Stage 1
		87770, -- Wind Burst
		-- Stage 2
		87904, -- Feedback
		"stormling",
		88301, -- Acid Rain
		-- Stage 3
		{89668, "ICON"},
		89588, -- Lightning Rod
		-- Heroic
		87873, -- Static Shock
		-- General
		88427, -- Electrocute
		"stages",
		"berserk",
	},{
		[87770] = CL.stage:format(1),
		[87904] = CL.stage:format(2),
		[89668] = CL.stage:format(3),
		[87873] = "heroic",
		[88427] = "general",
	}
end

function mod:VerifyEnable(unit)
	if UnitCanAttack(unit, "player") then
		return true
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "Electrocute", 88427)
	self:Log("SPELL_CAST_START", "WindBurst1", 87770)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Feedback", 87904)
	self:Log("SPELL_AURA_APPLIED", "Feedback", 87904)
	self:Log("SPELL_AURA_APPLIED_DOSE", "AcidRain", 88301)
	self:Log("SPELL_DAMAGE", "Shock", 87873) -- [May be wrong since MoP id changes]
	self:Log("SPELL_MISSED", "Shock", 87873) -- [May be wrong since MoP id changes]

	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1")

	self:Log("SPELL_AURA_APPLIED", "LightningRod", 89668)
	self:Log("SPELL_AURA_REMOVED", "RodRemoved", 89668)

	self:Log("SPELL_DAMAGE", "WindBurst3", 88858) -- Wrong id
	self:Log("SPELL_MISSED", "WindBurst3", 88858)

	self:Log("SPELL_DAMAGE", "Cloud", 89588)
	self:Log("SPELL_MISSED", "Cloud", 89588)
end

function mod:OnEngage()
	lastWindburst = 0
	acidRainCounter = 1
	acidRainCounted = false
	shock = false
	self:SetStage(1)
	self:Berserk(600)
	self:Bar(87770, 22) -- Windburst
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function Shocker()
		if mod:GetStage() == 1 then
			mod:Bar(87873, 10)
			mod:ScheduleTimer(Shocker, 10)
		end
	end
	function mod:Shock(args)
		if not shock then
			--Do we need a looping timer here?
			shock = true
			Shocker()
		end
	end
end

function mod:Cloud(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:LightningRod(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	self:PrimaryIcon(args.spellId, args.destName)
	self:PlaySound(args.spellId, "long")
end

function mod:RodRemoved(args)
	self:PrimaryIcon(args.spellId) -- De-mark
end

local function CloudSpawn(self)
	self:ScheduleTimer(CloudSpawn, 10, self)
	self:Bar(89588, 10) -- Lightning Clouds
	self:Message(89588, "red") -- Lightning Clouds
	self:PlaySound(89588, "info")
end

function mod:Feedback(args)
	local buffStack = args.amount or 1
	self:StopBar(L.feedback_message:format(buffStack-1))
	self:Bar(args.spellId, self:Heroic() and 20 or 30, L.feedback_message:format(buffStack))
	self:Message(args.spellId, "green", L.feedback_message:format(buffStack))
end

do
	local function clearCount()
		acidRainCounted = false
	end
	function mod:AcidRain(args)
		if acidRainCounted then return end
		acidRainCounter = acidRainCounter + 1
		acidRainCounted = true
		self:SimpleTimer(clearCount, 12) -- 15 - 3
		self:Bar(args.spellId, 15, CL.count:format(args.spellName, acidRainCounter))
		self:Message(args.spellId, "yellow", CL.count:format(args.spellName, acidRainCounter))
	end
end

function mod:Electrocute(args)
	self:TargetMessage(args.spellId, "red", args.destName)
end

function mod:WindBurst1(args)
	self:Bar(args.spellId, 26)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alert")
end

function mod:WindBurst3(args)
	if (args.time - lastWindburst) > 5 then
		self:Bar(87770, 19, args.spellName, args.spellId) -- 22 was too long, 19 should work
		self:Message(87770, "yellow", args.spellName, args.spellId)
	end
	lastWindburst = args.time
end

function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, _, spellId)
	if spellId == 88272 then -- Stormling
		self:Bar("stormling", 20, spellId, spellId)
		self:Message("stormling", "red", CL.incoming:format(self:SpellName(spellId)), spellId)
	elseif spellId == 88290 then -- Acid Rain
		self:SetStage(2)
		self:StopBar(87770) -- Windburst
		self:Message("stages", "green", CL.stage:format(2), 88301)
		self:PlaySound("stages", "info")
	elseif spellId == 89528 then -- Relentless Storm Initial Vehicle Ride Trigger
		self:SetStage(3)
		self:Message("stages", "green", CL.stage:format(3), 88875)
		self:Bar(87770, 24) -- Windburst
		self:Bar(89588, 16) -- Lightning Clouds
		self:ScheduleTimer(CloudSpawn, 16, self)
		self:StopBar(88272) -- Stormling
		self:StopBar(87904) -- Feedback
		self:StopBar(CL.count:format(self:SpellName(88301), acidRainCounter)) -- Acid Rain
	end
end

