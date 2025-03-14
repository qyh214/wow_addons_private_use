--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Blackwing Lair Trash", 469)
if not mod then return end
mod.displayName = CL.trash
if mod:GetSeason() == 2 then
	mod:RegisterEnableMob(
		12460, -- Death Talon Wyrmguard
		12461, -- Death Talon Overseer
		12459, -- Blackwing Warlock
		12557, -- Grethok the Controller
		13020, -- Vaelastrasz
		12017, -- Broodlord Lashlayer
		11983, -- Firemaw
		14601, -- Ebonroc
		11981, -- Flamegor
		14020, -- Chromaggus
		11583, -- Nefarian
		10162 -- Lord Victor Nefarius
	)
else
	mod:RegisterEnableMob(
		12460, -- Death Talon Wyrmguard
		12461, -- Death Talon Overseer
		12459 -- Blackwing Warlock
	)
end

--------------------------------------------------------------------------------
-- Locals
--

local buffList = {}
local arcaneBombMarker
local naturesFuryMarker

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.wyrmguard_overseer = "Death Talon Wyrmguard / Death Talon Overseer" -- NPC 12460 / 12461
	L.sandstorm = "Sandstorm"

	L.target_vulnerability = "Target Vulnerability Warnings"
	L.target_vulnerability_desc = "When your target is a Death Talon Wyrmguard or a Death Talon Overseer, show a warning for what vulnerability it has."
	L.target_vulnerability_icon = 22277
	L.target_vulnerability_message = "Target Vulnerability: %s"
	L.detect_magic_missing_message = "Detect Magic is missing from your target"
	L.detect_magic_warning = "A Mage must cast \124cff71d5ff\124Hspell:2855:0\124h[Detect Magic]\124h\124r on your target for vulnerability warnings to work."

	L.warlock = "Blackwing Warlock" -- NPC 12459
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{22291, "SAY", "SAY_COUNTDOWN"}, -- Brood Power: Bronze
		"target_vulnerability",
		19717, -- Rain of Fire
	},{
		[22291] = L.wyrmguard_overseer,
		[19717] = L.warlock,
	},{
		[22291] = L.sandstorm, -- Brood Power: Bronze (Sandstorm)
	}
end

