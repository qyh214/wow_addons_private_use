--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Flamegor", 469, 1534)
if not mod then return end
mod:RegisterEnableMob(11981)
mod:SetEncounterID(615)
if mod:GetSeason() == 2 then
	mod:SetRespawnTime(30)
end

--------------------------------------------------------------------------------
-- Locals
--

local killedBosses = {}
local UpdateInfoBoxList
local bossList = {
	[11981] = 1, -- Flamegor
	[14601] = 3, -- Ebonroc
}

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		23339, -- Wing Buffet
		22539, -- Shadow Flame
		23342, -- Enrage / Frenzy (different name on classic era)
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			23339, -- Wing Buffet
			22539, -- Shadow Flame
			23342, -- Enrage / Frenzy (different name on classic era)
			368521, -- Brand of Flame
			{467764, "CASTBAR", "CASTBAR_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Go!
			{467732, "CASTBAR", "CASTBAR_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Stop!
			{"health", "INFOBOX"},
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "WingBuffet", 23339)
	self:Log("SPELL_CAST_START", "ShadowFlame", 22539)
	self:Log("SPELL_AURA_APPLIED", "EnrageFrenzy", 23342)
	self:Log("SPELL_DISPEL", "EnrageFrenzyDispelled", "*")
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_START", "WingBuffet", 369080)
		self:Log("SPELL_CAST_START", "ShadowFlameSoD", 368942)
		self:Log("SPELL_AURA_APPLIED_DOSE", "BrandOfFlameApplied", 368521)
		self:Log("SPELL_AURA_APPLIED", "GoOrStopApplied", 467764, 467732) -- Go, Stop
		self:Log("SPELL_AURA_REMOVED", "GoOrStopRemoved", 467764, 467732)
		self:Log("SPELL_CAST_SUCCESS", "GoSuccess", 467764)
		self:Log("SPELL_CAST_SUCCESS", "StopSuccess", 467732)
		self:Death("Deaths", 11981, 14601) -- Flamegor, Ebonroc
	end
end

function mod:OnEngage()
	if self:GetPlayerAura(467047) then -- Black Essence
		self:CDBar(467732, 20) -- Stop
	end
	if self:GetSeason() == 2 then
		self:CDBar(23339, 66) -- Wing Buffet
		self:OpenInfo("health", CL.other:format("BigWigs", CL.health))
		for npcId, line in next, bossList do
			self:SetInfo("health", line, self:BossName(npcId == 11981 and 1534 or 1533)) -- Flamegor, Ebonroc
			self:SetInfoBar("health", line, 1)
			self:SetInfo("health", line + 1, "100%")
		end
		self:SimpleTimer(UpdateInfoBoxList, 1)
	else
		self:CDBar(23339, 29) -- Wing Buffet
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:WingBuffet(args)
	if self:MobId(args.sourceGUID) == 11981 then
		self:Message(23339, "yellow")
		self:CDBar(23339, self:GetSeason() == 2 and 25 or 32)
		self:PlaySound(23339, "info")
	end
end

function mod:ShadowFlame(args)
	if self:MobId(args.sourceGUID) == 11981 then
		self:Message(args.spellId, "red")
		self:PlaySound(args.spellId, "long")
	end
end

function mod:ShadowFlameSoD(args)
	if self:MobId(args.sourceGUID) == 11981 then
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if not unit or self:UnitWithinRange(unit, 35) or args.sourceGUID == self:UnitGUID("target") then
			self:Message(22539, "red")
			self:PlaySound(22539, "long")
		end
	end
end

function mod:EnrageFrenzy(args)
	self:Message(args.spellId, "orange", CL.buff_boss:format(args.spellName))
	self:TargetBar(args.spellId, 10, args.destName)
	self:PlaySound(args.spellId, "alarm")
end

function mod:EnrageFrenzyDispelled(args)
	if args.extraSpellName == self:SpellName(23342) then
		self:StopBar(args.extraSpellName, args.destName)
		self:Message(23342, "green", CL.removed_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:BrandOfFlameApplied(args)
	if self:Me(args.destGUID) then
		self:StackMessage(args.spellId, "blue", args.destName, args.amount, 3)
		if args.amount >= 3 then
			self:PlaySound(args.spellId, "alert", nil, args.destName)
		end
	end
end

function mod:GoOrStopApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
		self:CastBar(args.spellId, 5)
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:GoOrStopRemoved(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "removed")
	end
end

function mod:GoSuccess(args)
	self:StopBar(args.spellName) -- Go!
	self:CDBar(467732, 40) -- Stop!
end

function mod:StopSuccess(args)
	self:StopBar(args.spellName) -- Stop!
	self:CDBar(467764, 20) -- Go!
end

do
	local unitTracker = {}
	function mod:Deaths(args)
		unitTracker[args.mobId] = nil
		killedBosses[args.mobId] = true

		local line = bossList[args.mobId]
		self:SetInfoBar("health", line, 0)
		self:SetInfo("health", line + 1, CL.dead)
	end

	function UpdateInfoBoxList()
		if not mod:IsEngaged() then return end
		mod:SimpleTimer(UpdateInfoBoxList, 0.5)

		-- Flamegor
		if not killedBosses[11981] and (not unitTracker[11981] or mod:MobId(mod:UnitGUID(unitTracker[11981])) ~= 11981) then
			unitTracker[11981] = mod:GetUnitIdByGUID(11981)
		end
		-- Ebonroc
		if not killedBosses[14601] and (not unitTracker[14601] or mod:MobId(mod:UnitGUID(unitTracker[14601])) ~= 14601) then
			unitTracker[14601] = mod:GetUnitIdByGUID(14601)
		end

		for npcId, unitToken in next, unitTracker do
			local line = bossList[npcId]
			local currentHealthPercent = math.floor(mod:GetHealth(unitToken))
			mod:SetInfoBar("health", line, currentHealthPercent/100)
			mod:SetInfo("health", line + 1, ("%d%%"):format(currentHealthPercent))
		end
	end
end
