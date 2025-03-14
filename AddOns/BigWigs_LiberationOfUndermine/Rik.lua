
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Rik Reverb", 2769, 2641)
if not mod then return end
mod:RegisterEnableMob(228648) -- Rik Reverb
mod:SetEncounterID(3011)
mod:SetRespawnTime(30)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local amplificationCount = 1
local echoingChantCount = 1
local soundCannonCount = 1
local faultyZapCount = 1
local sparkblastIgnitionCount = 1
local soundCloudCount = 1
local blaringDropCount = 1

local fullAmplificationCount = 1
local fullEchoingChantCount = 1
local fullSoundCannonCount = 1
local fullFaultyZapCount = 1
local fullSparkblastIgnitionCount = 1

local mobCollector = {}
local mobMarks = {}

local timersNormal = {
	[473748] = { 9.5, 40.1, 37.8, 0 }, -- Amplification!
	[466866] = { 24.5, 58.5, 28.5, 0 }, -- Echoing Chant
	[467606] = { 32.0, 35.0, 0 }, -- Sound Cannon
	[466979] = { 43.5, 31.5, 26.5, 0 }, -- Faulty Zap
}
local timersHeroic = {
	[473748] = { 10.9, 39.6, 39.2, 0 }, -- Amplification!
	[466866] = { 24.6, 58.5, 0 }, -- Echoing Chant
	[467606] = { 32.1, 35.0, 0 }, -- Sound Cannon
	[466979] = { 43.5, 31.5, 26.0, 0 }, -- Faulty Zap
	[472306] = { 25.0, 39.5, 43.2, 0 }, -- Sparkblast Ignition
}
local timersMythic = {
	[473748] = { 11.0, 40.0, 39.0, 0 }, -- Amplification!
	[466866] = { 24.5, 39.0, 0 }, -- Echoing Chant
	[467606] = { 32.0, 35.0, 0 }, -- Sound Cannon
	[466979] = { 43.5, 31.5, 26.0, 0 }, -- Faulty Zap
	[472306] = { 25.0, 59.0, 21.5, 0 }, -- Sparkblast Ignition
}
local timers = mod:Easy() and timersNormal or mod:Mythic() and timersMythic or timersHeroic

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.amplification = "Amplifiers"
	L.echoing_chant = "Echoes"
	L.faulty_zap = "Zaps"
	L.sparkblast_ignition = "Barrels"
end

--------------------------------------------------------------------------------
-- Initialization
--

local amplifierMarker = mod:AddMarkerOption(false, "npc", 1, -31087, 1, 2, 3, 4, 5, 6, 7, 8)
function mod:GetOptions()
	return {
		amplifierMarker,
		"stages",
		-- Stage One: Party Starter
		473748, -- Amplification!
			1217122, -- Lingering Voltage
			468119, -- Resonant Echoes
				1214598, -- Entranced!
			-- 465795, -- Noise Pollution
			466093, -- Haywire -- XXX Check if this warning is needed
		466866, -- Echoing Chant
		{467606, "SAY", "SAY_COUNTDOWN"}, -- Sound Cannon
		466979, -- Faulty Zap
		472306, -- Sparkblast Ignition
			1214164, -- Excitement
		464518, -- Tinnitus
		-- Stage Two: Hype Hustle
		{473260, "CASTBAR"}, -- Blaring Drop
		{473655, "CASTBAR"}, -- Hype Fever!
	},{ -- Sections
		[473748] = -31656, -- Stage 1
		[473260] = -31655, -- Stage 2
	},{ -- Renames
		[473748] = L.amplification, -- Amplification! (Amplifiers)
		[466866] = L.echoing_chant, -- Echoing Chant (Echoes)
		[466979] = L.faulty_zap, -- Faulty Zap (Zaps)
		[472306] = L.sparkblast_ignition, -- Sparkblast Ignition (Barrels)
	}
end

