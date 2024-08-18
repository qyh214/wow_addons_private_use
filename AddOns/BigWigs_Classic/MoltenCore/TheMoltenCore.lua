--------------------------------------------------------------------------------
-- Module Declaration
--

if not BigWigsLoader.isSeasonOfDiscovery then return end
local mod, CL = BigWigs:NewBoss("The Molten Core", 409)
if not mod then return end
mod:RegisterEnableMob(227939, 228820) -- The Molten Core, Hydraxian Firefighter
mod:SetEncounterID(3018)
mod:SetRespawnTime(10)
mod:SetAllowWin(true)

--------------------------------------------------------------------------------
-- Locals
--

local heartOfAshTarget = nil
local heartOfAshOnMe = false
local mySaySpamTarget = nil
local firefighters = {}
local lineCount = 4

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.bossName = "The Molten Core"

	L.custom_on_linked_spam = CL.link_say_option_name
	L.custom_on_linked_spam_desc = CL.link_say_option_desc
	L.custom_on_linked_spam_icon = mod:GetMenuIcon("SAY")

	L["460883_icon"] = "inv_elemental_primal_fire"
	L.adds_icon = "spell_fire_elemental_totem"
end

--------------------------------------------------------------------------------
-- Initialization
--

local heartOfAshMarker = mod:AddMarkerOption(true, "player", 3, 460898, 3) -- Heart of Ash
local heartOfCinderMarker = mod:AddMarkerOption(true, "player", 6, 460895, 6) -- Heart of Cinder
function mod:GetOptions()
	return {
		{460898, "SAY", "ME_ONLY", "ME_ONLY_EMPHASIZE"}, -- Heart of Ash
		heartOfAshMarker,
		{460895, "SAY", "ME_ONLY", "ME_ONLY_EMPHASIZE"}, -- Heart of Cinder
		heartOfCinderMarker,
		"custom_on_linked_spam",
		460887, -- Harmonic Tremor
		{460885, "CASTBAR", "EMPHASIZE", "CASTBAR_COUNTDOWN"}, -- Doomsday
		460883, -- Meteor
		{"health", "INFOBOX"},
		"adds",
	},nil,{
		[460898] = CL.count:format(CL.link, 1), -- Heart of Ash (Link 1)
		[460895] = CL.count:format(CL.link, 2), -- Heart of Cinder (Link 2)
	}
end

function mod:VerifyEnable(unit, mobId)
	if mobId == 227939 or self:GetPlayerAura(458843) then -- The Molten Core, or Hydraxian Firefighter on Level 3
		return true
	end
end

function mod:OnRegister()
	self.displayName = L.bossName
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "HeartOfAshApplied", 460898)
	self:Log("SPELL_AURA_REMOVED", "HeartOfAshRemoved", 460898)
	self:Log("SPELL_AURA_APPLIED", "HeartOfCinderApplied", 460895)
	self:Log("SPELL_AURA_REMOVED", "HeartOfCinderRemoved", 460895)
	self:Log("SPELL_CAST_START", "HarmonicTremor", 460887, 462560, 462563) -- first, second, third
	self:Log("SPELL_CAST_START", "Doomsday", 460885)
	self:Log("SPELL_AURA_APPLIED", "FrigidCurrentApplied", 460899)
	self:Log("SWING_DAMAGE", "SwingDamage", "*")
	self:Log("SPELL_DAMAGE", "SpellDamage", "*")
	self:Death("FirefighterDeaths", 228820)
	self:Log("SPELL_CAST_SUCCESS", "ConjureFlame", 462619)
	self:Log("SPELL_CAST_SUCCESS", "Meteor", 460883, 462778, 462779, 462780) -- 1, 2, 3, 4
end

function mod:OnEngage()
	heartOfAshTarget = nil
	heartOfAshOnMe = false
	mySaySpamTarget = nil
	firefighters = {}
	lineCount = 3
	self:OpenInfo("health", CL.other:format("BigWigs", CL.health))
	self:CDBar("adds", 28, CL.adds, L.adds_icon)
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
	function mod:HeartOfAshApplied(args)
		heartOfAshTarget = args.destName
		self:TargetMessage(args.spellId, "yellow", args.destName, CL.count_icon:format(CL.link, 1, 3))
		self:CustomIcon(heartOfAshMarker, args.destName, 3)
		if self:Me(args.destGUID) then
			heartOfAshOnMe = true
			self:Say(args.spellId, CL.count_rticon:format(CL.link, 1, 3), nil, "Link (1{rt3})")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		end
	end

	function mod:HeartOfAshRemoved(args)
		mySaySpamTarget = nil -- Sometimes only one of the two has a removed event (player death?) so just nil it for everyone
		if self:Me(args.destGUID) then
			heartOfAshOnMe = false
			self:Say(args.spellId, CL.link_removed, true, "Link removed")
			self:PersonalMessage(args.spellId, false, CL.link_removed)
		end
		self:CustomIcon(heartOfAshMarker, args.destName)
	end

	function mod:HeartOfCinderApplied(args)
		self:StopBar(CL.count:format(CL.link, 2))
		self:TargetMessage(args.spellId, "yellow", args.destName, CL.count_icon:format(CL.link, 2, 6))
		self:CustomIcon(heartOfCinderMarker, args.destName, 6)
		if self:Me(args.destGUID) then
			if heartOfAshTarget and self:GetOption("custom_on_linked_spam") then
				mySaySpamTarget = {6, self:Ambiguate(heartOfAshTarget, "short")}
				self:SimpleTimer(RepeatLinkSay, 1.5)
			end
			self:Say(args.spellId, CL.count_rticon:format(CL.link, 2, 6), nil, "Link (2{rt6})")
			self:PlaySound(args.spellId, "warning", nil, args.destName)
		else
			if heartOfAshTarget then
				self:Message(args.spellId, "yellow", CL.link_both_icon:format(3, self:ColorName(heartOfAshTarget), 6, self:ColorName(args.destName)))
			end
			if heartOfAshOnMe and self:GetOption("custom_on_linked_spam") then
				mySaySpamTarget = {3, self:Ambiguate(args.destName, "short")}
				self:SimpleTimer(RepeatLinkSay, 1.5)
			end
		end
	end

	function mod:HeartOfCinderRemoved(args)
		mySaySpamTarget = nil -- Sometimes only one of the two has a removed event (player death?) so just nil it for everyone
		if self:Me(args.destGUID) then
			self:Say(args.spellId, CL.link_removed, true, "Link removed")
			self:PersonalMessage(args.spellId, false, CL.link_removed)
		end
		self:CustomIcon(heartOfCinderMarker, args.destName)
	end
