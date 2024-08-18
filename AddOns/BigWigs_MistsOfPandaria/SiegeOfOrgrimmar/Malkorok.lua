
--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Malkorok", 1136, 846)
if not mod then return end
mod:RegisterEnableMob(71454)
mod.engageId = 1595

--------------------------------------------------------------------------------
-- Locals
--

local smashCounter = 1
local slamCounter = 1
local breathCounter = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.custom_off_energy_marks = "Displaced Energy marker"
	L.custom_off_energy_marks_desc = "To help dispelling assignments, mark the people who have Displaced Energy on them with {rt1}{rt2}{rt3}{rt4}, requires promoted or leader.\n|cFFFF0000Only 1 person in the raid should have this enabled to prevent marking conflicts.|r"
	L.custom_off_energy_marks_icon = 1
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		142879, {142913, "FLASH", "PROXIMITY", "SAY"}, -- Rage Phase
		"custom_off_energy_marks",
		142826, {142851, "PROXIMITY"}, {142842, "FLASH"}, 142986, {142990, "TANK"}, -- Non rage phase
		"berserk",
	}, {
		[142879] = 142879,
		["custom_off_energy_marks"] = L.custom_off_energy_marks,
		[142826] = -7896, -- Non rage phase
		["berserk"] = "general",
	}
end

function mod:OnBossEnable()
	-- Rage Phase
	self:Log("SPELL_AURA_APPLIED", "DisplacedEnergyApplied", 142913)
	self:Log("SPELL_AURA_REMOVED", "DisplacedEnergyRemoved", 142913)
	self:Log("SPELL_CAST_SUCCESS", "DisplacedEnergy", 142913)
	self:Log("SPELL_CAST_START", "BloodRage", 142879)
	self:Log("SPELL_CAST_START", "ExpelMiasma", 143199) -- spell used at the end of rage phase
	-- Non rage phase
	self:Log("SPELL_AURA_APPLIED_DOSE", "FatalStrike", 142990)
	self:Log("SPELL_CAST_START", "BreathOfYShaarj", 142842)
	self:Log("SPELL_CAST_SUCCESS", "SeismicSlam", 142851)
	-- Arcing Smash has double CLEU events, pay attention if the warning stops working. 142826 first, 143805 second.
	self:Log("SPELL_CAST_SUCCESS", "ArcingSmash", 142826)
end

function mod:OnEngage()
	self:Berserk(self:LFR() and 720 or 360)
	breathCounter, smashCounter, slamCounter = 1, 1, 1
	self:Bar(142826, 12, CL.count:format(self:SpellName(142826), smashCounter)) -- Arcing Smash
	self:OpenProximity(142851, 5)
	self:Bar(142842, 67.7, CL.count:format(self:SpellName(142842), breathCounter)) -- Breath of Y'Shaarj
	-- Seismic Slam / Adds
	self:ScheduleTimer("MessageOld", 4.5, 142851, "orange", "info", CL.incoming:format(self:Mythic() and CL.adds or self:SpellName(142851)))
	self:Bar(142851, 5, self:Mythic() and CL.count:format(CL.adds, slamCounter))
end

--------------------------------------------------------------------------------
-- Event Handlers
--

-- Rage Phase

