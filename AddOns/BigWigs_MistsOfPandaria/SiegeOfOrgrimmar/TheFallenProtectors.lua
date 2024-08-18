--[[
TODO:
	improve timers by checking how they interact with different Desperate Measures -- Sun Tenderheart fixed, other two still need fixing
	fix Corrupted Brew timer (in mythic every 2 casts it gets .5s faster) Clash and Vengeful Strikes probably delay it, too
	need some data from normal for starting timers at intermission ends
]]--

--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("The Fallen Protectors", 1136, 849)
if not mod then return end
mod:RegisterEnableMob(71475, 71479, 71480) -- Rook Stonetoe, He Softfoot, Sun Tenderheart
mod.engageId = 1598

--------------------------------------------------------------------------------
-- Locals
--

local marksUsed = {}
local darkMeditationTimer
local intermission = {}

local infernoTarget, infernoTimer = nil, nil

local hcCalamityCount = 30

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.defile_you = "Defiled Ground under you"
	L.defile_you_desc = "Warning for when Defiled Ground is under you."
	L.defile_you_icon = -7958

	L.no_meditative_field = "You're not in the bubble!"

	L.intermission = -7940 -- Desperate Measures
	L.intermission_desc = "Warnings for when the bosses use Desperate Measures."

	L.inferno_self = "Inferno Strike on you"
	L.inferno_self_desc = "Special countdown when Inferno Strike is on you."
	L.inferno_self_icon = 143962
	L.inferno_self_bar = "You explode!"

	L.custom_off_bane_marks = "Shadow Word: Bane marker"
	L.custom_off_bane_marks_desc = "To help dispelling assignments, mark the initial people who have Shadow Word: Bane on them with {rt1}{rt2}{rt3}{rt4}{rt5} (in that order, not all marks may be used), requires promoted or leader."
	L.custom_off_bane_marks_icon = 1
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		{144396, "TANK"}, {143019, "FLASH", "SAY"}, 143027, {143007, "HEALER"}, {143958, "FLASH"}, {-7958, "TANK"}, {"defile_you", "FLASH"}, {-7959, "FLASH", "SAY", "PROXIMITY", "ICON"}, {"inferno_self", "SAY", "EMPHASIZE", "COUNTDOWN"}, -- Rook Stonetoe
		{143330, "TANK"}, {143292, "FLASH"}, {144367, "FLASH"}, {143840, "FLASH"}, -- He Softfoot
		{143446, "DISPEL"}, 143491, 143564, {143423, "ICON", "SAY", "FLASH"}, -- Sun Tenderheart
		"custom_off_bane_marks",
		143497, "intermission", "berserk", "proximity",
	}, {
		[144396] = -7885, -- Rook Stonetoe
		[143330] = -7889, -- He Softfoot
		[143446] = -7904, -- Sun Tenderheart
		["custom_off_bane_marks"] = L.custom_off_bane_marks,
		[143497] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", nil, "boss1", "boss2", "boss3", "boss4", "boss5")
	self:Log("SPELL_CAST_START", "Heal", 143497)
	-- Sun Tenderheart
	self:Log("SPELL_AURA_APPLIED", "SunIntermission", 143546) -- Dark Meditation
	self:Log("SPELL_AURA_REMOVED", "SunIntermissionEnd", 143546)
	self:Log("SPELL_CAST_START", "Calamity", 143491)
	self:Log("SPELL_CAST_SUCCESS", "Bane", 143446)
	self:Log("SPELL_AURA_APPLIED", "BaneApplied", 143434)
	self:Log("SPELL_AURA_REMOVED", "BaneRemoved", 143434)
	self:Log("SPELL_AURA_APPLIED", "ShaSear", 143423)
	-- He Softfoot
	self:Log("SPELL_AURA_APPLIED", "HeIntermission", 143812) -- Mark of Anguish
	self:Log("SPELL_AURA_REMOVED", "HeIntermissionEnd", 143812)
	self:RegisterEvent("RAID_BOSS_WHISPER", "GougeWhisper")
	self:Log("SPELL_CAST_START", "Gouge", 143330)
	self:Log("SPELL_AURA_APPLIED", "Fixate", 143292)
	self:Log("SPELL_DAMAGE", "NoxiousPoisonDamage", 144367)
	self:Log("SPELL_AURA_APPLIED", "MarkOfAnguish", 143840)
	self:Log("SPELL_AURA_REMOVED", "MarkOfAnguishRemoved", 143840)
	self:Log("SPELL_AURA_APPLIED_DOSE", "LingeringAnguish", 144176)
	-- Rook Stonetoe
	self:Log("SPELL_AURA_APPLIED", "RookIntermission", 143955) -- Misery, Sorrow, and Gloom
	self:Log("SPELL_AURA_REMOVED", "RookIntermissionEnd", 143955)
	self:Log("SPELL_CAST_START", "VengefulStrikes", 144396)
	self:Log("SPELL_CAST_SUCCESS", "Clash", 143027)
	self:Log("SPELL_CAST_SUCCESS", "CorruptionKick", 143007)
	self:Log("SPELL_CAST_SUCCESS", "CorruptionShock", 143958)
	self:Log("SPELL_DAMAGE", "DefiledGroundDamage", 144357)
	self:Log("SPELL_CAST_START", "InfernoStrike", 143962)
end

function mod:OnEngage()
	self:RegisterUnitEvent("UNIT_HEALTH", nil, "boss1", "boss2", "boss3")
	intermission = {}
	darkMeditationTimer = nil
	infernoTarget, infernoTimer = nil, nil
	self:OpenProximity("proximity", 5) -- this might not be needed in LFR
	self:Berserk(self:Mythic() and 600 or 900)
	self:Bar(144396, 7) -- Vengeful Strikes
	self:Bar(143019, 18) -- Corrupted Brew
	self:Bar(143027, 44) -- Clash
	self:Bar(143330, 23) -- Gouge
	if self:Dispeller("magic", nil, 143446) then
		self:Bar(143446, 14) -- Bane
	end
	self:Bar(143491, 29) -- Calamity
	hcCalamityCount = 30
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Sun Tenderheart

do
	local meditativeField = mod:SpellName(143564)
	local function warnDarkMeditation(spellId)
		if not mod:UnitDebuff("player", meditativeField, 143564) and UnitAffectingCombat("player") then
			mod:MessageOld(143564, "blue", "info", L.no_meditative_field)
		end
	end

	function mod:SunIntermissionEnd(args)
		if not self:Tank() then
			self:CancelTimer(darkMeditationTimer)
			darkMeditationTimer = nil
		end
		--if not self:Mythic() then
			--self:Bar(143027, ) -- Clash
		--end
		self:Bar(143491, 30) -- Calamity
		if self:Dispeller("magic", nil, 143446) then
			self:Bar(143446, 17) -- Bane
		end
	end

	function mod:SunIntermission(args)
		self:MessageOld("intermission", "red", "alert", args.spellName, args.spellId)
		if not self:Tank() then
			darkMeditationTimer = self:ScheduleRepeatingTimer(warnDarkMeditation, 3)
		end
		if not self:Mythic() then
			self:StopBar(143027) -- Clash
		end
		self:StopBar(143491) -- Calamity
		self:StopBar(143446) -- Bane
		hcCalamityCount = 30
	end
end

function mod:Calamity(args)
	self:Bar(args.spellId, 40)
	self:Bar(args.spellId, 5, CL.cast:format(args.spellName))
	if self:Mythic() then
		self:MessageOld(args.spellId, "yellow", nil, ("%s (%d%%)"):format(CL.casting:format(args.spellName), hcCalamityCount))
		hcCalamityCount = hcCalamityCount + 10
	else
		self:MessageOld(args.spellId, "yellow", nil, CL.casting:format(args.spellName))
	end
end

do
	function mod:BaneRemoved(args)
		if self.db.profile.custom_off_bane_marks then
			for i = 1, 5 do
				if marksUsed[i] == args.destName then
					marksUsed[i] = false
					self:CustomIcon(false, args.destName, 0)
				end
			end
		end
	end

	local function markBane(destName)
		for i = 1, 5 do
			if not marksUsed[i] then
				mod:CustomIcon(false, destName, i)
				marksUsed[i] = destName
				return
			end
		end
	end
	local prev = 0
	function mod:BaneApplied(args)
		-- XXX this whole marking probably use some code clean up
		if self.db.profile.custom_off_bane_marks then
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				marksUsed = {}
			end
			-- no _DOSE for this so gotta get stacks like this:
			local _, amount = self:UnitDebuff(args.destName, args.spellName)
			if amount and amount == 3 then -- only mark the initial cast
				markBane(args.destName)
			end
		end
	end
end

function mod:Bane(args)
	if self:Dispeller("magic", nil, args.spellId) then
		self:MessageOld(args.spellId, "orange", "alarm")
		self:Bar(args.spellId, 14)
	end
end

function mod:ShaSear(args)
	if infernoTarget then
		if self:Me(args.destGUID) then -- Only during Inferno Strike phase (when people are hugging)
			if not self:LFR() then
				self:Say(args.spellId, nil, nil, "Sha Sear")
			end
			self:Flash(args.spellId)
			self:TargetMessageOld(args.spellId, args.destName, "blue", "warning")
			self:TargetBar(args.spellId, 5, args.destName)
		end
		if not self:LFR() then
			self:SecondaryIcon(args.spellId, args.destName)
		end
	end
end

-- He Softfoot

do
	local anguishOnMe = false
	function mod:LingeringAnguish(args)
		-- inform the player with the debuff if stacks are getting high, the values might need adjusting (one warning about every 6 sec atm)
		if anguishOnMe and (args.amount > 7 and args.amount % 2 == 0) then -- Mark of Anguish
			self:StackMessageOld(143840, args.destName, args.amount, "blue", "info", 144176, 144176)
		end
	end

	function mod:MarkOfAnguish(args)
		self:TargetMessageOld(args.spellId, args.destName, "red", "alert")
		if self:Me(args.destGUID) then
			anguishOnMe = true
			self:Flash(args.spellId)
		end
	end
	function mod:MarkOfAnguishRemoved(args)
		if self:Me(args.destGUID) then
			anguishOnMe = false
		end
	end
end

do
	local prev = 0
	function mod:NoxiousPoisonDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL.underyou:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

function mod:Fixate(args)
	if not UnitIsFriend("player", args.destName) then return end
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
	end
	self:TargetMessageOld(args.spellId, args.destName, "yellow", "long")
end

do
	local prev = 0

	function mod:GougeWhisper(_, msg)
		local t = GetTime()
		if (t-prev) > 10 and msg:find("143330", nil, true) then
			prev = t
			self:MessageOld(143330, "orange", "warning")
			self:Bar(143330, 29)
		end
	end

	-- Whisper is 100% reliable, threat/target check is not, but it's faster. Just use both, whisper is our backup :)
	function mod:Gouge(args)
		if self:Tank() then
			for i = 1, 5 do
				local unit = ("boss%d"):format(i)
				if self:UnitGUID(unit) == args.sourceGUID and self:Me(self:UnitGUID(unit.."target")) then
					self:MessageOld(143330, "orange", "warning")
					self:Bar(143330, 29)
					prev = GetTime()
				end
			end
		end
	end
end

function mod:HeIntermission(args)
	self:StopBar(143330) -- Gouge
	if not self:Mythic() then
		self:StopBar(143491) -- Calamity
		self:StopBar(143027) -- Clash
	end
end

function mod:HeIntermissionEnd(args)
	--if not self:Mythic() then
		--self:Bar(143491, ) -- Calamity
		--self:Bar(143027, ) -- Clash
	--end
	self:Bar(143330, 23) -- Gouge
end

-- Rook Stonetoe

do
	local timeLeft = 8
	local prev = 0
	local function infernoCountdown(self)
		timeLeft = timeLeft - 1
		if timeLeft < 6 then
			self:Say("inferno_self", timeLeft, true)
			if timeLeft < 2 then
				self:CancelTimer(infernoTimer)
				infernoTimer = nil
			end
		end
	end
	local function startTimer(self)
		timeLeft = 8
		if infernoTimer then self:CancelTimer(infernoTimer) end
		infernoTimer = self:ScheduleRepeatingTimer(infernoCountdown, 1, self)
	end
	local function checkTarget(self, name, guid)
		local t = GetTime() - prev
		infernoTarget = name
		self:CloseProximity("proximity")
		self:PrimaryIcon(-7959, name)
		if self:Me(guid) then
			self:Flash(-7959)
			self:Say(-7959, nil, nil, "Inferno Strike")
			if not self:LFR() then -- Don't spam in LFR
				self:ScheduleTimer(startTimer, 1-t, self)
			end
			self:OpenProximity(-7959, 8, nil, true)
			-- Emphasized abilities
			self:TargetMessageOld("inferno_self", name, "orange", "warning", -7959)
			self:Bar("inferno_self", 9-t, L.inferno_self_bar, -7959)
		else
			self:TargetMessageOld(-7959, name, "orange")
			self:TargetBar(-7959, 9-t, name)
			if not self:Tank() and not self:LFR() then
				self:OpenProximity(-7959, 8, name, true)
			end
		end
	end
	function mod:InfernoStrike(args)
		prev = GetTime()
		if infernoTarget then
			self:StopBar(-7959, infernoTarget)
			self:StopBar(L.inferno_self_bar)
		end
		self:GetBossTarget(checkTarget, 0.6, args.sourceGUID)
		self:CloseProximity(-7959)
		self:PrimaryIcon(-7959)
		if infernoTimer then
			self:CancelTimer(infernoTimer)
			infernoTimer = nil
		end
	end
end

do
	local prev = 0
	function mod:DefiledGroundDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld("defile_you", "blue", "info", CL.underyou:format(args.spellName), args.spellId)
			self:Flash("defile_you", args.spellId)
		end
	end
end

do
	local prev = 0
	local function printTarget(self, name, guid)
		local t = GetTime()
		if t-prev > 5 then
			prev = t
			if self:Me(guid) then
				self:Flash(143958)
			end
			self:TargetMessageOld(143958, name, "blue", "info")
		end
	end
	local function printFallback()
		local t = GetTime()
		if t-prev > 5 then
			prev = t
			mod:MessageOld(143958, "blue", "info")
		end
	end
	function mod:CorruptionShock(args)
		self:SimpleTimer(printFallback, 0.2)
		self:GetBossTarget(printTarget, 0.3, args.sourceGUID)
	end
end

function mod:CorruptionKick(args)
	self:MessageOld(args.spellId, "red", "alarm")
end

function mod:Clash(args)
	self:MessageOld(args.spellId, "yellow")
	self:Bar(args.spellId, self:Mythic() and 50 or 46)
end

do
	local function printTarget(self, name, guid)
		if self:Me(guid) then
			self:Flash(143019)
			self:Say(143019, nil, nil, "Corrupted Brew")
		end
		self:TargetMessageOld(143019, name, "blue", "info")
	end
	function mod:UNIT_SPELLCAST_SUCCEEDED(_, unitId, _, spellId)
		if spellId == 143019 then -- Corrupted Brew
			-- timer is all over the place, need to figure out if something delays it or what
			self:Bar(spellId, 11)
			self:GetBossTarget(printTarget, 0.4, self:UnitGUID(unitId))
		elseif spellId == 143961 then
			if self:Tanking(unitId) then
				self:Bar(-7958, 10)
				self:MessageOld(-7958, "orange", "alarm")
			end
		elseif spellId == 138175 and self:MobId(self:UnitGUID(unitId)) == 71481 then -- Despawn Area Triggers
			self:CloseProximity(-7959)
			self:OpenProximity("proximity", 5)
			self:PrimaryIcon(-7959)
			self:SecondaryIcon(143423)
			if infernoTimer then
				self:CancelTimer(infernoTimer)
				infernoTimer = nil
			end
			if infernoTarget then
				self:StopBar(-7959, infernoTarget)
				self:StopBar(L.inferno_self_bar)
				infernoTarget = nil
			end
		end
	end
end

function mod:VengefulStrikes(args)
	-- only warn for the tank targeted by the mob
	local unit = self:GetUnitIdByGUID(args.sourceGUID)
	if self:Me(self:UnitGUID(unit.."target")) then -- or self:Healer()
		self:MessageOld(args.spellId, "orange", "alarm")
		self:Bar(args.spellId, 4, CL.cast:format(args.spellName))
		self:Bar(args.spellId, 22)
	end
end

function mod:RookIntermission(args)
	self:MessageOld("intermission", "red", "alert", args.spellName, false)
	self:StopBar(143027) -- Clash
	self:StopBar(144396) -- Vengeful Strikes
	self:StopBar(143019) -- Corrupted Brew
	if not self:Mythic() then
		self:StopBar(143491) -- Calamity
	end
	self:Bar(-7958, 9) -- Defiled Ground (first cast not limited to her tank, obviously)
	self:Bar(-7959, 7) -- Inferno Strike
	self:Bar(143958, 5) -- Corruption Shock
end

function mod:RookIntermissionEnd(args)
	self:StopBar(-7958) -- Defiled Ground
	self:OpenProximity("proximity", 5)
	if not self:Mythic() then
		self:Bar(143491, 5) -- Calamity
		self:Bar(143027, 57) -- Clash
	end
	self:Bar(144396, 7) -- Vengeful Strikes
	self:Bar(143019, 12) -- Corrupted Brew
end


function mod:Heal(args)
	self:Bar(args.spellId, 15, CL.cast:format(CL.other:format(self:SpellName(2060), args.sourceName))) -- "Heal"
	self:MessageOld(args.spellId, "green", "warning", CL.other:format(self:SpellName(37455), args.sourceName)) -- "Healing"
end

function mod:UNIT_HEALTH(event, unit)
	local mobId = self:MobId(self:UnitGUID(unit))
	if mobId == 71475 or mobId == 71479 or mobId == 71480 then
		local hp = self:GetHealth(unit)
		if hp < 70 and not intermission[mobId] then -- 66%
			local boss = self:UnitName(unit)
			self:MessageOld("intermission", "cyan", "info", CL.soon:format(("%s (%s)"):format(self:SpellName(L.intermission), boss)), false)
			intermission[mobId] = 1
		elseif hp < 37 and intermission[mobId] == 1 then -- 33%
			local boss = self:UnitName(unit)
			self:MessageOld("intermission", "cyan", "info", CL.soon:format(("%s (%s)"):format(self:SpellName(L.intermission), boss)), false)
			intermission[mobId] = 2
			if intermission[71475] == 2 and intermission[71479] == 2 and intermission[71480] == 2 then
				self:UnregisterUnitEvent(event, "boss1", "boss2", "boss3")
			end
		end
	end
end

