--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ascendant Council", 671, 158)
if not mod then return end
mod:RegisterEnableMob(43686, 43687, 43688, 43689, 43735) --Ignacious, Feludius, Arion, Terrastra, Elementium Monstrosity
mod:SetEncounterID(1028)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locals
--

local quake, thundershock = mod:SpellName(83565), mod:SpellName(83067)
local crushMarked = false
local timeLeft = 8
local phase = 1
local isWaterlogged = false
local staticOverloadTarget = nil
local staticOverloadOnMe = false
local gravityCoreOnMe = false
local mySaySpamTarget = nil

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.health_report = "%s at %d%%, phase change soon!"
	L.switch = "Switch"
	L.switch_desc = "Warning for boss switches."

	L.shield_up_message = "Shield is UP!"
	L.shield_down_message = "Shield is DOWN!"
	L.shield_bar = "Shield"

	L.switch_trigger = "We will handle them!"

	L.thundershock_quake_soon = "%s in 10sec!"

	L.quake_trigger = "The ground beneath you rumbles ominously...."
	L.thundershock_trigger = "The surrounding air crackles with energy...."

	L.thundershock_quake_spam = "%s in %d"

	L.last_phase_trigger = "An impressive display..."

	L.custom_on_linked_spam = CL.link_say_option_name
	L.custom_on_linked_spam_desc = CL.link_say_option_desc
	L.custom_on_linked_spam_icon = mod:GetMenuIcon("SAY")
end

--------------------------------------------------------------------------------
-- Initialization
--

local lightningRodMarker = mod:AddMarkerOption(true, "player", 1, 83099, 1, 2, 3) -- Lightning Rod
local gravityCrushMarker = mod:AddMarkerOption(true, "player", 1, 84948, 1, 2, 3) -- Gravity Crush
local staticOverloadMarker = mod:AddMarkerOption(true, "player", 4, 92067, 4) -- Static Overload
local gravityCoreMarker = mod:AddMarkerOption(true, "player", 5, 92075, 5) -- Gravity Core
function mod:GetOptions()
	return {
		-- Ignacious
		82631, -- Aegis of Flame
		82660, -- Burning Blood
		82860, -- Inferno Rush
		-- Feludius
		82746, -- Glaciate
		82665, -- Heart of Ice
		82762, -- Waterlogged
		-- Arion
		83067, -- Thundershock
		{83099, "SAY", "ME_ONLY_EMPHASIZE"}, -- Lightning Rod
		lightningRodMarker,
		-- Terrastra
		83565, -- Quake
		83718, -- Harden Skin
		-- Monstrosity
		84948, -- Gravity Crush
		gravityCrushMarker,
		84915, -- Liquid Ice
		84913, -- Lava Seed
		-- Heroic
		{92067, "SAY", "ME_ONLY", "ME_ONLY_EMPHASIZE"}, -- Static Overload
		staticOverloadMarker,
		{92075, "SAY", "ME_ONLY", "ME_ONLY_EMPHASIZE"}, -- Gravity Core
		gravityCoreMarker,
		"custom_on_linked_spam",
		{92307, "SAY", "ICON", "ME_ONLY_EMPHASIZE"}, -- Frost Beacon
		-- General
		"switch"
	},{
		[82631] = -3118, -- Ignacious
		[82746] = -3110, -- Feludius
		[83067] = -3123, -- Arion
		[83565] = -3125, -- Terrastra
		[84948] = -3145, -- Elementium Monstrosity
		[92067] = "heroic",
		switch = "general",
	},{
		[82860] = CL.underyou:format(CL.fire), -- Inferno Rush (Fire under YOU)
		[92067] = CL.count:format(CL.link, 1), -- Static Overload (Link 1)
		[92075] = CL.count:format(CL.link, 2), -- Gravity Core (Link 2)
		[92307] = CL.orb, -- Frost Beacon (Orb)
	}
end

