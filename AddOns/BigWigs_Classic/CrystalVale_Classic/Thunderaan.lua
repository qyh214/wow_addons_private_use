--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Thunderaan Season of Discovery", 2804)
if not mod then return end
mod:RegisterEnableMob(231494)
mod:SetEncounterID(3079)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Prince Thunderaan"
	L.mender = "Storm Mender" -- NPC 231858
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{465700, "CASTBAR", "SAY", "ICON", "ME_ONLY_EMPHASIZE"}, -- Chain Lightning
		466211, -- Tendrils of Air
		466774, -- Cyclonic Winds
		470866, -- Lightning Cloud
		11642, -- Heal
	},{
		[465700] = L.bossName,
		[11642] = L.mender,
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "ChainLightningStart", 465700)
	self:Log("SPELL_CAST_SUCCESS", "ChainLightning", 465700)
	self:Log("SPELL_AURA_APPLIED", "TendrilsOfAirApplied", 466211)
	self:Log("SPELL_AURA_APPLIED_DOSE", "TendrilsOfAirAppliedDose", 466211)
	self:Log("SPELL_CAST_SUCCESS", "CyclonicWinds", 466774)
	self:Log("SPELL_AURA_APPLIED", "LightningCloudDamage", 470866)
	self:Log("SPELL_PERIODIC_DAMAGE", "LightningCloudDamage", 470866)
	self:Log("SPELL_PERIODIC_MISSED", "LightningCloudDamage", 470866)

	self:Log("SPELL_CAST_START", "Heal", 11642)
	self:Log("SPELL_INTERRUPT", "HealInterrupted", "*")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function printTarget(self, name, guid)
		self:PrimaryIcon(465700, name)
		self:TargetMessage(465700, "red", name)
		if self:Me(guid) then
			self:Say(465700, nil, nil, "Chain Lightning")
			self:PlaySound(465700, "warning", nil, name)
		end
	end

	function mod:ChainLightningStart(args)
		local sourceGUID = args.sourceGUID -- Store the GUID as the values on the args table may have changed after the delay
		self:SimpleTimer(function() self:GetUnitTarget(printTarget, 0.2, sourceGUID) end, 1.7) -- He doesn't pick a target until about 1.3s left on the cast
		self:Message(args.spellId, "red")
		self:CastBar(args.spellId, 3)
	end
end

function mod:ChainLightning(args)
	self:PrimaryIcon(args.spellId)
end

function mod:TendrilsOfAirApplied(args)
	self:TargetMessage(args.spellId, "purple", args.destName)
	self:PlaySound(args.spellId, "alarm", nil, args.destName)
end

function mod:TendrilsOfAirAppliedDose(args)
	self:StackMessage(args.spellId, "purple", args.destName, args.amount, args.amount)
	self:PlaySound(args.spellId, "alarm", nil, args.destName)
end

function mod:CyclonicWinds(args)
	self:Message(args.spellId, "yellow", CL.on_group:format(args.spellName))
	self:PlaySound(args.spellId, "info")
end

do
	local prev = 0
	function mod:LightningCloudDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

function mod:Heal(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	if self:Interrupter() then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:HealInterrupted(args)
	if args.extraSpellName == self:SpellName(11642) then
		self:Message(11642, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end
