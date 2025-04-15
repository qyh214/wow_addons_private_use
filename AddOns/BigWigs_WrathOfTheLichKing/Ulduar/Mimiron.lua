--------------------------------------------------------------------------------
-- Module Declaration
--

local mod = BigWigs:NewBoss("Mimiron", 603, 1647)
if not mod then return end
mod:RegisterEnableMob(
	33350, -- Mimiron
	33432, -- Leviathan Mk II
	33651, -- VX-001
	33670  -- Aerial Command Unit
)
mod:SetEncounterID(BigWigsLoader.isWrath and 754 or 1138)
mod:SetRespawnTime(31)
mod:SetStage(1)

--------------------------------------------------------------------------------
-- Locals
--

local ishardmode = false

--------------------------------------------------------------------------------
-- Localization
--

local L = mod:NewLocale("enUS", true)
if L then
	L.phase = "Phases"
	L.phase_desc = "Warn for phase changes."
	L.engage_warning = "Phase 1"
	L.engage_trigger = "^We haven't much time, friends!"
	L.phase2_warning = "Phase 2 incoming"
	L.phase2_trigger = "^WONDERFUL! Positively marvelous results!"
	L.phase3_warning = "Phase 3 incoming"
	L.phase3_trigger = "^Thank you, friends!"
	L.phase4_warning = "Phase 4 incoming"
	L.phase4_trigger = "^Preliminary testing phase complete"
	L.phase_bar = "Phase %d"

	L.hardmode_trigger = "^Now, why would you go and do something like that?"

	L.plasma_warning = "Casting Plasma Blast!"
	L.plasma_soon = "Plasma soon!"
	L.plasma_bar = "Plasma"

	L.shock_next = "Next Shock Blast"

	L.laser_soon = "Spinning up!"
	L.laser_bar = "Barrage"

	L.magnetic_message = "ACU Rooted!"

	L.suppressant_warning = "Suppressant incoming!"

	L.fbomb_bar = "Next Frost Bomb"

	L.bomb_message = "Bomb Bot spawned!"
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:GetOptions()
	return {
		64529, -- Plasma Blast
		63631, -- Shock Blast
		{63274, "FLASH"}, -- P3Wx2 Laser Barrage
		64444, -- Magnetic Core
		63811, -- Bomb Bot
		64623, -- Frost Bomb
		64570, -- Flame Suppressant
		"phase",
		"proximity",
		"berserk" ,
	}, {
		[64529] = "normal",
		[64623] = "hard", -- Hard Mode
		phase = "general",
	}
end

function mod:VerifyEnable(unit)
	return (UnitIsEnemy(unit, "player") and self:GetHealth(unit) > 1) and true or false
end

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "PlasmaBlast", 64529)
	self:Log("SPELL_CAST_START", "FlameSuppressant", 64570)
	self:Log("SPELL_CAST_START", "FrostBomb", 64623)
	self:Log("SPELL_CAST_START", "ShockBlast", 63631)
	self:Log("SPELL_CAST_SUCCESS", "SpinningUp", 63414)
	self:Log("SPELL_SUMMON", "MagneticCore", 64444)
	self:Log("SPELL_SUMMON", "BombBot", 63811)
	self:RegisterEvent("CHAT_MSG_LOOT")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL")
end

function mod:OnEngage()
	self:SetStage(1)
	self:MessageOld("phase", "yellow", nil, L["engage_warning"], false)
	self:Bar("phase", 7, L["phase_bar"]:format(1), "INV_Gizmo_01")

	self:Bar(63631, 30, L["shock_next"])
	self:Bar(64529, 20, L["plasma_bar"])
	self:DelayedMessage(64529, 17, "yellow", L["plasma_soon"])
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:BombBot(args)
	self:MessageOld(args.spellId, "red", "alert", L["bomb_message"])
end

function mod:FlameSuppressant(args)
	self:MessageOld(args.spellId, "red", nil, L["suppressant_warning"])
	self:Bar(args.spellId, 3)
end

function mod:FrostBomb(args)
	self:MessageOld(args.spellId, "red")
	self:Bar(args.spellId, 2)
	self:Bar(args.spellId, 30, L["fbomb_bar"])
end

function mod:PlasmaBlast(args)
	self:MessageOld(args.spellId, "red", nil, L["plasma_warning"])
	self:Bar(args.spellId, 3, L["plasma_warning"])
	self:Bar(args.spellId, 30, L["plasma_bar"])
end

function mod:ShockBlast(args)
	self:MessageOld(args.spellId, "red")
	self:Bar(args.spellId, 3.5)
	self:Bar(args.spellId, 34, L["shock_next"])
end

function mod:SpinningUp(args)
	self:MessageOld(63274, "blue", "long", L["laser_soon"], args.spellId)
	self:Flash(63274)
	self:ScheduleTimer("MessageOld", 4, 63274, "red", nil, L["laser_bar"])
	self:ScheduleTimer("Bar", 4, 63274, 60, L["laser_bar"])
end

function mod:MagneticCore(args)
	self:MessageOld(args.spellId, "red", nil, L["magnetic_message"])
	self:Bar(args.spellId, 15)
end

function mod:CHAT_MSG_MONSTER_YELL(_, msg)
	if msg:find(L["hardmode_trigger"]) then
		ishardmode = true
		self:Berserk(612, true)
		self:OpenProximity("proximity", 5)
	elseif msg:find(L["engage_trigger"]) then
		ishardmode = false
		self:Berserk(900, true)
	elseif msg:find(L["phase2_trigger"]) then
		self:SetStage(2)
		self:StopBar(L["plasma_bar"])
		self:StopBar(L["shock_next"])
		self:MessageOld("phase", "yellow", nil, L["phase2_warning"], false)
		self:Bar("phase", 40, L["phase_bar"]:format(2), "INV_Gizmo_01")
		if ishardmode then
			self:Bar(64623, 45, L["fbomb_bar"])
		end
		self:CloseProximity()
	elseif msg:find(L["phase3_trigger"]) then
		self:SetStage(3)
		self:MessageOld("phase", "yellow", nil, L["phase3_warning"], false)
		self:Bar("phase", 25, L["phase_bar"]:format(3), "INV_Gizmo_01")
	elseif msg:find(L["phase4_trigger"]) then
		self:SetStage(4)
		self:MessageOld("phase", "yellow", nil, L["phase4_warning"], false)
		self:Bar("phase", 25, L["phase_bar"]:format(4), "INV_Gizmo_01")
		if ishardmode then
			self:Bar(64623, 30, L["fbomb_bar"])
		end
		self:Bar(63631, 48, L["shock_next"])
	end
end

do
	-- WoW 7.0
	--CHAT_MSG_LOOT:Varian receives loot: |cffffffff|Hitem:46029::::::::110:253::::::|h[Magnetic Core]|h|r.::::Varian::0:0::0:247:nil:0:false:false:false:false:
	function mod:CHAT_MSG_LOOT(event, msg, _, _, _, playerName)
		if msg:find("Hitem:46029", nil, true) then
			self:TargetMessageOld(64444, playerName, "green", "info")
		end
	end
end