function mod:OnBossEnable()
	--heroic
	self:Log("SPELL_AURA_APPLIED", "StaticOverload", 92067)
	self:Log("SPELL_AURA_REMOVED", "StaticOverloadRemoved", 92067)
	self:Log("SPELL_AURA_APPLIED", "GravityCore", 92075)
	self:Log("SPELL_AURA_REMOVED", "GravityCoreRemoved", 92075)
	self:Log("SPELL_AURA_APPLIED", "FrostBeaconApplied", 92307)
	self:Log("SPELL_AURA_REMOVED", "FrostBeaconRemoved", 92307)

	--normal
	self:Log("SPELL_CAST_SUCCESS", "LightningRod", 83099)
	self:Log("SPELL_AURA_APPLIED", "LightningRodApplied", 83099)
	self:Log("SPELL_AURA_REMOVED", "LightningRodRemoved", 83099)

	--Shield
	self:Log("SPELL_CAST_START", "FlameShield", 82631)
	self:Log("SPELL_AURA_REMOVED", "FlameShieldRemoved", 82631)

	self:Log("SPELL_CAST_START", "HardenSkinStart", 83718)
	self:Log("SPELL_CAST_START", "Glaciate", 82746)
	self:Log("SPELL_AURA_APPLIED", "WaterloggedApplied", 82762)
	self:Log("SPELL_AURA_REMOVED", "WaterloggedRemoved", 82762)
	self:Log("SPELL_CAST_SUCCESS", "HeartofIce", 82665)
	self:Log("SPELL_CAST_SUCCESS", "BurningBlood", 82660)

	self:BossYell("Switch", L["switch_trigger"])

	self:Log("SPELL_CAST_START", "Quake", 83565)
	self:Log("SPELL_CAST_START", "Thundershock", 83067)

	self:Emote("QuakeTrigger", L["quake_trigger"])
	self:Emote("ThundershockTrigger", L["thundershock_trigger"])

	self:BossYell("LastPhase", L["last_phase_trigger"])

	self:Log("SPELL_DAMAGE", "InfernoRushDamage", 82860)
	self:Log("SPELL_MISSED", "InfernoRushDamage", 82860)

	-- Stage 3
	self:Log("SPELL_DAMAGE", "LiquidIceDamage", 84915)
	self:Log("SPELL_MISSED", "LiquidIceDamage", 84915)
	self:Log("SPELL_CAST_SUCCESS", "GravityCrush", 84948)
	self:Log("SPELL_AURA_APPLIED", "GravityCrushApplied", 84948)
	self:Log("SPELL_AURA_REMOVED", "GravityCrushRemoved", 84948)
	self:Log("SPELL_CAST_START", "LavaSeed", 84913)
end

function mod:OnEngage()
	isWaterlogged = false
	staticOverloadTarget = nil
	staticOverloadOnMe = false
	gravityCoreOnMe = false
	mySaySpamTarget = nil

	self:Bar(82631, 30, L["shield_bar"])
	self:Bar(82746, 30) -- Glaciate
	if self:Heroic() then
		self:Bar(92067, 20, CL.count:format(CL.link, 1)) -- Static Overload
	end

	phase = 1
	crushMarked = false
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1", "boss2", "boss3", "boss4")
end

--------------------------------------------------------------------------------
-- Event Handlers
--

