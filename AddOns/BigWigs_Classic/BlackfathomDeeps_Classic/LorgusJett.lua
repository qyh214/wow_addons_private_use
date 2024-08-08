--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Lorgus Jett Discovery", 48)
if not mod then return end
mod:RegisterEnableMob(207356, 207358) -- Lorgus Jett Season of Discovery, Blackfathom Tide Priestess
mod:SetEncounterID(2710)
mod:SetAllowWin(true)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "Lorgus Jett"
	L.priestess = "Blackfathom Tide Priestess"
	L.priestess_short = "Priestess" -- Shortened version of L.priestess (Blackfathom Tide Priestess)
	L.murloc = "Blackfathom Murloc"
	L["419649_icon"] = "inv_misc_head_murloc_01"
end

--------------------------------------------------------------------------------
-- Initialization
--

local windfuryTotemMarker = mod:AddMarkerOption(false, "npc", 8, 414691, 8) -- Corrupted Windfury Totem
local shieldTotemMarker = mod:AddMarkerOption(true, "npc", 8, 414763, 8) -- Corrupted Lightning Shield Totem
local moltenTotemMarker = mod:AddMarkerOption(false, "npc", 8, 419636, 8) -- Corrupted Molten Fury Totem
function mod:GetOptions()
	return {
		419649, -- Spawn Murloc
		22883, -- Heal
		"stages",
		414691, -- Corrupted Windfury Totem
		windfuryTotemMarker,
		{414763, "COUNTDOWN"}, -- Corrupted Lightning Shield Totem
		shieldTotemMarker,
		419636, -- Corrupted Molten Fury Totem
		moltenTotemMarker,
	},{
		[419649] = L.murloc,
		[22883] = L.priestess,
		["stages"] = L.bossName,
	}
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	-- Murloc
	self:Log("SPELL_CAST_SUCCESS", "SpawnMurloc", 419649)

	-- Priestess
	self:Log("SPELL_CAST_START", "Heal", 22883)
	self:Log("SPELL_CAST_SUCCESS", "HealSuccess", 22883)
	self:Log("SPELL_INTERRUPT", "HealInterrupted", "*")
	self:Death("Priest1Death", 207358)
	self:Death("Priest2Death", 207359)
	self:Death("Priest3Death", 207367)

	-- Lorgus Jett
	self:Log("SPELL_CAST_SUCCESS", "CorruptedWindfuryTotem", 414691)
	self:Log("SPELL_SUMMON", "CorruptedWindfuryTotemSummon", 414691)
	self:Log("SPELL_CAST_SUCCESS", "CorruptedLightningShieldTotem", 414763)
	self:Log("SPELL_SUMMON", "CorruptedLightningShieldTotemSummon", 414763)
	self:Log("SPELL_CAST_SUCCESS", "CorruptedMoltenFuryTotem", 419636)
	self:Log("SPELL_SUMMON", "CorruptedMoltenFuryTotemSummon", 419636)
end

function mod:OnEngage()
	self:SetStage(1)
	self:Message("stages", "cyan", CL.stage:format(1), false)
	self:CDBar(419649, 27, self:SpellName(419649), L["419649_icon"]) -- Spawn Murloc
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:SpawnMurloc(args)
	self:Message(args.spellId, "cyan", args.spellName, L["419649_icon"])
	self:CDBar(args.spellId, 27, args.spellName, L["419649_icon"])
end

function mod:Heal(args)
	self:Message(args.spellId, "orange", CL.casting:format(args.spellName))
	self:CDBar(args.spellId, 11.3) -- 11.3-14.6+ with some oddballs as low as 8.1
	if self:Interrupter() then
		self:PlaySound(args.spellId, "alert")
	end
end

function mod:HealSuccess(args)
	self:CDBar(args.spellId, 11.1) -- Failure to interrupt seems to reset it
end

function mod:HealInterrupted(args)
	if args.extraSpellName == self:SpellName(22883) then
		self:Message(22883, "green", CL.interrupted_by:format(args.extraSpellName, self:ColorName(args.sourceName)))
	end
end

function mod:Priest1Death()
	self:Message("stages", "cyan", CL.mob_remaining:format(L.priestess_short, 2), false)
	self:StopBar(22883) -- Heal
end

function mod:Priest2Death()
	self:Message("stages", "cyan", CL.mob_remaining:format(L.priestess_short, 1), false)
	self:StopBar(22883) -- Heal
end

function mod:Priest3Death()
	self:SetStage(2)
	self:Message("stages", "cyan", CL.stage:format(2), false)
	self:StopBar(22883) -- Heal
	self:StopBar(419649) -- Spawn Murloc
end

function mod:CorruptedWindfuryTotem(args)
	self:Message(args.spellId, "yellow")
	self:Bar(414763, 9.7) -- Corrupted Lightning Shield Totem
	self:PlaySound(args.spellId, "alert")
end

do
	local totemGUID = nil

	function mod:CorruptedWindfuryTotemSummon(args)
		-- register events to auto-mark totem
		if self:GetOption(windfuryTotemMarker) then
			totemGUID = args.destGUID
			self:RegisterTargetEvents("MarkWindfuryTotem")
		end
	end

	function mod:MarkWindfuryTotem(_, unit, guid)
		if totemGUID == guid then
			totemGUID = nil
			self:CustomIcon(windfuryTotemMarker, unit, 8)
			self:UnregisterTargetEvents()
		end
	end
end

function mod:CorruptedLightningShieldTotem(args)
	self:Message(args.spellId, "red")
	self:Bar(419636, 9.7) -- Corrupted Molten Fury Totem
	self:PlaySound(args.spellId, "warning")
end

do
	local totemGUID = nil

	function mod:CorruptedLightningShieldTotemSummon(args)
		-- register events to auto-mark totem
		if self:GetOption(shieldTotemMarker) then
			totemGUID = args.destGUID
			self:RegisterTargetEvents("MarkLightningShieldTotem")
		end
	end

	function mod:MarkLightningShieldTotem(_, unit, guid)
		if totemGUID == guid then
			totemGUID = nil
			self:CustomIcon(shieldTotemMarker, unit, 8)
			self:UnregisterTargetEvents()
		end
	end
end

function mod:CorruptedMoltenFuryTotem(args)
	self:Message(args.spellId, "orange")
	self:Bar(414691, 9.7) -- Corrupted Windfury Totem
	self:PlaySound(args.spellId, "info")
end

do
	local totemGUID = nil

	function mod:CorruptedMoltenFuryTotemSummon(args)
		-- register events to auto-mark totem
		if self:GetOption(moltenTotemMarker) then
			totemGUID = args.destGUID
			self:RegisterTargetEvents("MarkMoltenFuryTotem")
		end
	end

	function mod:MarkMoltenFuryTotem(_, unit, guid)
		if totemGUID == guid then
			totemGUID = nil
			self:CustomIcon(moltenTotemMarker, unit, 8)
			self:UnregisterTargetEvents()
		end
	end
end
