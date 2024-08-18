
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Kor'kron Dark Shaman", 1136, 856)
if not mod then return end
mod:RegisterEnableMob(71859, 71858, 71923, 71921) -- Earthbreaker Haromm, Wavebinder Kardris, Bloodclaw, Darkfang
mod.engageId = 1606

--------------------------------------------------------------------------------
-- Locals
--

local marksUsed = {}
local ashCounter = 1
local hpWarned = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.blobs = "Blobs"

	L.custom_off_mist_marks = "Toxic Mist marker"
	L.custom_off_mist_marks_desc = "To help healing assignments, mark the people who have Toxic Mist on them with {rt1}{rt2}{rt3}{rt4}{rt5}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.custom_off_mist_marks_icon = 1
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{144330, "FLASH"}, 144328,
		{144215, "TANK"}, "custom_off_mist_marks", {-8132, "FLASH", "ICON", "SAY"}, 144070, -- Earthbreaker Haromm
		{144005, "FLASH", "SAY"}, {143990, "FLASH", "ICON"}, 143973, -- Wavebinder Kardris
		-8124, 144302, "berserk",
	}, {
		[144330] = "mythic",
		[144215] = -8128, -- Earthbreaker Haromm
		[144005] = -8134, -- Wavebinder Kardris
		[-8124] = "general",
	}
end

function mod:OnBossEnable()
	-- Mythic
	self:Log("SPELL_AURA_APPLIED", "IronPrison", 144330)
	self:Log("SPELL_CAST_START", "IronTomb", 144328)
	-- Earthbreaker Haromm
	self:Log("SPELL_AURA_APPLIED", "ToxicMistApplied", 144089)
	self:Log("SPELL_AURA_REMOVED", "ToxicMistRemoved", 144089)
	self:Log("SPELL_CAST_START", "FoulStream", 144090) -- SUCCESS has destName but is way too late, and "boss1target" should be reliable for it
	self:Log("SPELL_AURA_APPLIED", "FroststormStrike", 144215)
	self:Log("SPELL_AURA_APPLIED_DOSE", "FroststormStrike", 144215)
	self:Log("SPELL_CAST_START", "AshenWall", 144070)
	-- Wavebinder Kardris
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", nil, "boss1", "boss2") -- Falling Ash
	self:Log("SPELL_CAST_SUCCESS", "FoulGeyser", 143990)
	self:Log("SPELL_AURA_REMOVED", "FoulGeyserRemoved", 143990)
	self:Log("SPELL_CAST_START", "ToxicStorm", 144005)
	self:Log("SPELL_DAMAGE", "ToxicStormDamage", 144017)
	-- General
	self:Log("SPELL_CAST_SUCCESS", "Bloodlust", 144302)
end

function mod:OnEngage()
	self:Berserk(540)
	marksUsed = {}
	ashCounter = 1
	hpWarned = 1
	self:RegisterUnitEvent("UNIT_HEALTH", "TotemWarn", "boss1", "boss2") -- Check both as one may get out of range when using the splitting tactic
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Mythic

function mod:IronTomb(args)
	self:Bar(args.spellId, 31)
	self:MessageOld(args.spellId, "red", "long")
end

do
	local function ironPrisonOverSoon(spellId, spellName)
		mod:MessageOld(spellId, "yellow", "warning", CL.soon:format(CL.removed:format(spellName)))
		mod:Flash(spellId)
	end
	function mod:IronPrison(args)
		if self:Me(args.destGUID) then
			self:Bar(args.spellId, 60)
			self:ScheduleTimer(ironPrisonOverSoon, 56, args.spellId, args.spellName)
		end
	end
end

-- Earthbreaker Haromm

