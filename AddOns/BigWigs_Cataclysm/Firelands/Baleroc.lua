--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Baleroc", 720, 196)
if not mod then return end
mod:RegisterEnableMob(53494)

local countdownTargets = mod:NewTargetList()
local countdownCounter, shardCounter = 1, 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.torment = "Torment stacks on Focus"
	L.torment_desc = "Warn when your /focus gains another torment stack."
	L.torment_icon = 99256

	L.blade_bar = "~Next Blade"
	L.shard_message = "Purple shards (%d)!"
	L.focus_message = "Your focus has %d stacks!"
	L.link_message = "Link"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		99259, "torment", -2598, --Blades of Baleroc
		"berserk",
		{99516, "FLASH", "ICON"}
	}, {
		[99259] = "general",
		[99516] = "heroic"
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Countdown", 99516)
	self:Log("SPELL_AURA_REMOVED", "CountdownRemoved", 99516)
	self:Log("SPELL_CAST_START", "Shards", 99259)
	self:Log("SPELL_CAST_START", "Blades", 99352, 99350)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Torment", 99256)
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:Death("Win", 53494)
end

function mod:OnEngage()
	self:Berserk(360)
	self:Bar(99259, 5) -- Shard of Torment
	self:Bar(-2598, 30, L["blade_bar"], 99352)
	if self:Heroic() then
		self:Bar(99516, 25, L["link_message"]) -- Countdown
		countdownCounter = 1
	end
	shardCounter = 0
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Blades(args)
	self:MessageOld(-2598, "yellow", nil, args.spellId)
	self:Bar(-2598, 47, L["blade_bar"], args.spellId)
end

function mod:Countdown(args)
	countdownTargets[#countdownTargets + 1] = args.destName
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
	if countdownCounter == 1 then
		self:PrimaryIcon(args.spellId, args.destName)
		countdownCounter = 2
	else
		self:Bar(args.spellId, 47.6, L["link_message"])
		self:TargetMessageOld(args.spellId, countdownTargets, "red", "alarm", L["link_message"])
		self:SecondaryIcon(args.spellId, args.destName)
		countdownCounter = 1
	end
end

function mod:CountdownRemoved(args)
	self:PrimaryIcon(args.spellId)
	self:SecondaryIcon(args.spellId)
end

function mod:Shards(args)
	shardCounter = shardCounter + 1
	self:MessageOld(args.spellId, "orange", "alert", L["shard_message"]:format(shardCounter))
	self:Bar(args.spellId, 34)
end

function mod:Torment(args)
	if self:UnitGUID("focus") == args.destGUID and args.amount > 1 then
		self:MessageOld("torment", "blue", args.amount > 5 and "info", L["focus_message"]:format(args.amount), args.spellId)
	end
end

