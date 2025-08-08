--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Reborn Council", 2856)
if not mod then return end
mod:RegisterEnableMob(240795, 240809, 240810) -- Herod, Vishas, Doan
mod:SetEncounterID(3188)
mod:SetRespawnTime(12)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local wwThrottle = false
local peeledSecretsCount = 1
local killedBosses = {}
local UpdateInfoBoxList
local bossList = {
	[240795] = 1, -- Herod
	[240809] = 3, -- Vishas
	[240810] = 5, -- Doan
}

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Reborn Council"
	L[240795] = "Herod"
	L[240809] = "Vishas"
	L[240810] = "Doan"

	L.custom_select_interrupt_counter = "Interrupt Counter"
	L.custom_select_interrupt_counter_desc = "Choose when the interrupt counter should reset back to 1."
	L.custom_select_interrupt_counter_icon = "ability_kick"
	L.custom_select_interrupt_counter_value1 = "Count to 2. 1,2,1,2, etc."
	L.custom_select_interrupt_counter_value2 = "Count to 3. 1,2,3,1,2,3, etc."
	L.custom_select_interrupt_counter_value3 = "Count to 4. 1,2,3,4,1,2,3,4, etc."
	L.custom_select_interrupt_counter_value4 = "Count to 5. 1,2,3,4,5,1,2,3,4,5, etc."
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{1231095, "NAMEPLATE"}, -- Peeled Secrets
		"custom_select_interrupt_counter",
		1231282, -- Molten Basin
		{1231264, "CASTBAR"}, -- Blades of Light
		{1231383, "CASTBAR"}, -- Divine Avatar
		"stages",
		{"health", "INFOBOX"},
		"berserk",
	},nil,{
		[1231264] = mod:SpellName(1680), -- Blades of Light (Whirlwind)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
	self:SetSpellRename(1231264, mod:SpellName(1680)) -- Blades of Light (Whirlwind)
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "UpdateMarks", 1231227, 1231200, 1236220) -- Reborn Inspiration, Fireball, Slow
	self:Log("SPELL_CAST_START", "MoltenBasin", 1231282)
	self:Log("SPELL_CAST_START", "BladesOfLight", 1231264)
	self:Log("SPELL_AURA_REMOVED", "BladesOfLightRemoved", 1231264)
	self:Log("SPELL_CAST_SUCCESS", "BladesOfLightSuccess", 1231264)
	self:Log("SPELL_CAST_START", "PeeledSecrets", 1231095)
	self:Log("SPELL_CAST_SUCCESS", "PeeledSecretsSuccess", 1231095)
	self:Log("SPELL_INTERRUPT", "PeeledSecretsInterrupted", "*")
	self:Log("SPELL_CAST_START", "DivineAvatar", 1231383)
	self:Log("SPELL_CAST_SUCCESS", "DivineAvatarSuccess", 1231383)
	self:Death("Deaths", 240795, 240809, 240810)
end

do
	local function UpdateNameplate()
		UpdateInfoBoxList() -- Just re-using this function as we want both UpdateNameplate and UpdateInfoBoxList on a 1sec delay from engage

		local unit = mod:GetUnitIdByGUID(240809)
		if unit then
			local guid = mod:UnitGUID(unit)
			if guid then
				mod:Nameplate(1231095, 20, guid, (">%d<"):format(peeledSecretsCount))
				mod:SetSpellRename(1231095, CL.count:format(mod:SpellName(1231095), peeledSecretsCount))
			end
		end
	end

	function mod:OnEngage()
		wwThrottle = false
		peeledSecretsCount = 1
		killedBosses = {}

		self:OpenInfo("health", CL.other:format("BigWigs", CL.health))
		for npcId, line in next, bossList do
			self:SetInfo("health", line, L[npcId])
			self:SetInfoBar("health", line, 1)
			self:SetInfo("health", line + 1, "100%")
		end
		self:ScheduleTimer(UpdateNameplate, 3)

		self:CDBar(1231264, 26, self:SpellName(1680)) -- Blades of Light (Whirlwind)
		self:Berserk(600)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UpdateMarks(args)
	self:RemoveLog("SPELL_CAST_SUCCESS", args.spellId)

	local icon = self:GetIconTexture(self:GetIcon(args.sourceRaidFlags))
	if icon then
		local npcId = self:MobId(args.sourceGUID)
		local line = bossList[npcId]
		self:SetInfo("health", line, icon.. L[npcId]) -- Add raid icons to the boss names
	end
end

function mod:MoltenBasin(args)
	self:Message(args.spellId, "cyan", CL.incoming:format(args.spellName))
	self:Bar(args.spellId, 38)
	self:PlaySound(args.spellId, "long")
end

function mod:BladesOfLight(args)
	self:StopBar(mod:SpellName(1680))
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 10) then
		self:Message(args.spellId, "yellow", self:SpellName(1680))
		self:PlaySound(args.spellId, "warning")
	end