do
	function mod:ToxicMistRemoved(args)
		if self.db.profile.custom_off_mist_marks then
			for i = 1, 7 do
				if marksUsed[i] == args.destName then
					marksUsed[i] = false
					self:CustomIcon(false, args.destName, 0)
				end
			end
		end
	end

	local function markMist(destName)
		for i = 1, 7 do
			if not marksUsed[i] then
				mod:CustomIcon(false, destName, i)
				marksUsed[i] = destName
				return
			end
		end
	end
	function mod:ToxicMistApplied(args)
		if self.db.profile.custom_off_mist_marks then
			markMist(args.destName)
		end
	end
end

do
	local function printTarget(self, name, guid)
		self:PrimaryIcon(-8132, name)
		if self:Me(guid) then
			self:Say(-8132, nil, nil, "Foul Stream")
			self:Flash(-8132)
		end
		self:TargetMessageOld(-8132, name, "green", "alarm")
	end
	function mod:FoulStream(args)
		self:Bar(-8132, 32)
		self:GetBossTarget(printTarget, 0.4, args.sourceGUID)
	end
end

function mod:FroststormStrike(args)
	local amount = args.amount or 1
	if amount == 2 or amount > 3 then
		self:StackMessageOld(args.spellId, args.destName, amount, "yellow", amount > 4 and "warning")
		self:Bar(args.spellId, 6)
	else -- if tanking Haromm
		local boss = self:GetUnitIdByGUID(args.sourceGUID)
		if self:Tanking(boss) then
			self:Bar(args.spellId, 6)
		end
	end
end

function mod:AshenWall(args)
	self:MessageOld(args.spellId, "cyan")
	self:Bar(args.spellId, 32.2)
end

-- Wavebinder Kardris

function mod:UNIT_SPELLCAST_START(_, _, _, spellId)
	if spellId == 143973 then -- Falling Ash
		-- this is for when the damage happens
		self:DelayedMessage(143973, 14, "yellow", CL.soon:format(CL.count:format(self:SpellName(143973), ashCounter)), 143973, self:Healer() and "info")
		self:Bar(143973, 17, CL.count:format(self:SpellName(143973), ashCounter))
		ashCounter = ashCounter + 1
	end
end

function mod:FoulGeyser(args) -- Blobs
	self:PrimaryIcon(-8132)
	self:SecondaryIcon(args.spellId, args.destName)
	self:Bar(args.spellId, 32, L.blobs)
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
	self:TargetMessageOld(args.spellId, args.destName, "red", "alert", L.blobs)
end

function mod:FoulGeyserRemoved(args)
	if self:MobId(args.destGUID) == 71858 then -- Wavebinder Kardris
		self:SecondaryIcon(args.spellId)
	end
end

do
	local prev = 0
	function mod:ToxicStormDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(144005, "blue", "info", CL.underyou:format(args.spellName))
			self:Flash(144005)
		end
	end
end

do
	local function printTarget(self, name, guid)
		if self:Me(guid) then
			self:Say(144005, nil, nil, "Toxic Storm")
		end
		self:TargetMessageOld(144005, name, "orange", "alert")
	end
	function mod:ToxicStorm(args)
		self:Bar(args.spellId, 32)
		self:GetBossTarget(printTarget, 0.2, args.sourceGUID)
	end
end

-- General

function mod:Bloodlust(args)
	self:MessageOld(args.spellId, "cyan", "info")
end

do
	local hpWarn = { 87, 68, 53, 28, 0 } -- Last is 0 to prevent errors, saves on having a hpWarn[hpWarned] existence check being called every time it fires
	local warnings = { -8125, -8126, -8127, -8120 } -- Poisonmist, Foulstream, Ashflare, Bloodlust.
	function mod:TotemWarn(event, unit)
		local hp = self:GetHealth(unit)
		if hp < hpWarn[hpWarned] then
			local msg = CL.soon:format(self:SpellName(warnings[hpWarned]))
			hpWarned = hpWarned + 1
			self:MessageOld(-8124, "cyan", "info", msg, false)
			if hpWarned > 4 then
				self:UnregisterUnitEvent(event, "boss1", "boss2")
			end
		end
	end
end

