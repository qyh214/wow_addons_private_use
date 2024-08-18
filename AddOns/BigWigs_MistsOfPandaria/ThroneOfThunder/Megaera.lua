
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Megaera", 1098, 821)
if not mod then return end
mod:RegisterEnableMob(70248, 70212, 70235, 70247, 68065) -- Arcane Head, Flaming Head, Frozen Head, Venomous Head, Megaera

--------------------------------------------------------------------------------
-- Locals
--
local frostOrFireDead = nil
local breathCounter = 0
local headCounter = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.breaths = "Breaths"
	L.breaths_desc = "Warnings related to all the different types of breaths."
	L.breaths_icon = 105050

	L.arcane_adds = "Arcane adds"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		140138, 140179, {139993, "HEALER"},
		{139822, "FLASH", "ICON", "SAY"}, {137731, "HEALER"},
		{139866, "FLASH", "ICON", "SAY"}, {139909, "FLASH"}, {139843, "TANK"},
		{139840, "HEALER"},
		139458, {"breaths", "FLASH"}, "proximity",
	}, {
		[140138] = ("%s (%s)"):format(mod:SpellName(-7005), CL["heroic"]), -- Arcane Head
		[139822] = -6998, -- Fire Head
		[139866] = -7002, -- Frost Head
		[139840] = -7004, -- Poison Head
		[139458] = "general",
	}
end

function mod:OnBossEnable()
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	-- Arcane
	self:Log("SPELL_AURA_APPLIED", "Suppression", 140179)
	self:Log("SPELL_CAST_SUCCESS", "NetherTear", 140138)
	-- Frost
	self:Log("SPELL_PERIODIC_DAMAGE", "IcyGround", 139909)
	self:Log("SPELL_PERIODIC_MISSED", "IcyGround", 139909)
	self:Log("SPELL_AURA_APPLIED_DOSE", "ArcticFreeze", 139843)
	-- Fire
	self:Log("SPELL_DAMAGE", "CindersDamage", 139836)
	self:Log("SPELL_MISSED", "CindersDamage", 139836)
	self:Log("SPELL_AURA_APPLIED", "CindersApplied", 139822)
	self:Log("SPELL_AURA_REMOVED", "CindersRemoved", 139822)
	-- General
	self:Log("SPELL_DAMAGE", "BreathDamage", 137730, 139842, 139839, 139992)
	self:Log("SPELL_MISSED", "BreathDamage", 137730, 139842, 139839, 139992)
	self:Log("SPELL_CAST_START", "Breaths", 137729, 139841, 139838, 139991)
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "Rampage", "boss1")
	self:Log("SPELL_AURA_APPLIED", "TankDebuffApplied", 137731, 139840, 139993) -- Ignite Flesh, Rot Armor, Diffusion
	self:Log("SPELL_AURA_APPLIED_DOSE", "TankDebuffApplied", 137731, 139840, 139993)
	self:Log("SPELL_AURA_REMOVED", "TankDebuffRemoved", 137731, 139840, 139993)

	self:Death("Deaths", 70248, 70212, 70235, 70247) -- Arcane Head, Flaming Head, Frozen Head, Venomous Head
	self:Death("Win", 68065) -- Megaera
end

function mod:OnEngage()
	frostOrFireDead = nil
	breathCounter = 0
	headCounter = 0
	self:Bar("breaths", 5, L["breaths"], L.breaths_icon)
	self:MessageOld("breaths", "yellow", nil, CL["custom_start_s"]:format(self.displayName, L["breaths"], 5), false)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

--------------------------------------------------------------------------------
-- General
--

function mod:TankDebuffApplied(args)
	if self:Tank(args.destName) then
		self:TargetBar(args.spellId, 45, args.destName)
	end
end

function mod:TankDebuffRemoved(args)
	self:StopBar(args.spellId, args.destName)
end

do
	local prev = 0
	function mod:Breaths(args)
		local t = GetTime()
		if t-prev > 6 then
			prev = t
			breathCounter = breathCounter + 1
			self:MessageOld("breaths", "yellow", nil, CL["count"]:format(L["breaths"], breathCounter), L.breaths_icon) -- neutral breath icon
			self:Bar("breaths", 16.5, L["breaths"], L.breaths_icon)
		end
	end
end

