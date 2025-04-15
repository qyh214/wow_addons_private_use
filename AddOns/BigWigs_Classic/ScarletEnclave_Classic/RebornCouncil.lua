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
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		1231010, -- Tortuous Rebuke
		1231095, -- Peeled Secrets
		"stages",
		{"health", "INFOBOX"},
		"berserk",
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "TortuousRebukeApplied", 1231010)
	self:Log("SPELL_CAST_START", "PeeledSecrets", 1231095)
	self:Log("SPELL_INTERRUPT", "PeeledSecretsInterrupted", "*")
	self:Death("Deaths", 240795, 240809, 240810)
end

function mod:OnEngage()
	killedBosses = {}

	self:OpenInfo("health", CL.other:format("BigWigs", CL.health))
	for npcId, line in next, bossList do
		self:SetInfo("health", line, L[npcId])
		self:SetInfoBar("health", line, 1)
		self:SetInfo("health", line + 1, "100%")
	end
	self:SimpleTimer(UpdateInfoBoxList, 1)

	self:Berserk(330)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:TortuousRebukeApplied(args)
	if self:Me(args.destGUID) then
		self:Message(1231010, "blue", args.spellName.. " on YOU - Try avoid casting!")
		self:PlaySound(1231010, "warning", nil, args.destName)
	end
end

do
	local inRange = false
	function mod:PeeledSecrets(args)
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if not unit or self:UnitWithinRange(unit, 10) or args.sourceGUID == self:UnitGUID("target") then
			inRange = true
			self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
			self:PlaySound(args.spellId, "info")
		else
			inRange = false
		end
	end

	function mod:PeeledSecretsInterrupted(args)
		if inRange and args.extraSpellName == self:SpellName(1231095) then
			self:Message(1231095, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
		end
	end
end

do
	local unitTracker = {}
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
			mod:SetInfoBar("health", line, currentHealthPercent/100)
			mod:SetInfo("health", line + 1, ("%d%%"):format(currentHealthPercent))
		end
	end
end