do
	local function RepeatLinkSay()
		if not mod:IsEngaged() or not mySaySpamTarget then return end
		mod:SimpleTimer(RepeatLinkSay, 1.5)
		mod:Say(false, CL.link_with_rticon:format(mySaySpamTarget[1], mySaySpamTarget[2]), true, ("{rt%d}Linked with %s"):format(mySaySpamTarget[1], mySaySpamTarget[2]))
	end
	function mod:StaticOverload(args)
		staticOverloadTarget = args.destName
		self:StopBar(CL.count:format(CL.link, 1))
		self:TargetMessage(args.spellId, "yellow", args.destName, CL.count_icon:format(CL.link, 1, 4))
		self:Bar(92075, 5, CL.count:format(CL.link, 2)) -- Gravity Core
		self:CustomIcon(staticOverloadMarker, args.destName, 4)
		if self:Me(args.destGUID) then
			staticOverloadOnMe = true
			self:Say(args.spellId, CL.count_rticon:format(CL.link, 1, 4), nil, "Link (1{rt4})")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end

	function mod:StaticOverloadRemoved(args)
		if self:Me(args.destGUID) then
			staticOverloadOnMe = false
			mySaySpamTarget = nil
			self:Say(args.spellId, CL.link_removed, true, "Link removed")
		end
		self:CustomIcon(staticOverloadMarker, args.destName)
	end

	function mod:GravityCore(args)
		self:StopBar(CL.count:format(CL.link, 2))
		self:TargetMessage(args.spellId, "yellow", args.destName, CL.count_icon:format(CL.link, 2, 5))
		self:Bar(92067, 15, CL.count:format(CL.link, 1)) -- Static Overload
		self:CustomIcon(gravityCoreMarker, args.destName, 5)
		if self:Me(args.destGUID) then
			gravityCoreOnMe = true
			if staticOverloadTarget and self:GetOption("custom_on_linked_spam") then
				mySaySpamTarget = {5, self:Ambiguate(staticOverloadTarget, "short")}
				self:SimpleTimer(RepeatLinkSay, 1.5)
			end
			self:Say(args.spellId, CL.count_rticon:format(CL.link, 2, 5), nil, "Link (2{rt5})")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		else
			if staticOverloadTarget then
				self:Message(args.spellId, "yellow", CL.link_both_icon:format(4, self:ColorName(staticOverloadTarget), 5, self:ColorName(args.destName)))
			end
			if staticOverloadOnMe and self:GetOption("custom_on_linked_spam") then
				mySaySpamTarget = {4, self:Ambiguate(args.destName, "short")}
				RepeatLinkSay()
			end
		end
	end

	function mod:GravityCoreRemoved(args)
		if self:Me(args.destGUID) then
			gravityCoreOnMe = false
			mySaySpamTarget = nil
			self:Say(args.spellId, CL.link_removed, true, "Link removed")
		end
		self:CustomIcon(gravityCoreMarker, args.destName)
	end
end

do
	local playerList = {}
	function mod:LightningRod()
		playerList = {}
	end
	function mod:LightningRodApplied(args)
		local count = #playerList+1
		playerList[count] = args.destName
		self:TargetsMessage(args.spellId, "red", playerList, self:GetMaxPlayers() == 10 and 1 or 3)
		self:CustomIcon(lightningRodMarker, args.destName, count)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Lightning Rod")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

function mod:LightningRodRemoved(args)
	self:CustomIcon(lightningRodMarker, args.destName)
end

function mod:FrostBeaconApplied(args)
	self:TargetMessage(args.spellId, "yellow", args.destName, CL.orb)
	self:PrimaryIcon(args.spellId, args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, CL.orb, nil, "Orb")
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	else
		self:PlaySound(args.spellId, "alarm", nil, args.destName)
	end
end

function mod:FrostBeaconRemoved(args)
	if self:Me(args.destGUID) then
		self:PersonalMessage(args.spellId, "removed", CL.orb)
	end
	self:PrimaryIcon(args.spellId)
end

function mod:UNIT_HEALTH(event, unit)
	local hp = self:GetHealth(unit)
	if phase == 1 then
		if hp < 30 then
			self:MessageOld("switch", "yellow", "info", L["health_report"]:format(self:UnitName(unit), hp), 26662)
			phase = 2
		end
	elseif phase == 2 then
		if hp > 1 and hp < 30 then
			local arion = self:SpellName(-3123)
			local terrastra = self:SpellName(-3125)
			local name = self:UnitName(unit)
			if name == arion or name == terrastra then
				phase = 3
				self:MessageOld("switch", "yellow", "info", L["health_report"]:format(name, hp), 26662)
				self:UnregisterUnitEvent(event, "boss1", "boss2", "boss3", "boss4")
			end
		end
	end
end

function mod:FlameShield(args)
	self:Bar(args.spellId, 62, L["shield_bar"])
	self:MessageOld(args.spellId, "red", "alert", L["shield_up_message"])
end

function mod:FlameShieldRemoved(args)
	self:MessageOld(args.spellId, "red", "alert", L["shield_down_message"])
end

function mod:HardenSkinStart(args)
	self:Bar(args.spellId, 44)
	self:MessageOld(args.spellId, "orange", "info")
end

function mod:Glaciate(args)
	self:Bar(args.spellId, 33)
	self:MessageOld(args.spellId, "yellow", "alert")
end

function mod:WaterloggedApplied(args)
	if self:Me(args.destGUID) then
		isWaterlogged = true
		self:PersonalMessage(args.spellId)
		self:PlaySound(args.spellId, "warning", nil, args.destName)
	end
end