do
	local prev = 0
	function mod:BreathDamage(args)
		if not self:Me(args.destGUID) or self:Tank() then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld("breaths", "blue", "info", CL["you"]:format(args.spellName), args.spellId)
			self:Flash("breaths", args.spellId)
		end
	end
end

do
	local function rampageOver(self, spellId, spellName)
		self:MessageOld(spellId, "green", nil, CL["over"]:format(spellName))
		if frostOrFireDead and not self:LFR() then
			self:OpenProximity("proximity", 5)
		end
		self:RegisterEvent("UNIT_AURA")
	end
	function mod:Rampage(_, _, _, spellId)
		if spellId == 139458 then
			self:UnregisterEvent("UNIT_AURA")
			self:Bar("breaths", 30, L["breaths"], L.breaths_icon)
			local spellName = self:SpellName(spellId)
			self:MessageOld(spellId, "red", "long", CL["count"]:format(spellName, headCounter))
			self:Bar(spellId, 20, CL["count"]:format(spellName, headCounter))
			self:ScheduleTimer(rampageOver, 20, self, spellId, spellName)
			breathCounter = 0
		end
	end
end

function mod:Deaths(args)
	if args.mobId == 70235 or args.mobId == 70212 then
		frostOrFireDead = true
	end

	headCounter = headCounter + 1
	self:CloseProximity("proximity")
	self:StopBar(L["breaths"])
	self:MessageOld(139458, "yellow", nil, CL["soon"]:format(CL["count"]:format(self:SpellName(139458), headCounter))) -- Rampage
	self:Bar(139458, 5, CL["incoming"]:format(self:SpellName(139458)))
end

--------------------------------------------------------------------------------
-- Arcane Head
--

function mod:Suppression(args)
	self:TargetMessageOld(args.spellId, args.destName, "orange")
end

function mod:NetherTear(args)
	self:MessageOld(args.spellId, "orange", "alarm", L["arcane_adds"])
	self:Bar(args.spellId, 6, CL["cast"]:format(L["arcane_adds"])) -- this is to help so you know when all the adds have spawned
end

--------------------------------------------------------------------------------
-- Frost Head
--

do
	local prev = 0
	function mod:IcyGround(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(args.spellId, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(args.spellId)
		end
	end
end

do
	local iceTorrent, torrentList = mod:SpellName(139857), {}
	local function torrentOver(expires)
		torrentList[expires] = nil
		if not next(torrentList) then
			mod:PrimaryIcon(139866)
		end
	end
	function mod:UNIT_AURA(_, unit)
		local _, _, _, expires = self:UnitDebuff(unit, iceTorrent, 139857)
		if expires and not torrentList[expires] then
			local duration = expires - GetTime() -- EJ says 8, spell tooltip says 11
			local player = self:UnitName(unit)
			if UnitIsUnit(unit, "player") then
				self:TargetBar(139866, duration, player)
				self:Flash(139866)
				self:Say(139866, nil, nil, "Torrent of Ice")
			end
			self:TargetMessageOld(139866, player, "orange", "info")
			self:PrimaryIcon(139866, player)
			self:ScheduleTimer(torrentOver, duration + 1, expires)
			torrentList[expires] = true
		end
	end
end

function mod:ArcticFreeze(args)
	if args.amount > 3 then
		self:StackMessageOld(args.spellId, args.destName, args.amount, "orange", "warning")
	end
end

--------------------------------------------------------------------------------
-- Fire Head
--

do
	local prev = 0
	function mod:CindersDamage(args)
		if not self:Me(args.destGUID) then return end
		local t = GetTime()
		if t-prev > 2 then
			prev = t
			self:MessageOld(139822, "blue", "info", CL["underyou"]:format(args.spellName))
			self:Flash(139822)
		end
	end
end

function mod:CindersApplied(args)
	self:SecondaryIcon(args.spellId, args.destName)
	self:TargetMessageOld(args.spellId, args.destName, "red", "alert", nil, nil, true)
	self:TargetBar(args.spellId, 30, args.destName)
	if self:Me(args.destGUID) then
		self:Flash(args.spellId)
		self:Say(args.spellId, nil, nil, "Cinders")
	end
end

function mod:CindersRemoved(args)
	self:SecondaryIcon(args.spellId)
	self:StopBar(args.spellId, args.destName)
end

