--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Mekgineer Thermaplugg Discovery", 90)
if not mod then return end
mod:RegisterEnableMob(
	218537, -- Mekgineer Thermaplugg
	218538, -- STX-96/FR
	218970, -- STX-97/IC
	218972, -- STX-98/PO
	218974 -- STX-99/XD
)
mod:SetEncounterID(2940)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local highVoltageList = {}
local highVoltageDebuffTime = {}
local castCollector = {}
local currentBossGUID = "none"
local UpdateInfoBoxList

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Mekgineer Thermaplugg"
	L.red_button = "Red Button"
	L.position = "Position %d" -- Position 5
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		-- General
		"stages",
		437853, -- Summon Bomb
		{438735, "INFOBOX"}, -- High Voltage!
		-- STX-96/FR
		438683, -- Sprocketfire Punch
		438710, -- Sprocketfire
		438713, -- Furnace Surge
		-- STX-97/IC
		438719, -- Supercooled Smash
		438720, -- Freezing
		438723, -- Coolant Discharge
		-- STX-98/PO
		438726, -- Hazardous Hammer
		438727, -- Radiation Sickness
		{438732, "EMPHASIZE"}, -- Toxic Ventilation
	},{
		["stages"] = CL.general,
		[438683] =  CL.stage:format(1),
		[438719] =  CL.stage:format(2),
		[438726] =  CL.stage:format(3),
	},{
		[437853] = CL.bombs, -- Summon Bomb (Bombs)
		[438735] = L.red_button, -- High Voltage! (Red Button)
		[438727] = CL.disease, -- Radiation Sickness (Disease)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterMessage("BigWigs_BossComm")

	-- General
	self:Log("SPELL_CAST_SUCCESS", "SummonBomb", 11518, 11521, 11523, 11524, 11526, 11527) -- Activate Bomb 01 -> 06 (03 is hidden)
	self:Log("SPELL_AURA_APPLIED", "HighVoltageApplied", 438735)
	self:Log("SPELL_AURA_REMOVED", "HighVoltageRemoved", 438735)
	-- STX-96/FR
	self:Log("SPELL_CAST_SUCCESS", "SprocketfirePunch", 438683)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SprocketfireApplied", 438710)
	self:Log("SPELL_CAST_START", "FurnaceSurge", 438713)
	-- STX-97/IC
	self:Log("SPELL_CAST_SUCCESS", "SupercooledSmash", 438719)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FreezingApplied", 438720)
	self:Log("SPELL_CAST_START", "CoolantDischarge", 438723)
	-- STX-98/PO
	self:Log("SPELL_CAST_SUCCESS", "HazardousHammer", 438726)
	self:Log("SPELL_AURA_APPLIED", "RadiationSicknessApplied", 438727)
	self:Log("SPELL_AURA_APPLIED_DOSE", "RadiationSicknessApplied", 438727)
	self:Log("SPELL_CAST_SUCCESS", "ToxicVentilation", 438732)
	self:Log("SPELL_INTERRUPT", "ToxicVentilationInterrupted", "*")
end

function mod:OnEngage()
	highVoltageList = {}
	highVoltageDebuffTime = {}
	castCollector = {}
	currentBossGUID = "none"
	for unit in self:IterateGroup() do
		local name = self:UnitName(unit)
		highVoltageList[#highVoltageList + 1] = name
	end

	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)

	self:OpenInfo(438735, CL.other:format("BigWigs", "|T237290:0:0:0:0:64:64:4:60:4:60|t".. L.red_button), 10)
	self:SimpleTimer(UpdateInfoBoxList, 0.1)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local prev = 0
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, _, castGUID, spellId)
		if spellId == 11523 and not castCollector[castGUID] then -- Activate Bomb 03
			castCollector[castGUID] = true
			self:Sync("b3")
		elseif spellId == 438572 and not castCollector[castGUID] then -- Vehicle Damaged
			castCollector[castGUID] = true
			self:Sync("stage")
		--elseif spellId == 438487 and not castCollector[castGUID] then -- Ride Vehicle XXX just for testing
		--	castCollector[castGUID] = true
		--	self:Sync("ride")
		end
	end
end

