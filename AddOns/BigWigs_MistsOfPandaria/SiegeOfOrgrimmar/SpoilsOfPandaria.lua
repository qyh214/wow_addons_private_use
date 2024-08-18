
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Spoils of Pandaria", 1136, 870)
if not mod then return end
mod:RegisterEnableMob(73152, 73720, 71512) -- Storeroom Guard ( trash guy ), Mogu Spoils, Mantid Spoils
mod.engageId = 1594

--------------------------------------------------------------------------------
-- Locals
--

local setToBlow = {}
local sparkCounter = 0
local bossUnitPowers = {}
local massiveCrates = 2
local stoutCrates = 6
local prevEnrage = 0

local function checkPlayerSide()
	return 1 -- XXX fixme
end

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.enable_zone = "Artifact Storage"
	L.start_trigger = "Hey, we recording?"
	L.win_trigger = "System resetting. Don't turn the power off, or the whole thing will probably explode."

	L.crates = "Crates"
	L.crates_desc = "Messages for how much power you still need and how many large/medium/small crates it will take."
	L.crates_icon = 96362

	L.full_power = "Full Power!"
	L.power_left = "%d left! (%d/%d/%d)"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{146815, "FLASH"},
		145288, {145461, "TANK"}, {142947, "TANK"}, 142694, -- Mogu crate
		{145987, "PROXIMITY", "FLASH"}, {145747, "FLASH"}, {145692, "TANK"}, {145715, "FLASH"}, {145786, "DISPEL"},-- Mantid crate
		{146217, "FLASH"}, 146222, 146257, -- Crate of Panderan Relics
		"proximity", {"crates", "TANK"}, {"warmup", "COUNTDOWN"}, "berserk",
	}, {
		[146815] = "mythic",
		[145288] = -8434, -- Mogu crate
		[145987] = -8439, -- Mantid crate
		[146217] = -8366, -- Crate of Panderan Relics
		["proximity"] = "general",
	}
end

function mod:OnRegister() -- Unit APIs don't work on chest mouseover :(
	-- Kel'Thuzad v3
	local f = CreateFrame("Frame")
	local func = function()
		if not mod:IsEnabled() and GetSubZoneText() == L.enable_zone then
			mod:Enable()
		end
	end
	f:SetScript("OnEvent", func)
	f:RegisterEvent("ZONE_CHANGED_INDOORS")
	f:RegisterEvent("ZONE_CHANGED_NEW_AREA") -- Summoned to the zone which doesn't fire ZONE_CHANGED_INDOORS
	func()
end

function mod:OnBossEnable()
	-- Crate of Panderan Relics
	self:Log("SPELL_DAMAGE", "PathOfBlossoms", 146257)
	self:Log("SPELL_CAST_START", "BreathOfFire", 146222)
	self:Log("SPELL_AURA_APPLIED", "KegToss", 146217)
	-- Mogu crate
	self:Log("SPELL_CAST_START", "CrimsonReconstitution", 142947)
	self:Log("SPELL_PERIODIC_HEAL", "CrimsonReconstitutionHeal", 145271)
	self:Log("SPELL_CAST_START", "MoguRuneOfPower", 145461)
	self:Log("SPELL_CAST_START", "MatterScramble", 145288)
	self:Log("SPELL_CAST_SUCCESS", "SparkOfLife", 142765) -- Pulse
	self:Log("SPELL_CAST_SUCCESS", "SparkOfLifeDeath", 149277) -- Nova
	-- Mantid crate
	self:Log("SPELL_AURA_APPLIED", "Residue", 145790)
	self:Log("SPELL_CAST_START", "ResidueStart", 145786)
	self:Log("SPELL_DAMAGE", "BlazingCharge", 145715)
	self:Log("SPELL_AURA_APPLIED", "BlazingCharge", 145716)
	self:Log("SPELL_AURA_APPLIED", "WarcallerEnrage", 145692)
	self:Log("SPELL_DAMAGE", "BubblingAmber", 145748)
	self:Log("SPELL_AURA_APPLIED", "BubblingAmber", 145747)
	self:Log("SPELL_AURA_APPLIED", "SetToBlowApplied", 145987)
	self:Log("SPELL_AURA_REMOVED", "SetToBlowRemoved", 145987)

	self:BossYell("Warmup", L.start_trigger)