do
	local function Reset() isWaterlogged = false end
	function mod:WaterloggedRemoved(args)
		if self:Me(args.destGUID) then
			self:SimpleTimer(Reset, 1)
			self:PersonalMessage(args.spellId, "removed")
		end
	end
end

function mod:HeartofIce(args)
	self:TargetMessageOld(args.spellId, args.destName, "red")
	--if self:Me(args.destGUID) then
	--	self:Flash(args.spellId)
	--end
end

function mod:BurningBlood(args)
	self:TargetMessageOld(args.spellId, args.destName, "red")
	--if self:Me(args.destGUID) then
	--	self:Flash(args.spellId)
	--end
end

function mod:Switch()
	self:StopBar(L["shield_bar"])
	self:StopBar(82746) -- Glaciate
	self:Bar(83565, 33) -- Quake
	self:Bar(83067, 70) -- Thundershock
	self:Bar(83718, 25.5) -- Harden Skin
	self:CancelAllTimers()
	-- XXX this needs to be delayed
end

do
	local hardenTimer = nil
	local function quakeIncoming()
		if mod:UnitDebuff("player", mod:SpellName(83500), 83500) then -- Swirling Winds
			mod:CancelTimer(hardenTimer)
			return
		end
		mod:MessageOld(83565, "blue", "info", L["thundershock_quake_spam"]:format(quake, timeLeft), 83500)
		timeLeft = timeLeft - 2
	end

	function mod:QuakeTrigger()
		self:Bar(83565, 10)
		self:MessageOld(83565, "red", "info", L["thundershock_quake_soon"]:format(quake))
		timeLeft = 8
		hardenTimer = self:ScheduleRepeatingTimer(quakeIncoming, 2)
	end

	function mod:Quake(args)
		self:Bar(args.spellId, 68)
		self:MessageOld(args.spellId, "red", "alarm")
		self:CancelTimer(hardenTimer) -- Should really wait 3 more sec.
	end
end

do
	local thunderTimer = nil
	local function thunderShockIncoming()
		if mod:UnitDebuff("player", mod:SpellName(83581), 83581) then -- Grounded
			mod:CancelTimer(thunderTimer)
			return
		end
		mod:MessageOld(83067, "blue", "info", L["thundershock_quake_spam"]:format(thundershock, timeLeft), 83581)
		timeLeft = timeLeft - 2
	end

	function mod:ThundershockTrigger()
		self:MessageOld(83067, "red", "info", L["thundershock_quake_soon"]:format(thundershock))
		self:Bar(83067, 10)
		timeLeft = 8
		thunderTimer = self:ScheduleRepeatingTimer(thunderShockIncoming, 2)
	end

	function mod:Thundershock(args)
		self:Bar(args.spellId, 65)
		self:MessageOld(args.spellId, "red", "alarm")
		self:CancelTimer(thunderTimer) -- Should really wait 3 more sec but meh.
	end
end

function mod:LastPhase()
	self:StopBar(83565) -- Quake
	self:StopBar(83067) -- Thundershock
	self:StopBar(83718) -- Harden Skin
	self:CancelAllTimers()
	self:CDBar(84913, 34) -- Lava Seed
	self:Bar(84948, 43) -- Gravity Crush
	self:UnregisterUnitEvent("UNIT_HEALTH", "boss1", "boss2", "boss3", "boss4")
end

do
	local prev = 0
	function mod:InfernoRushDamage(args)
		if self:Me(args.destGUID) and not isWaterlogged and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou", CL.fire)
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

-- Stage 3
do
	local prev = 0
	function mod:LiquidIceDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 2 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

do
	local playerList = {}
	function mod:GravityCrush(args)
		playerList = {}
		self:Bar(args.spellId, 25)
	end
	function mod:GravityCrushApplied(args)
		local count = #playerList+1
		playerList[count] = args.destName
		self:TargetsMessage(args.spellId, "red", playerList, self:GetMaxPlayers() == 10 and 1 or 3)
		self:CustomIcon(gravityCrushMarker, args.destName, count)
		if self:Me(args.destGUID) then
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end
end

function mod:GravityCrushRemoved(args)
	self:CustomIcon(gravityCrushMarker, args.destName)
end

function mod:LavaSeed(args)
	self:Message(args.spellId, "orange")
	self:CDBar(args.spellId, 24)
end