do
	local times = {
		["b3"] = 0,
		["stage"] = 0,
		--["ride"] = 0,
	}
	function mod:BigWigs_BossComm(_, msg)
		if times[msg] then
			local t = GetTime()
			if t-times[msg] > 5 then
				times[msg] = t
				if msg == "b3" then
					self:SummonBomb({["spellId"]=11523})
				elseif msg == "stage" then
					local stage = self:GetStage()+1
					self:SetStage(stage)
					self:Message("stages", "cyan", CL.stage:format(stage), false)
					self:StopBar(CL.bombs) -- Summon Bomb
					self:StopBar(438726) -- Hazardous Hammer
					self:StopBar(438732) -- Toxic Ventilation
					self:StopBar(438683) -- Sprocketfire Punch
					self:StopBar(438713) -- Furnace Surge
					self:StopBar(438719) -- Supercooled Smash
					self:StopBar(438723) -- Coolant Discharge
					self:StopBar(CL.next_ability)
				--elseif msg == "ride" then
				--	self:Message("stages", "cyan", self:SpellName(438487), false) -- Just for testing, probably useless
				end
			end
		end
	end
end

local function stageCheck(self, sourceGUID)
	local curStage = self:GetStage()
	local sourceMobId = self:MobId(sourceGUID)
	local nextStage
	if curStage ~= 2 and sourceMobId == 218970 then -- STX-97/IC = Stage 2
		nextStage = 2
	elseif curStage ~= 3 and sourceMobId == 218972 then -- STX-98/PO = Stage 3
		nextStage = 3
	elseif curStage ~= 4 and sourceMobId == 218974 then -- STX-99/XD = Stage 4
		nextStage = 4
	end
	if not nextStage then return end -- No stage change
	self:SetStage(nextStage)
	self:Message("stages", "cyan", CL.stage:format(nextStage), false)
	self:StopBar(CL.bombs) -- Summon Bomb
	self:StopBar(438726) -- Hazardous Hammer
	self:StopBar(438732) -- Toxic Ventilation
	self:StopBar(438683) -- Sprocketfire Punch
	self:StopBar(438713) -- Furnace Surge
	self:StopBar(438719) -- Supercooled Smash
	self:StopBar(438723) -- Coolant Discharge
	self:StopBar(CL.next_ability)
end

do
	local bombCount = {
		[11518] = 1,
		[11521] = 2,
		[11523] = 3,
		[11524] = 4,
		[11526] = 5,
		[11527] = 6,
	}
	function mod:SummonBomb(args)
		self:Message(437853, "cyan", CL.extra:format(CL.bombs, L.position:format(bombCount[args.spellId])))
		self:CDBar(437853, 11, CL.bombs)
		self:PlaySound(437853, "info")
	end
end

function mod:HighVoltageApplied(args)
	self:DeleteFromTable(highVoltageList, args.destName)
	highVoltageList[#highVoltageList + 1] = args.destName
	highVoltageDebuffTime[args.destName] = GetTime() + 30
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, L.red_button)
		self:TargetBar(args.spellId, 30, args.destName, L.red_button)
	end
end

function mod:HighVoltageRemoved(args)
	highVoltageDebuffTime[args.destName] = nil
	if self:Me(args.destGUID) then
		self:StopBar(L.red_button, args.destName)
		self:PersonalMessage(args.spellId, "over", L.red_button)
		self:PlaySound(args.spellId, "long")
	end
end

-- STX-96/FR
function mod:SprocketfirePunch(args)
	currentBossGUID = args.sourceGUID
	self:Message(args.spellId, "purple")
	if self:GetStage() < 4 then -- no timers in stage 4
		stageCheck(self, args.sourceGUID)
		self:CDBar(args.spellId, 8.2)
	end
	self:PlaySound(args.spellId, "alarm")
end

function mod:SprocketfireApplied(args)
	if args.amount >= 3 then
		if self:Me(args.destGUID) then
			self:StackMessage(args.spellId, "blue", args.destName, args.amount, 4)
		else
			local bossUnit = self:GetUnitIdByGUID(currentBossGUID) -- Source can vary or be nil here, so store it from other abilities
			local targetUnit = self:UnitTokenFromGUID(args.destGUID, true)
			if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
				self:StackMessage(args.spellId, "orange", args.destName, args.amount, 4)
			end
		end
	end
end

