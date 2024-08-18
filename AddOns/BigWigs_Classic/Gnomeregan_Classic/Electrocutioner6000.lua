--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Electrocutioner 6000 Discovery", 90)
if not mod then return end
mod:RegisterEnableMob(220072) -- Electrocutioner 6000
mod:SetEncounterID(2927)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local knockbackCount = 1
local staticArcList = {}
local staticArcDebuffTime = {}
local magneticPulsePlayer = nil
local UpdateInfoBoxList

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Electrocutioner 6000"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{433359, "SAY", "ME_ONLY_EMPHASIZE"}, -- Magnetic Pulse
		{433398, "COUNTDOWN"}, -- Discombobulation Protocol
		{433251, "CASTBAR", "SAY", "SAY_COUNTDOWN", "ICON", "ME_ONLY_EMPHASIZE", "INFOBOX"}, -- Static Arc
	},nil,{
		[433398] = CL.knockback, -- Discombobulation Protocol (Knockback)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "MagneticPulseApplied", 433359)
	self:Log("SPELL_AURA_REMOVED", "MagneticPulseRemoved", 433359)
	self:Log("SPELL_CAST_SUCCESS", "DiscombobulationProtocol", 433398)
	self:Log("SPELL_CAST_START", "StaticArcStart", 433251)
	self:Log("SPELL_CAST_SUCCESS", "StaticArc", 433251)
	self:Log("SPELL_AURA_APPLIED", "StaticArcApplied", 433251)
	self:Log("SPELL_AURA_REMOVED", "StaticArcRemoved", 433251)
end

function mod:OnEngage()
	knockbackCount = 1
	staticArcList = {}
	staticArcDebuffTime = {}
	magneticPulsePlayer = nil
	for unit in self:IterateGroup() do
		local name = self:UnitName(unit)
		staticArcList[#staticArcList + 1] = name
	end

	self:CDBar(433251, 6.2) -- Static Arc
	self:Bar(433398, 30.5, CL.count:format(CL.knockback, knockbackCount)) -- Discombobulation Protocol

	self:OpenInfo(433251, CL.other:format("BigWigs", "|T237587:0:0:0:0:64:64:4:60:4:60|t".. self:SpellName(433251)), 10)
	self:SimpleTimer(UpdateInfoBoxList, 0.1)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:MagneticPulseApplied(args)
	magneticPulsePlayer = args.destName
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:TargetBar(args.spellId, 12, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, nil, nil, "Magnetic Pulse")
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:MagneticPulseRemoved(args)
	if magneticPulsePlayer == args.destName then
		magneticPulsePlayer = nil
	end
	self:StopBar(args.spellName, args.destName)
end

function mod:DiscombobulationProtocol(args)
	self:Message(args.spellId, "orange", CL.count:format(CL.knockback, knockbackCount))
	knockbackCount = knockbackCount + 1
	self:Bar(args.spellId, 30.7, CL.count:format(CL.knockback, knockbackCount))
	self:PlaySound(args.spellId, "info")
end

do
	local function printTarget(self, name, guid, elapsed)
		self:PrimaryIcon(433251, name)
		self:TargetMessage(433251, "red", name)
		if self:Me(guid) then
			self:Say(433251, nil, nil, "Static Arc")
			self:SayCountdown(433251, 3.5-elapsed, nil, 2)
			self:PlaySound(433251, "warning", nil, name)
		end
	end

	function mod:StaticArcStart(args)
		self:GetUnitTarget(printTarget, 0.5, args.sourceGUID) -- Can take a while to swap target
		self:CastBar(args.spellId, 3.5)
		self:CDBar(args.spellId, 14.5)
	end
end

function mod:StaticArc(args)
	self:PrimaryIcon(args.spellId)
end

function mod:StaticArcApplied(args)
	self:DeleteFromTable(staticArcList, args.destName)
	staticArcList[#staticArcList + 1] = args.destName
	staticArcDebuffTime[args.destName] = GetTime() + 20
end

function mod:StaticArcRemoved(args)
	staticArcDebuffTime[args.destName] = nil
end

function UpdateInfoBoxList()
	if not mod:IsEngaged() then return end
	mod:SimpleTimer(UpdateInfoBoxList, 0.1)

	local t = GetTime()
	local line = 1
	for i = 1, 10 do
		local player = staticArcList[i]
		if player then
			local remaining = (staticArcDebuffTime[player] or 0) - t
			mod:SetInfo(433251, line, mod:ColorName(player))
			if remaining > 0 then
				mod:SetInfo(433251, line + 1, CL.seconds:format(remaining))
				mod:SetInfoBar(433251, line, remaining / 20)
			else
				if mod:UnitIsDeadOrGhost(player) then
					mod:SetInfo(433251, line + 1, CL.dead, 1, 0.2, 0.2)
				else
					if player == magneticPulsePlayer then
						mod:SetInfo(433251, line + 1, "|T135768:0:0:0:0:64:64:4:60:4:60|t")
					else
						mod:SetInfo(433251, line + 1, CL.ready, 0.13, 1, 0.13)
					end
				end
				mod:SetInfoBar(433251, line, 0)
			end
		else
			mod:SetInfo(433251, line, "")
			mod:SetInfo(433251, line + 1, "")
			mod:SetInfoBar(433251, line, 0)
		end
		line = line + 2
	end
end
