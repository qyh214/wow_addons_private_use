--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Majordomo Staghelm", 720, 197)
if not mod then return end
mod:RegisterEnableMob(52571, 53619) --Staghelm, Druid of the Flame
mod:SetEncounterID(1185)
mod:SetRespawnTime(30)

--------------------------------------------------------------------------------
-- Locales
--

-- Update, in 4.3 the rate at which his energy is affected by Adrenaline is nerfed considerbly. (Despite what tooltip says)
-- I don't have data to determine if/when it caps at 3.7, but if it does, it's somewhere much later then it used to be.
-- So stack beyond 11-12 may falsely report 3.7 until data for more specials can be determined (although it was already wrong to begin with post 4.3 so this is unchanged)
local specialCD = {17.3, 14.4, 12, 10.9, 9.6, 8.4, 8.4, 7.2, 7.2, 6.0, 6.0}
local specialCounter = 1
local form = "cat"

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.seed_explosion = "You explode soon!"
	L.seed_bar = "You explode!"
	L.adrenaline_message = "Adrenaline x%d!"
	L.leap_say = "Leap"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		98379,
		98474,
		98374,
		{98476, "ICON", "SAY"},
		{98450, "CASTBAR", "CASTBAR_COUNTDOWN", "SAY_COUNTDOWN", "ME_ONLY_EMPHASIZE"},
		98451,
		97238,
		"berserk",
	},{
		[98379] = 98379,
		[98374] = 98374,
		[98450] = -2922,
		[97238] = "general"
	},{
		[98450] = CL.bomb, -- Searing Seeds (Bomb)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Adrenaline", 97238)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Adrenaline", 97238)
	self:Log("SPELL_AURA_APPLIED", "CatForm", 98374)
	self:Log("SPELL_AURA_APPLIED", "ScorpionForm", 98379)
	self:Log("SPELL_AURA_REMOVED", "FormCanceled", 98374, 98379)
	self:Log("SPELL_CAST_SUCCESS", "LeapingFlames", 98476)
	self:Log("SPELL_CAST_START", "RecklessLeap", 99629)
	self:Log("SPELL_AURA_APPLIED", "SearingSeedsApplied", 98450)
	self:Log("SPELL_AURA_REMOVED", "SearingSeedsRemoved", 98450)
	self:Log("SPELL_CAST_START", "BurningOrbs", 98451)
end

function mod:OnEngage()
	self:Berserk(600) -- assumed
	specialCounter = 1
	form = "cat"
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Adrenaline(args)
	self:MessageOld(args.spellId, "yellow", nil, L["adrenaline_message"]:format(args.amount or 1))
	 -- this is power based, not time. Power regen is affected by adrenaline
	 -- adrenaline gets stacked every special
	specialCounter = specialCounter + 1
	if form == "cat" then
		self:Bar(98476, specialCD[specialCounter] or 3.7) -- Leaping Flames
	elseif form == "scorpion" then
		self:Bar(98474, specialCD[specialCounter] or 3.7) -- Flame Scythe
	end
end

do
	local prev, fired, timer = 0, 0, nil
	local function checkTarget(spellId)
		fired = fired + 1
		local guid = mod:UnitGUID("boss1target")
		if guid and not mod:Tanking("boss1", "boss1target") then
			mod:CancelTimer(timer)
			timer = nil
			if mod:Me(guid) then
				mod:Say(spellId, L["leap_say"], nil, "Leap")
			end
			local player = mod:UnitName("boss1target")
			mod:TargetMessageOld(spellId, player, "orange", "long") -- Leaping Flames
			mod:PrimaryIcon(spellId, player)
			return
		end
		if fired > 18 then
			mod:CancelTimer(timer)
			timer = nil
		end
	end
	function mod:LeapingFlames(args)
		local t = GetTime() --Throttle as it's sometimes casted twice in a row
		if t-prev > 2 then
			prev, fired = t, 0
			if not timer then
				timer = self:ScheduleRepeatingTimer(checkTarget, 0.05, args.spellId)
			end
		end
	end
end

do
	local function checkTarget(guid)
		for unit in mod:IterateGroup() do
			local leapTarget = unit.."target"
			if mod:UnitGUID(leapTarget) == guid and UnitIsUnit("player", leapTarget.."target") then
				mod:Say(98476, L["leap_say"], nil, "Leap")
				break
			end
		end
	end
	function mod:RecklessLeap(args)
		--3sec cast so we have room to balance accuracy vs reaction time
		self:ScheduleTimer(checkTarget, 1.5, args.sourceGUID)
	end
end

function mod:CatForm(args)
	form = "cat"
	self:MessageOld(args.spellId, "red", "alert")
	specialCounter = 1
	self:Bar(98476, specialCD[specialCounter]) -- Leaping Flames
	--Don't open if already opened from seed
	--local hasDebuff, _, _, remaining = self:UnitDebuff("player", self:SpellName(98450)) -- Searing Seeds
	--if not hasDebuff or (remaining - GetTime() > 6) then
	--	self:OpenProximity(args.spellId, 10)
	--end
end

function mod:ScorpionForm(args)
	form = "scorpion"
	self:MessageOld(args.spellId, "red", "alert")
	self:PrimaryIcon(98476)
	--self:CloseProximity(98374)
	specialCounter = 1
	self:Bar(98474, specialCD[specialCounter]) -- Flame Scythe
end

function mod:FormCanceled(args)
	if args.spellId == 98379 then -- Scorpion Form
		self:StopBar(98474) -- Flame Scythe
	elseif args.spellId == 98374 then -- Cat Form
		self:StopBar(98476) -- Leaping Flames
	end
end

function mod:SearingSeedsRemoved(args)
	if self:Me(args.destGUID) then
		self:CancelSayCountdown(args.spellId)
		self:StopBar(CL.cast:format(CL.explosion))
		self:PersonalMessage(args.spellId, "removed", CL.bomb)
	end
	--if form == "cat" then
	--	self:OpenProximity(98374, 10)
	--else
	--	self:CloseProximity(args.spellId)
	--end
end

function mod:BurningOrbs(args)
	self:Bar(args.spellId, 64)
end

do
	--local function searingSeed(spellId)
		--mod:OpenProximity(spellId, 12)
	--end

	function mod:SearingSeedsApplied(args)
		if self:Me(args.destGUID) then
			self:PersonalMessage(args.spellId, "you", CL.bomb)
			local tbl = self:GetPlayerAura(args.spellId) -- Duration is different for everyone
			if tbl then
				local duration = tbl.duration
				self:SayCountdown(args.spellId, duration, nil, 5)
				self:CastBar(args.spellId, duration, CL.explosion)
			end
			self:PlaySound(args.spellId, "warning")
		end
	end
end
