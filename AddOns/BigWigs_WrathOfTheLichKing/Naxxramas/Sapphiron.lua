--------------------------------------------------------------------------------
-- Module declaration
--

local mod, CL = BigWigs:NewBoss("Sapphiron", 533, 1614)
if not mod then return end
mod:RegisterEnableMob(15989)
mod:SetEncounterID(1119)
-- mod:SetRespawnTime(0) -- resets, doesn't respawn

--------------------------------------------------------------------------------
-- Locals
--

local breathCount = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale()
if L then
	L.airphase_trigger = "Sapphiron lifts off into the air!"
	L.deepbreath_trigger = "%s takes a deep breath."

	L.air_phase = "Air Phase"
	L.air_phase_icon = "spell_frost_arcticwinds"
	L.ground_phase = "Ground Phase"
	L.ground_phase_icon = "ability_warrior_cleave"

	L.ice_bomb = "Ice Bomb"
	L.ice_bomb_icon = "spell_frost_frostshock"
	L.ice_bomb_warning = "Ice Bomb Incoming!"
	L.ice_bomb_bar = "Ice Bomb Lands!"

	L.icebolt_say = "I'm a Block!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		28542, -- Life Drain
		28524, -- Frost Breath
		{28522, "ICON", "SAY"}, -- Ice Bolt
		{55699, "FLASH"},
		"stages",
		"berserk",
	}, nil, {
		[28524] = L.ice_bomb, -- Frost Breath (Ice Bomb)
		[28522] = self:SpellName(45438), -- Ice Bolt (Ice Block)
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_SUCCESS", "LifeDrain", 28542, 55665)
	self:Log("SPELL_CAST_SUCCESS", "IceBomb", 28524)
	self:Log("SPELL_AURA_APPLIED", "Icebolt", 28522)
	self:Log("SPELL_AURA_APPLIED", "Chill", 55699)
	self:Log("SPELL_CAST_SUCCESS", "BerserkCast", 26662)

	self:Emote("AirPhase", L.airphase_trigger)
	self:Emote("DeepBreath", L.deepbreath_trigger)
end

function mod:OnEngage()
	breathCount = 1

	-- berserk is when he lands after the 10th breath.
	-- quite a bit of variance due to walk to the center time.
	-- so just start the bar in the last air phase.
	self:Message("berserk", "yellow", CL.custom_start:format(self.displayName, self:SpellName(26662), 15), false)
	self:CDBar(28542, 12) -- Drain Life
	self:CDBar("stages", 48.8, CL.count:format(L.air_phase, breathCount), L.air_phase_icon)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:LifeDrain(args)
	self:Message(28542, "yellow")
	self:CDBar(28542, 22)
	if self:Dispeller("curse") then
		self:PlaySound(28542, "alert")
	end
end

function mod:AirPhase()
	self:StopBar(CL.count:format(L.air_phase, breathCount))
	self:StopBar(28542) -- Life Drain

	self:Message("stages", "cyan", CL.count:format(L.air_phase, breathCount), false)
	self:PlaySound("stages", "info")
	self:Bar(28524, 23.7, L.ice_bomb_bar, L.ice_bomb_icon) -- Frost Breath
	if breathCount == 10 then
		self:Message("berserk", "orange", CL.soon:format(self:SpellName(26662)), false)
		self:Bar("berserk", 32, 26662)
	end
end

function mod:DeepBreath()
	self:Message(28524, "red", L.ice_bomb_warning, L.ice_bomb_icon)
	self:PlaySound(28524, "alarm")
	self:Bar(28524, {9.7, 23.7}, L.ice_bomb_bar, L.ice_bomb_icon)

	if breathCount < 10 then
		-- Berserk bar instead of ground phase for 10
		self:DelayedMessage("stages", 17, "cyan", L.ground_phase, false, "info")
		self:CDBar("stages", 17, L.ground_phase, L.ground_phase_icon)
		self:ScheduleTimer("CDBar", 17, "stages", 60, CL.count:format(L.air_phase, breathCount + 1), L.air_phase_icon)
	end
	self:CDBar(28542, 18) -- Life Drain
end

function mod:Icebolt(args)
	self:TargetMessage(args.spellId, "yellow", args.destName)
	if self:Me(args.destGUID) then
		self:Say(args.spellId, L.icebolt_say, true)
	end
	self:PrimaryIcon(args.spellId, args.destName)
end

function mod:IceBomb(args)
	breathCount = breathCount + 1
	self:Message(28524, "red", L.ice_bomb, L.ice_bomb_icon)
	self:PlaySound(28524, "alarm")
	self:PrimaryIcon(28522)
end

do
	local prev = 0
	function mod:Chill(args)
		if self:Me(args.destGUID) then
			local t = args.time
			if t-prev > 2 then
				prev = t
				self:PersonalMessage(args.spellId)
				self:PlaySound(args.spellId, "underyou")
				self:Flash(args.spellId)
			end
		end
	end
end

function mod:BerserkCast(args)
	self:StopBar(args.spellName)
	self:StopBar(L.air_phase)
	self:Message("berserk", "red", CL.custom_end:format(self.displayName, args.spellName), args.spellId)
	self:PlaySound("berserk", "alarm")
end