function mod:OnRegister()
	self:SetSpellRename(473748, L.amplification) -- Amplification! (Amplifiers)
	self:SetSpellRename(466866, L.echoing_chant) -- Echoing Chant (Echoes)
	self:SetSpellRename(466979, L.faulty_zap) -- Faulty Zap (Zaps)
	self:SetSpellRename(472306, L.sparkblast_ignition) -- Sparkblast Ignition (Barrels)
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Amplification", 473748)
	self:Log("SPELL_AURA_APPLIED", "LingeringVoltageApplied", 1217122)
	self:Log("SPELL_AURA_APPLIED_DOSE", "LingeringVoltageApplied", 1217122)
	self:Log("SPELL_AURA_APPLIED", "ResonantEchoesApplied", 468119)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ResonantEchoesApplied", 468119)
	self:Log("SPELL_AURA_APPLIED", "EntrancedApplied", 1214598)
	self:Log("SPELL_AURA_APPLIED", "HaywireApplied", 466093)
	self:Log("SPELL_CAST_SUCCESS", "EchoingChant", 466866)
	self:Log("SPELL_CAST_START", "SoundCannon", 467606)
	self:Log("SPELL_AURA_APPLIED", "SoundCannonApplied", 469380)
	self:Log("SPELL_AURA_REMOVED", "SoundCannonRemoved", 469380)
	self:Log("SPELL_CAST_SUCCESS", "SoundCannonSuccess", 467606)
	self:Log("SPELL_CAST_START", "FaultyZap", 466979)
	self:Log("SPELL_AURA_APPLIED", "FaultyZapApplied", 467108) -- pre debuffs
	self:Log("SPELL_SUMMON", "PyrotechnicsSpawn", 1214688) -- Sparkblast Ignition
	self:Log("SPELL_AURA_APPLIED", "ExcitementApplied", 1214164)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ExcitementApplied", 1214164)
	self:Log("SPELL_AURA_APPLIED", "TinnitusApplied", 464518)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TinnitusApplied", 464518)

	-- Stage Two: Hype Hustle
	self:Log("SPELL_AURA_APPLIED", "SoundCloudApplied", 1213817)
	self:Log("SPELL_AURA_REMOVED", "SoundCloudRemoved", 1213817)
	self:Log("SPELL_CAST_START", "BlaringDropStart", 473260)
	self:Log("SPELL_AURA_APPLIED", "BlaringDropApplied", 467991)
	self:Log("SPELL_AURA_APPLIED_DOSE", "BlaringDropApplied", 467991)
	self:Log("SPELL_CAST_START", "HypeFever", 473655)
	self:Log("SPELL_CAST_SUCCESS", "HypeFeverSuccess", 473655)

	timers = self:Easy() and timersNormal or self:Mythic() and timersMythic or timersHeroic
end

function mod:OnEngage()
	self:SetStage(1)
	amplificationCount = 1
	echoingChantCount = 1
	soundCannonCount = 1
	faultyZapCount = 1
	sparkblastIgnitionCount = 1
	soundCloudCount = 1

	-- these are on the bars
	fullAmplificationCount = 1
	fullEchoingChantCount = 1
	fullSoundCannonCount = 1
	fullFaultyZapCount = 1
	fullSparkblastIgnitionCount = 1

	mobCollector = {}
	mobMarks = {}

	self:CDBar(473748, timers[473748][amplificationCount], CL.count:format(L.amplification, fullAmplificationCount)) -- Amplification!
	if not self:Easy() then
		self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(L.sparkblast_ignition, fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	end
	self:Bar(466866, timers[466866][echoingChantCount], CL.count:format(L.echoing_chant, fullEchoingChantCount)) -- Echoing Chant
	self:Bar(467606, timers[467606][soundCannonCount], CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:Bar(466979, timers[466979][faultyZapCount], CL.count:format(L.faulty_zap, fullFaultyZapCount)) -- Faulty Zap
	self:Bar("stages", 121, CL.stage:format(2), 66911) -- disco ball icon // until _applied

	if self:GetOption(amplifierMarker) then
		self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	-- remove marks for removed amps
	for icon = 1, 8 do
		local guid = mobMarks[icon]
		if guid and not self:UnitTokenFromGUID(guid) then
			mobMarks[icon] = nil
		end
	end

	for i = 2, 9 do
		local unit = ("boss%d"):format(i)
		local guid = self:UnitGUID(unit)
		if guid then
			local mobId = self:MobId(guid)
			if mobId == 230197 and not mobCollector[guid] then -- Amplifier
				mobCollector[guid] = true
				for icon = 1, 8 do
					if not mobMarks[icon] then
						mobMarks[icon] = guid
						self:CustomIcon(amplifierMarker, unit, icon)
						break
					end
				end
			end
		end
	end
end

-- Stage One: Party Starter

function mod:Amplification(args)
	self:StopBar(CL.count:format(L.amplification, fullAmplificationCount))
	self:Message(args.spellId, "yellow", CL.count:format(L.amplification, fullAmplificationCount))
	self:PlaySound(args.spellId, "alert") -- spawning amplifier
	amplificationCount = amplificationCount + 1
	fullAmplificationCount = fullAmplificationCount + 1
	self:CDBar(args.spellId, timers[args.spellId][amplificationCount], CL.count:format(L.amplification, fullAmplificationCount))
end

function mod:LingeringVoltageApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		local tooHigh = 10 -- XXX Check what is high enough
		if amount % 2 == 1 or amount > tooHigh then
			self:StackMessage(args.spellId, "blue", args.destName, amount, tooHigh)
			if amount > tooHigh then
				self:PlaySound(args.spellId, "alarm") -- watch stacks
			end
		end
	end
end

function mod:ResonantEchoesApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 1)
		if self:Easy() then -- Warning sound in heroic+ from Entranced!
			self:PlaySound(args.spellId, "alarm") -- watch stacks
		end
	end
end

function mod:EntrancedApplied(args)
	self:TargetMessage(args.spellId, "red", args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(args.spellId, "warning") -- lured in
	end
end

function mod:HaywireApplied(args)
	if self:GetStage() == 1 then
		local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags)) or ""
		self:Message(args.spellId, "red", args.spellName .. icon)
		self:PlaySound(args.spellId, "alarm")
	end