end

do
	local prev = 0
	function mod:BladesOfLightSuccess(args)
		wwThrottle = false
		prev = args.time
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if unit and self:UnitWithinRange(unit, 10) then
			self:CastBar(args.spellId, 6, self:SpellName(1680))
		end
	end

	function mod:BladesOfLightRemoved(args)
		self:StopCastBar(mod:SpellName(1680))
		local duration = 26-(args.time-prev) -- Takes around 26s to go from 0% to 100% power, then cast at random
		self:CDBar(args.spellId, duration > 0 and duration or 18.5, self:SpellName(1680)) -- Fallback for safety (26-7.5) (1.5s cast + 6s channel = 7.5)
	end
end

do
	local inRange = false
	function mod:PeeledSecrets(args)
		local icon = self:GetIconTexture(self:GetIcon(args.sourceRaidFlags))
		if icon then
			self:SetInfo("health", 3, icon.. L[240809]) -- Add raid icons to the boss names
		end

		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if not unit or self:UnitWithinRange(unit, 10) or args.sourceGUID == self:UnitGUID("target") then
			inRange = true
			self:Message(args.spellId, "orange", CL.count:format(args.spellName, peeledSecretsCount))
			self:PlaySound(args.spellId, "info")
		else
			inRange = false
		end
	end

	function mod:PeeledSecretsSuccess(args)
		peeledSecretsCount = peeledSecretsCount + 1
		local option = self:GetOption("custom_select_interrupt_counter") + 2
		if peeledSecretsCount == option then peeledSecretsCount = 1 end
		self:Nameplate(args.spellId, 20, args.sourceGUID, (">%d<"):format(peeledSecretsCount))
		self:SetSpellRename(args.spellId, CL.count:format(args.spellName, peeledSecretsCount))
	end

	function mod:PeeledSecretsInterrupted(args)
		if args.extraSpellName == self:SpellName(1231095) then
			if inRange then
				self:Message(1231095, "green", CL.interrupted_by:format(CL.count:format(args.extraSpellName, peeledSecretsCount), self:ColorName(args.sourceName)))
			end
			peeledSecretsCount = peeledSecretsCount + 1
			local option = self:GetOption("custom_select_interrupt_counter") + 2
			if peeledSecretsCount == option then peeledSecretsCount = 1 end
			self:Nameplate(1231095, 20, args.destGUID, (">%d<"):format(peeledSecretsCount))
			self:SetSpellRename(1231095, CL.count:format(args.extraSpellName, peeledSecretsCount))
		end
	end
end

function mod:DivineAvatar(args)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if unit and self:UnitWithinRange(unit, 10) then
		self:Message(args.spellId, "red")
		if self:Tanking(unit) then
			self:PlaySound(args.spellId, "alarm")
		end
	end
end

function mod:DivineAvatarSuccess(args)
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if unit and self:Tanking(unit) then
		self:CastBar(args.spellId, 15)
	end
end

do
	local unitTracker = {}
	local currentHealth = {}
	function mod:Deaths(args)
		unitTracker[args.mobId] = nil
		killedBosses[args.mobId] = true
		local count = #killedBosses + 1
		killedBosses[count] = true

		local line = bossList[args.mobId]
		self:SetInfoBar("health", line, 0)
		self:SetInfo("health", line + 1, CL.dead)

		if count < 3 then
			self:Message("stages", "cyan", CL.mob_killed:format(args.destName, count, 3), false)
			if args.mobId == 240810 then -- Doan
				self:StopBar(1231282) -- Molten Basin, this becomes permanent after death
			end
		else
			unitTracker, currentHealth = {}, {}
		end
	end

	function UpdateInfoBoxList()
		if not mod:IsEngaged() then return end
		mod:SimpleTimer(UpdateInfoBoxList, 0.5)

		for npcId in next, bossList do
			if not killedBosses[npcId] and (not unitTracker[npcId] or mod:MobId(mod:UnitGUID(unitTracker[npcId])) ~= npcId) then
				unitTracker[npcId] = mod:GetUnitIdByGUID(npcId)
			end
		end

		for npcId, unitToken in next, unitTracker do
			local line = bossList[npcId]
			local currentHealthPercent = math.floor(mod:GetHealth(unitToken))
			if currentHealthPercent ~= currentHealth[npcId] then
				currentHealth[npcId] = currentHealthPercent
				mod:SetInfoBar("health", line, currentHealthPercent/100)
				mod:SetInfo("health", line + 1, ("%d%%"):format(currentHealthPercent))
			end

			-- Sticking the rage check into the health check
			if npcId == 240795 and not wwThrottle then
				local power = UnitPower(unitToken) / UnitPowerMax(unitToken) * 100
				if power >= 80 then
					wwThrottle = true
					mod:CDBar(1231264, {6, 26}, mod:SpellName(1680)) -- Blades of Light (Whirlwind)
				end
			end
		end
	end
end
