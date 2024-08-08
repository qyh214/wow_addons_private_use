--------------------------------------------------------------------------------
-- Module Declaration
--

local mod, CL = BigWigs:NewBoss("Ultraxion", 967, 331)
if not mod then return end
mod:RegisterEnableMob(55294, 56667) -- Ultraxion, Thrall

--------------------------------------------------------------------------------
-- Locales
--

local hourCounter = 1

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Now is the hour of twilight!"

	L.warmup = "Warmup"
	L.warmup_desc = "Time until combat with the boss starts."
	L.warmup_icon = "achievment_boss_ultraxion"
	L.warmup_trigger = "I am the beginning of the end...the shadow which blots out the sun"

	L.crystal = "Buff Crystals"
	L.crystal_desc = "Timers for the various buff crystals the NPCs summon."
	L.crystal_icon = "inv_misc_head_dragon_01"
	L.crystal_red = "Red Crystal"
	L.crystal_green = "Green Crystal"
	L.crystal_green_icon = "inv_misc_head_dragon_green"
	L.crystal_blue = "Blue Crystal"
	L.crystal_blue_icon = "inv_misc_head_dragon_blue"
	L.crystal_bronze_icon = "inv_misc_head_dragon_bronze"

	L.twilight = "Twilight"
	L.cast = "Twilight Cast Bar"
	L.cast_desc = "Show a 5 (Normal) or 3 (Heroic) second bar for Twilight being cast."
	L.cast_icon = 106371

	L.lightself = "Fading Light on You"
	L.lightself_desc = "Show a bar displaying the time left until Fading Light causes you to explode."
	L.lightself_bar = "<You Explode>"
	L.lightself_icon = 105925

	L.lighttank = "Fading Light on Tanks"
	L.lighttank_desc = "If a tank has Fading Light, show an explode bar and Flash/Shake."
	L.lighttank_bar = "<%s Explodes>"
	L.lighttank_message = "Exploding Tank"
	L.lighttank_icon = 105925
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions(CL)
	return {
		{106371, "FLASH"}, "cast",
		105925, {"lightself", "FLASH"}, {"lighttank", "FLASH", "TANK"},
		"warmup", "crystal", "berserk"
	}, {
		[106371] = L["twilight"],
		[105925] = mod:SpellName(105925),
		warmup = CL["general"],
	}
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "HourofTwilight", 106371)
	self:Log("SPELL_AURA_APPLIED", "FadingLight", 109075, 105925) -- Normal/Tank

	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", "CheckBossStatus")

	self:BossYell("Warmup", L["warmup_trigger"])
	self:Emote("Gift", L["crystal_icon"])
	self:Emote("Dreams", L["crystal_green_icon"])
	self:Emote("Magic", L["crystal_blue_icon"])
	self:Emote("Loop", L["crystal_bronze_icon"])

	self:Death("Win", 55294)
end

function mod:Warmup()
	self:Bar("warmup", 30, self.displayName, "achievment_boss_ultraxion")
end

function mod:OnEngage()
	self:Berserk(360)
	self:Bar(106371, 45) -- Hour of Twilight
	self:Bar("crystal", 80, L["crystal_red"], L["crystal_icon"])
	hourCounter = 1
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Gift()
	self:Bar("crystal", 75, L["crystal_green"], L["crystal_green_icon"])
	self:MessageOld("crystal", "green", "info", L["crystal_red"], L["crystal_icon"])
end

function mod:Dreams()
	self:Bar("crystal", 60, L["crystal_blue"], L["crystal_blue_icon"])
	self:MessageOld("crystal", "green", "info", L["crystal_green"], L["crystal_green_icon"])
end

function mod:Magic()
	self:Bar("crystal", 75, 105984, L["crystal_bronze_icon"]) -- Timeloop
	self:MessageOld("crystal", "green", "info", L["crystal_blue"], L["crystal_blue_icon"])
end

function mod:Loop()
	self:MessageOld("crystal", "green", "info", 105984, L["crystal_bronze_icon"]) -- Timeloop
end

function mod:HourofTwilight(args)
	self:MessageOld(106371, "red", "alert", ("%s (%d)"):format(args.spellName, hourCounter), args.spellId)
	hourCounter = hourCounter + 1
	self:Bar(106371, 45, ("%s (%d)"):format(args.spellName, hourCounter), args.spellId)
	self:Bar("cast", self:Heroic() and 3 or 5, CL["cast"]:format(L["twilight"]), args.spellId)
	self:Flash(106371)
end

do
	local scheduled = nil
	local lightTargets = mod:NewTargetList()
	local function fadingLight()
		mod:TargetMessageOld(105925, lightTargets, "yellow", "alarm")
		scheduled = nil
	end
	function mod:FadingLight(args)
		lightTargets[#lightTargets + 1] = args.destName
		if self:Me(args.destGUID) then
			local _, _, duration = self:UnitDebuff("player", args.spellName)
			self:Bar("lightself", duration, L["lightself_bar"], args.spellId)
			self:Flash("lightself", args.spellId)
		else -- This is mainly a tanking assist
			if args.spellId == 105925 then
				self:Flash("lighttank", args.spellId)
				local _, _, duration = self:UnitDebuff(args.destName, args.spellName)
				self:Bar("lighttank", duration, L["lighttank_bar"]:format(args.destName), args.spellId)
				self:TargetMessageOld("lighttank", args.destName, "yellow", "alarm", L["lighttank_message"], args.spellId, true)
			end
		end
		if not scheduled then
			scheduled = self:ScheduleTimer(fadingLight, 0.2)
		end
	end
end