end

function mod:EchoingChant(args)
	self:StopBar(CL.count:format(L.echoing_chant, fullEchoingChantCount))
	self:Message(args.spellId, "orange", CL.count:format(L.echoing_chant, fullEchoingChantCount))
	self:PlaySound(args.spellId, "alert") -- watch amplifiers
	echoingChantCount = echoingChantCount + 1
	fullEchoingChantCount = fullEchoingChantCount + 1

	local cd = timers[args.spellId][echoingChantCount]
	self:Bar(args.spellId, cd, CL.count:format(L.echoing_chant, fullEchoingChantCount))
end

function mod:SoundCannon(args)
	self:StopBar(CL.count:format(args.spellName, fullSoundCannonCount))
	self:Bar(args.spellId, timers[args.spellId][soundCannonCount+1], CL.count:format(args.spellName, fullSoundCannonCount+1))
end

function mod:SoundCannonApplied(args)
	self:TargetMessage(467606, "red", args.destName, CL.count:format(self:SpellName(467606), fullSoundCannonCount))
	self:TargetBar(467606, 5, args.destName)
	if self:Me(args.destGUID) then
		self:PlaySound(467606, "warning")
		if self:Mythic() then -- soak
			self:Yell(467606, nil, nil, "Sound Cannon")
			self:YellCountdown(467606, 5)
		else -- avoid
			self:Say(467606, nil, nil, "Sound Cannon")
			self:SayCountdown(467606, 5)
		end
	else
		self:PlaySound(467606, "alert", nil, args.destName) -- avoid / soak
	end
end

function mod:SoundCannonRemoved(args)
	self:StopBar(467606, args.destName)
	if self:Me(args.destGUID) then
		if self:Mythic() then
			self:CancelYellCountdown(467606)
		else
			self:CancelSayCountdown(467606)
		end
	end
end

function mod:SoundCannonSuccess(args)
	-- increase count here incase of re-casting
	soundCannonCount = soundCannonCount + 1
	fullSoundCannonCount = fullSoundCannonCount + 1
end

function mod:FaultyZap(args)
	self:StopBar(CL.count:format(L.faulty_zap, fullFaultyZapCount))
	self:Message(args.spellId, "yellow", CL.count:format(L.faulty_zap, fullFaultyZapCount))
	faultyZapCount = faultyZapCount + 1
	fullFaultyZapCount = fullFaultyZapCount + 1
	self:Bar(args.spellId, timers[args.spellId][faultyZapCount], CL.count:format(L.faulty_zap, fullFaultyZapCount))
end

function mod:FaultyZapApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(466979)
		self:PlaySound(466979, "alarm")
	end
end

do
	local prev = 0
	function mod:PyrotechnicsSpawn(args)
		if args.time - prev > 3 then
			prev = args.time
			self:StopBar(CL.count:format(L.sparkblast_ignition, fullSparkblastIgnitionCount))
			self:Message(472306, "cyan", CL.count:format(L.sparkblast_ignition, fullSparkblastIgnitionCount))
			self:PlaySound(472306, "info") -- adds
			sparkblastIgnitionCount = sparkblastIgnitionCount + 1
			fullSparkblastIgnitionCount = fullSparkblastIgnitionCount + 1
			self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(L.sparkblast_ignition, fullSparkblastIgnitionCount))
		end
	end
end