function mod:FurnaceSurge(args)
	self:Message(args.spellId, "yellow")
	if self:GetStage() < 4 then
		self:CDBar(args.spellId, 34)
	else
		self:CDBar("stages", 20, CL.next_ability, "INV_Misc_QuestionMark") -- Random which cast is next in stage 4
	end
	self:PlaySound(args.spellId, "alert")
end

-- STX-97/IC
function mod:SupercooledSmash(args)
	currentBossGUID = args.sourceGUID
	self:Message(args.spellId, "purple")
	if self:GetStage() < 4 then -- no timers in stage 4
		stageCheck(self, args.sourceGUID)
		self:CDBar(args.spellId, 6.5)
	end
	self:PlaySound(args.spellId, "alarm")
end

function mod:FreezingApplied(args)
	if args.amount >= 5 then
		if self:Me(args.destGUID) then
			self:StackMessage(args.spellId, "blue", args.destName, args.amount, 5)
		elseif self:Player(args.destFlags) then -- Players, not pets
			local bossUnit = self:GetUnitIdByGUID(currentBossGUID) -- Source can vary or be nil here, so store it from other abilities
			local targetUnit = self:UnitTokenFromGUID(args.destGUID, true)
			if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
				self:StackMessage(args.spellId, "orange", args.destName, args.amount, 5)
			end
		end
	end
end

function mod:CoolantDischarge(args)
	self:Message(args.spellId, "yellow")
	if self:GetStage() < 4 then
		self:CDBar(args.spellId, 24)
	else
		self:CDBar("stages", 20, CL.next_ability, "INV_Misc_QuestionMark") -- Random which cast is next in stage 4
	end
	self:PlaySound(args.spellId, "alert")
end

-- STX-98/PO
function mod:HazardousHammer(args)
	currentBossGUID = args.sourceGUID
	self:Message(args.spellId, "purple")
	if self:GetStage() < 4 then -- no timers in stage 4
		stageCheck(self, args.sourceGUID)
		self:CDBar(args.spellId, 6)
	end
	self:PlaySound(args.spellId, "alarm")
end

function mod:RadiationSicknessApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 3, CL.disease)
	elseif args.amount then
		local bossUnit = self:GetUnitIdByGUID(currentBossGUID) -- Source can vary or be nil here, so store it from other abilities
		local targetUnit = self:UnitTokenFromGUID(args.destGUID, true)
		if bossUnit and targetUnit and self:Tanking(bossUnit, targetUnit) then
			self:StackMessage(args.spellId, "orange", args.destName, args.amount, 3, CL.disease)
		end
	end
end

function mod:ToxicVentilation(args)
	self:Message(args.spellId, "yellow")
	if self:GetStage() < 4 then
		self:CDBar(args.spellId, 21)
	else
		self:CDBar("stages", 20, CL.next_ability, "INV_Misc_QuestionMark") -- Random which cast is next in stage 4
	end
	self:PlaySound(args.spellId, "alert")
end

function mod:ToxicVentilationInterrupted(args)
	if args.extraSpellName == self:SpellName(438732) then
		self:Message(438732, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)), 438732, true) -- Disable emphasize
	end
end

function UpdateInfoBoxList()
	if not mod:IsEngaged() then return end
	mod:SimpleTimer(UpdateInfoBoxList, 0.1)

	local t = GetTime()
	local line = 1
	for i = 1, 10 do
		local player = highVoltageList[i]
		if player then
			local remaining = (highVoltageDebuffTime[player] or 0) - t
			mod:SetInfo(438735, line, mod:ColorName(player))
			if remaining > 0 then
				mod:SetInfo(438735, line + 1, CL.seconds:format(remaining))
				mod:SetInfoBar(438735, line, remaining / 30)
			else
				if mod:UnitIsDeadOrGhost(player) then
					mod:SetInfo(438735, line + 1, CL.dead, 1, 0.2, 0.2)
				else
					mod:SetInfo(438735, line + 1, CL.ready, 0.13, 1, 0.13)
				end
				mod:SetInfoBar(438735, line, 0)
			end
		else
			mod:SetInfo(438735, line, "")
			mod:SetInfo(438735, line + 1, "")
			mod:SetInfoBar(438735, line, 0)
		end
		line = line + 2
	end
end