if mod:GetSeason() == 2 then
	arcaneBombMarker = mod:AddMarkerOption(true, "player", 6, 466357, 6) -- Arcane Bomb
	naturesFuryMarker = mod:AddMarkerOption(true, "player", 4, 466435, 4) -- Nature's Fury
	function mod:GetOptions()
		return {
			{22291, "SAY", "SAY_COUNTDOWN"}, -- Brood Power: Bronze
			"target_vulnerability",
			369330, -- Rain of Fire
			{466357, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Arcane Bomb
			arcaneBombMarker,
			{466435, "SAY", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"}, -- Nature's Fury
			naturesFuryMarker,
		},{
			[22291] = L.wyrmguard_overseer,
			[369330] = L.warlock,
			[466357] = CL.general,
		},{
			[22291] = L.sandstorm, -- Brood Power: Bronze (Sandstorm)
		}
	end
elseif mod:Vanilla() then
	function mod:GetOptions()
		return {
			{22291, "SAY", "SAY_COUNTDOWN"}, -- Brood Power: Bronze
			"target_vulnerability",
			369330, -- Rain of Fire
		},{
			[22291] = L.wyrmguard_overseer,
			[369330] = L.warlock,
		},{
			[22291] = L.sandstorm, -- Brood Power: Bronze (Sandstorm)
		}
	end
end

function mod:OnRegister()
	buffList = {
		[22277] = L.target_vulnerability_message:format(CL.fire),
		[22278] = L.target_vulnerability_message:format(CL.frost),
		[22279] = L.target_vulnerability_message:format(CL.shadow),
		[22280] = L.target_vulnerability_message:format(CL.nature),
		[22281] = L.target_vulnerability_message:format(CL.arcane),
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "BroodPowerBronzeApplied", 22291)
	self:Log("SPELL_AURA_REFRESH", "BroodPowerBronzeApplied", 22291)
	self:Log("SPELL_AURA_REMOVED", "BroodPowerBronzeRemoved", 22291)
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	if self:Vanilla() then
		self:Log("SPELL_AURA_APPLIED", "DetectMagicApplied", 2855)
		self:Log("SPELL_AURA_APPLIED", "RainOfFireDamage", 369330)
		self:Log("SPELL_PERIODIC_DAMAGE", "RainOfFireDamage", 369330)
		self:Log("SPELL_PERIODIC_MISSED", "RainOfFireDamage", 369330)
	else
		self:Log("SPELL_AURA_APPLIED", "RainOfFireDamage", 19717)
		self:Log("SPELL_PERIODIC_DAMAGE", "RainOfFireDamage", 19717)
		self:Log("SPELL_PERIODIC_MISSED", "RainOfFireDamage", 19717)
	end
	if self:GetSeason() == 2 then
		self:Log("SPELL_AURA_APPLIED", "ArcaneBombApplied", 466357)
		self:Log("SPELL_AURA_REMOVED", "ArcaneBombRemoved", 466357)
		self:Log("SPELL_AURA_APPLIED", "NaturesFuryApplied", 466435)
		self:Log("SPELL_AURA_REMOVED", "NaturesFuryRemoved", 466435)
	else
		self:RegisterMessage("BigWigs_OnBossEngage", "Disable")
	end
end

--------------------------------------------------------------------------------
-- Event Handlers
--

--[[ Death Talon Wyrmguard / Death Talon Overseer ]]--

function mod:BroodPowerBronzeApplied(args)
	self:TargetBar(args.spellId, 5, args.destName, L.sandstorm)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, nil, L.sandstorm)
		self:Say(args.spellId, L.sandstorm, nil, "Sandstorm")
		self:CancelSayCountdown(args.spellId)
		self:SayCountdown(args.spellId, 5)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	else
		local unit = self:GetUnitIdByGUID(args.sourceGUID)
		if unit and self:UnitWithinRange(unit, 10) then
			self:PersonalMessage(args.spellId, "near", L.sandstorm)
			self:PlaySound(args.spellId, "warning")
		else
			self:TargetMessage(args.spellId, "orange", args.destName, L.sandstorm)
		end
	end
end

function mod:BroodPowerBronzeRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:StopBar(L.sandstorm, args.destName)
end

do
	local printed = false
	local prevMsg = 0
	local prevGUID = nil
	function mod:CheckTarget()
		local guid = self:UnitGUID("target")
		if guid ~= prevGUID then
			local npcId = self:MobId(guid)
			if npcId == 12460 or npcId == 12461 then -- Death Talon Wyrmguard, Death Talon Overseer
				if self:Vanilla() and not self:UnitDebuff("target", 2855) then
					if not printed then
						printed = true
						BigWigs:Print(L.detect_magic_warning)
					end
					if GetTime() - prevMsg > 40 and self:GetHealth("target") > 5 then
						prevMsg = GetTime()
						local icon = self:GetIconTexture(self:GetIcon("target"))
						if icon then
							self:Message("target_vulnerability", "red", icon.. L.detect_magic_missing_message, 2855)
						else
							self:Message("target_vulnerability", "red", L.detect_magic_missing_message, 2855)
						end
					end
					return
				end
				for buffId, message in next, buffList do
					if self:UnitBuff("target", buffId) then
						prevGUID = guid
						local icon = self:GetIconTexture(self:GetIcon("target"))
						if icon then
							self:Message("target_vulnerability", "yellow", icon.. message, 22277)
						else
							self:Message("target_vulnerability", "yellow", message, 22277)
						end
						return
					end
				end
			end
		end
	end
	function mod:PLAYER_TARGET_CHANGED()
		prevGUID = nil
		self:CheckTarget()
	end
	function mod:DetectMagicApplied(args)
		if args.destGUID == self:UnitGUID("target") then
			self:SimpleTimer(function() self:CheckTarget() end, 0.1) -- Combat log is sometimes faster than the aura API
		end
	end
end

--[[ Blackwing Warlock ]]--

do
	local prev = 0
	function mod:RainOfFireDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "aboveyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

--[[ Season of Discovery ]]--

function mod:ArcaneBombApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:TargetBar(args.spellId, 8, args.destName)
	self:CustomIcon(arcaneBombMarker, args.destName, 6)
	if self:Me(args.destGUID) then
		self:Yell(args.spellId, CL.rticon:format(args.spellName, 6), nil, "Arcane Bomb ({rt6})")
		self:YellCountdown(args.spellId, 8, 6, 6)
	end
	self:PlaySound(args.spellId, "warning", nil, args.destName)
end

function mod:ArcaneBombRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelYellCountdown(args.spellId)
	end
	self:StopBar(args.spellName, args.destName)
	self:CustomIcon(arcaneBombMarker, args.destName)
end

function mod:NaturesFuryApplied(args)
	self:TargetMessage(args.spellId, "orange", args.destName)
	self:TargetBar(args.spellId, 8, args.destName)
	self:CustomIcon(naturesFuryMarker, args.destName, 4)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.rticon:format(args.spellName, 4), nil, "Nature's Fury ({rt4})")
		self:SayCountdown(args.spellId, 8, 4, 5)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

function mod:NaturesFuryRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
	end
	self:StopBar(args.spellName, args.destName)
	self:CustomIcon(naturesFuryMarker, args.destName)
end
