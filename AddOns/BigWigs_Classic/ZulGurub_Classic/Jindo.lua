--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Jin'do the Hexxer", 309)
if not mod then return end
mod:RegisterEnableMob(11380)
mod:SetEncounterID(792)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Jin'do the Hexxer"
end

--------------------------------------------------------------------------------
-- Initialization
--

local brainWashTotemMarker = mod:AddMarkerOption(true, "npc", 8, 24262, 8) -- Summon Brain Wash Totem
local powerfulHealingWardMarker = mod:AddMarkerOption(true, "npc", 7, 24309, 7) -- Powerful Healing Ward
function mod:GetOptions()
	return {
		{24306, "ME_ONLY"}, -- Delusions of Jin'do
		17172, -- Hex
		{24262, "EMPHASIZE"}, -- Summon Brain Wash Totem
		brainWashTotemMarker,
		24309, -- Powerful Healing Ward
		powerfulHealingWardMarker,
		24466, -- Banish
	},nil,{
		[24262] = CL.totem, -- Summon Brain Wash Totem (Totem)
		[24466] = CL.teleport, -- Banish (Teleport)
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "DelusionsOfJindo", 24306)
	self:Log("SPELL_AURA_APPLIED", "Hex", 17172)
	self:Log("SPELL_SUMMON", "SummonBrainWashTotem", 24262)
	self:Log("SPELL_SUMMON", "PowerfulHealingWard", 24309)
	self:Log("SPELL_CAST_SUCCESS", "Banish", 24466)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:DelusionsOfJindo(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	self:PlaySound(args.spellId, "alarm", nil, args.destName)
end

function mod:Hex(args)
	self:TargetMessage(args.spellId, "purple", args.destName)
	self:PlaySound(args.spellId, "alert", nil, args.destName)
end

do
	local totemGUID = nil

	function mod:SummonBrainWashTotem(args)
		self:Message(args.spellId, "red", CL.totem)
		self:PlaySound(args.spellId, "warning")
		-- register events to auto-mark totem
		if self:GetOption(brainWashTotemMarker) then
			totemGUID = args.destGUID
			self:RegisterTargetEvents("MarkBrainWashTotem")
		end
	end

	function mod:MarkBrainWashTotem(_, unit, guid)
		if totemGUID == guid then
			totemGUID = nil
			self:CustomIcon(brainWashTotemMarker, unit, 8)
			self:UnregisterTargetEvents()
		end
	end
end

do
	local totemGUID = nil

	function mod:PowerfulHealingWard(args)
		self:Message(args.spellId, "orange")
		self:PlaySound(args.spellId, "info")
		-- register events to auto-mark totem
		if self:GetOption(powerfulHealingWardMarker) then
			totemGUID = args.destGUID
			self:RegisterTargetEvents("MarkPowerfulHealingWard")
		end
	end

	function mod:MarkPowerfulHealingWard(_, unit, guid)
		if totemGUID == guid then
			totemGUID = nil
			self:CustomIcon(powerfulHealingWardMarker, unit, 7)
			self:UnregisterTargetEvents()
		end
	end
end

function mod:Banish(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.teleport)
	self:PlaySound(args.spellId, "long", nil, args.destName)
end