end

function mod:Warmup()
	self:Bar("warmup", 19, COMBAT, "achievement_boss_spoils_of_pandaria")
end

function mod:OnEngage()
	sparkCounter = 0
	prevEnrage = 0
	massiveCrates = 2
	stoutCrates = 6
	setToBlow = {}
	bossUnitPowers = {}
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", nil, "boss1", "boss2")
	--self:RegisterWidgetEvent(527, "UpdateBerserkTimer") -- XXX get the correct widget
	self:OpenProximity("proximity", 3)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:UNIT_POWER_FREQUENT(_, unit, powerType)
	if powerType ~= "ALTERNATE" then return end

	local power = UnitPower(unit, 10) -- Enum.PowerType.Alternate = 10
	if power == 0 then return end -- might be needed when you change rooms

	local mobId = self:MobId(self:UnitGUID(unit))
	if bossUnitPowers[mobId] == power then return end -- don't fire twice for the same value
	local change = power - (bossUnitPowers[mobId] or 0)
	bossUnitPowers[mobId] = power

	local playerSide = checkPlayerSide()
	if ((mobId == 71512 or mobId == 73721) and playerSide > 0) or ((mobId == 73720 or mobId == 73722) and playerSide < 0) then -- mantid or mogu (side you're on)
		-- guessimate how many crates of a type you need to open
		if change > 13 then
			massiveCrates = massiveCrates - 1
		elseif change > 2 then
			stoutCrates = stoutCrates - 1
		end
		if power == 50 then
			self:MessageOld("crates", "red", "long", L.full_power, L.crates_icon)
			massiveCrates = 2
			stoutCrates = 6
		else
			local remaining = 50 - power
			local small = remaining
			small = max(0, small - (massiveCrates * 14))
			local medium = min(floor(small / 3), stoutCrates)
			small = max(0, small - (medium * 3))
			self:MessageOld("crates", "yellow", nil, L.power_left:format(remaining, massiveCrates, medium, small), L.crates_icon)
		end
	elseif self:Mythic() then
		self:MessageOld(146815, "red", "alert", CL.incoming:format(self:SpellName(-8469))) -- Unstable Spark
		if self:Damager() then
			self:Flash(146815)
		end
	end
end

-- Crate of Panderan Relics

do
	local prev = 0
	function mod:PathOfBlossoms(args)
		local t = GetTime()
		if t-prev > 2 and self:Me(args.destGUID) then -- don't spam
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
		end
	end
end

function mod:BreathOfFire(args)
	-- can be on both sides so check range on someone targeting him
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	local player = unit and unit:match("^(.-)target$") -- should always be a player or nil

	-- XXX no range checking now
	if not player then --or self:Range(player) < 30 then
		self:MessageOld(args.spellId, "yellow")
		if self:UnitDebuff("player", self:SpellName(146217)) then -- Keg Toss
			self:PlaySound(args.spellId, "long")
			self:Flash(146217) -- flash again
		end
	end
end

function mod:KegToss(args)
	if self:Me(args.destGUID) then
		self:MessageOld(args.spellId, "blue", "info")
		self:Flash(args.spellId)
	end
end

-- Mogu crate
function mod:CrimsonReconstitution(args)
	if checkPlayerSide() < 0 then
		self:MessageOld(args.spellId, "orange", "warning", CL.casting:format(args.spellName))
	end
end

do
	local prev = 0
	function mod:CrimsonReconstitutionHeal()
		local t = GetTime()
		if t-prev > 2 and checkPlayerSide() < 0 then
			prev = t
			self:MessageOld(142947, "orange", "alarm")
		end
	end
end

function mod:MoguRuneOfPower(args)
	if checkPlayerSide() < 0 then
		self:MessageOld(args.spellId, "orange", "alarm")
	end
end

function mod:MatterScramble(args)
	if checkPlayerSide() < 0 then
		self:MessageOld(args.spellId, "red", "alert", ("%s - %s"):format(args.spellName, CL.incoming:format(self:SpellName(125619))))
		self:Bar(args.spellId, 8, 125619) -- 125619 = Explosion
	end
end

function mod:SparkOfLife()
	if checkPlayerSide() < 0 then
		sparkCounter = sparkCounter + 1
		self:MessageOld(142694, "yellow", nil, CL.count:format(self:SpellName(-8380), sparkCounter))
	end
end

function mod:SparkOfLifeDeath()
	if checkPlayerSide() < 0 and sparkCounter > 0 then -- counting after side check to prevent straggling kills messing with counts on room transition
		sparkCounter = sparkCounter - 1
	end
end

-- Mantid crate
do
	local prev = 0
	function mod:Residue(args)
		local t = GetTime()
		if t-prev > 2 and checkPlayerSide() > 0 and self:Dispeller("magic", true, 145786) then
			prev = t
			self:MessageOld(145786, "orange", "alarm")
		end
	end
end

function mod:ResidueStart(args)
	if checkPlayerSide() > 0 and self:Dispeller("magic", true, args.spellId) then
		self:MessageOld(args.spellId, "yellow", nil, CL.casting:format(args.spellName))
	end
end

function mod:WarcallerEnrage(args)
	if checkPlayerSide() > 0 then
		self:TargetMessageOld(args.spellId, args.destName, "orange", "alarm")
	end
end

do
	local prev = 0
	function mod:BlazingCharge(args)
		local t = GetTime()
		if t-prev > 2 and self:Me(args.destGUID) then -- don't spam
			prev = t
			self:MessageOld(145715, "blue", "info", CL.underyou:format(args.spellName))
		end
	end
end

do
	local prev = 0
	function mod:BubblingAmber(args)
		local t = GetTime()
		if t-prev > 2 and self:Me(args.destGUID) then -- don't spam
			prev = t
			self:MessageOld(145747, "blue", "info", CL.underyou:format(args.spellName))
		end
	end
end

do
	local openForMe = nil
	local function updateProximity(spellId)
		if openForMe then return end

		if checkPlayerSide() > 0 and #setToBlow > 0 then
			mod:CloseProximity("proximity")
			mod:OpenProximity(spellId, 12, setToBlow)
		else
			mod:CloseProximity(spellId)
			mod:OpenProximity("proximity", 3)
		end
	end

	function mod:SetToBlowRemoved(args)
		if self:Me(args.destGUID) then
			self:MessageOld(args.spellId, "green", nil, CL.over:format(args.spellName))
			self:StopBar(args.spellId, args.destName)
			openForMe = nil
		else
			for i, name in ipairs(setToBlow) do
				if name == args.destName then
					tremove(setToBlow, i)
					break
				end
			end
		end
		updateProximity(args.spellId)
	end

	function mod:SetToBlowApplied(args)
		if self:Me(args.destGUID) then
			self:CloseProximity("proximity")
			self:OpenProximity(args.spellId, 12) -- 10, but be more safe
			self:MessageOld(args.spellId, "red", "warning", CL.you:format(args.spellName))
			self:TargetBar(args.spellId, 30, args.destName)
			self:Flash(args.spellId)
			openForMe = true
		else
			setToBlow[#setToBlow+1] = args.destName
			updateProximity(args.spellId)
		end
	end
end

function mod:UpdateBerserkTimer(_, text)
	-- NEW MISSION! I want you to blow up... THE OCEAN!
	-- If it wasn't clear from this code, I don't trust this API at all.
	-- Hardcoding the values and firing :Berserk on engage/room change seemed to end up with timers going out of sync.
	-- Doing this without timer refreshing every 60 seconds also ended up with sync issues.
	-- Repeatedly running through LFR to test various methods was also a delightful experience.
	-- Pretty much, I hate it. The only positive from this is that we don't need to schedule the messages.
	-- If this ever breaks in a future patch, $#!+.
	local remaining = text:match("%d+")
	if remaining then
		local timeRemaining = tonumber(remaining)
		if timeRemaining and timeRemaining > 0 then
			if timeRemaining > prevEnrage or timeRemaining % 60 == 0 then
				self:Bar("berserk", timeRemaining+1, 26662) -- +1s to compensate for timer rounding.
			end
			-- It shouldn't fire the same value twice, but throttle for safety.
			if timeRemaining ~= prevEnrage and (timeRemaining == 60 or timeRemaining == 30 or timeRemaining == 10 or timeRemaining == 5) then
				self:MessageOld("berserk", "green", nil, format(CL.custom_sec, self:SpellName(26662), timeRemaining), 26662)
			end
			prevEnrage = timeRemaining
		end
	end
end
