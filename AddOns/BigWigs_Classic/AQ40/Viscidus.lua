--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Viscidus", 531, 1548)
if not mod then return end
mod:RegisterEnableMob(15299)
mod:SetEncounterID(713)

--------------------------------------------------------------------------------
-- Locals
--

local swingCount = -1
local frostCount = 0

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:GetLocale()
if L then
	L.freeze = "Freezing States"
	L.freeze_desc = "Warn for the different frozen states."
	L.freeze_icon = "spell_frost_glacier"

	L.freeze_trigger1 = "%s begins to slow!"
	L.freeze_trigger2 = "%s is freezing up!"
	L.freeze_trigger3 = "%s is frozen solid!"
	L.freeze_trigger4 = "%s begins to crack!"
	L.freeze_trigger5 = "%s looks ready to shatter!"

	L.freeze_warn1 = "First freeze phase!"
	L.freeze_warn2 = "Second freeze phase!"
	L.freeze_warn3 = "Viscidus is frozen!"
	L.freeze_warn4 = "Cracking up - keep going!"
	L.freeze_warn5 = "Cracking up - almost there!"
	L.freeze_warn_melee = "%d melee attacks - %d more to go"
	L.freeze_warn_frost = "%d frost attacks - %d more to go"
end

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		"freeze",
		25991, -- Poison Bolt Volley
		25989, -- Toxin
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "PoisonBoltVolley", 25991)

	self:Log("SPELL_AURA_APPLIED", "ToxinDamage", 25989)
	self:Log("SPELL_PERIODIC_DAMAGE", "ToxinDamage", 25989)
	self:Log("SPELL_PERIODIC_MISSED", "ToxinDamage", 25989)

	self:Log("SPELL_DAMAGE", "FrostDamage", "*")
	self:Log("SPELL_PERIODIC_DAMAGE", "FrostDamage", "*")
	self:Log("SWING_DAMAGE", "SwingDamage", "*")

	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
	self:RegisterEvent("UNIT_TARGET")
end

function mod:OnEngage()
	self:CDBar(25991, 8.8) -- Poison Bolt Volley
end

function mod:OnWipe()
	frostCount = 0 -- We might pull with a frost ability, so don't reset on engage
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:PoisonBoltVolley(args)
	swingCount = -1
	self:Message(args.spellId, "yellow")
	self:CDBar(args.spellId, 10)
end

do
	local prev = 0
	function mod:ToxinDamage(args)
		if self:Me(args.destGUID) and args.time - prev > 3 then
			prev = args.time
			self:PersonalMessage(args.spellId, "underyou")
			self:PlaySound(args.spellId, "underyou")
		end
	end
end

if mod:Vanilla() then
	function mod:FrostDamage(args)
		if bit.band(args.spellSchool, 0x10) == 0x10 and self:MobId(args.destGUID) == 15299 then -- 0x10 is Frost
			frostCount = frostCount + 1
			if frostCount < 170 and frostCount % 20 == 0 then
				self:Message("freeze", "green", L.freeze_warn_frost:format(frostCount, 170-frostCount), L.freeze_icon)
			end
		end
	end

	function mod:SwingDamage(args)
		if swingCount ~= -1 and self:MobId(args.destGUID) == 15299 then
			swingCount = swingCount + 1
			if swingCount < 100 and swingCount % 20 == 0 then
				self:Message("freeze", "green", L.freeze_warn_melee:format(swingCount, 100-swingCount), L.freeze_icon)
			end
		end
	end
else
	function mod:FrostDamage(args)
		if bit.band(args.spellSchool, 0x10) == 0x10 and self:MobId(args.destGUID) == 15299 then -- 0x10 is Frost
			frostCount = frostCount + 1
			if frostCount < 20 and frostCount % 3 == 0 then
				self:Message("freeze", "green", L.freeze_warn_frost:format(frostCount, 20-frostCount), L.freeze_icon)
			end
		end
	end

	function mod:SwingDamage(args)
		if swingCount ~= -1 and self:MobId(args.destGUID) == 15299 then
			swingCount = swingCount + 1
			if swingCount < 30 and swingCount % 3 == 0 then
				self:Message("freeze", "green", L.freeze_warn_melee:format(swingCount, 30-swingCount), L.freeze_icon)
			end
		end
	end
end

function mod:CHAT_MSG_MONSTER_EMOTE(_, msg)
	-- Happy with the frost & swing warnings on vanilla so no need for the emote warnings also, retail & classic however...
	if msg:find(L.freeze_trigger1, nil, true) and not self:Vanilla() then
		self:Message("freeze", "orange", CL.count:format(L.freeze_warn1, frostCount), L.freeze_icon)
	elseif msg:find(L.freeze_trigger2, nil, true) and not self:Vanilla() then
		self:Message("freeze", "orange", CL.count:format(L.freeze_warn2, frostCount), L.freeze_icon)
	elseif msg:find(L.freeze_trigger3, nil, true) then
		swingCount = 0
		self:StopBar(25991) -- Poison Bolt Volley
		self:Message("freeze", "red", CL.count:format(L.freeze_warn3, frostCount), L.freeze_icon)
		self:Bar("freeze", 30, L.freeze_warn3, L.freeze_icon)
		frostCount = 999
	elseif msg:find(L.freeze_trigger4, nil, true) and not self:Vanilla() then
		self:Message("freeze", "orange", CL.count:format(L.freeze_warn4, swingCount), L.freeze_icon)
	elseif msg:find(L.freeze_trigger5, nil, true) and not self:Vanilla() then
		self:Message("freeze", "red", CL.count:format(L.freeze_warn5, swingCount), L.freeze_icon)
	end
end

function mod:UNIT_TARGET(_, unit)
	if self:MobId(self:UnitGUID(unit.."target")) == 15667 and swingCount ~= -1 then -- Glob of Viscidus
		frostCount = 0
		self:StopBar(L.freeze_warn3)
		self:StopBar(25991) -- Poison Bolt Volley
		self:Message("freeze", "green", tostring(swingCount), false)
		swingCount = -1
	end
end
