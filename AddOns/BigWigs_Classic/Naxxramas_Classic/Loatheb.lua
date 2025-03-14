--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Loatheb", 533, 1606)
if not mod then return end
mod:RegisterEnableMob(16011)
mod:SetEncounterID(1115)

--------------------------------------------------------------------------------
-- Locals
--

local sporeCount = 1
local doomCount = 1
local healerList = {}
local healerDebuffTime = {}
local numInfoLines = 10
local UpdateHealerList

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L["29234_icon"] = "Spell_nature_wispsplodegreen"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{29865, "OFF"}, -- Poison Aura
		29204, -- Inevitable Doom
		30281, -- Remove Curse
		29234, -- Summon Spore
		{29184, "INFOBOX", "ME_ONLY_EMPHASIZE"}, -- Corrupted Mind
		29232, -- Fungal Bloom
	}
end

if mod:GetSeason() == 2 then
	function mod:GetOptions()
		return {
			{29865, "OFF"}, -- Poison Aura
			29204, -- Inevitable Doom
			30281, -- Remove Curse
			29234, -- Summon Spore
			1225419, -- Necrotic Aura
			29232, -- Fungal Bloom
		}
	end
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "PoisonAura", 29865)
	self:Log("SPELL_CAST_SUCCESS", "InevitableDoom", 29204)
	self:Log("SPELL_CAST_SUCCESS", "RemoveCurse", 30281)
	self:Log("SPELL_CAST_SUCCESS", "SummonSpore", 29234)
	self:Log("SPELL_AURA_APPLIED", "FungalBloomApplied", 29232)
	if self:GetSeason() == 2 then
		self:Log("SPELL_CAST_SUCCESS", "NecroticAura", 1225419)
		self:Log("SPELL_AURA_APPLIED", "NecroticAuraApplied", 1225419)
		self:Log("SPELL_AURA_REMOVED", "NecroticAuraRemoved", 1225419)
	else
		self:Log("SPELL_AURA_APPLIED", "CorruptedMindApplied", 29184, 29195, 29197, 29199) -- Priest, Druid, Paladin, Shaman
		self:Log("SPELL_AURA_REMOVED", "CorruptedMindRemoved", 29184, 29195, 29197, 29199)
		self:Log("SPELL_AURA_APPLIED", "InitialCorruptedMindApplied", 29185, 29194, 29196, 29198) -- Priest, Druid, Paladin, Shaman
		self:Log("SPELL_AURA_REMOVED", "InitialCorruptedMindRemoved", 29185, 29194, 29196, 29198)
	end
end

function mod:OnEngage()
	sporeCount = 1
	doomCount = 1
	healerList = {}
	healerDebuffTime = {}
	numInfoLines = 10

	self:CDBar(30281, 3.1) -- Remove Curse
	self:CDBar(29865, 6.2) -- Poison Aura
	self:Bar(29234, 11.2, CL.count:format(self:SpellName(29234), sporeCount), L["29234_icon"]) -- Summon Spore
	self:Bar(29204, 120, CL.count:format(self:SpellName(29204), doomCount)) -- Inevitable Doom

	-- Corrupted Mind
	if self:GetSeason() == 2 then
		self:Bar(1225419, 11.4) -- Necrotic Aura
	else
		self:OpenInfo(29184, "|T136122:0:0:0:0:64:64:4:60:4:60|t".. self:SpellName(29184), numInfoLines) -- Corrupted Mind
		self:SimpleTimer(UpdateHealerList, 0.1)
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:NecroticAura(args)
	self:Bar(args.spellId, 21)
end

function mod:NecroticAuraApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
	end
end

function mod:NecroticAuraRemoved(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "removed")
		self:PlaySound(args.spellId, "long")
	end
end

function mod:PoisonAura(args)
	self:Message(args.spellId, "yellow")
	self:Bar(args.spellId, 14.5)
end

do
	local timers = {120, 29.1, 32.4, 29.1, 32.4, 29.1, 32.4, 9.7, 19.4, 11.3, 21, 11.3}
	function mod:InevitableDoom(args)
		self:Message(args.spellId, "red", CL.count:format(args.spellName, doomCount))
		doomCount = doomCount + 1
		self:Bar(args.spellId, timers[doomCount], CL.count:format(args.spellName, doomCount))
		self:PlaySound(args.spellId, "warning")
	end
end

function mod:RemoveCurse(args)
	self:Message(args.spellId, "orange")
	self:Bar(args.spellId, 30.5)
	self:PlaySound(args.spellId, "alert")
end

function mod:SummonSpore(args)
	self:Message(args.spellId, "red", CL.count:format(args.spellName, sporeCount), L["29234_icon"])
	sporeCount = sporeCount + 1
	self:Bar(args.spellId, 12.5, CL.count:format(args.spellName, sporeCount), L["29234_icon"])
	self:PlaySound(args.spellId, "info")
end

function mod:CorruptedMindApplied(args)
	if self:Me(args.destGUID) then
		self:TargetBar(29184, 60, args.destName)
		self:PersonalMessage(29184)
	end
	self:DeleteFromTable(healerList, args.destName)
	healerList[#healerList + 1] = args.destName
	healerDebuffTime[args.destName] = GetTime() + 60
end

function mod:CorruptedMindRemoved(args)
	healerDebuffTime[args.destName] = nil
	if self:Me(args.destGUID) then
		self:StopBar(args.spellName, args.destName)
		self:PersonalMessage(29184, "removed")
		self:PlaySound(29184, "long")
	end
end

function mod:InitialCorruptedMindApplied(args)
	self:DeleteFromTable(healerList, args.destName)
	healerList[#healerList + 1] = args.destName
	if #healerList > 10 and numInfoLines ~= 20 then
		numInfoLines = 20
		self:OpenInfo(29184, CL.other:format("BigWigs", "|T136122:0:0:0:0:64:64:4:60:4:60|t".. self:SpellName(29184)), numInfoLines)
	end
end

function mod:InitialCorruptedMindRemoved(args) -- The player died
	self:DeleteFromTable(healerList, args.destName)
end

function mod:FungalBloomApplied(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId)
	end
end

function UpdateHealerList()
	if not mod:IsEngaged() then return end
	mod:SimpleTimer(UpdateHealerList, 0.1)

	-- Healer rotation lite
	local t = GetTime()
	local line = 1
	for i = 1, numInfoLines do
		local player = healerList[i]
		if player then
			local remaining = (healerDebuffTime[player] or 0) - t
			mod:SetInfo(29184, line, mod:ColorName(player))
			if remaining > 0 then
				mod:SetInfo(29184, line + 1, CL.seconds:format(remaining))
				mod:SetInfoBar(29184, line, remaining / 60)
			else
				mod:SetInfo(29184, line + 1, CL.ready, 0.13, 1, 0.13)
				mod:SetInfoBar(29184, line, 0)
			end
		else
			mod:SetInfo(29184, line, "")
			mod:SetInfo(29184, line + 1, "")
			mod:SetInfoBar(29184, line, 0)
		end
		line = line + 2
	end
end
