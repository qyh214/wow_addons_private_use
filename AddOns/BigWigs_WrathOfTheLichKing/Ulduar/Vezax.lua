--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("General Vezax", 603, 1648)
if not mod then return end
mod:RegisterEnableMob(33271)
mod:SetEncounterID(BigWigsLoader.isWrath and 755 or 1134)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local vaporCount = 1
local surgeCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.surge_bar = "Surge %d"

	L.animus = "Saronite Animus"
	L.animus_desc = "Warn when the Saronite Animus spawns."
	L.animus_trigger = "The saronite vapors mass and swirl violently, merging into a monstrous form!"
	L.animus_message = "Animus spawns!"

	L.vapor = "Saronite Vapors"
	L.vapor_desc = "Warn when Saronite Vapors spawn."
	L.vapor_message = "Saronite Vapor %d!"
	L.vapor_bar = "Vapor"
	L.vapor_trigger = "A cloud of saronite vapors coalesces nearby!"

	L.vaporstack = "Vapors Stack"
	L.vaporstack_desc = "Warn when you have 5 or more stacks of Saronite Vapors."
	L.vaporstack_message = "Vapors x%d!"

	L.crash_say = "Crash"

	L.mark_message = "Mark"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"vapor",
		{"vaporstack", "FLASH"},
		{62660, "ICON", "SAY"}, -- Shadow Crash
		{63276, "ICON", "SAY", "FLASH"}, -- Mark of the Faceless
		62661, -- Searing Flames
		{62662, "CASTBAR"}, -- Surge of Darkness
		"animus",
		"berserk",
	}, {
		vapor = L.vapor,
		[62660] = 62660,
		[63276] = 63276,
		[62661] = "normal",
		animus = "hard",
		berserk = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")

	self:Log("SPELL_CAST_START", "SearingFlames", 62661)
	self:Log("SPELL_CAST_START", "SurgeOfDarkness", 62662)
	self:Log("SPELL_AURA_APPLIED", "SurgeOfDarknessApplied", 62662)
	self:Log("SPELL_AURA_APPLIED_DOSE", "SaroniteVaporsApplied", 63322)
	self:Log("SPELL_CAST_SUCCESS", "ShadowCrash", 62660)
	self:Log("SPELL_CAST_SUCCESS", "MarkOfTheFaceless", 63276)
	self:Log("SPELL_AURA_REMOVED", "MarkOfTheFacelessRemoved", 63276)
end

function mod:OnEngage()
	vaporCount = 1
	surgeCount = 1
	self:Berserk(600)
	self:Bar(62662, 60, L["surge_bar"]:format(surgeCount))
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:CHAT_MSG_RAID_BOSS_EMOTE(_, msg)
	if msg == L.vapor_trigger then
		self:MessageOld("vapor", "green", nil, L.vapor_message:format(vaporCount), 63322)
		vaporCount = vaporCount + 1
		if vaporCount < (self:Classic() and 9 or 7) then
			self:Bar("vapor", 30, CL.count_amount:format(L.vapor_bar, vaporCount, self:Classic() and 8 or 6), 63322)
		end
	elseif msg == L.animus_trigger then
		self:MessageOld("animus", "red", nil, L.animus_message, "spell_frost_summonwaterelemental_2") -- spell_frost_summonwaterelemental_2 / icon 135862
	end
end

function mod:SaroniteVaporsApplied(args)
	if self:Me(args.destGUID) and args.amount > 5 then
		self:MessageOld("vaporstack", "blue", nil, L["vaporstack_message"]:format(args.amount), 63322)
		self:Flash("vaporstack", 63322)
	end
end

do
	local function printTarget(self, name, guid)
		self:TargetMessageOld(62660, name, "orange", "alert")
		self:SecondaryIcon(62660, name)
		self:ScheduleTimer("SecondaryIcon", 3, 62660)
		if self:Me(guid) then
			self:Say(62660, L["crash_say"], nil, "Crash")
		end
	end

	function mod:ShadowCrash(args)
		self:GetUnitTarget(printTarget, 0.5, args.sourceGUID) -- Classic doesn't have boss frames for GetBossTarget
	end
end

function mod:MarkOfTheFaceless(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange", "alert")
	if self:Me(args.destGUID) then
		self:Say(63276, L.mark_message, nil, "Mark")
		self:Flash(63276)
	end
	self:TargetBar(args.spellId, 10, args.destName, L.mark_message)
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:MarkOfTheFacelessRemoved(args)
	self:StopBar(L.mark_message, args.destName)
	self:PrimaryIcon(args.spellId)
end

function mod:SearingFlames(args)
	self:MessageOld(args.spellId, "yellow", self:Interrupter() and "warning")
end

function mod:SurgeOfDarkness(args)
	self:MessageOld(args.spellId, "red", "long", CL.count:format(args.spellName, surgeCount))
	self:CastBar(args.spellId, 3, L["surge_bar"]:format(surgeCount))
	surgeCount = surgeCount + 1
	self:Bar(args.spellId, 60, L["surge_bar"]:format(surgeCount))
end

function mod:SurgeOfDarknessApplied(args)
	self:Bar(args.spellId, 10)
end