end

function mod:HarmonicTremor(args)
	if args.spellId == 460887 then -- first in sequence of 3
		self:Message(460887, "orange", CL.count_amount:format(args.spellName, 1, 3))
	elseif args.spellId == 462560 then -- second
		self:Message(460887, "orange", CL.count_amount:format(args.spellName, 2, 3))
	else -- 462563, third
		self:Message(460887, "orange", CL.count_amount:format(args.spellName, 3, 3))
	end
	self:PlaySound(460887, "alarm")
end

function mod:Doomsday(args)
	self:CastBar(args.spellId, 20)
	self:Message(args.spellId, "red")
	self:PlaySound(args.spellId, "long")
end

function mod:FrigidCurrentApplied(args)
	if self:MobId(args.sourceGUID) == 228820 and self:MobId(args.destGUID) == 227939 then -- Hydraxian Firefighter, The Molten Core
		if not firefighters[args.sourceGUID] and lineCount < 10 then
			firefighters[args.sourceGUID] = {lineCount, 77700}
			self:SetInfo("health", 1, args.sourceName)
			local icon = self:GetIconTexture(self:GetIcon(args.sourceRaidFlags))
			self:SetInfo("health", lineCount, icon or "")
			self:SetInfoBar("health", lineCount, 1)
			self:SetInfo("health", lineCount + 1, "100%")
			lineCount = lineCount + 2
		end
	end
end

function mod:SwingDamage(args)
	local tbl = firefighters[args.destGUID]
	if tbl then
		local line = tbl[1]
		local hp = tbl[2]
		local newHp = hp - args.spellId -- spellId = Damage the melee swing did
		tbl[2] = newHp
		local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags))
		self:SetInfo("health", line, icon or "")
		local currentHealthPercent = math.floor((newHp / 77700) * 100)
		self:SetInfoBar("health", line, currentHealthPercent/100)
		self:SetInfo("health", line + 1, ("%d%%"):format(currentHealthPercent))
	end
end

function mod:SpellDamage(args)
	local tbl = firefighters[args.destGUID]
	if tbl then
		local line = tbl[1]
		local hp = tbl[2]
		local newHp = hp - args.extraSpellId -- extraSpellId = Damage the spell did
		tbl[2] = newHp
		local icon = self:GetIconTexture(self:GetIcon(args.destRaidFlags))
		self:SetInfo("health", line, icon or "")
		local currentHealthPercent = math.floor((newHp / 77700) * 100)
		self:SetInfoBar("health", line, currentHealthPercent/100)
		self:SetInfo("health", line + 1, ("%d%%"):format(currentHealthPercent))
	end
end

function mod:FirefighterDeaths(args)
	local tbl = firefighters[args.destGUID]
	if tbl then
		firefighters[args.destGUID] = nil
		local line = tbl[1]
		self:SetInfoBar("health", line, 0)
		self:SetInfo("health", line + 1, CL.dead)
		if not next(firefighters) then
			self:StopBar(CL.adds)
		end
	end
end

function mod:ConjureFlame()
	self:CDBar("adds", 31, CL.adds, L.adds_icon)
	self:Message("adds", "cyan", CL.adds_spawned, L.adds_icon)
	self:PlaySound("adds", "info")
end

function mod:Meteor(args)
	if args.spellId == 462778 then -- 2 Meteors
		self:Message(460883, "red", CL.count:format(args.spellName, 2), L["460883_icon"])
	elseif args.spellId == 462779 then -- 3 Meteors
		self:Message(460883, "red", CL.count:format(args.spellName, 3), L["460883_icon"])
	elseif args.spellId == 462780 then -- 4 Meteors
		self:Message(460883, "red", CL.count:format(args.spellName, 4), L["460883_icon"])
	else -- 460883, 1 Meteor
		self:Message(460883, "red", CL.count:format(args.spellName, 1), L["460883_icon"])
	end
	self:PlaySound(460883, "alert")
end