do
	function mod:DisplacedEnergyRemoved(args)
		if self:Me(args.destGUID) then
			self:CloseProximity(args.spellId)
		end
		if self.db.profile.custom_off_energy_marks then
			self:CustomIcon(false, args.destName, 0)
		end
	end

	local energyList, scheduled, counter, prev = mod:NewTargetList(), nil, 1, 0
	local function warnDisplacedEnergy(spellId)
		mod:TargetMessageOld(spellId, energyList, "orange", "alert")
		scheduled = nil
	end
	function mod:DisplacedEnergyApplied(args)
		if self:Me(args.destGUID) then
			self:Say(args.spellId, nil, nil, "Displaced Energy")
			self:Flash(args.spellId)
			self:OpenProximity(args.spellId, 8)
		end
		energyList[#energyList+1] = args.destName
		if not scheduled then
			scheduled = self:ScheduleTimer(warnDisplacedEnergy, 0.4, args.spellId)
		end
		if self.db.profile.custom_off_energy_marks then
			local t = GetTime()
			if t-prev > 2 then
				prev = t
				counter = 1
			end
			self:CustomIcon(false, args.destName, counter)
			counter = counter + 1
		end
	end
end

function mod:DisplacedEnergy(args)
	self:Bar(args.spellId, 10)
end

function mod:BloodRage(args)
	self:MessageOld(args.spellId, "cyan", "long")
	self:Bar(args.spellId, 22.5)
	self:StopBar(142851) -- Seismic Slam
	self:CloseProximity(142851)
end

function mod:ExpelMiasma() -- Blood Rage over
	self:MessageOld(142879, "cyan", "long", CL.over:format(self:SpellName(142879)))
	self:OpenProximity(142851, 5)
	self:StopBar(142913) -- Displaced Energy
	breathCounter, smashCounter, slamCounter = 1, 1, 1
	self:Bar(142826, 17, CL.count:format(self:SpellName(142826), smashCounter)) -- Arcing Smash
	self:Bar(142842, 72.2, CL.count:format(self:SpellName(142842), breathCounter)) -- Breath of Y'Shaarj
	-- Seismic Slam / Adds
	self:ScheduleTimer("MessageOld", 9, 142851, "orange", "info", CL.incoming:format(self:Mythic() and CL.adds or self:SpellName(142851)))
	self:Bar(142851, 10, self:Mythic() and CL.count:format(CL.adds, slamCounter))
end

-- Non rage phase

function mod:FatalStrike(args)
	if args.amount > 8 and args.amount % 3 == 0 then
		self:StackMessageOld(args.spellId, args.destName, args.amount, "yellow")
	end
end

function mod:BreathOfYShaarj(args)
	smashCounter, slamCounter = 1, 1

	self:Flash(args.spellId)
	self:MessageOld(args.spellId, "red", "warning", CL.count:format(args.spellName, breathCounter))
	breathCounter = breathCounter + 1

	if breathCounter == 2 then
		self:Bar(142826, 15, CL.count:format(self:SpellName(142826), smashCounter)) -- Arcing Smash
		self:Bar(args.spellId, 69.8, CL.count:format(args.spellName, breathCounter))

		-- Seismic Slam / Adds
		self:ScheduleTimer("MessageOld", 6.5, 142851, "orange", "info", CL.incoming:format(self:Mythic() and CL.adds or self:SpellName(142851)))
		self:Bar(142851, 7.5, self:Mythic() and CL.count:format(CL.adds, slamCounter))
	end
end

function mod:SeismicSlam(args)
	slamCounter = slamCounter + 1
	if slamCounter > 3 then return end
	self:ScheduleTimer("MessageOld", 18.5, args.spellId, "orange", "info", CL.incoming:format(self:Mythic() and CL.adds or args.spellName))
	self:Bar(args.spellId, 19.5, self:Mythic() and CL.count:format(CL.adds, slamCounter))
end

function mod:ArcingSmash(args)
	self:ScheduleTimer("MessageOld", 4, 142986, "orange", "alarm") -- Imploding Energy, don't wanna use SPELL_DAMAGE, and this seems accurate enough
	self:Bar(142986, 9, 67792) -- A bar with a text "Implosion" for when the damage actually happens, so people can time immunities. 67792 is just a random spell called "Implosion"

	self:MessageOld(args.spellId, "yellow", nil, CL.count:format(args.spellName, smashCounter))
	smashCounter = smashCounter + 1
	if smashCounter > 3 then return end
	self:Bar(args.spellId, 17, CL.count:format(args.spellName, smashCounter))
end