function mod:ExcitementApplied(args)
	if self:Me(args.destGUID) then
		local amount = args.amount or 1
		if amount % 2 == 1 then
			self:Message(args.spellId, "green", CL.stackyou:format(amount, args.spellName))
			self:PlaySound(args.spellId, "info") -- buffs!
		end
	end
end

function mod:TinnitusApplied(args)
	if self:Tank() and self:Tank(args.destName) then
		local amount = args.amount or 1
		self:StackMessage(args.spellId, "purple", args.destName, amount, 0)
		if amount > 5 and amount % 2 == 0 then -- 6, 8...
			self:PlaySound(args.spellId, "warning") -- swap?
		end
	elseif self:Me(args.destGUID) then -- Not a tank
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 0)
		self:PlaySound(args.spellId, "warning")
	end
end

-- Stage Two: Hype Hustle
function mod:SoundCloudApplied(args)
	if self:GetStage() == 3 then return end
	self:StopBar(CL.count:format(self:SpellName(473748), fullAmplificationCount)) -- Amplification!
	self:StopBar(CL.count:format(self:SpellName(472306), fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	self:StopBar(CL.count:format(self:SpellName(466866), fullEchoingChantCount)) -- Echoing Chant
	self:StopBar(CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:StopBar(CL.count:format(self:SpellName(466979), fullFaultyZapCount)) -- Faulty Zap
	self:StopBar(CL.stage:format(2))

	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:PlaySound("stages", "long") -- stage 2
	soundCloudCount = soundCloudCount + 1
	if soundCloudCount < 3 then
		self:Bar("stages", self:Mythic() and 28 or 32, CL.stage:format(1), args.spellId)
	end

	blaringDropCount = 1
end

function mod:SoundCloudRemoved(args)
	if self:GetStage() == 3 then return end
	self:StopBar(CL.stage:format(1))

	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:PlaySound("stages", "long") -- stage 1
	if soundCloudCount < 3 then
		self:Bar("stages", 120, CL.stage:format(2), 66911) -- disco ball icon // until _applied
	else
		self:Bar(473655, 115) -- third cast -> Hype Fever
	end

	amplificationCount = 1
	echoingChantCount = 1
	soundCannonCount = 1
	faultyZapCount = 1
	sparkblastIgnitionCount = 1

	self:CDBar(473748, timers[473748][amplificationCount], CL.count:format(L.amplification, fullAmplificationCount)) -- Amplification!
	if not self:Easy() then
		self:Bar(472306, timers[472306][sparkblastIgnitionCount], CL.count:format(L.sparkblast_ignition, fullSparkblastIgnitionCount)) -- Sparkblast Ignition
	end
	self:Bar(466866, timers[466866][echoingChantCount], CL.count:format(L.echoing_chant, fullEchoingChantCount)) -- Echoing Chant
	self:Bar(467606, timers[467606][soundCannonCount], CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:Bar(466979, timers[466979][faultyZapCount], CL.count:format(L.faulty_zap, fullFaultyZapCount)) -- Faulty Zap
end

function mod:BlaringDropStart(args)
	self:Message(args.spellId, "red", CL.count:format(args.spellName, blaringDropCount))
	self:PlaySound(args.spellId, "warning") -- go amplifier
	self:CastBar(args.spellId, 5, CL.count_amount:format(args.spellName, blaringDropCount, 4))
	blaringDropCount = blaringDropCount + 1
end

function mod:BlaringDropApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(473260, "blue", args.destName, args.amount, 1)
		self:PlaySound(473260, "warning") -- failed to avoid
	end
end

function mod:HypeFever(args)
	self:StopBar(args.spellId)
	self:StopBar(CL.count:format(L.amplification, fullAmplificationCount)) -- Amplification!
	self:StopBar(CL.count:format(L.echoing_chant, fullEchoingChantCount)) -- Echoing Chant
	self:StopBar(CL.count:format(self:SpellName(467606), fullSoundCannonCount)) -- Sound Cannon
	self:StopBar(CL.count:format(L.faulty_zap, fullFaultyZapCount)) -- Faulty Zap
	self:StopBar(CL.count:format(L.sparkblast_ignition, fullSparkblastIgnitionCount)) -- Sparkblast Ignition

	self:SetStage(3)
	self:Message(args.spellId, "red", CL.casting:format(args.spellName))
	self:PlaySound(args.spellId, "long")
	self:CastBar(args.spellId, 5)

	blaringDropCount = 1
end

function mod:HypeFeverSuccess(args)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "alarm") -- enrage
end
